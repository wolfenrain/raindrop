import 'dart:async';

/// {@template tracer}
/// Root class that provides the start of a trace tree.
/// {@endtemplate}
class Tracer extends Span {
  /// {@macro tracer}
  Tracer(
    super.name, {
    this.isTracing = true,
  });

  @override
  void ended(Span child) {
    _end = _end?.isBefore(child._end!) ?? true ? child._end : _end!;
    return super.ended(child);
  }

  /// Indicates if tracing is enabled, defaults to true.
  @override
  bool isTracing;
}

/// {@template span}
/// Describes a single traced span from start to end.
///
/// It will automatically start and close spans via to the [trace] method.
/// {@endtemplate}
class Span {
  /// {@macro span}
  Span(this.name, [this.parent])
      : _start = DateTime.now(),
        attributes = {},
        _children = [];

  /// The name of the span.
  final String name;

  /// The parent of this span, if any.
  final Span? parent;

  /// Returns true if tracing is enabled.
  bool get isTracing => parent?.isTracing ?? false;

  /// Returns true if tracing is not enabled.
  bool get isNotTracing => !isTracing;

  /// The attributes associated with this span.
  final Map<String, dynamic> attributes;

  /// The children spans that have completed.
  Iterable<Span> get children => _children.where((e) => e.hasEnded);
  final List<Span> _children;

  /// The current active span child.
  Span? get active => Zone.current[Span] as Span?;

  /// The duration of this span.
  ///
  /// Returns null if it has not yet ended.
  Duration? get duration => _end?.difference(_start);

  /// Returns true if this span has ended.
  bool get hasEnded => _end != null;

  final DateTime _start;
  DateTime? _end;

  /// Start a new trace with the [name] on the [callback].
  ///
  /// Both synchronous and asynchronous [callback]s are supported.
  ///
  /// If tracing is disabled it immediately calls [callback] and returns it.
  T trace<T>(String name, T Function(Span? span) callback) {
    if (isNotTracing) return callback(null);

    final span = Span(name, active ?? this);
    var synchronous = true;

    try {
      final value = runZoned(() => callback(span), zoneValues: {Span: span});
      if (value is Future) {
        synchronous = false;
        return (value..then((_) => span.end(), onError: span.fail)) as T;
      }
      return value;
    } catch (err, stackTrace) {
      if (synchronous) span.fail(err, stackTrace);
      rethrow;
    } finally {
      if (synchronous) span.end();
    }
  }

  /// Called when the span finished.
  void end() {
    _end = DateTime.now();
    return parent?.ended(this);
  }

  /// Called when the span failed with the given [err] and the [stackTrace].
  void fail(Object? err, StackTrace stackTrace) {
    // TODO(wolfen): store err and stack trace.
    _end = DateTime.now();
    return parent?.ended(this);
  }

  /// Called internally when a child span ends.
  void ended(Span child) {
    // if (_activeSpan == child) _activeSpan = null;
    _children.add(child);
  }

  /// Dump the span and it's children as JSON.
  ///
  /// Note: this will reset the span.
  Map<String, dynamic> dump() {
    final data = <String, dynamic>{
      'name': name,
      if (duration != null) 'time': '${duration!.inMilliseconds}ms',
      if (attributes.isNotEmpty) 'attributes': {...attributes},
    };

    final spans = children.map((e) => e.dump()).toList();
    if (spans.isNotEmpty) data['children'] = spans;

    _end = null;
    attributes.clear();
    _children.clear();

    return data;
  }
}
