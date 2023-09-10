import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_tracker/models/transaction.dart';
import 'package:money_tracker/utils/collection_names.dart';
import 'package:money_tracker/widgets/transaction_card.dart';
import '../utils/global_constants.dart';


class UserTransactions extends StatefulWidget {
  const UserTransactions({Key? key, required this.appUser}) : super(key: key);

  final AppUser appUser;

  @override
  State<UserTransactions> createState() => _UserTransactionsState();
}

class _UserTransactionsState extends State<UserTransactions> {
  DateTime? selectedStartDate;

  DateTime? selectedEndDate;

  final TextEditingController startTimeController = TextEditingController();

  final TextEditingController endTimeController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appUser.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Form(
              key: formKey,
              child: Row(
                children: [
                  Expanded(
                      child: TextFormField(
                        controller: startTimeController,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2025));
                          print('pickedDate: ${pickedDate}');
                          if (pickedDate != null && pickedDate != selectedStartDate) {
                            selectedStartDate = pickedDate;
                            startTimeController.text =
                                DateFormat("dd-MM-yyyy")
                                    .format(selectedStartDate!)
                                    .toString();
                            // setState(() {});
                          }
                        },

                        validator: (value) {
                          if (selectedStartDate == null) {
                            return "field is required";
                          }
                          return null;
                        },

                        decoration: const InputDecoration(
                            labelText: "Start Date",
                            hintText: "Start Date",
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(),
                            disabledBorder: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(),
                            isDense: true),
                        maxLines: 1,
                        readOnly: true,
                        // enabled: false,
                      )),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      child: TextFormField(
                        controller: endTimeController,
                        onTap: () async {
                          DateTime? pickedDate  = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2025));
                          if (pickedDate != null && pickedDate != selectedEndDate) {
                            selectedEndDate = pickedDate;
                            endTimeController.text =
                                DateFormat("dd-MM-yyyy")
                                    .format(selectedEndDate!)
                                    .toString();
                            // setState(() {});
                          }
                        },

                        validator: (value) {
                          if (selectedEndDate == null) {
                            return "field is required";
                          }
                          return null;
                        },

                        decoration: const InputDecoration(
                            labelText: "End Date",
                            hintText: "End Date",
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(),
                            disabledBorder: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(),
                            isDense: true),
                        maxLines: 1,
                        readOnly: true,
                        // enabled: false,
                      ))
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                    child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            setState(() {});

                          }
                          },
                        child: const Text("Apply"))),
                const SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: ElevatedButton(
                      onPressed: () {
                        selectedEndDate = null;
                        selectedStartDate = null;
                        startTimeController.text = '';
                        endTimeController.text = '';
                        setState(() {});
                      },
                      child: const Text("Reset")),
                )
              ],
            ),
            Expanded(child:
            (selectedStartDate==null || selectedEndDate==null) ?
            const Center(
              child: Text("Please select start and end date"),
            ) :
            FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection(Collections.transactions)
                    .where("createdAt",
                    isGreaterThanOrEqualTo: selectedStartDate ?? DateTime(2000),
                    isLessThanOrEqualTo: selectedEndDate?.add(const Duration(days: 1)) ?? DateTime.now()).
                where('createdBy.id',isEqualTo: widget.appUser.id)
                    .orderBy("createdAt", descending: true)
                    .get(),
                builder: (context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                    snapshot) {


                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.data?.docs.isEmpty ?? true) {
                    return const Center(
                      child: Text("No Transactions to show"),
                    );
                  }


                  return Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Text('Total Transactions: ${snapshot.data!.size}',
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                        ),),
                      const SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: ListView.builder(
                            itemCount: isAdmin ? snapshot.data!.size : 10,
                            itemBuilder: (context, index) {

                              TransactionModel transaction = TransactionModel.fromMap(
                                  snapshot.data!.docs[index].data());
                              if(transaction.createdBy.id!=widget.appUser.id){
                                return const SizedBox();
                              }


                              return TransactionCard(transactionModel: transaction);

                            }

                        ),
                      ),
                    ],
                  );
                }),
            )
          ],
        ),
      ),
    );
  }
}
