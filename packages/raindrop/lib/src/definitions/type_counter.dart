import 'package:raindrop/raindrop.dart';

class TypeCounter {
  final Map<Type, int> _counter = {};

  int call<S extends Schema<S>>() {
    final current = _counter[S] ??= 0;
    return _counter[S] = current + 1;
  }
}
