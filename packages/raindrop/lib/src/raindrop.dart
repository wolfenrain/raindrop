import 'dart:async';

import 'package:raindrop/raindrop.dart';

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

  /// Perform a transaction on the database.
  Future<T> transaction<T>(
    Future<T> Function(TransactionDelegate delegate) transaction,
  );
}

/// {@template raindrop}
/// The database class of Raindrop.
///
/// It encapsulates the [RaindropDelegate] in such a way that end-users can
/// change their underlying implementation.
/// {@endtemplate}
class Raindrop extends RaindropExecutor<RaindropDelegate> {
  /// {@macro raindrop}
  const Raindrop(super.delegate);

  /// Ensure the database is open.
  Future<void> ensureOpen() {
    return Raindrop.tracer.trace(
      'Raindrop.ensureOpen',
      (_) => delegate.ensureOpen(),
    );
  }

  @override
  Future<List<Map<String, dynamic>>> execute(
    String query, [
    List<Object?> values = const [],
  ]) async {
    await ensureOpen();
    return tracer.trace('Raindrop.execute', (span) {
      span?.attributes.addAll({'query': query, 'values': values});
      return delegate.execute(query, values);
    });
  }

  /// Perform a transaction on the database.
  Future<T> transaction<T>(
    Future<T> Function(RaindropExecutor<TransactionDelegate> tx) transaction,
  ) {
    return delegate.transaction((tx) => transaction(RaindropExecutor(tx)));
  }

  /// Close the Raindrop database.
  Future<void> close() => delegate.close();

  /// The default tracer used by [Raindrop].
  ///
  /// It is by turned off by default.
  static final tracer = Tracer('raindrop', isTracing: false);
}
