// import 'package:raindrop/raindrop.dart';

// class Select<E extends Entity<E>, V> extends Query<E, V> {
//   const Select(
//     super.table, {
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
//     super.table, {
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

// class SelectBuilder<E extends Entity<E>, C extends SelectConfig<E>, V>
//     extends QueryBuilder<Select<E, V>, C, E, V> {
//   SelectBuilder({required super.config});

//   SelectBuilder<E, C, V> where(Filter filter) => this..config.where = filter;

//   SelectBuilder<E, C, V> limit(int limit) => this..config.limit = limit;

//   SelectBuilder<E, C, V> offset(int offset) => this..config.offset = offset;

//   @override
//   Select<E, V> toQuery() => Select(
//         config.table,
//         joins: config.joins,
//         where: config.where,
//         limit: config.limit,
//         offset: config.offset,
//       );
// }

// extension SelectBuilderJoin<E1 extends Entity<E1>, C extends SelectConfig<E1>
// >
//     on SelectBuilder<E1, C, E1> {
//   SelectBuilder<E1, SelectConfig<E1>, (E1, O)> join<O extends Entity<O>>(
//     TableDefinition<O> table,
//     Filter on,
//   ) {
//     return SelectBuilderJoin1<E1, SelectConfig<E1>, O>(
//       config: SelectConfig<E1>(
//         config.executor,
//         config.table,
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

//   SelectBuilder<E1, SelectConfig<E1>, (E1, O?)> leftJoin<O extends Entity<O>>
// (
//     TableDefinition<O> table,
//     Filter on,
//   ) {
//     return SelectBuilderJoin1<E1, SelectConfig<E1>, O?>(
//       config: SelectConfig<E1>(
//         config.executor,
//         config.table,
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

//   SelectBuilder<E1, SelectConfig<E1>, (E1?, O)> rightJoin<O extends Entity<O>
// >(
//     TableDefinition<O> table,
//     Filter on,
//   ) {
//     return SelectBuilderJoin1<E1, SelectConfig<E1>, O>(
//       config: SelectConfig<E1>(
//         config.executor,
//         config.table,
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

// class SelectBuilderJoin1<E1 extends Entity<E1>, C extends SelectConfig<E1>,
//     E2 extends Object?> extends SelectBuilder<E1, C, (E1, E2)> {
//   SelectBuilderJoin1({required super.config});

//   SelectBuilder<E1, SelectConfig<E1>, (E1, E2, O)> join<O extends Entity<O>>(
//     TableDefinition<O> table,
//     Filter on,
//   ) {
//     return SelectBuilderJoin2<E1, SelectConfig<E1>, E2, O>(
//       config: SelectConfig<E1>(
//         config.executor,
//         config.table,
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
// }

// class SelectBuilderJoin2<
//     E1 extends Entity<E1>,
//     C extends SelectConfig<E1>,
//     E2 extends Object?,
//     E3 extends Object?> extends SelectBuilder<E1, C, (E1, E2, E3)> {
//   SelectBuilderJoin2({required super.config});

//   SelectBuilder<E1, SelectConfig<E1>, (E1, E2, E3, O)>
//       join<O extends Entity<O>>(
//     TableDefinition<O> table,
//     Filter on,
//   ) {
//     return SelectBuilderJoin3<E1, SelectConfig<E1>, E2, E3, O>(
//       config: SelectConfig<E1>(
//         config.executor,
//         config.table,
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
// }

// class SelectBuilderJoin3<
//     E1 extends Entity<E1>,
//     C extends SelectConfig<E1>,
//     E2 extends Object?,
//     E3 extends Object?,
//     E4 extends Object?> extends SelectBuilder<E1, C, (E1, E2, E3, E4)> {
//   SelectBuilderJoin3({required super.config});
// }

// abstract class Join<E extends Entity<E>> {
//   const Join(this.table, {required this.on});

//   final TableDefinition<E> table;

//   final Filter on;
// }

// class InnerJoin<E extends Entity<E>> extends Join<E> {
//   InnerJoin(super.table, {required super.on});
// }

// class LeftJoin<E extends Entity<E>> extends Join<E> {
//   LeftJoin(super.table, {required super.on});
// }

// class RightJoin<E extends Entity<E>> extends Join<E> {
//   RightJoin(super.table, {required super.on});
// }
