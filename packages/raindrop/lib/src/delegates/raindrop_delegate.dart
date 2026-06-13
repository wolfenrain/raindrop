part of 'delegates.dart';

/// {@template raindrop_delegate}
/// Base class for providing delegation between a [RaindropExecutor] and the
/// SQL database.
/// {@endtemplate}
abstract class RaindropDelegate extends Delegate {
  /// {@macro raindrop_delegate}
  RaindropDelegate({required SqlDialect dialect}) : super(dialect);
}
