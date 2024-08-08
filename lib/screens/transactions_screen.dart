import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker/controllers/transaction_controller.dart';
import 'package:money_tracker/models/transaction.dart';
import 'package:money_tracker/screens/search_screen.dart';
import 'package:money_tracker/utils/collection_names.dart';
import 'package:money_tracker/widgets/transaction_card.dart';
import '../models/category.dart';
import '../utils/global_functions.dart';
import '../widgets/dropdown_button.dart';

class TransactionsScreen extends StatelessWidget {
  TransactionsScreen({Key? key}) : super(key: key);

  final TransactionController transactionController = Get.put(TransactionController());

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(Collections.transactions)
        .where('createdAt', isGreaterThan: DateTime.now().subtract(const Duration(days: 365)))
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          debugPrint('transactions upper stream builder: ${snapshot.connectionState}');
          if (snapshot.connectionState == ConnectionState.waiting || !(snapshot.hasData)) {
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: const Text('Kitaab'),
              ),
              body:  Center(
                child: snapshot.hasError ? const Text('Something went wrong') : const CircularProgressIndicator(),
              ),
            );
          }

          debugPrint('transactions snapshot length: ${snapshot.data?.docs.length}');

         transactionController.allTransactions.value = (snapshot.data?.docs ?? [])
              .map((e) => TransactionModel.fromMap(e.data()))
              .toList();
          transactionController.filterList();
          debugPrint('total transactions before filtering: ${transactionController.allTransactions.length}');

          return const TransactionBodyScreen();
        });
  }
}


class TransactionBodyScreen extends StatefulWidget {
  const TransactionBodyScreen({Key? key,}) : super(key: key);

  @override
  State<TransactionBodyScreen> createState() => _TransactionBodyScreenState();
}

class _TransactionBodyScreenState extends State<TransactionBodyScreen> {

