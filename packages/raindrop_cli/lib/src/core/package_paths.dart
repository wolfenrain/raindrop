import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:raindrop_cli/src/ddl/ddl_subprocess_host_source.dart';

/// Resolves Raindrop package files on disk for `dart` subprocess helpers.
class RaindropPackagePaths {
  RaindropPackagePaths._();

  /// Resolves [packageName] to an on-disk file under that package.
  ///
  /// When [raindrop_cli] is not in the user's `package_config.json` (typical
  /// for compiled zonai), materializes known helper scripts under
  /// `.dart_tool/raindrop/` in the project.
  static Future<File?> packageFile({
    required String packageName,
    required String relativePath,
    String? projectPath,
  }) async {
    final fromConfig = _packageFileFromConfig(
      packageName: packageName,
      relativePath: relativePath,
      projectPath: projectPath,
    );
    if (fromConfig != null) {
      return fromConfig;
    }

    if (packageName == 'raindrop_cli' &&
        relativePath == 'lib/src/ddl/ddl_subprocess_host.dart') {
      return _materializeSubprocessHost(projectPath);
    }

    return null;
  }

  static File _materializeSubprocessHost(String? projectPath) {
    final root = p.normalize(
      p.absolute(projectPath ?? Directory.current.path),
    );
    final dir = Directory(p.join(root, '.dart_tool', 'raindrop'));
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final file = File(p.join(dir.path, 'ddl_subprocess_host.dart'));
    if (!file.existsSync()) {
      file.writeAsStringSync(ddlSubprocessHostSource);
    }

    return file;
  }

  static File? _packageFileFromConfig({
    required String packageName,
    required String relativePath,
    required String? projectPath,
  }) {
    final configFile = _findPackageConfig(projectPath);
    if (configFile == null) {
      return null;
    }

    final configContent = configFile.readAsStringSync();
    final config = jsonDecode(configContent) as Map<String, dynamic>;
    final packages = config['packages'] as List<dynamic>;

    for (final pkg in packages) {
      final pkgMap = pkg as Map<String, dynamic>;
      if (pkgMap['name'] != packageName) {
        continue;
      }

      final rootUri = pkgMap['rootUri'] as String;
      final configDir = p.dirname(configFile.path);
      final packageRoot = rootUri.startsWith('file://')
          ? Uri.parse(rootUri).toFilePath()
          : p.normalize(p.join(configDir, rootUri));
      final file = File(p.join(packageRoot, relativePath));
      if (file.existsSync()) {
        return file;
      }
    }

    return null;
  }

  static File? _findPackageConfig(String? projectPath) {
    var current = Directory(projectPath ?? Directory.current.path).absolute;

    while (true) {
      final configFile = File(
        p.join(current.path, '.dart_tool', 'package_config.json'),
      );
      if (configFile.existsSync()) {
        return configFile;
      }

      final parent = current.parent;
      if (parent.path == current.path) {
        break;
      }
      current = parent;
    }

    return null;
  }
}
