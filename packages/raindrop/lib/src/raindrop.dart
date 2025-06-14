import 'dart:async';

import 'package:raindrop/raindrop.dart';
import 'package:raindrop/src/lock.dart';

part 'raindrop_executor.dart';

/// {@template raindrop}
/// The database class of Raindrop.
///
/// It encapsulates the [RaindropDelegate] in such a way that end-users can
/// change their underlying implementation.
/// {@endtemplate}
class Raindrop extends RaindropExecutor<RaindropDelegate> {
  /// {@macro raindrop}
  Raindrop(super.delegate, {super.logger = const NoopLogger()});

  /// Ensure the database is open.
  Future<void> ensureOpen() {
    return Raindrop.tracer.trace(
      'Raindrop.ensureOpen',
      (_) => _lock.run(delegate.ensureOpen),
    );
  }

  @override
  Future<DatabaseResult> execute(
    String query, [
    List<Object?> values = const [],
  ]) async {
    await ensureOpen();
    return tracer.trace('Raindrop.execute', (span) {
      span?.attributes.addAll({'query': query, 'values': values});
      return super.execute(query, values);
    });
  }

  /// Close the Raindrop database.
  Future<void> close() => _lock.run(delegate.close);

  /// The default tracer used by [Raindrop].
  ///
  /// It is by turned off by default.
  static final tracer = Tracer('raindrop', isTracing: false);
}
