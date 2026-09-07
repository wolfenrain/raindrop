import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

/// Scores workspace packages with pana as pub.dev would score them.
///
/// pana scores a copy of the package that resolves its dependencies from a
/// pub host, never from the workspace. So a driver that changes together with
/// raindrop would therefore score against the published raindrop and fail on
/// APIs that are not released yet.
///
/// This tool serves the workspace itself as that host: every publishable
/// workspace package is offered at its current version, everything else is
/// proxied to pub.dev, and pana is pointed at it with `--hosted-url`.
///
///   dart tool/pana.dart                        # every publishable package
///   dart tool/pana.dart raindrop_sqlite        # one package
Future<void> main(List<String> arguments) async {
  final packages = _workspacePackages();
  final selected = [
    for (final argument in arguments)
      if (!argument.startsWith('--')) _resolve(argument, packages),
  ];
  final pub = _PubProxy(packages);
  await pub.start(8765);

  try {
    final targets = switch (selected) {
      final selected when selected.isNotEmpty => selected,
      _ => [for (final package in packages) package.directory.path],
    };
    final results = [for (final target in targets) await _score(target, pub)];
    _summarize(results);
    if (results.any((result) => !result.passed)) exit(1);
  } finally {
    await pub.close();
  }
}

typedef Package = ({String name, String version, Directory directory});

typedef Score = ({
  String package,
  int granted,
  int max,
  List<({String title, int granted, int max, String summary})> failed,
});

extension on Score {
  bool get passed => granted == max;

  String get verdict => '${passed ? '✅' : '❌'} $package: $granted/$max';
}

/// The directory of the workspace package called [name].
String _resolve(String name, List<Package> packages) {
  for (final package in packages) {
    if (package.name == name) return package.directory.path;
  }
  stderr.writeln(
    '"$name" is not a publishable workspace package. Choose from: '
    '${packages.map((package) => package.name).join(', ')}.',
  );
  exit(64);
}

Future<Score> _score(String target, _PubProxy pub) async {
  final package = p.basename(target);
  final live = stdout.hasTerminal;
  stdout.writeln(live ? '⏳ $package' : 'Scoring $package...');
  final result = await Process.run(Platform.resolvedExecutable, [
    'pub', 'global', 'run', 'pana', //
    '--no-warning',
    '--json',
    '--hosted-url', pub.url,
    target,
  ]);

  final Map<String, Object?> report;
  try {
    report = jsonDecode(result.stdout as String) as Map<String, Object?>;
  } on FormatException {
    stderr
      ..writeln('pana produced no report for $package:')
      ..writeln(result.stdout)
      ..writeln(result.stderr);
    exit(1);
  }

  final scores = report['scores']! as Map<String, Object?>;
  final sections =
      (report['report']! as Map<String, Object?>)['sections']! as List<Object?>;
  final score = (
    package: package,
    granted: scores['grantedPoints']! as int,
    max: scores['maxPoints']! as int,
    failed: [
      for (final section in sections.cast<Map<String, Object?>>())
        if (section['grantedPoints'] != section['maxPoints'])
          (
            title: section['title']! as String,
            granted: section['grantedPoints']! as int,
            max: section['maxPoints']! as int,
            summary: section['summary']! as String,
          ),
    ],
  );

  if (live) stdout.write('\x1B[1A\x1B[2K');
  stdout.writeln(score.verdict);
  return score;
}

