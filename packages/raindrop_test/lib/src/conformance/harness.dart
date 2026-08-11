import 'dart:async';

import 'package:raindrop/ddl.dart';
import 'package:raindrop/raindrop.dart';
import 'package:raindrop_test/src/conformance/fixtures.dart';

/// {@template driver_test_harness}
/// What a driver provides so `testDriverConformance` can run the shared
/// behavioral suite against it.
///
/// Before every test the suite calls [open], derives the fixture tables
/// from its own schemas and creates them through [createDdlGenerator]'s
/// generator, after every test it calls [close]. Each test therefore sees a
/// fresh pair of tables produced by the driver's own DDL.
/// {@endtemplate}
abstract class DriverTestHarness {
  /// {@macro driver_test_harness}
  const DriverTestHarness();

  /// Whether the database this harness drives is reachable.
  ///
  /// Checked once before the suite runs, if it returns `false`
  /// then every test is skipped instead of failing.
  FutureOr<bool> isAvailable() => true;

  /// Opens a fresh delegate to the database.
  FutureOr<RaindropDelegate> open();

  /// Creates the driver's [DdlGenerator].
  DdlGenerator createDdlGenerator();

  /// Releases whatever [open] acquired.
  FutureOr<void> close(RaindropDelegate delegate);
}

/// {@template returning_support}
/// A driver's RETURNING capability, declared by passing it to
/// `testDriverConformance`.
///
/// Each hook applies the driver's own row-yielding transform to a write on
/// the conformance fixtures:
///
/// ```dart
/// testDriverConformance(
///   MyDriverHarness(),
///   returning: ReturningSupport(
///     insert: (builder) => builder.returning(),
///     update: (builder) => builder.returning(),
///     delete: (builder) => builder.returning(),
///   ),
/// );
/// ```
/// {@endtemplate}
class ReturningSupport {
  /// {@macro returning_support}
  const ReturningSupport({
    required this.insert,
    required this.update,
    required this.delete,
  });

  /// The driver's `returning()` applied to a fixture insert.
  final InsertWithValuesBuilder<Schema<User>, User, User> Function(
    InsertWithValuesBuilder<Schema<User>, User, void> builder,
  ) insert;

  /// The driver's `returning()` applied to a fixture update.
  final UpdateWhereBuilder<Schema<User>, User, User> Function(
    UpdateWhereBuilder<Schema<User>, User, void> builder,
  ) update;

  /// The driver's `returning()` applied to a fixture delete.
  final DeleteWhereBuilder<Schema<User>, User, User> Function(
    DeleteWhereBuilder<Schema<User>, User, void> builder,
  ) delete;
}
