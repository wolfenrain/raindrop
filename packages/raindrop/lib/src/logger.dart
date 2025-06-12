import 'dart:convert';
import 'dart:developer';

/// {@template logger}
/// Provides logging capabilities inside Raindrop.
/// {@endtemplate}
abstract interface class Logger {
  /// {@macro logger}
  const Logger();

  /// Log a [query] statement and it's [values].
  void query(String query, List<Object?> values);
}

/// {@template developer_logger}
/// A [Logger] implementation that uses the [log] function from dart:developer
/// to log info.
/// {@endtemplate}
class DeveloperLogger implements Logger {
  /// {@macro developer_logger}
  const DeveloperLogger();

  @override
  void query(String query, List<Object?> values) {
    return log(
      '$query${values.isNotEmpty ? ' -- [${values.map(json.tryEncode).join(', ')}]' : ''}',
      name: 'raindrop',
    );
  }
}

/// {@template noop_logger}
/// A [Logger] implementation that has empty implementation for logging.
/// {@endtemplate}
class NoopLogger implements Logger {
  /// {@macro noop_logger}
  const NoopLogger();

  @override
  void query(String query, List<Object?> values) {}
}

extension on JsonCodec {
  dynamic tryEncode(Object? i) {
    try {
      return encode(i);
    } catch (err) {
      return i.toString();
    }
  }
}
