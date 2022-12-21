// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
//
// import '../models/transaction.dart';
// import '../utils/collection_names.dart';
// import '../widgets/transaction_card.dart';
//
// class SpecificSignedTransactionsScreen extends StatelessWidget {
//   const SpecificSignedTransactionsScreen({Key? key, required this.transactionSign}) : super(key: key);
//
//   final String transactionSign;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(transactionSign=='+' ? "Added Transactions" : "Withdrew Transactions" ),
//       ),
//       body: FutureBuilder(
//           future: FirebaseFirestore.instance
//               .collection(Collections.transactions)
//           .where('transactionSign', isEqualTo: transactionSign)
//               .orderBy("createdAt", descending: true)
//               .get(),
//           builder: (context,
//
//               AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
//               snapshot) {
//             if (!snapshot.hasData) {
//               return const Center(
//                 child: Text("No Transactions to show"),
//               );
//             }
//
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(
//                 child: Text("Loading Transactions"),
//               );
//             }
//
//             if (snapshot.data!.docs.isEmpty) {
//               return const Center(
//                 child: Text("No Transactions to show"),
//               );
//             }
//
//             return ListView.builder(
//                 itemCount: snapshot.data!.size ,
//                 itemBuilder: (context, index) {
//                   TransactionModel transaction =
//                   TransactionModel.fromMap(
//                       snapshot.data!.docs[index].data());
//
//                   return TransactionCard(
//                       transactionModel: transaction);
//
//
//                   // return Obx(() => Container(
//                   //   child: (transaction.category.toLowerCase().contains(searchController.searchText.value.toLowerCase())) || (transaction.desc.toLowerCase().contains(searchController.searchText.value.toLowerCase()) || searchController.searchText.value.trim().isEmpty) ?
//                   //   TransactionCard(transactionModel: transaction) : const SizedBox(),
//                   // ));
//                 });
//           }),
//     );
//   }
// }
