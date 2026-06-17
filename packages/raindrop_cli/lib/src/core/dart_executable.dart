import 'dart:io';

import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

/// Resolves the `dart` executable for subprocess use.
///
/// When the host process is a compiled AOT binary (not the Dart VM), callers
/// must spawn a `dart` subprocess instead of using [Isolate.spawnUri].
class DartExecutable {
  /// Optional SDK root or path to the `dart` binary (e.g. from app settings).
  static String? configuredPath;

  /// Returns a runnable `dart` executable path.
  ///
  /// Resolution order:
  /// 1. [configuredPath] (SDK root or `bin/dart` path)
  /// 2. `DART_SDK` environment variable
  /// 3. `DART_HOME` environment variable
  /// 4. FVM / Flutter install paths (see [_commonInstallCandidates])
  /// 5. [Platform.resolvedExecutable] when it is `dart`
  /// 6. `dart` on `PATH` (verified with `--version`)
  static Future<String> resolve({String? projectRoot}) async {
    for (final candidate in _candidates(projectRoot: projectRoot)) {
      if (await _isRunnable(candidate)) {
        return candidate;
      }
    }

    throw StateError(
      'Could not find a Dart SDK. Install Dart, add it to PATH, or set '
      'dartSdkPath in zonai.yaml (or DART_SDK / DART_HOME).',
    );
  }

  /// Synchronous best-effort resolution (no PATH verification).
  ///
  /// Prefer [resolve] when spawning subprocesses; this matches the legacy
  /// raindrop behavior for callers that only need a candidate path.
  static String resolveSync({String? projectRoot}) {
    for (final candidate in _candidates(projectRoot: projectRoot)) {
      if (_exists(candidate)) {
        return candidate;
      }
    }

    return _dartBinName;
  }

  /// Exposed for tests verifying FVM / Flutter install discovery.
  @visibleForTesting
  static Iterable<String> installCandidates({String? projectRoot}) =>
      _commonInstallCandidates(projectRoot);

  static String get _dartBinName =>
      Platform.isWindows ? 'dart.exe' : 'dart';

  static Iterable<String> _candidates({String? projectRoot}) sync* {
    yield* _expandConfigured(configuredPath);
    yield* _expandConfigured(Platform.environment['DART_SDK']);
    yield* _expandConfigured(Platform.environment['DART_HOME']);
    yield* _commonInstallCandidates(projectRoot);

    final resolved = Platform.resolvedExecutable;
    final name = p.basename(resolved).toLowerCase();
    if (name == 'dart' || name == 'dart.exe') {
      yield resolved;
    }

    yield _dartBinName;
  }

  static Iterable<String> _commonInstallCandidates(String? projectRoot) sync* {
    yield* _fvmCandidates(projectRoot);

    final home =
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (home != null) {
      yield p.join(home, 'fvm', 'default', 'bin', _dartBinName);
      yield p.join(home, '.fvm', 'default', 'bin', _dartBinName);
      yield p.join(home, 'flutter', 'bin', _dartBinName);
    }

    if (!Platform.isWindows) {
      yield '/opt/homebrew/bin/dart';
      yield '/usr/local/bin/dart';
    }
  }

  /// Walks up from [projectRoot] for `.fvm/flutter_sdk/bin/dart`.
  static Iterable<String> _fvmCandidates(String? projectRoot) sync* {
    if (projectRoot == null) return;

    var dir = p.normalize(p.absolute(projectRoot));
    while (true) {
      yield p.join(dir, '.fvm', 'flutter_sdk', 'bin', _dartBinName);
      final parent = p.dirname(dir);
      if (parent == dir) {
        break;
      }
      dir = parent;
    }
  }

  static Iterable<String> _expandConfigured(String? raw) sync* {
    if (raw == null) return;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return;

    final path = p.normalize(p.absolute(trimmed));
    final base = p.basename(path).toLowerCase();
    if (base == 'dart' || base == 'dart.exe') {
      yield path;
      return;
    }

    yield p.join(path, 'bin', _dartBinName);
  }

  static bool _exists(String executable) {
    if (executable.contains(p.separator)) {
      return File(executable).existsSync();
    }
    return true;
  }

  static Future<bool> _isRunnable(String executable) async {
    if (executable.contains(p.separator) && !File(executable).existsSync()) {
      return false;
    }

    try {
      final result = await Process.run(
        executable,
        const ['--version'],
        runInShell: Platform.isWindows && !executable.contains(p.separator),
      );
      return result.exitCode == 0;
    } on ProcessException {
      return false;
    }
  }
}
