part of 'delegates.dart';

/// {@template raindrop_delegate}
/// Base class for providing delegation between a [RaindropExecutor] and the
/// SQL database.
/// {@endtemplate}
abstract class RaindropDelegate extends Delegate {
  /// {@macro raindrop_delegate}
  RaindropDelegate({required SqlDialect dialect}) : super(dialect);

  Completer<void>? _opener;

  /// Returns true if this delegate is open.
  bool get isOpen => _opener?.isCompleted ?? false;

  /// Ensure that the delegate is opened.
  Future<void> ensureOpen() async {
    return Raindrop.tracer.trace('$runtimeType.ensureOpen', (_) {
      if (_opener == null) {
        _opener = Completer();
        onOpen().then(_opener!.complete).ignore();
      }
      return _opener!.future;
    });
  }

  /// Called after opening to perform extra actions.
  Future<void> onOpen();

  /// Close the delegate's connection.
  Future<void> close() async {
    if (_opener == null) return;
    _opener = null;
    return onClose();
  }

  /// Called after closing to perform extra actions.
  Future<void> onClose();
}
