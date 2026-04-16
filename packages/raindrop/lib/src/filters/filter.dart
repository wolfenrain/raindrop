/// {@template filter}
/// Base class for any kind of filtering.
/// {@endtemplate}
abstract class Filter {
  /// {@macro filter}
  const Filter();

  /// Provide logical filtering of the AND operation.
  Filter operator &(Filter? right) =>
      right != null ? LogicalFilter(this, right) : this;

  /// Provide logical filtering of the OR operation.
  Filter operator |(Filter? right) =>
      right != null ? LogicalFilter(this, right, or: true) : this;
}

/// {@template logical_filter}
/// Provide logical filtering of AND/OR operations.
/// {@endtemplate}
class LogicalFilter extends Filter {
  /// {@macro logical_filter}
  const LogicalFilter(this.left, this.right, {this.or = false});

  /// The left filter.
  final Filter left;

  /// The right filter.
  final Filter right;

  /// If true it uses OR operations, otherwise AND operations.
  final bool or;
}

extension FilterX on Filter? {
  operator &(Filter? right) {
    final left = this;
    if (left == null) return right;

    return left & right;
  }

  operator |(Filter? right) {
    final left = this;
    if (left == null) return right;

    return left | right;
  }
}
