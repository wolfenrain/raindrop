// import 'package:raindrop/raindrop.dart';

// class Update<E extends Entity<E>, V> extends Query<E, V> {
//   const Update(
//     super.table, {
//     required this.set,
//     this.where,
//   });

//   final E set;

//   final Filter? where;
// }

// class UpdateConfig<E extends Entity<E>> extends QueryConfig<E>
//     implements Update<E, void> {
//   UpdateConfig(
//     super.executor,
//     super.table, {
//     this.where,
//   });

//   @override
//   late E set;

//   @override
//   Filter? where;
// }

// class UpdateBuilder<E extends Entity<E>, C extends UpdateConfig<E>>
//     extends QueryBuilder<Update<E, void>, C, E, void> {
//   UpdateBuilder({required super.config});

//   UpdateBuilder<E, C> set(E value) => this..config.set = value;

//   UpdateBuilder<E, C> where(Filter filter) => this..config.where = filter;

//   @override
//   Update<E, void> toQuery() =>
//       Update(config.table, set: config.set, where: config.where);
// }
