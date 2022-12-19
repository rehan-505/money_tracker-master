import 'package:flutter/material.dart';
import 'package:money_tracker/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_tracker/models/transaction.dart';
import 'package:money_tracker/utils/collection_names.dart';
import 'package:money_tracker/widgets/transaction_card.dart';
import '../utils/global_constants.dart';


class UserTransactions extends StatelessWidget {
  const UserTransactions({Key? key, required this.appUser}) : super(key: key);

  final AppUser appUser;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appUser.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(Collections.transactions)
                .orderBy("createdAt", descending: true)
                .snapshots(),
            builder: (context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: Text("No Transactions to show"),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Text("Loading Transactions"),
                );
              }

              if (snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text("No Transactions to show"),
                );
              }


              return ListView.builder(
                  itemCount: isAdmin ? snapshot.data!.size : 10,
                  itemBuilder: (context, index) {

                    TransactionModel transaction = TransactionModel.fromMap(
                        snapshot.data!.docs[index].data());
                    if(transaction.createdBy.id!=appUser.id){
                      return SizedBox();
                    }

                    return TransactionCard(transactionModel: transaction);

                  }

              );
            }),
      ),
    );
  }

  // void setAmounts(TransactionModel transaction) {
  //   if (transaction.transactionSign == '+') {
  //     if (transaction.transactionType == 'cash') {
  //       amountController.totalAmountCash =
  //           transaction.amount + amountController.totalAmountCash;
  //       amountController.totalAddedCash =
  //           transaction.amount + amountController.totalAddedCash;
  //     } else {
  //       amountController.totalAmountCard =
  //           amountController.totalAmountCard + transaction.amount;
  //       amountController.totalAddedCard =
  //           transaction.amount + amountController.totalAddedCard;
  //     }
  //   } else if (transaction.transactionSign == '-') {
  //     if (transaction.transactionType == 'cash') {
  //       amountController.totalAmountCash =
  //           amountController.totalAmountCash - transaction.amount;
  //       amountController.totalWithdrawCash =
  //           transaction.amount + amountController.totalWithdrawCash;
  //     } else {
  //       amountController.totalAmountCard =
  //           amountController.totalAmountCard - transaction.amount;
  //       amountController.totalWithdrawCard =
  //           transaction.amount + amountController.totalWithdrawCard;
  //     }
  //   }
  // }
  //
  // Widget amountContainer(String title, String amount, String totalAdded, String totalWithdrawal) {
  //   return SizedBox(
  //     width: double.infinity,
  //     child: Material(
  //       elevation: 2,
  //       child: Container(
  //         color: Colors.grey.withOpacity(0.2),
  //         child: Padding(
  //           padding: const EdgeInsets.symmetric(vertical: 12.0),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             children: [
  //               Text(title,
  //                   style: const TextStyle(
  //                       color: Colors.black,
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.bold)),
  //               // const SizedBox(
  //               //   height: 20,
  //               // ),
  //               // Text(
  //               //   amount,
  //               //   style: const TextStyle(
  //               //       color: Colors.blue,
  //               //       fontSize: 18,
  //               //       fontWeight: FontWeight.bold),
  //               // ),
  //               const SizedBox(
  //                 height: 20,
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.only(left: 8.0),
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     Row(
  //                       children: [
  //                         const Text("Total Added:       "),
  //                         const SizedBox(
  //                           width: 10,
  //                         ),
  //                         Text(
  //                           totalAdded,
  //                           style: const TextStyle(
  //                               color: Colors.green, fontWeight: FontWeight.bold),
  //                         ),
  //                       ],
  //                     ),
  //                     const SizedBox(
  //                       height: 5,
  //                     ),
  //                     Row(
  //                       children: [
  //                         const Text("Total Withdrawn:"),
  //                         const SizedBox(
  //                           width: 10,
  //                         ),
  //                         Text(
  //                           totalWithdrawal,
  //                           style: const TextStyle(
  //                               color: Colors.red, fontWeight: FontWeight.bold),
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

}
