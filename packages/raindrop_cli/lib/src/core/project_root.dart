import 'dart:io';

import 'package:path/path.dart' as p;

/// The directory containing the nearest `pubspec.yaml` at or above [path].
///
/// [path] may be a file or directory. Used to find the Dart package that owns
/// schema files (for `package:` imports and `package_config.json` when
/// running generated introspection scripts).
String findPubspecRootContaining(String path) {
  var dir = p.normalize(p.absolute(path));
  if (FileSystemEntity.isFileSync(dir)) {
    dir = p.dirname(dir);
  }
  if (!FileSystemEntity.isDirectorySync(dir)) {
    throw StateError('Not a file or directory: $path');
  }
  while (true) {
    if (File(p.join(dir, 'pubspec.yaml')).existsSync()) {
      return dir;
    }
    final parent = p.dirname(dir);
    if (parent == dir) {
      throw StateError(
        'No pubspec.yaml found above schema path: ${p.normalize(path)}',
      );
    }
    dir = parent;
  }
}

/// Walks up from [startDir] until `pubspec.yaml` is found (for the CLI/tool package).
String findProjectRoot(String startDir) {
  var current = p.normalize(p.absolute(startDir));
  while (true) {
    if (File(p.join(current, 'pubspec.yaml')).existsSync()) {
      return current;
    }
    final parent = p.dirname(current);
    if (parent == current) {
      throw StateError(
        'No pubspec.yaml found above config path: ${p.normalize(startDir)}',
      );
    }
    current = parent;
  }
}