/// Prints the lost sections in full, and on GitHub
/// Actions an annotation per failing package plus a table in the job summary.
void _summarize(List<Score> results) {
  final buffer = StringBuffer();
  for (final result in results) {
    buffer.writeln(
      '| ${result.package} | ${result.granted}/${result.max} '
      '| ${result.passed ? '✅' : '❌'} |',
    );
    for (final section in result.failed) {
      stdout
        ..writeln(result.verdict)
        ..writeln('   ${section.title}: ${section.granted}/${section.max}')
        ..writeln(_indent(section.summary));
      buffer
        ..writeln()
        ..writeln(
          '<details><summary>${result.package}: ${section.title} '
          '(${section.granted}/${section.max})</summary>',
        )
        ..writeln()
        ..writeln(section.summary)
        ..writeln('</details>');
    }
    if (!result.passed && Platform.environment.containsKey('GITHUB_ACTIONS')) {
      final lost = result.failed.map((section) => section.title).join(', ');
      stdout.writeln(
        '::error title=pub.dev score::${result.package} scores '
        '${result.granted}/${result.max}, points lost in: $lost',
      );
    }
  }

  final summaryPath = Platform.environment['GITHUB_STEP_SUMMARY'];
  if (summaryPath != null) {
    File(summaryPath).writeAsStringSync(
      '## pub.dev score\n\n| Package | Points | |\n|:-|:-|:-|\n$buffer',
      mode: FileMode.append,
    );
  }
}

String _indent(String text) => text
    .trim()
    .split('\n')
    .map((line) => line.isEmpty ? '' : '      $line')
    .join('\n');

/// Every workspace member that is not `publish_to: none`.
List<Package> _workspacePackages() {
  final root = File('pubspec.yaml').readAsStringSync();
  final members = RegExp(r'^\s+-\s+(\S+)\s*$', multiLine: true)
      .allMatches(root.substring(root.indexOf('\nworkspace:')))
      .map((match) => match[1]!);

  final packages = <Package>[];
  for (final member in members) {
    final directory = Directory(p.normalize(p.absolute(member)));

    final pubspec = File(p.join(directory.path, 'pubspec.yaml'));
    if (!pubspec.existsSync()) continue;

    final content = pubspec.readAsStringSync();
    if (RegExp(r'^publish_to:\s*none', multiLine: true).hasMatch(content)) {
      continue;
    }

    packages.add(
      (
        name: _field(content, 'name'),
        version: _field(content, 'version'),
        directory: directory,
      ),
    );
  }
  return packages;
}

String _field(String pubspec, String key) =>
    RegExp('^$key:\\s*(.+)\$', multiLine: true).firstMatch(pubspec)![1]!.trim();

/// A pub proxy over the workspace, proxying every other package to pub.dev.
class _PubProxy {
  _PubProxy(List<Package> packages)
    : _packages = {for (final package in packages) package.name: package},
      _archives = {
        for (final package in packages)
          '${package.name}-${package.version}.tar.gz': package,
      };

  static final Uri _upstream = Uri.parse('https://pub.dev');

  final Map<String, Package> _packages;
  final Map<String, Package> _archives;

  final _client = HttpClient();
  final _packed = <String, File>{};

  late final Directory _scratch;
  late final HttpServer _server;

  String get url => 'http://localhost:${_server.port}';

  Future<void> start(int port) async {
    _scratch = await Directory.systemTemp.createTemp('pana_');
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    _server.listen(_handle);
  }

  Future<void> close() async {
    await _server.close(force: true);
    _client.close(force: true);
    await _scratch.delete(recursive: true);
  }

  Future<void> _handle(HttpRequest request) async {
    try {
      await switch (request.uri.pathSegments) {
        ['api', 'packages', final name] when _packages.containsKey(name) =>
          _listing(request, _packages[name]!),
        ['api', 'packages', final name, 'advisories']
            when _packages.containsKey(name) =>
          _json(request, {'advisories': <Object>[], 'advisoriesUpdated': null}),
        ['archives', final file] when _archives.containsKey(file) => _archive(
          request,
          _archives[file]!,
        ),
        _ => _proxy(request),
      };
    } on Object catch (error, stack) {
      stderr.writeln('$error\n$stack');
      await request.response.close();
    }
  }

