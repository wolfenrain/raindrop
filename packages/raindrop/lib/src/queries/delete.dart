// import 'package:raindrop/raindrop.dart';

// class Delete<E extends Entity<E>, V> extends Query<E, V> {
//   const Delete(
//     super.table, {
//     this.where,
//   });

//   final Filter? where;
// }

// class DeleteConfig<E extends Entity<E>, V> extends QueryConfig<E>
//     implements Delete<E, V> {
//   DeleteConfig(
//     super.executor,
//     super.table, {
//     this.where,
//   });

//   @override
//   Filter? where;
// }

// class DeleteBuilder<E extends Entity<E>, C extends DeleteConfig<E, V>, V>
//     extends QueryBuilder<Delete<E, V>, C, E, V> {
//   DeleteBuilder({required super.config});

//   DeleteBuilder<E, C, V> where(Filter filter) => this..config.where = filter;

//   @override
//   Delete<E, V> toQuery() => Delete(config.table, where: config.where);
// }
