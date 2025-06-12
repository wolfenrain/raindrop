part of 'delegates.dart';

/// {@template transaction_delegate}
/// Delegate used within transactional environments.
///
/// It can [rollback] any changes that has happened within the context of this
/// delegate.
/// {@endtemplate}
abstract class TransactionDelegate extends Delegate {
  /// {@macro transaction_delegate}
  const TransactionDelegate(super.dialect, [this.depth = 0]);

  /// The depth of the transaction.
  ///
  /// Each SQL delegate is required to handle incrementing this
  /// themselves.
  final int depth;

  /// Roll back the transaction.
  Future<void> rollback();
}

/// {@template transaction_rollback}
/// An exception that can be thrown to trigger a transaction rollback.
///
/// Most SQL delegate will do a rollback on error thrown and this can be used
/// on [TransactionDelegate.rollback] implementations to facilitate that.
/// {@endtemplate}
class TransactionRollback implements Exception {
  /// {@macro transaction_rollback}
  const TransactionRollback();
}
