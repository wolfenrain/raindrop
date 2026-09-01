import 'package:raindrop/ddl.dart';
import 'package:raindrop/raindrop.dart';
import 'package:raindrop/src/introspect.dart';

/// One applied migration, as the storage reports it.
typedef AppliedMigration = ({String tag, String checksum});

/// {@template migration_storage}
/// Where a driver keeps its record of applied migrations.
///
/// A driver that supports migrations exposes one through
/// `RaindropDelegate.migrationStorage`, a driver that does not leaves it
/// `null` and `migrate` refuses to run.
/// {@endtemplate}
abstract class MigrationStorage {
  /// {@macro migration_storage}
  const MigrationStorage();

  /// Makes sure the storage exists, creating it when absent.
  ///
  /// Runs before every migration run, so it must be safe to repeat.
  Future<void> ensure(RaindropExecutor<Delegate> executor);

  /// Loads every applied migration, in application order.
  Future<List<AppliedMigration>> loadApplied(
    RaindropExecutor<Delegate> executor,
  );

  /// Records one applied migration.
  Future<void> record(
    RaindropExecutor<Delegate> executor, {
    required String tag,
    required String checksum,
  });
}

/// {@template ddl_migration_storage}
/// [MigrationStorage] kept in a `_raindrop_migrations` table.
///
/// The column types default to the common SQL spellings. A dialect that
/// spells one differently passes its own, for example
/// `appliedAtType: 'NUMBER(19)'` for a dialect without `BIGINT`. A driver
/// where even the table shape does not fit implements [MigrationStorage]
/// directly instead.
/// {@endtemplate}
class DdlMigrationStorage extends MigrationStorage {
  /// {@macro ddl_migration_storage}
  DdlMigrationStorage(
    this.generator, {
    this.idType = 'INTEGER',
    this.textType = 'TEXT',
    this.appliedAtType = 'BIGINT',
  });

  /// The driver's generator, which spells the storage in its own dialect.
  final DdlGenerator generator;

  /// The type of the auto-increment `id` key column.
  final String idType;

  /// The type of the `tag` and `checksum` columns.
  final String textType;

  /// The type of the `applied_at` column, which holds an epoch in
  /// milliseconds, so it must fit 64-bit integers.
  final String appliedAtType;

  static const _table = '_raindrop_migrations';

  /// The bookkeeping table, in the driver's dialect.
  late final _MigrationSchema _schema = table<_MigrationSchema, _MigrationRow>(
    _table,
    ($) => _MigrationSchema(
      $,
      idType: idType,
      textType: textType,
      appliedAtType: appliedAtType,
    ),
    dialect: generator.dialect,
    extra: (schema) {
      uniqueIndex('${_table}_tag').on(schema.tag);
    },
  );

  @override
  Future<void> ensure(RaindropExecutor<Delegate> executor) async {
    final snapshot = buildSnapshot([_schema], dialect: generator.dialect);
    final sql = generator.generate([
      for (final table in snapshot.tableInfos)
        CreateTable(table, ifNotExists: true),
      for (final index in snapshot.indexInfos)
        CreateIndex(index: index, ifNotExists: true),
    ]);
    for (final statement in generator.dialect.splitStatements(sql)) {
      await executor.execute(statement);
    }
  }

  @override
  Future<List<AppliedMigration>> loadApplied(
    RaindropExecutor<Delegate> executor,
  ) async {
    final rows =
        await executor.select().from(_schema).orderBy({_schema.id: Order.asc});

    return [
      for (final row in rows) (tag: row.tag, checksum: row.checksum),
    ];
  }

  @override
  Future<void> record(
    RaindropExecutor<Delegate> executor, {
    required String tag,
    required String checksum,
  }) async {
    await executor.insert(into: _schema).values([
      _MigrationRow(
        tag: tag,
        checksum: checksum,
        appliedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    ]);
  }
}

/// One row of the bookkeeping table.
class _MigrationRow {
  const _MigrationRow({
    required this.tag,
    required this.checksum,
    required this.appliedAt,
    this.id,
  });

  /// The key the database assigns, absent until the row is written.
  final int? id;

  /// The migration's tag.
  final String tag;

  /// The checksum of the migration source at the time it was applied.
  final String checksum;

  /// When the migration was applied, as an epoch in milliseconds.
  final int appliedAt;
}

class _MigrationSchema extends Schema<_MigrationRow> {
  _MigrationSchema(
    super.$, {
    required String idType,
    required String textType,
    required String appliedAtType,
  })  : id = $
            .column<int, int?>('id', (row) => row.id, sqlType: idType)
            .primaryKey(autoIncrement: true),
        tag = $.column<String, String>(
          'tag',
          (row) => row.tag,
          sqlType: textType,
        ),
        checksum = $.column<String, String>(
          'checksum',
          (row) => row.checksum,
          sqlType: textType,
        ),
        appliedAt = $.column<int, int>(
          'applied_at',
          (row) => row.appliedAt,
          sqlType: appliedAtType,
        );

  final ColumnType<int?> id;

  final ColumnType<String> tag;

  final ColumnType<String> checksum;

  final ColumnType<int> appliedAt;

  @override
  _MigrationRow fromRow(RowReader read) => _MigrationRow(
        id: read(id),
        tag: read(tag),
        checksum: read(checksum),
        appliedAt: read(appliedAt),
      );
}
