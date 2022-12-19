import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_tracker/models/transaction.dart';

class ChangeLog{
  final String message;
  final Timestamp createdAt;
  final TransactionModel previousTransaction;
  final TransactionModel? updatedTransaction;

  const ChangeLog({
    required this.message,
    required this.createdAt,
    required this.previousTransaction,
    this.updatedTransaction,
  });

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'createdAt': createdAt,
      'previousTransaction': previousTransaction.toMap(),
      'updatedTransaction': updatedTransaction?.toMap(),
    };
  }

  factory ChangeLog.fromMap(Map<String, dynamic> map) {
    return ChangeLog(
      message: map['message'] as String,
      createdAt: map['createdAt'] as Timestamp,
      previousTransaction: TransactionModel.fromMap(map['previousTransaction']),
      updatedTransaction: (map['updatedTransaction']!=null) ? TransactionModel.fromMap(map['updatedTransaction']) : null,
    );
  }
}
