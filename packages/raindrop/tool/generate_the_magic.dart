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
  updateableColumns(
    '${script.parent.path}/../lib/src/artifacts/updateable_columns.dart',
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

  derivedSchemas(
    '${script.parent.path}/../lib/src/definitions/derived_schemas.dart',
    amount,
  );

  Process.runSync('melos', ['format:fix']);
}

void derivedSchemas(String path, int amount) {
  final buffer = StringBuffer()..writeln('''
// GENERATED CODE - DO NOT EDIT BY HAND.
// Run `dart run tool/generate_the_magic.dart` to regenerate.
// coverage:ignore-file
// ignore_for_file: public_member_api_docs
import 'package:raindrop/raindrop.dart';
import 'package:raindrop/src/builders/derived.dart';
import 'package:raindrop/src/definitions/table.dart';
''');

  for (var n = 1; n <= amount; n++) {
    final indices = List.generate(n, (j) => j);
    final params = indices.map((j) => 'V$j').join(', ');
    final record =
        n == 1 ? '(V0,)' : '(${indices.map((j) => 'V$j').join(', ')})';
    final on = n == 1
        ? 'SingleProjectionFromBuilder<Schema<dynamic>, dynamic, V0>'
        : 'ProjectionFromBuilder<Schema<dynamic>, dynamic, $record>';
    final element = n == 1 ? 'V0' : record;

    buffer.writeln('''
class Derived$n<$params> extends Schema<$record> {
  Derived$n(super.\$, ${indices.map((j) => 'this.\$${j + 1}').join(', ')});

${indices.map((j) => '  final ColumnType<V$j> \$${j + 1};').join('\n')}

  @override
  $record fromRow(RowReader read) => (${indices.map((j) => 'read(\$${j + 1})').join(', ')}${n == 1 ? ',' : ''});
}

extension DerivedProjection$n<$params> on $on {
  /// The rows this projection returns, usable where a table is.
  ///
  /// Pass [as] when a single query holds more than one derived table, so their
  /// names cannot collide.
  Derived$n<$params> derived({String? as}) {
    final prepared = prepareDerived<$element>(this);
    return derivedTable<Derived$n<$params>, $record>(
      as ?? defaultDerivedName(config),
      (\$) => Derived$n<$params>(
        \$,
${indices.map((j) => '        ColumnType(derivedColumn<$record, V$j>(\$, prepared, $j, (r) => r.\$${j + 1})),').join('\n')}
      ),
      prepared.query,
    );
  }
}
''');
  }

  File(path)
    ..createSync(recursive: true)
    ..writeAsStringSync(buffer.toString());
}

