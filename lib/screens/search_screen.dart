import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:money_tracker/models/transaction.dart';
import 'package:money_tracker/utils/collection_names.dart';
import 'package:money_tracker/widgets/transaction_card.dart';
import '../controllers/transaction_screen_amount_controller.dart';
import '../utils/global_constants.dart';
import '../utils/global_functions.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

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
            FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection(Collections.transactions)
                    .orderBy("createdAt", descending: true)
                    .get(),
                builder: (context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  amountController.reset();
                  if (snapshot.hasData &&
                      (!(snapshot.connectionState ==
                          ConnectionState.waiting))) {

                    for (int i = 0; i < snapshot.data!.docs.length; i++) {
                      TransactionModel transaction = TransactionModel.fromMap(
                          snapshot.data!.docs[i].data());
                      if ((transaction.category
                              .toLowerCase()
                              .contains(searchController.text.toLowerCase())) ||

                          (transaction.desc.toLowerCase().contains(
                                  searchController.text.toLowerCase()) ||
                              searchController.text.trim().isEmpty)

                      ||
                          ( transaction.amount.toString().contains(searchController.text)  )

                      ) {
                        setAmounts(transaction);
                      }
                    }
                  }

                  return Row(
                    children: [
                      Expanded(
                          child: amountContainer(
                            "Cash",
                            amountController.totalAmountCash,
                            amountController.totalAddedCash,
                            amountController.totalWithdrawCash
                            ,
                          )),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                          child: amountContainer(
                            "Card",
                            amountController.totalAmountCard,
                            amountController.totalAddedCard,
                            amountController.totalWithdrawCard
                            ,
                          )),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                          child: amountContainer(
                            "Bank",
                            amountController.totalAmountBank,
                            amountController.totalAddedBank,
                            amountController.totalWithdrawBank
                            ,
                          ))
                    ],
                  );
                }),
            const SizedBox(height: 20,),
            Expanded(
              child: FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection(Collections.transactions)
                      .orderBy("createdAt", descending: true)
                      .get(),
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
                          || ( transaction.amount.toString().contains(searchController.text)  )
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
        amountController.totalAmountCash = transaction.amount + amountController.totalAmountCash;
        amountController.totalAddedCash = transaction.amount + amountController.totalAddedCash;
      }
      else if (transaction.transactionType=='bank'){
        amountController.totalAmountBank = amountController.totalAmountBank + transaction.amount;
        amountController.totalAddedBank = transaction.amount + amountController.totalAddedBank;
      }

      else {
        amountController.totalAmountCard = amountController.totalAmountCard + transaction.amount;
        amountController.totalAddedCard = transaction.amount + amountController.totalAddedCard;
      }
    } else if (transaction.transactionSign == '-') {
      if (transaction.transactionType == 'cash') {
        amountController.totalAmountCash = amountController.totalAmountCash - transaction.amount;
        amountController.totalWithdrawCash = transaction.amount + amountController.totalWithdrawCash;
      }
      else if (transaction.transactionType=='bank'){
        amountController.totalAmountBank = amountController.totalAmountBank - transaction.amount;
        amountController.totalWithdrawBank = transaction.amount + amountController.totalWithdrawBank;
      }


      else {
        amountController.totalAmountCard = amountController.totalAmountCard - transaction.amount;
        amountController.totalWithdrawCard = transaction.amount + amountController.totalWithdrawCard;
      }
    }
  }

}
