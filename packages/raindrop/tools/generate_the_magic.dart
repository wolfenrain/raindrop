import 'dart:io';

final script = File.fromUri(Platform.script);

void main(List<String> arguments) {
  final amount = int.tryParse(arguments.firstOrNull ?? '') ?? 20;

  selectableColumns(
    '${script.parent.path}/../lib/src/artifacts/selectable_columns.dart',
    amount,
  );
  selectableRecords(
    '${script.parent.path}/../lib/src/artifacts/selectable_records.dart',
    amount,
  );

  generateJoin(
    '${script.parent.path}/../lib/src/builders/select/joins/inner_joins.dart',
    'Inner',
    amount,
  );
  generateJoin(
    '${script.parent.path}/../lib/src/builders/select/joins/left_joins.dart',
    'Left',
    amount,
  );
  generateJoin(
    '${script.parent.path}/../lib/src/builders/select/joins/right_joins.dart',
    'Right',
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
extension SelectableColumns$i<V${vs.join(', V')}> on (${vs.map((v) => 'ColumnOf<V$v>').join(', ')}) {
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

void generateJoin(String path, String type, int amount) {
  final methodName = switch (type) {
    'Left' => 'leftJoin',
    'Right' => 'rightJoin',
    _ => 'join',
  };

  final buffer = StringBuffer()..writeln('''
// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars

import 'package:raindrop/raindrop.dart';

extension SelectWith${type}Join<V extends Object?, S extends Schema<S>> on SelectFromBuilder<S, V> {
  /// Add a ${type.toLowerCase()} join clause of the builder.
  SelectFromBuilder<S, V> $methodName<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          ${type}Join<O>(Table.get(table)! as Table<O>, on: on),
        ],
      }),
    );
  }
}

extension SelectWith${type}Join0<S extends Schema<S>> on SelectFromBuilder<S, S> {
  /// Add a ${type.toLowerCase()} join clause of the builder.
  SelectFromBuilder<S, (S${type == 'Right' ? '?' : ''}, O${type == 'Left' ? '?' : ''})> $methodName<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final s = config.get(#selecting) as Table<S>;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S, O)>([s, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          ${type}Join<O>(o, on: on),
        ],
      }),
    );
  }
}''');

  for (var i = 1; i < amount; i++) {
    final types =
        List.generate(i + 1, (j) => 'S$j${type == 'Right' ? '?' : ''}');

    buffer.write('''

extension SelectWith${type}Join$i<S extends Schema<S>, ${List.generate(i + 1, (s) => 'S$s extends Schema<S$s>?').join(', ')}> on SelectFromBuilder<S, (${types.join(', ').replaceAll('?', '')})> {
  /// Add a ${type.toLowerCase()} join clause of the builder.
  SelectFromBuilder<S, (${types.join(', ')}, O${type == 'Left' ? '?' : ''})> $methodName<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S, ${types.join(', ')}, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          ${type}Join<O>(o, on: on),
        ],
      }),
    );
  }
}
''');
  }

  File(path)
    ..createSync(recursive: true)
    ..writeAsStringSync(buffer.toString());
}
