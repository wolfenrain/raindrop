// import 'package:raindrop/raindrop.dart';
// import 'package:raindrop/src/queries/select.dart';

// class Select<E extends Entity<E>, V> extends Query<E, V> {
//   const Select(
//     super.from, {
//     this.joins = const [],
//     this.where,
//     this.limit,
//     this.offset,
//   });

//   final List<Join> joins;

//   final Filter? where;

//   final int? limit;

//   final int? offset;
// }

// class SelectConfig<E extends Entity<E>> extends QueryConfig<E>
//     implements Select<E, void> {
//   SelectConfig(
//     super.executor,
//     super.from, {
//     this.where,
//     this.limit,
//     this.offset,
//     this.joins = const [],
//   });

//   @override
//   Filter? where;

//   @override
//   int? limit;

//   @override
//   int? offset;

//   @override
//   List<Join> joins;
// }

// class SelectBuilder<V extends Object?> {
//   const SelectBuilder(this._executor);

//   final RaindropExecutor _executor;
// }

// extension EmptySelect on SelectBuilder<Object?> {
//   SelectFromBuilder<E, SelectConfig<E>, E> from<E extends Entity<E>>(
//     TableDefinition<E> table,
//   ) {
//     return SelectFromBuilder(config: SelectConfig(_executor, table));
//   }
// }

// extension NotEmptySelect<V extends Object> on SelectBuilder<V> {
//   SelectFromBuilder<E, SelectConfig<E>, V> from<E extends Entity<E>>(
//     TableDefinition<E> table,
//   ) {
//     return SelectFromBuilder(config: SelectConfig(_executor, table));
//   }
// }

// class SelectFromBuilder<E extends Entity<E>, C extends SelectConfig<E>, V>
//     extends QueryBuilder<Select<E, V>, C, E, V> {
//   SelectFromBuilder({required super.config});

//   SelectFromBuilder<E, C, V> where(Filter filter) =>
//       this..config.where = filter;

//   SelectFromBuilder<E, C, V> limit(int limit) => this..config.limit = limit;

//   SelectFromBuilder<E, C, V> offset(int offset) => this..config.offset =
// offset;

//   @override
//   Select<E, V> toQuery() => Select(
//         config.from,
//         joins: config.joins,
//         where: config.where,
//         limit: config.limit,
//         offset: config.offset,
//       );
// }

// extension<E extends Entity<E>, V> on SelectFromBuilder<E, SelectConfig<E>, V>
// {
//   SelectFromBuilder<E, SelectConfig<E>, V> join<O extends Entity<O>>(
//     TableDefinition<O> table,
//     Filter on,
//   ) {
//     return SelectFromBuilder(
//       config: SelectConfig(
//         config.executor,
//         config.from,
//         where: config.where,
//         limit: config.limit,
//         offset: config.offset,
//         joins: [
//           ...config.joins,
//           InnerJoin<O>(table, on: on),
//         ],
//       ),
//     );
//   }

//   SelectFromBuilder<E, SelectConfig<E>, V> leftJoin<O extends Entity<O>>(
//     TableDefinition<O> table,
//     Filter on,
//   ) {
//     return SelectFromBuilder(
//       config: SelectConfig(
//         config.executor,
//         config.from,
//         where: config.where,
//         limit: config.limit,
//         offset: config.offset,
//         joins: [
//           ...config.joins,
//           LeftJoin<O>(table, on: on),
//         ],
//       ),
//     );
//   }

//   SelectFromBuilder<E, SelectConfig<E>, V> rightJoin<O extends Entity<O>>(
//     TableDefinition<O> table,
//     Filter on,
//   ) {
//     return SelectFromBuilder(
//       config: SelectConfig(
//         config.executor,
//         config.from,
//         where: config.where,
//         limit: config.limit,
//         offset: config.offset,
//         joins: [
//           ...config.joins,
//           RightJoin<O>(table, on: on),
//         ],
//       ),
//     );
//   }
// }