  Future<void> _listing(HttpRequest request, Package package) {
    final pubspec = File(p.join(package.directory.path, 'pubspec.yaml'));
    final version = {
      'version': package.version,
      'pubspec': _pubspecJson(pubspec.readAsStringSync()),
      'archive_url': '$url/archives/${package.name}-${package.version}.tar.gz',
      'published': DateTime.now().toUtc().toIso8601String(),
    };
    return _json(request, {
      'name': package.name,
      'latest': version,
      'versions': [version],
    });
  }

  Future<void> _archive(HttpRequest request, Package package) async {
    final archive = _packed[package.name] ??= await _pack(package);
    request.response.headers.contentType = ContentType('application', 'gzip');
    await request.response.addStream(archive.openRead());
    await request.response.close();
  }

  Future<File> _pack(Package package) async {
    final staging = Directory(p.join(_scratch.path, package.name));
    await for (final entity in package.directory.list(recursive: true)) {
      final relative = p.relative(entity.path, from: package.directory.path);
      final segments = p.split(relative);
      if (segments.any(const {'.dart_tool', 'build', 'coverage'}.contains)) {
        continue;
      }
      if (relative == 'pubspec.lock' || segments.first.startsWith('pana-')) {
        continue;
      }

      if (entity is! File) continue;

      final target = File(p.join(staging.path, relative));
      await target.parent.create(recursive: true);
      if (relative == 'pubspec.yaml') {
        await target.writeAsString(
          entity.readAsStringSync().replaceAll(
            RegExp(r'^resolution:.*\n', multiLine: true),
            '',
          ),
        );
      } else {
        await entity.copy(target.path);
      }
    }

    final archive = File(p.join(_scratch.path, '${package.name}.tar.gz'));
    final entries = [
      for (final entity in staging.listSync()) p.basename(entity.path),
    ];
    final result = await Process.run(
      'tar',
      ['-czf', archive.path, '-C', staging.path, ...entries],
    );
    if (result.exitCode != 0) {
      throw ProcessException('tar', entries, '${result.stderr}');
    }
    return archive;
  }

  Future<void> _proxy(HttpRequest request) async {
    final upstream = await _client.openUrl(
      request.method,
      _upstream.replace(path: request.uri.path, query: request.uri.query),
    );
    final accept = request.headers.value(HttpHeaders.acceptHeader);
    if (accept != null) upstream.headers.set(HttpHeaders.acceptHeader, accept);
    final response = await upstream.close();

    request.response
      ..statusCode = response.statusCode
      ..contentLength = -1;
    final contentType = response.headers.contentType;
    if (contentType != null) request.response.headers.contentType = contentType;
    await request.response.addStream(response);
    await request.response.close();
  }

  Future<void> _json(HttpRequest request, Object body) async {
    request.response.headers.contentType = ContentType(
      'application',
      'vnd.pub.v2+json',
    );
    request.response.write(jsonEncode(body));
    await request.response.close();
  }

  Map<String, Object?> _pubspecJson(String pubspec) => {
    'name': _field(pubspec, 'name'),
    'version': _field(pubspec, 'version'),
    'environment': {'sdk': _sdkConstraint(pubspec)},
    'dependencies': _section(pubspec, 'dependencies'),
  };

  String _sdkConstraint(String pubspec) => RegExp(
    r'^\s+sdk:\s*(.+)$',
    multiLine: true,
  ).firstMatch(pubspec)![1]!.trim().replaceAll(RegExp(r'''^["']|["']$'''), '');

  Map<String, Object?> _section(String pubspec, String section) {
    final match = RegExp(
      '^$section:\\n((?:[ \\t]+.*\\n?)*)',
      multiLine: true,
    ).firstMatch(pubspec);
    if (match == null) return {};

    return {
      for (final line in match[1]!.split('\n'))
        if (RegExp(r'^  (\w+):\s*(.*)$').firstMatch(line) case final match?)
          match[1]!: switch (match[2]) {
            final value? => value.replaceAll(RegExp(r'''^["']|["']$'''), ''),
            _ => 'any',
          },
    };
  }
}
