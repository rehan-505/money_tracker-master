import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker/models/changelog.dart';
import 'package:money_tracker/models/transaction.dart';


class DeletedTransactionWidget extends StatelessWidget {
  const DeletedTransactionWidget({Key? key, required this.previousTransaction, required this.changeLog, }) : super(key: key);

  final TransactionModel previousTransaction;
  final ChangeLog changeLog;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Material(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(DateFormat.yMMMEd().add_jms().format(DateTime.fromMillisecondsSinceEpoch(changeLog.createdAt.millisecondsSinceEpoch))),
              const SizedBox(height: 7,),
              Text(changeLog.message, style: const TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),),
              const SizedBox(height: 7,),
              const Text("Deleted Transaction: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold ) ,),
              const SizedBox(height: 7,),
              Container(
                margin: const EdgeInsets.only(left: 16, right: 16,),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(previousTransaction.transactionType.capitalizeFirst!,style: const TextStyle(fontSize: 16, )),
                    // const SizedBox(height: 5,),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:  [
                        Text("${previousTransaction.createdBy.name.capitalizeFirst!} has ${ (previousTransaction.transactionSign == '+') ? "added" : "withdrawn"} ${previousTransaction.amount.toInt()}", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 18),),
                        Flexible(child: Text("${previousTransaction.transactionSign} ${previousTransaction.amount.toInt()}", style: TextStyle(color: previousTransaction.transactionSign=="+" ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 22), )),
                      ],
                    ),
                    const SizedBox(height: 5,),
                    Text("Category : ${previousTransaction.category}",),
                    const SizedBox(height: 5,),
                    Text("Note : ${previousTransaction.desc}")

                  ],
                ),
              ),
              SizedBox(height: 15,),


            ],
          ),
        ),
      ),
    );
  }
}
