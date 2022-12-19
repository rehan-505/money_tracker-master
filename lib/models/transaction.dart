import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_tracker/models/user.dart';

class TransactionModel{
  final Timestamp createdAt;
  final String category;
  final String desc;
  final String transactionType;
  final String transactionSign;
  final AppUser createdBy;
  final double amount;
  final String id;

  const TransactionModel({
    required this.createdAt,
    required this.category,
    required this.desc,
    required this.transactionType,
    required this.transactionSign,
    required this.createdBy,
    required this.amount,
    required this.id
  });

  Map<String, dynamic> toMap() {
    return {
      'createdAt': createdAt,
      'category': category,
      'desc': desc,
      'transactionType': transactionType,
      'transactionSign': transactionSign,
      'createdBy': createdBy.toMap(),
      'amount': amount,
      'id': id
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      createdAt: map['createdAt'] as Timestamp,
      category: map['category'] as String,
      desc: map['desc'] as String,
      transactionType: map['transactionType'] as String,
      transactionSign: map['transactionSign'] as String,
      createdBy: AppUser.fromMap(map['createdBy']),
      amount: map['amount'] as double,
      id: map['id']
    );
  }
}

// enum TransactionType{
//   cash,
//   card
// }

