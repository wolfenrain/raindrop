import 'package:raindrop/raindrop.dart';

/// {@template transaction_delegate}
/// Delegate used within transactional environments.
///
/// It can [rollback] any changes that has happened within the context of this
/// delegate.
/// {@endtemplate}
abstract class TransactionDelegate extends Delegate {
  /// {@macro transaction_delegate}
  const TransactionDelegate(super.dialect);

  /// Roll back the transaction.
  Future<void> rollback();
}
