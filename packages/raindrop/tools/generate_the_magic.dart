import 'dart:io';

final script = File.fromUri(Platform.script);

void main(List<String> arguments) {
  final amount = int.tryParse(arguments.firstOrNull ?? '') ?? 20;

  selectableReader(
    '${script.parent.path}/../lib/src/artifacts/selectable_reader.dart',
    amount,
  );

  selectableColumns(
    '${script.parent.path}/../lib/src/artifacts/selectable_columns.dart',
    amount,
  );
  selectableRecords(
    '${script.parent.path}/../lib/src/artifacts/selectable_records.dart',
    amount,
  );
}

void selectableColumns(String path, int amount) {
  final buffer = StringBuffer()..writeln('''
// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars

import 'package:raindrop/raindrop.dart';
''');

  final vs = <int>[1];
  for (var i = 2; i < amount; i++) {
    vs.add(i);
    buffer.writeln('''
extension SelectableColumns$i<V${vs.join(', V')}> on (${vs.map((v) => 'ColumnType<V$v>').join(', ')}) {
  SelectableResult<(V${vs.join(', V')})> get \$ {
    return SelectableResult([${vs.map((i) => 'this.\$$i.\$').join(', ')}]);
  }
}''');
  }

  return File(path).writeAsStringSync(buffer.toString());
}

void selectableRecords(String path, int amount) {
  final buffer = StringBuffer()..writeln('''
// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars

import 'package:raindrop/raindrop.dart';
''');

  final vs = <int>[1];
  for (var i = 2; i < amount; i++) {
    vs.add(i);
    buffer.writeln('''
extension SelectableRecords$i<V${vs.join(', V')}> on (${vs.map((v) => 'Selectable<V$v>').join(', ')}) {
  SelectableResult<(V${vs.join(', V')})> get \$ {
    return SelectableResult([${vs.map((i) => 'this.\$$i').join(', ')}]);
  }
}''');
  }

  return File(path).writeAsStringSync(buffer.toString());
}

void selectableReader(String path, int amount) {
  final buffer = StringBuffer()..writeln('''
// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars

import 'package:raindrop/raindrop.dart';

extension ConvertResult<R> on SelectableResult<R> {
  R read(Map<String, dynamic> data, AliasRegistry registry) {
    switch(selected.length) {''');

  for (var i = 2; i < amount; i++) {
    final part = List.generate(i, (i) => i);

    buffer.write('''
      case $i:
        return (
          ${part.map((e) => 'Selectable.read(selected[$e], data, registry),').join('\n          ')}
        ) as R;
''');
  }
  buffer.writeln(r'''
      default:
        throw UnsupportedError('${selected.length}');
    }
  }
}''');

  return File(path).writeAsStringSync(buffer.toString());
}
