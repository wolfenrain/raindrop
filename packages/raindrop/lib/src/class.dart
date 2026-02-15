/// {@template class}
///
/// {@endtemplate}
class Class<C> {
  /// {@macro class}
  const Class();

  /// Test if [C] is the same type as [O].
  bool equals<O>() => C == O;

  /// Test if [C] implements [O].
  ///
  /// If [O] is [dynamic] this will return true, if there are generics on the
  /// class (like a [List]) then you should use [isImplementedBy] on the
  /// reverse contract. Because [C] always implements [O] if [O] is
  /// [dynamic] but [dynamic] never implements [C].
  bool implements<O>() => this is Class<O> && !equals<O>();

  /// Test if [O] implements [C].
  ///
  /// This method will create a new [Class] instance so whenever possible try to
  /// create a constant instance of `Class<O>` and use [implements] with [C].
  bool isImplementedBy<O>() => Class<O>().implements<C>();

  /// Check if the given [C] is nullable.
  static bool isNullable<C>() => null is C;

  /// Check if the given [C] is a list.
  static bool isList<C>() => const Class<List<dynamic>>().isImplementedBy<C>();

  /// Check if the given [C] is a native type.
  ///
  /// Native type are classes a developer cant extend/implement.
  static bool isNative<C>() =>
      C == int || C == double || C == String || C == bool;
}
