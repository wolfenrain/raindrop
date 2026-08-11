import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:raindrop_cli/src/core/config.dart';
import 'package:raindrop_cli/src/core/journal.dart';

/// Writes the Dart file that embeds every migration in [journal], in order.
Future<void> emitDartMigrations(
  RaindropConfig config,
  MigrationJournal journal,
  String outputPath,
) async {
  final buffer = StringBuffer()
    ..writeln("import 'package:raindrop/raindrop.dart';")
    ..writeln()
    ..writeln('/// Generated migrations. Do not edit by hand.')
    ..writeln('final migrations = [');

  for (final entry in journal.entries) {
    final sql =
        await File(p.join(config.outPath, '${entry.tag}.sql')).readAsString();
    final escapedSql = sql.replaceAll("'''", r"\'''");
    buffer
      ..writeln("  const Migration('${entry.tag}', '''")
      ..write(escapedSql)
      ..writeln("'''),");
  }

  buffer.writeln('];');

  final dartFile = File(outputPath);
  final dartDir = Directory(dartFile.parent.path);
  if (!dartDir.existsSync()) {
    dartDir.createSync(recursive: true);
  }
  await dartFile.writeAsString(buffer.toString());
}

/// Normalises a migration name into the tag's trailing segment.
String sanitizeMigrationName(String name) {
  return name
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9_]'), '_')
      .replaceAll(RegExp('_+'), '_');
}

/// Walks up from [startDir] to the nearest directory holding a pubspec.yaml,
/// falling back to [startDir] at the filesystem root.
String findProjectRoot(String startDir) {
  var current = startDir;
  while (true) {
    if (File(p.join(current, 'pubspec.yaml')).existsSync()) return current;
    final parent = p.dirname(current);
    if (parent == current) return startDir;
    current = parent;
  }
}
