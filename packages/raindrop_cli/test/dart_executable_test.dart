import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:raindrop_cli/src/core/dart_executable.dart';
import 'package:test/test.dart';

void main() {
  group('DartExecutable', () {
    tearDown(() {
      DartExecutable.configuredPath = null;
    });

    test('resolveSync expands configured SDK root', () {
      final sdkRoot = Directory.systemTemp.createTempSync('dart_sdk_test_');
      addTearDown(() => sdkRoot.deleteSync(recursive: true));
      final binDir = Directory(p.join(sdkRoot.path, 'bin'))..createSync();
      final dart = File(p.join(binDir.path, Platform.isWindows ? 'dart.exe' : 'dart'))
        ..writeAsStringSync('');

      DartExecutable.configuredPath = sdkRoot.path;

      expect(DartExecutable.resolveSync(), dart.path);
    });

    test('installCandidates includes FVM dart under project root', () {
      final projectRoot = Directory.systemTemp.createTempSync('fvm_proj_');
      addTearDown(() => projectRoot.deleteSync(recursive: true));
      final dart = p.join(
        projectRoot.path,
        '.fvm',
        'flutter_sdk',
        'bin',
        Platform.isWindows ? 'dart.exe' : 'dart',
      );

      expect(
        DartExecutable.installCandidates(projectRoot: projectRoot.path),
        contains(dart),
      );
    });

    test('installCandidates walks up to find FVM dart in parent directory', () {
      final projectRoot = Directory.systemTemp.createTempSync('fvm_walk_');
      addTearDown(() => projectRoot.deleteSync(recursive: true));
      final nested = p.join(projectRoot.path, 'apps', 'playground');
      Directory(nested).createSync(recursive: true);
      final dart = p.join(
        projectRoot.path,
        '.fvm',
        'flutter_sdk',
        'bin',
        Platform.isWindows ? 'dart.exe' : 'dart',
      );

      expect(
        DartExecutable.installCandidates(projectRoot: nested),
        contains(dart),
      );
    });

    test('resolve uses configured SDK root when dart responds', () async {
      final realDart = Platform.resolvedExecutable;
      if (!p.basename(realDart).toLowerCase().startsWith('dart')) {
        return;
      }

      final sdkRoot = p.normalize(p.join(p.dirname(realDart), '..'));
      DartExecutable.configuredPath = sdkRoot;

      expect(await DartExecutable.resolve(), realDart);
    });

    test('resolve uses configured dart binary path', () async {
      final realDart = Platform.resolvedExecutable;
      if (!p.basename(realDart).toLowerCase().startsWith('dart')) {
        return;
      }

      DartExecutable.configuredPath = realDart;

      expect(await DartExecutable.resolve(), realDart);
    });

    test('resolve falls back to runnable dart on PATH', () async {
      DartExecutable.configuredPath = null;

      expect(await DartExecutable.resolve(), isNotEmpty);
    });
  });
}
