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
  final uncovered = <String, int>{};
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
        uncovered[current] = (uncovered[current] ?? 0) + 1;
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
    stdout.writeln('  ${entry.key} (${entry.value} lines)');
  }
  exit(1);
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