void selectableColumns(String path, int amount) {
  final indices = List.generate(amount, (i) => i);
  final buffer = StringBuffer()..writeln('''
// GENERATED CODE - DO NOT EDIT BY HAND.
// Run `dart run tool/generate_the_magic.dart` to regenerate.
// coverage:ignore-file
// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars
import 'package:raindrop/raindrop.dart';

/// Extension that provides insert, select, update and delete methods.
///
/// This file is fully generated to allow for resolution logic of types.
extension ISUDRaindropExecutor on RaindropExecutor<Delegate> {
  /// Create an insert builder for inserting entities [into] the database.
  InsertValuesBuilder<Schema<R>, R, void> insert<R>({required Schema<R> into}) {
    return delegate.insert<R>(this, into.\$);
  }

  /// Create a select builder that can filter down on columns if needed.
  SelectingBuilder<${indices.map((i) => 'S$i').join(', ')}> select<${indices.map((i) => 'S$i extends Selectable<Object?>?').join(', ')}>([${indices.map((i) => 'S$i? s$i').join(', ')}]) {
    return delegate.select(this, _Selecting<${indices.map((i) => 'S$i').join(', ')}>(${indices.map((i) => 's$i').join(', ')}));
  }

  /// Create an update builder that can update a [table].
  UpdateSettingBuilder<Schema<R>, R, void> update<R>(Schema<R> table) {
    return delegate.update<R>(this, table.\$);
  }

  /// Create a delete builder that can delete data [from] the database.
  DeleteAllBuilder<Schema<R>, R, void> delete<R>({required Schema<R> from}) {
    return delegate.delete<R>(this, from.\$);
  }
}

typedef SelectingBuilder<${indices.map((i) => 'S$i extends Selectable<Object?>?').join(', ')}> = SelectBuilder<(${indices.map((i) => 'S$i').join(', ')})?>;

/// The signature of [ISUDRaindropExecutor.select].
typedef SelectFunction = SelectingBuilder<${indices.map((i) => 'S$i').join(', ')}> Function<${indices.map((i) => 'S$i extends Selectable<Object?>?').join(', ')}>([${indices.map((i) => 'S$i?').join(', ')}]);

/// `SELECT DISTINCT`, as an extension on the torn-off `select` itself.
extension DistinctSelect on SelectFunction {
  /// Select distinct rows:
  ///
  /// ```dart
  /// db.select.distinct(users.country, users.city).from(users);
  /// // SELECT DISTINCT "country", "city" FROM "users"
  /// ```
  ///
  /// Takes the same columns and returns the same builder as [ISUDRaindropExecutor.select].
  ///
  /// For one aggregate's operand, `COUNT(DISTINCT x)`, wrap the column in
  /// `distinct()` instead.
  SelectingBuilder<${indices.map((i) => 'S$i').join(', ')}> distinct<${indices.map((i) => 'S$i extends Selectable<Object?>?').join(', ')}>([${indices.map((i) => 'S$i? s$i').join(', ')}]) {
    final builder = this<${indices.map((i) => 'S$i').join(', ')}>(${indices.map((i) => 's$i').join(', ')});
    return SelectBuilder(
      builder.executor,
      config: builder.config.copyWith({#distinct: true}),
    );
  }
}

typedef _Unused = Selectable<Object?>?;

class _Selecting<${indices.map((i) => 'S$i extends Selectable<Object?>?').join(', ')}> implements Selectable<(${indices.map((i) => 'S$i').join(', ')})?> {
  const _Selecting(${indices.map((i) => 'this.s$i').join(', ')});

${indices.map((i) => '  final S$i? s$i;').join('\n')}
}

extension SelectableColumns on SelectBuilder<(${List.filled(amount, '_Unused').join(', ')})?> {
  /// Create a from builder where the whole table gets selected.
  WholeRowFromBuilder<Schema<R>, R> from<R>(Schema<R> from) {
    final table = from.\$;
    return WholeRowFromBuilder(
      executor,
      config: config.copyWith({#selecting: table, #from: table}),
    );
  }
}
''');

  // Generate SelectableFrom extensions for each arity
  for (var i = 0; i < amount; i++) {
    final activeIndices = List.generate(i + 1, (j) => j);
    final unusedCount = amount - i - 1;

    // Type parameters for the extension
    final typeParams = activeIndices.map((j) => 'V$j').join(', ');

    // The "on" type - active selectables + _Unused for the rest
    final onTypeInner = [
      ...activeIndices.map((j) => 'Selectable<V$j>'),
      ...List.filled(unusedCount, '_Unused'),
    ].join(', ');

    // Result type for from
    final resultType =
        i == 0 ? 'V0' : '(${activeIndices.map((j) => 'V$j').join(', ')})';

    // One column is its own class: its element type is V0 rather than a
    // 1-tuple, so nothing downstream can tell it apart by element type.
    final builder =
        i == 0 ? 'SingleProjectionFromBuilder' : 'ProjectionFromBuilder';

    buffer.writeln('''
extension SelectableColumns$i<$typeParams>
    on SelectBuilder<($onTypeInner)?> {
  /// Create a from builder.
  $builder<Schema<R>, R, $resultType> from<R>(Schema<R> from) {
    final selecting = config.selecting! as _Selecting;
    return $builder(
      executor,
      config: config.copyWith({
        #selecting: ${i == 0 ? 'selecting.s0' : 'SelectableResult<$resultType>([${activeIndices.map((j) => 'selecting.s$j!').join(', ')}])'},
        #from: from.\$,
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
// GENERATED CODE - DO NOT EDIT BY HAND.
// Run `dart run tool/generate_the_magic.dart` to regenerate.
// coverage:ignore-file
// ignore_for_file: public_member_api_docs
import 'package:raindrop/raindrop.dart';

extension IndexBuilderOn on IndexBuilder {
  /// Create an index on the given column(s).
  ///
  /// ```dart
  /// index('composite_idx').on(schema.col1, schema.col2);
  /// uniqueIndex('unique_idx').on(schema.col1);
  /// ```
  Index on(ColumnType<dynamic>? c0, [${columns.map((v) => 'ColumnType<dynamic>? c$v').join(', ')}]) {
    final cols = [c0, ${columns.map((v) => 'c$v').join(', ')}];
    final resolved = [...cols.whereType<Column<dynamic, dynamic>>()];

    final index = Index(name, resolved, isUnique: isUnique, where: where);
    resolved.first.table.addIndex(index);
    return index;
  }
}''');

  return File(path).writeAsStringSync(buffer.toString());
}

void updateableColumns(String path, int amount) {
  final indices = List.generate(amount, (i) => i);
  final params = [
    'Updateable<dynamic> u0',
    if (indices.length > 1)
      '[${indices.skip(1).map((i) => 'Updateable<dynamic>? u$i').join(', ')}]',
  ].join(', ');
  final buffer = StringBuffer()..writeln('''
// GENERATED CODE - DO NOT EDIT BY HAND.
// Run `dart run tool/generate_the_magic.dart` to regenerate.
// coverage:ignore-file
// ignore_for_file: public_member_api_docs
import 'package:raindrop/raindrop.dart';

extension UpdateableColumnsOn<S extends Schema<RR>, RR, R> on UpdateSettingBuilder<S, RR, R> {
  /// Set columns to update.
  UpdateWhereBuilder<S, RR, R> set($params) {
    final updates = <Updateable<dynamic>?>[${indices.map((i) => 'u$i').join(', ')}].whereType<Updateable<dynamic>>().toList();
    return UpdateWhereBuilder(
      executor,
      config: config.copyWith({#set: UpdateableResult<List<Object?>>(updates)}),
    );
  }

  /// Set columns from a list or iterable (e.g. built dynamically, or more than
  /// [set]'s positional limit). Must be non-empty.
  ///
  /// ```dart
  /// db.update(users).setAll([users.name.to('new'), users.age.to(25)]);
  /// ```
  UpdateWhereBuilder<S, RR, R> setAll(Iterable<Updateable<dynamic>> updates) {
    final list = List<Updateable<dynamic>>.from(updates);
    if (list.isEmpty) {
      throw ArgumentError.value(updates, 'updates', 'must not be empty');
    }
    return UpdateWhereBuilder(
      executor,
      config: config.copyWith({#set: UpdateableResult<List<Object?>>(list)}),
    );
  }
}
''');

  return File(path).writeAsStringSync(buffer.toString());
}

void generateJoin(String path, String type, int amount) {
  final methodName = switch (type) {
    'Left' => 'leftJoin',
    'Right' => 'rightJoin',
    _ => 'join',
  };

  final buffer = StringBuffer()..writeln('''
// GENERATED CODE - DO NOT EDIT BY HAND.
// Run `dart run tool/generate_the_magic.dart` to regenerate.
// coverage:ignore-file
// ignore_for_file: public_member_api_docs

import 'package:raindrop/raindrop.dart';

extension SelectWith${type}Join0<S extends Schema<R>, R> on SelectFromBuilder<S, R, R> {
  /// Add a ${type.toLowerCase()} join clause of the builder.
  SelectFromBuilder<S, R, (R${type == 'Right' ? '?' : ''}, OR${type == 'Left' ? '?' : ''})> $methodName<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final s = config.selecting! as Table<S, R>;
    final o = table.\$;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R, OR)>([s, o]),
        #joins: [
          ...config.joins,
          ${type}Join<Schema<OR>, OR>(o, on: on),
        ],
      }),
    );
  }
}''');

  for (var i = 1; i < amount; i++) {
    final types =
        List.generate(i + 1, (j) => 'R$j${type == 'Right' ? '?' : ''}');

    buffer.write('''

extension SelectWith${type}Join$i<S extends Schema<R>, R, ${List.generate(i + 1, (s) => 'R$s').join(', ')}> on SelectFromBuilder<S, R, (${types.join(', ').replaceAll('?', '')})> {
  /// Add a ${type.toLowerCase()} join clause of the builder.
  SelectFromBuilder<S, R, (${types.join(', ')}, OR${type == 'Left' ? '?' : ''})> $methodName<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.selecting! as SelectableResult;
    final o = table.\$;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(${types.join(', ')}, OR)>([...result.selected, o]),
        #joins: [
          ...config.joins,
          ${type}Join<Schema<OR>, OR>(o, on: on),
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
