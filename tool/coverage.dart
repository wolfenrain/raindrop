import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final coverage = Directory('coverage');
  if (coverage.existsSync()) coverage.deleteSync(recursive: true);

  await _run(['test', '--coverage=coverage']);
  await _run([
    'run',
    'coverage:format_coverage',
    '--lcov',
    '--check-ignore',
    '--in=coverage',
    '--out=coverage/lcov.info',
    '--report-on=lib',
  ]);

  final lcov = File('coverage/lcov.info').readAsLinesSync();

  final sources = <String>{
    for (final line in lcov)
      if (line.startsWith('SF:')) _normalize(line.substring(3)),
  };

  var missing = false;
  final libFiles = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
  for (final file in libFiles) {
    final source = file.readAsStringSync();

    if (source.contains('coverage:ignore-file')) continue;
    if (!_hasExecutableCode(source)) continue;

    final path = _normalize(file.path);
    if (!sources.any((sf) => sf == path || sf.endsWith('/$path'))) {
      stdout.writeln('no test loads $path');
      missing = true;
    }
  }
  if (missing) exit(1);

  var total = 0;
  var hit = 0;
  final uncovered = <String, List<int>>{};
  var current = '';
  for (final line in lcov) {
    if (line.startsWith('SF:')) {
      current = _normalize(line.substring(3));
      final lib = current.indexOf('/lib/');
      if (lib != -1) current = current.substring(lib + 1);
    } else if (line.startsWith('DA:')) {
      total++;
      final hits = int.parse(line.substring(3).split(',')[1]);
      if (hits > 0) {
        hit++;
      } else {
        final number = int.parse(line.substring(3).split(',')[0]);
        (uncovered[current] ??= []).add(number);
      }
    }
  }

  if (hit == total) {
    return stdout.writeln('💯 100% covered.');
  }

  final percent = (100 * hit / total).toStringAsFixed(1);
  stdout.writeln(
    '❌ FAILED: $percent% covered ($hit/$total lines), 100% required. '
    'Uncovered:',
  );
  for (final entry in uncovered.entries) {
    stdout.writeln(
      '  ${entry.key} (${entry.value.length} lines): '
      '${entry.value.join(', ')}',
    );
    _reportPerSuite(entry.key, entry.value);
  }
  exit(1);
}

/// Prints what every suite's raw VM report holds for [lines] of [libPath], so
/// a failure shows which suite lost its hits and whether the file was loaded.
void _reportPerSuite(String libPath, List<int> lines) {
  final suffix = libPath.replaceFirst('lib/', '/');
  final reports = Directory('coverage')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.vm.json'));
  for (final report in reports) {
    final suite = _normalize(report.path).replaceFirst('coverage/', '');
    final document =
        jsonDecode(report.readAsStringSync()) as Map<String, Object?>;
    final entries = (document['coverage'] as List<Object?>? ?? const [])
        .cast<Map<String, Object?>>()
        .where((entry) => (entry['source']! as String).endsWith(suffix));
    if (entries.isEmpty) {
      stdout.writeln('    $suite: file not loaded');
      continue;
    }
    for (final entry in entries) {
      final hits = (entry['hits']! as List<Object?>).cast<int>();
      final byLine = {
        for (var i = 0; i < hits.length; i += 2) hits[i]: hits[i + 1],
      };
      final covered = byLine.values.where((count) => count > 0).length;
      final wanted = [for (final line in lines) '$line=${byLine[line] ?? '-'}'];
      stdout.writeln(
        '    $suite: $covered of ${byLine.length} lines hit, '
        '${wanted.join(' ')}',
      );
    }
  }
}

String _normalize(String path) => path.trim().replaceAll(r'\', '/');

/// Whether [source] contains anything beyond comments and
/// `export`/`import`/`library`/`part` directives.
bool _hasExecutableCode(String source) {
  final withoutComments = source
      .split('\n')
      .map((line) => line.replaceFirst(RegExp('//.*'), ''))
      .join(' ');
  final withoutDirectives = withoutComments.replaceAll(
    RegExp('(export|import|library|part)[^;]*;'),
    '',
  );
  return withoutDirectives.trim().isNotEmpty;
}

Future<void> _run(List<String> arguments) async {
  final process = await Process.start(
    Platform.resolvedExecutable,
    arguments,
    mode: ProcessStartMode.inheritStdio,
  );
  final exitCode = await process.exitCode;
  if (exitCode != 0) exit(exitCode);
}
