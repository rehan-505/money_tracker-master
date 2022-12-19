import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_tracker/models/transaction.dart';
import 'package:money_tracker/models/user.dart';
import 'package:money_tracker/screens/add_user_screen.dart';
import 'package:money_tracker/widgets/change_log_widget.dart';
import 'package:money_tracker/widgets/deleted_transaction_widget.dart';
import 'package:money_tracker/widgets/user_tile.dart';

import '../models/changelog.dart';
import '../utils/collection_names.dart';

class ChangeLogScreen extends StatelessWidget {
  const ChangeLogScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Change Logs"),),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('changeLogs').orderBy("createdAt", descending: true)
              .snapshots(),
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
              snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: Text("No change logs to show"),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Text("Loading"),
              );
            }

            if (snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text("No data to show"),
              );
            }

            // List<QueryDocumentSnapshot> documents = snapshot.data!.docs.sort()

            return ListView.builder(
                itemCount:  snapshot.data!.size,
                itemBuilder: (context, index) {
                  ChangeLog chageLog = ChangeLog.fromMap(snapshot.data!.docs[index].data());
                  if(chageLog.updatedTransaction!=null) {
                    return ChangeLogWidget(
                      newTransaction: chageLog.updatedTransaction!,
                      previousTransaction: chageLog.previousTransaction,
                      changeLog: chageLog,
                    );
                  }

                  return DeletedTransactionWidget(previousTransaction: chageLog.previousTransaction, changeLog: chageLog);
                });
          }),
    );
  }
}
