import 'dart:io';
import 'dart:isolate';

import 'package:meta/meta.dart';
import 'package:raindrop/ddl.dart';
import 'package:raindrop/raindrop.dart';
import 'package:raindrop_test/src/conformance/fixture_operations.dart';
import 'package:test/test.dart';

/// Verifies the CLI-facing contract of the driver package [packageName].
///
/// Where `[estDriverConformance` proves runtime behavior against a real
/// database, this suite proves the package *layout* the CLI relies on:
///
/// * the driver's table function tags tables with its dialect's `name`,
///   which is what snapshot building filters on.
/// * `lib/ddl.dart` exists and its `main` serves the DDL generator over the
///   isolate protocol, answering a real `generate` request exactly like the
///   in-process generator.
///
/// ```dart
/// testDriverContract(
///   packageName: 'raindrop_sqlite',
///   createDdlGenerator: SQLiteHarness().createDdlGenerator,
///   probe: sqliteTable('probe', UserSchema.new),
/// );
/// ```
@isTestGroup
void testDriverContract({
  required String packageName,
  required DdlGenerator Function() createDdlGenerator,
  required Schema<dynamic> probe,
}) {
  group('driver contract', () {
    test('the table function tags tables with the dialect name', () {
      expect(probe.$.dialect?.name, createDdlGenerator().dialect.name);
    });

    test('lib/ddl.dart serves the DDL generator over the isolate protocol',
        () async {
      final entrypoint = await Isolate.resolvePackageUri(
        Uri.parse('package:$packageName/ddl.dart'),
      );
      expect(
        entrypoint,
        isNotNull,
        reason: 'package:$packageName/ddl.dart must exist: it is the '
            'entrypoint the CLI spawns for DDL generation.',
      );

      final generator = createDdlGenerator();
      final operations = fixtureCreateTableOperations(generator.dialect);

      final handshake = ReceivePort();
      final errors = ReceivePort();
      final isolate = await Isolate.spawnUri(
        entrypoint!,
        [],
        handshake.sendPort,
        onError: errors.sendPort,
        packageConfig: await _packageConfig(),
      );

      try {
        final failure = errors.first.then(
          // coverage:ignore-start fires only when the entrypoint fails to load.
          (error) => throw StateError('The DDL entrypoint failed:\n$error'),
          // coverage:ignore-end
        );
        final commands =
            await Future.any([handshake.first, failure]) as SendPort;

        final replies = ReceivePort();
        commands.send({
          'action': 'generate',
          'operations': [for (final op in operations) op.toMap()],
          'replyPort': replies.sendPort,
        });
        final reply = ((await Future.any([replies.first, failure]))! as Map)
            .cast<String, Object?>();
        replies.close();

        expect(reply['success'], isTrue, reason: '${reply['error']}');
        expect(reply['sql'], generator.generate(operations));
      } finally {
        handshake.close();
        errors.close();
        isolate.kill(priority: Isolate.immediate);
      }
    });
  });
}

/// The package config of the running test, for [Isolate.spawnUri].
///
/// Falls back to walking up from the working directory, which handles
/// workspaces where package_config.json lives at the repository root.
Future<Uri?> _packageConfig() async {
  final fromIsolate = await Isolate.packageConfig;
  if (fromIsolate != null) return fromIsolate;

  // Under `dart test` Isolate.packageConfig is always set, so the walk only
  // runs in hosts that hide it.
  // coverage:ignore-start
  var current = Directory.current.absolute;
  while (true) {
    final candidate = File('${current.path}/.dart_tool/package_config.json');
    if (candidate.existsSync()) return candidate.uri;
    if (current.parent.path == current.path) return null;
    current = current.parent;
  }
  // coverage:ignore-end
}
