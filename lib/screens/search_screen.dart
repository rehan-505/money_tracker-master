import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:money_tracker/models/transaction.dart';
import 'package:money_tracker/utils/collection_names.dart';
import 'package:money_tracker/widgets/transaction_card.dart';
import '../controllers/transaction_screen_amount_controller.dart';
import '../utils/global_constants.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();

  // final SearchController searchController = SearchController();
  final TransactionScreenAmountController amountController =
      TransactionScreenAmountController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: searchController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Field is required";
            }
            return null;
          },
          onChanged: (v) {
            setState(() {});
          },
          // controller: searchController,
          decoration: InputDecoration(
            isDense: true,
            // labelText: 'Search Transactions',
            // labelStyle:  TextStyle(color: Colors.white),
            hintText: "Search Transactions",
            hintStyle: TextStyle(color: Colors.white),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(width: 1.5, color: Colors.white),
              borderRadius: BorderRadius.circular(15),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(width: 1.5, color: Colors.white),
              borderRadius: BorderRadius.circular(15),
            ),
            border: OutlineInputBorder(
              borderSide: const BorderSide(width: 1.5, color: Colors.white),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          cursorColor: Colors.white,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection(Collections.transactions)
                    .orderBy("createdAt", descending: true)
                    .snapshots(),
                builder: (context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  amountController.reset();
                  if (snapshot.hasData &&
                      (!(snapshot.connectionState ==
                          ConnectionState.waiting))) {
                    // int count = 0;
                    for (int i = 0; i < snapshot.data!.docs.length; i++) {
                      TransactionModel transaction = TransactionModel.fromMap(
                          snapshot.data!.docs[i].data());
                      if ((transaction.category
                              .toLowerCase()
                              .contains(searchController.text.toLowerCase())) ||
                          (transaction.desc.toLowerCase().contains(
                                  searchController.text.toLowerCase()) ||
                              searchController.text.trim().isEmpty)) {
                        // count++;
                        // print("before transaction $count :");
                        // print("total added cash: ${amountController.totalAddedCash}");
                        // print("total withdraw cash: ${amountController.totalWithdrawCash}");
                        // print("total added card: ${amountController.totalAddedCard}");
                        // print("total withdraw card: ${amountController.totalWithdrawCard}");
                        setAmounts(transaction);
                        // print("after transaction $count :");
                        // print("total added cash: ${amountController.totalAddedCash}");
                        // print("total withdraw cash: ${amountController.totalWithdrawCash}");
                        // print("total added card: ${amountController.totalAddedCard}");
                        // print("total withdraw card: ${amountController.totalWithdrawCard}\n\n");

                        // print("before transaction $count :");
                        // // setAmounts(transaction);
                        // print("after transaction $count :");

                      }
                    }
                  }

                  return Row(
                    children: [
                      Expanded(
                          child: amountContainer(
                        "Total Amount (Cash)",
                        amountController.totalAmountCash.toString(),
                        amountController.totalAddedCash.toString(),
                        amountController.totalWithdrawCash.toString(),
                      )),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                          child: amountContainer(
                        "Total Amount (Card)",
                        amountController.totalAmountCard.toString(),
                        amountController.totalAddedCard.toString(),
                        amountController.totalWithdrawCard.toString(),
                      )),
                    ],
                  );
                }),
            Expanded(
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
                          TransactionModel transaction =
                              TransactionModel.fromMap(
                                  snapshot.data!.docs[index].data());

                          if (transaction.category.toLowerCase().contains(
                                  searchController.text.toLowerCase()) ||
                              (searchController.text.trim().isEmpty) ||
                              transaction.desc.toLowerCase().contains(
                                  searchController.text.toLowerCase())
                          ) {
                            return TransactionCard(
                                transactionModel: transaction);
                          }
                          print("false");
                          return SizedBox();

                          // return Obx(() => Container(
                          //   child: (transaction.category.toLowerCase().contains(searchController.searchText.value.toLowerCase())) || (transaction.desc.toLowerCase().contains(searchController.searchText.value.toLowerCase()) || searchController.searchText.value.trim().isEmpty) ?
                          //   TransactionCard(transactionModel: transaction) : const SizedBox(),
                          // ));
                        });
                  }),
            ),
          ],
        ),
      ),
    );
  }

  void setAmounts(TransactionModel transaction) {
    if (transaction.transactionSign == '+') {
      if (transaction.transactionType == 'cash') {
        amountController.totalAmountCash =
            transaction.amount + amountController.totalAmountCash;
        amountController.totalAddedCash =
            transaction.amount + amountController.totalAddedCash;
      } else {
        amountController.totalAmountCard =
            amountController.totalAmountCard + transaction.amount;
        amountController.totalAddedCard =
            transaction.amount + amountController.totalAddedCard;
      }
    } else if (transaction.transactionSign == '-') {
      if (transaction.transactionType == 'cash') {
        amountController.totalAmountCash =
            amountController.totalAmountCash - transaction.amount;
        amountController.totalWithdrawCash =
            transaction.amount + amountController.totalWithdrawCash;
      } else {
        amountController.totalAmountCard =
            amountController.totalAmountCard - transaction.amount;
        amountController.totalWithdrawCard =
            transaction.amount + amountController.totalWithdrawCard;
      }
    }
  }

  Widget amountContainer(String title, String amount, String totalAdded, String totalWithdrawal) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        elevation: 2,
        child: Container(
          color: Colors.grey.withOpacity(0.2),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  amount,
                  style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Text("Total Added:       "),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            totalAdded,
                            style: const TextStyle(
                                color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const Text("Total Withdrawn:"),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            totalWithdrawal,
                            style: const TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
