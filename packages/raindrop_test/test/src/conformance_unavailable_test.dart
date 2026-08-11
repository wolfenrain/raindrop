import 'package:raindrop/ddl.dart';
import 'package:raindrop/raindrop.dart';
import 'package:raindrop_test/conformance.dart';

void main() {
  testDriverConformance(_UnavailableHarness());
}

class _UnavailableHarness extends DriverTestHarness {
  @override
  bool isAvailable() => false;

  @override
  RaindropDelegate open() => throw UnsupportedError('unreachable');

  @override
  DdlGenerator createDdlGenerator() => throw UnsupportedError('unreachable');

  @override
  void close(RaindropDelegate delegate) =>
      throw UnsupportedError('unreachable');
}