  final TransactionController transactionController = Get.find();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Kitaab"), centerTitle: true, actions: [
        InkWell(
          onTap: () {
            Get.to(SearchScreen(transactions: transactionController.allTransactions,));
          },
          child: const Icon(
            Icons.search,
            color: Colors.white,
          ),
        ),
        const SizedBox(
          width: 20,
        )
      ]),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: transactionController.formKey,
          child: _buildTransactionsList(transactionController.filteredTransactions),
        ),
      ),
    );
  }

  Widget _buildTransactionsList(List<TransactionModel> transactionsList){

    debugPrint('total transactions after filtering: ${transactionsList.length}');

    if(transactionsList.isEmpty) {
      return ListView(
        children: [
          _buildUpperArea(),
          const SizedBox(height: 10,),
          const Center(child: Text('No transactions found')),
          const SizedBox(height: 10,),
        ],
      );
    }

    return ListView.builder(
        itemCount: (transactionsList.length) + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildUpperArea();
          }

          TransactionModel transaction = transactionsList[index - 1];
          return TransactionCard(
            transactionModel: transaction,
          );
        });
  }

  Widget buttonsRow() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
                child: ElevatedButton(
                    onPressed: () {
                      transactionController.filterList();
                      transactionController.collapse.value = true;
                      setState(() {});
                    },
                    child: const Text("Apply"))),
            const SizedBox(
              width: 15,
            ),
            Expanded(
              child: ElevatedButton(
                  onPressed: () {
                    transactionController.resetFilters();
                    setState(() {});
                  },
                  child: const Text("Reset")),
            )
          ],
        ),
        // const SizedBox(height: 10,),
        ///Users and Transaction Button
      ],
    );
  }

  Widget _buildOnlyAmountSearchCheckbox(){
    return Row(
      children: [
        Obx(() => Checkbox(
            value: transactionController.searchByAmount.value,
            onChanged: (value) {
              transactionController.searchByAmount.value = value ?? false;
            })),
        const Text("Search by amount", style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
      ],
    );
  }

  Widget _buildUpperArea() {

    // return SizedBox();

    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        Obx(() => InkWell(
              onTap: () {
                transactionController.collapse.value =
                    !transactionController.collapse.value;
              },
              child: Row(
                children: [
                  Text(transactionController.collapse.value
                      ? "Expand Filters"
                      : "Collapse Filters",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Icon(
                      transactionController.collapse.value? Icons.arrow_drop_down_sharp :
                      Icons.arrow_drop_up_sharp),
                ],
              ),
            )),
        const SizedBox(
          height: 20,
        ),
        Obx(() => Container(
              child: transactionController.collapse.value
                  ? const SizedBox()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: TextFormField(
                              controller: transactionController.startTimeController,
                              onTap: () async {
                                transactionController.selectedStartDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2025));
                                if (transactionController.selectedStartDate != null) {
                                  transactionController.startTimeController.text =
                                      DateFormat("dd-MM-yyyy")
                                          .format(transactionController.selectedStartDate!)
                                          .toString();
                                  // setState(() {});
                                }
                              },

                              validator: (value) {
                                if (transactionController.selectedStartDate == null) {
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
                              controller: transactionController.endTimeController,
                              onTap: () async {
                                transactionController.selectedEndDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2025));
                                if (transactionController.selectedEndDate != null) {
                                  transactionController.endTimeController.text =
                                      DateFormat("dd-MM-yyyy")
                                          .format(transactionController.selectedEndDate!)
                                          .toString();
                                  // setState(() {});
                                }
                              },

                              validator: (value) {
                                if (transactionController.selectedEndDate == null) {
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
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: transactionController.searchController,
                          decoration: const InputDecoration(
                            labelText: "Search",
                            hintText: "Search",
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(),
                            disabledBorder: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(),
                            isDense: true,
                          ),
                          maxLines: 1,
                          // enabled: false,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection(Collections.categories)
                                .orderBy('createdAt')
                                .snapshots(),
                            builder: (context,
                                AsyncSnapshot<
                                        QuerySnapshot<Map<String, dynamic>>>
                                    snapshot) {
                              final Map<String, Color> colorsMap = {};
                              List<String> stringCategories = [];
                              if ((snapshot.hasData) &&
                                  (!(snapshot.connectionState ==
                                      ConnectionState.waiting))) {
                                List<CategoryModel> categories = snapshot
                                    .data!.docs
                                    .map((DocumentSnapshot<Map<String, dynamic>>
                                            document) =>
                                        CategoryModel.fromMap(document.data()!))
                                    .toList();
                                categories = reorderList(categories);
                                stringCategories =
                                    categories.map((c) => c.title).toList();
                                stringCategories.insert(0, "All Categories");

                                for (var category in categories) {
                                  colorsMap[category.title] =
                                      Color(category.colorCode).withOpacity(1);
                                }
                              }

                              return MyDropDownButton(
                                dropdownValue: transactionController.selectedCategory,
                                items: stringCategories,
                                function: (String v) {
                                  transactionController.selectedCategory = v;
                                },
                                hintText: "Select Category",
                                colorsMap: colorsMap,
                              );
                            }),
                        const SizedBox(
                          height: 10,
                        ),
                        MyDropDownButton(
                          dropdownValue: transactionController.selectedPaymentMode,
                          items: const [
                            'All Payment Modes',
                            'cash',
                            'card',
                            'bank'
                          ],
                          function: (String v) {
                            transactionController.selectedPaymentMode = v;
                          },
                          hintText: "Select Payment Mode",
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        _buildOnlyAmountSearchCheckbox(),
                        const SizedBox(
                          height: 10,
                        ),
                        buttonsRow(),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                                child: amountContainer(
                              "Cash",
                                  transactionController.amountController.totalAmountCash,
                                  transactionController.amountController.totalAddedCash,
                                  transactionController.amountController.totalWithdrawCash,
                            )),
                            const SizedBox(
                              width: 15,
                            ),
                            Expanded(
                                child: amountContainer(
                              "Card",
                                  transactionController.amountController.totalAmountCard,
                                  transactionController.amountController.totalAddedCard,
                                  transactionController.amountController.totalWithdrawCard,
                            )),
                            const SizedBox(
                              width: 15,
                            ),
                            Expanded(
                                child: amountContainer(
                              "Bank",
                                  transactionController.amountController.totalAmountBank,
                                  transactionController.amountController.totalAddedBank,
                                  transactionController.amountController.totalWithdrawBank,
                            ))
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
            )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  transactionController.onSignSelection('+');
                  setState(() {});
                },
                child: Container(
                    decoration: BoxDecoration(
                        color: transactionController.selectedSign == '+' ? Colors.green : null,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1)),
                    padding: const EdgeInsets.all(7.5),
                    child: Icon(
                      Icons.add,
                      color: transactionController.selectedSign == '+' ? Colors.white : Colors.green,
                    )),
              ),
              const Text("Recent Transactions",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              InkWell(
                onTap: () {
                  transactionController.onSignSelection('-');
                  setState(() {});
                },
                child: Container(
                    decoration: BoxDecoration(
                        color: transactionController.selectedSign == '-' ? Colors.red : null,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1)),
                    padding: const EdgeInsets.all(7.5),
                    child: Icon(
                      Icons.remove,
                      color: transactionController.selectedSign == '-' ? Colors.white : Colors.red,
                    )),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
