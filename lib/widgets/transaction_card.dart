import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker/models/transaction.dart';
import 'package:money_tracker/screens/edit_transaction.dart';
import 'package:money_tracker/utils/collection_names.dart';
import 'package:money_tracker/utils/db_operations.dart';
import 'package:uuid/uuid.dart';

import '../models/changelog.dart';
import '../utils/global_constants.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard({Key? key, required this.transactionModel}) : super(key: key);
  final TransactionModel transactionModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Material(
        elevation: 2,
        child: Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(DateFormat.yMMMEd().add_jms().format(DateTime.fromMillisecondsSinceEpoch(transactionModel.createdAt.millisecondsSinceEpoch))),
              const SizedBox(height: 5,),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:  [
                  Text("${transactionModel.createdBy.name.capitalizeFirst!} has ${ (transactionModel.transactionSign == '+') ? "added" : "withdrawn"} ${transactionModel.amount}", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 16),),
                  // const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(transactionModel.transactionType.capitalizeFirst!,style: const TextStyle(fontSize: 16, )),
                      const SizedBox(width: 10,),
                      Flexible(child: Text("${transactionModel.transactionSign} ${transactionModel.amount}", style: TextStyle(color: transactionModel.transactionSign=="+" ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 20),)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 5,),
              Text("Category : ${transactionModel.category}",),
              const SizedBox(height: 5,),
              Row(
                mainAxisSize: MainAxisSize.max,
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Note : ${transactionModel.desc}"),
                  const Spacer(),
                  isAdmin ? Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: InkWell(
                        onTap: () async{
                          Get.to(EditTransactionScreen(transactionModel: transactionModel));
                        },
                        child: const Icon(Icons.edit, color: Colors.blue,)),
                  ) : const SizedBox(),
                  isAdmin ? InkWell(
                      onTap: () async{
                        await showDialog(
                            context: context,
                            barrierColor: Colors.transparent,
                            builder: (BuildContext ctx) {
                              return                       BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                                child: AlertDialog(
                                  elevation: 10,
                                  content: const Text('Are You Sure You Want To Delete This Transaction ?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                          await FirebaseFirestore.instance.collection(Collections.transactions).doc(transactionModel.id).delete();

                                          if(transactionModel.transactionSign=='+'){
                                            await DBOperations.subtractCash(transactionModel.transactionType, transactionModel.amount);
                                          }
                                          else{
                                            await DBOperations.addCash(transactionModel.transactionType, transactionModel.amount);
                                          }

                                          String username = (await DBOperations.getCurrentUser())!.name;

                                          sendChangeNotification(username);
                                          await FirebaseFirestore.instance.collection("changeLogs").doc(Uuid().v4()).set(ChangeLog(message: "$username deleted a transaction", createdAt: Timestamp.now(), previousTransaction: transactionModel).toMap());

                                          Get.snackbar("Success", "Transaction Deleted", backgroundColor: Colors.white);
                                        },
                                        child: const Text(
                                          'Yes',
                                          style: TextStyle(color: Colors.brown),
                                        )),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child:
                                        const Text('No', style: TextStyle(color: Colors.brown)))
                                  ],
                                ),
                              );
                            });
                      },
                      child: const Icon(Icons.delete_forever_sharp, color: Colors.red,)) : const SizedBox()
                ],
              ),
              // Divider(),

            ],
          ),
        ),
      ),
    );
  }

  sendChangeNotification(String username)async{
    try{
      DocumentSnapshot<Map<String,dynamic>> documentSnapshot = await FirebaseFirestore.instance
          .collection(Collections.users).doc(adminId).get();
      Map map = documentSnapshot.data()!;
      await DBOperations.sendNotification(
          registrationIds: map['fcmTokens'], text: "$username deleted a transaction of ${transactionModel.amount} and ${transactionModel.category} category. See Logs for details.", title: "Transaction Deleted");
    }
    catch(e){
      print(e);
      // rethrow;
    }
  }

}

