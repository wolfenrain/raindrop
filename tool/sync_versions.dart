import 'dart:io';

import 'package:path/path.dart' as p;

void main() {
  final packages = Directory('packages')
      .listSync()
      .whereType<Directory>()
      .where(
        (package) => File(
          p.join(package.path, 'lib', 'src', 'version.dart'),
        ).existsSync(),
      );

  for (final package in packages) {
    final pubspec = File(
      p.join(package.path, 'pubspec.yaml'),
    ).readAsStringSync();
    final name = RegExp(
      r'^name: (.+)$',
      multiLine: true,
    ).firstMatch(pubspec)![1]!;
    final version = RegExp(
      r'^version: (.+)$',
      multiLine: true,
    ).firstMatch(pubspec)![1]!;

    File(p.join(package.path, 'lib', 'src', 'version.dart')).writeAsStringSync(
      '''
// coverage:ignore-file

/// The current version of the `$name` package.
const packageVersion = '$version';
''',
    );
    stdout.writeln('$name: packageVersion = $version');
  }
}
