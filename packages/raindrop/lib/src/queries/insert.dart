// import 'package:raindrop/raindrop.dart';

// class Insert<E extends Entity<E>, V> extends Query<E, V> {
//   const Insert(
//     super.table, {
//     required this.values,
//   });

//   Insert.one(
//     super.table, {
//     required E value,
//   }) : values = [value];

//   final List<E> values;
// }

// class InsertConfig<E extends Entity<E>, V> extends QueryConfig<E>
//     implements Insert<E, V> {
//   InsertConfig(
//     super.executor,
//     super.table, {
//     this.values = const [],
//   });

//   @override
//   List<E> values;
// }

// class InsertBuilder<E extends Entity<E>, C extends InsertConfig<E, V>, V>
//     extends QueryBuilder<Insert<E, V>, C, E, V> {
//   InsertBuilder({required super.config});

//   InsertBuilder<E, C, V> value(E value) => values([value]);

//   InsertBuilder<E, C, V> values(List<E> values) => this..config.values =
// values;

//   @override
//   Insert<E, V> toQuery() => Insert(config.table, values: config.values);
// }
