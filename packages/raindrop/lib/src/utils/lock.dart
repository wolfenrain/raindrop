import 'dart:async';

/// Basic lock that locks execution between [run] calls.
class Lock {
  Future<dynamic> _active = Future.value();

  /// If it returns `true` the lock is currently locked and processing a
  /// previous call to [run].
  bool get isLocked => _isLocked;
  var _isLocked = false;

  /// Call [body] and return it's result once this call is able to acquire the
  /// lock.
  ///
  /// If [isLocked] is `true` then it will wait until the lock is released by
  /// the previous run.
  Future<T> run<T>(Future<T> Function() body) async {
    if (isLocked) await _active;
    _isLocked = true;

    final current = _active = body();
    try {
      return await current;
    } finally {
      _isLocked = false;
    }
  }
}
