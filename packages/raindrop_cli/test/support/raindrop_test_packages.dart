import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

/// Package roots for raindrop_cli integration tests.
class RaindropTestPackages {
  RaindropTestPackages._({
    required this.raindropCli,
    required this.raindrop,
    required this.raindropSqlite,
  });

  final String raindropCli;
  final String raindrop;
  final String raindropSqlite;

  static RaindropTestPackages load() {
    final configPath = Platform.packageConfig;
    if (configPath == null) {
      throw StateError('Platform.packageConfig is null');
    }

    final configFile = File(
      configPath.startsWith('file://')
          ? Uri.parse(configPath).toFilePath()
          : configPath,
    );
    final configDir = p.dirname(p.normalize(configFile.absolute.path));
    final config =
        jsonDecode(configFile.readAsStringSync()) as Map<String, dynamic>;

    String rootFor(String packageName) {
      for (final raw in config['packages'] as List<dynamic>) {
        final pkg = raw as Map<String, dynamic>;
        if (pkg['name'] != packageName) {
          continue;
        }

        final rootUri = pkg['rootUri'] as String;
        if (rootUri.startsWith('file://')) {
          return p.normalize(Uri.parse(rootUri).toFilePath());
        }
        return p.normalize(p.join(configDir, rootUri));
      }

      throw StateError('Package "$packageName" not found in ${configFile.path}');
    }

    final raindropCli = rootFor('raindrop_cli');
    final raindrop = rootFor('raindrop');

    return RaindropTestPackages._(
      raindropCli: raindropCli,
      raindrop: raindrop,
      raindropSqlite: p.normalize(p.join(raindropCli, '..', 'raindrop_sqlite')),
    );
  }
}
