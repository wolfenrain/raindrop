import 'dart:io';

final script = File.fromUri(Platform.script);

void main(List<String> arguments) {
  final amount = int.tryParse(arguments.firstOrNull ?? '') ?? 20;

  selectableColumns(
    '${script.parent.path}/../lib/src/artifacts/selectable_columns.dart',
    amount,
  );
  indexableColumns(
    '${script.parent.path}/../lib/src/artifacts/index_columns.dart',
    amount,
  );
  updatableColumns(
    '${script.parent.path}/../lib/src/artifacts/updatable_columns.dart',
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
  final indices = List.generate(amount, (i) => i);
  final buffer = StringBuffer()..writeln('''
// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars
import 'package:raindrop/raindrop.dart';

/// Extension that provides insert, select, update and delete methods.
/// 
/// This file is fully generated to allow for resolution logic of types.
extension ISUDRaindropExecutor on RaindropExecutor<RaindropDelegate> {
  /// Create an insert builder for inserting entities [into] the database.
  InsertValuesBuilder<S, void> insert<S extends Schema<S>>({required S into}) {
    return delegate.insert(this, Table.get(into)! as Table<S>);
  }

  /// Create a select builder that can filter down on columns if needed.
  SelectingBuilder<${indices.map((i) => 'V$i').join(', ')}> select<${indices.map((i) => 'V$i extends dynamic').join(', ')}>([${indices.map((i) => 'Selectable<V$i>? s$i').join(', ')}]) {
    return delegate.select(this, _Selecting(${indices.map((i) => 's$i').join(', ')}));
  }

  /// Create an update builder that can update a [table].
  UpdateSettingBuilder<S, void> update<S extends Schema<S>>(S table) {
    return delegate.update(this, Table.get(table)! as Table<S>);
  }

  /// Create a delete builder that can delete data [from] the database.
  DeleteAllBuilder<S, void> delete<S extends Schema<S>>({required S from}) {
    return delegate.delete(this, Table.get(from)! as Table<S>);
  }
}

typedef SelectingBuilder<${indices.map((i) => 'V$i extends dynamic').join(', ')}> = SelectBuilder<(${indices.map((i) => 'Selectable<V$i>').join(', ')})?>;

typedef _Unused = Selectable<dynamic>;

class _Selecting<${indices.map((i) => 'S$i extends Selectable<Object?>?').join(', ')}> implements Selectable<(${indices.map((i) => 'S$i').join(', ')})?> {
  const _Selecting(${indices.map((i) => 'this.s$i').join(', ')});

${indices.map((i) => '  final S$i? s$i;').join('\n')}
}

extension SelectableColumns on SelectBuilder<(${List.filled(amount, '_Unused').join(', ')})?> {
  /// Create a from builder where the whole table gets selected.
  SelectFromBuilder<S, S> from<S extends Schema<S>>(S from) {
    final table = Table.get(from);
    return SelectFromBuilder(
      executor,
      config: config.copyWith({#selecting: table, #from: table}),
    );
  }
}
''');

  // Generate SelectableFrom extensions for each arity
  for (var i = 0; i < amount; i++) {
    final activeIndices = List.generate(i + 1, (j) => j);
    final _UnusedCount = amount - i - 1;

    // Type parameters for the extension
    final typeParams =
        activeIndices.map((j) => 'V$j extends Object').join(', ');

    // The "on" type - active selectables + _Unused for the rest
    final onTypeInner = [
      ...activeIndices.map((j) => 'Selectable<V$j>'),
      ...List.filled(_UnusedCount, '_Unused'),
    ].join(', ');

    // Result type for from
    final resultType =
        i == 0 ? 'V0' : '(${activeIndices.map((j) => 'V$j').join(', ')})';

    buffer.writeln('''
extension SelectableColumns$i<$typeParams>
    on SelectBuilder<($onTypeInner)?> {
  /// Create a from builder.
  SelectFromBuilder<S, $resultType> from<S extends Schema<S>>(S from) {
    final selecting = config[#selecting]! as _Selecting;
    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: ${i == 0 ? 'selecting.s0' : 'SelectableResult<$resultType>([${activeIndices.map((j) => 'selecting.s$j!').join(', ')}])'},
        #from: Table.get(from),
      }),
    );
  }
}''');
  }

  return File(path).writeAsStringSync(buffer.toString());
}

void indexableColumns(String path, int amount) {
  final columns = List.generate(amount - 1, (i) => i + 1);
  final buffer = StringBuffer()..writeln('''
// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars
import 'package:raindrop/raindrop.dart';

extension IndexBuilderOn on IndexBuilder {
  /// Create an index on the given colum(s).
  ///
  /// ```dart
  /// index('composite_idx').on(schema.col1, schema.col2);
  /// uniqueIndex('unique_idx').on(schema.col1);
  /// ```
  Index on(ColumnType<dynamic> c0, [${columns.map((v) => 'ColumnType<dynamic>? c$v').join(', ')}]) {
    final cols = [c0.\$, ${columns.map((v) => 'c$v?.\$').join(', ')}];
    return Index(name, [...cols.whereType()], isUnique: isUnique);
  }
}''');

  return File(path).writeAsStringSync(buffer.toString());
}

void updatableColumns(String path, int amount) {
  final indices = List.generate(amount, (i) => i);
  final buffer = StringBuffer()..writeln('''
// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars
import 'package:raindrop/raindrop.dart';

extension UpdatableColumnsOn<S extends Schema<S>, R> on UpdateSettingBuilder<S, R> {
  /// Set columns to update.
  ///
  /// ```dart
  /// db.update(users).set(users.name.to('new'), users.age.to(25));
  /// db.update(users).set(users.to(User(name: 'new', age; 25)));
  /// ```
  UpdateSetWhereBuilder<S, ${indices.map((i) => 'V$i').join(', ')}, R> set<${indices.map((i) => 'V$i extends dynamic').join(', ')}>(Updateable<V0> u0, [${indices.skip(1).map((i) => 'Updateable<V$i>? u$i').join(', ')}]) {
    return UpdateWhereBuilder(
      executor,
      config: config.copyWith({#set: _Set(${indices.map((i) => 'u$i').join(', ')})}),
    );
  }
}

typedef UpdateSetWhereBuilder<S extends Schema<S>, ${indices.map((i) => 'V$i extends dynamic').join(', ')}, R> = UpdateWhereBuilder<S, (${indices.map((i) => 'Updateable<V$i>').join(', ')})?, R>;

typedef _Unused = Updateable<dynamic>;

class _Set<${indices.map((i) => 'U$i extends Updateable<Object?>?').join(', ')}> implements Updateable<(${indices.map((i) => 'U$i').join(', ')})> {
  const _Set(${indices.map((i) => 'this.u$i').join(', ')});

${indices.map((i) => '  final U$i? u$i;').join('\n')}
}
''');

  // Generate UpdatableColumnsN extensions for each arity
  for (var i = 0; i < amount; i++) {
    final activeIndices = List.generate(i + 1, (j) => j);
    final unusedCount = amount - i - 1;

    // Type parameters for the extension
    final typeParams =
        activeIndices.map((j) => 'V$j extends Object').join(', ');

    // The "on" type - active Updateable<Vx> + _Unused for the rest
    final onTypeInner = [
      ...activeIndices.map((j) => 'Updateable<V$j>'),
      ...List.filled(unusedCount, '_Unused'),
    ].join(', ');

    // Result type for where
    final resultType =
        i == 0 ? 'V0' : '(${activeIndices.map((j) => 'V$j').join(', ')})';

    buffer.writeln('''
extension UpdatableColumns$i<S extends Schema<S>, R, $typeParams> on UpdateWhereBuilder<S, ($onTypeInner)?, R> {
  /// Filter the update query.
  UpdateWhereBuilder<S, $resultType, R> where(Filter where) {
    final set = config[#set]! as _Set;
    return UpdateWhereBuilder(
      executor,
      config: config.copyWith({
        #set: ${i == 0 ? 'set.u0' : 'UpdateableResult<$resultType>([${activeIndices.map((j) => 'set.u$j!').join(', ')}])'},
        #where: where,
      }),
    );
  }
}
''');
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
        #selecting: SelectableResult<(${types.join(', ')}, O)>([...result.selected, o]),
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
