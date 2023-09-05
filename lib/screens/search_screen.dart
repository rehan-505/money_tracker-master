import 'package:flutter/material.dart';
import 'package:money_tracker/models/transaction.dart';
import 'package:money_tracker/widgets/transaction_card.dart';
import '../controllers/transaction_screen_amount_controller.dart';
import '../utils/global_functions.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key, required this.transactions}) : super(key: key);
  final List<TransactionModel> transactions;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();

  // final SearchController searchController = SearchController();
  final TransactionScreenAmountController amountController =
      TransactionScreenAmountController();

  String selectedSign = 'both';
  List<TransactionModel> transactions = [];

  @override
  void initState() {
    transactions = List.from(widget.transactions);
    amountController.reset();
    setContainerAmounts(widget.transactions);
    super.initState();
  }

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
            filterOut();
          },
          // controller: searchController,
          decoration: InputDecoration(
            isDense: true,
            // labelText: 'Search Transactions',
            // labelStyle:  TextStyle(color: Colors.white),
            hintText: "Search Transactions",
            hintStyle: const TextStyle(color: Colors.white),
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
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: (){
                      onSignSelection('+');
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            color: selectedSign == '+' ? Colors.green : null,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black,width: 1)

                        ),
                        padding: EdgeInsets.all(7.5),
                        child: Icon(Icons.add, color: selectedSign == '+' ? Colors.white : Colors.green,)),
                  ),
                  const Text("Recent Transactions",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  InkWell(
                    onTap: (){
                      onSignSelection('-');
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            color: selectedSign == '-' ? Colors.red : null,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black,width: 1)

                        ),
                        padding: EdgeInsets.all(7.5),
                        child: Icon(Icons.remove, color: selectedSign == '-' ? Colors.white : Colors.red,)),
                  )            ],
              ),
            ),
            Row(
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
            ),
            const SizedBox(height: 20,),
            Expanded(
              child: Builder(
                  builder: (context,) {
                    if (transactions.isEmpty) {
                      return const Center(
                        child: Text("No Transactions to show"),
                      );
                    }

                    return ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          TransactionModel transaction = transactions[index];

                            return TransactionCard(
                                transactionModel: transaction);
                        });
                  }),
            ),
          ],
        ),
      ),
    );
  }

  void setContainerAmounts(List<TransactionModel> transactionsList) {
    amountController.reset();
    for (int i = 0; i < transactionsList.length; i++){
      TransactionModel transaction = transactionsList[i];
      if (transaction.transactionSign == '+') {
        if (transaction.transactionType == 'cash') {
          amountController.totalAmountCash =
              transaction.amount + amountController.totalAmountCash;
          amountController.totalAddedCash =
              transaction.amount + amountController.totalAddedCash;
        } else if (transaction.transactionType == 'bank') {
          amountController.totalAmountBank =
              amountController.totalAmountBank + transaction.amount;
          amountController.totalAddedBank =
              transaction.amount + amountController.totalAddedBank;
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
        } else if (transaction.transactionType == 'bank') {
          amountController.totalAmountBank =
              amountController.totalAmountBank - transaction.amount;
          amountController.totalWithdrawBank =
              transaction.amount + amountController.totalWithdrawBank;
        } else {
          amountController.totalAmountCard =
              amountController.totalAmountCard - transaction.amount;
          amountController.totalWithdrawCard =
              transaction.amount + amountController.totalWithdrawCard;
        }
      }
    }
  }

  bool matchFilters(TransactionModel transaction){

    if(transaction.transactionSign != selectedSign && selectedSign!='both'){
      return false;
    }

    if((double.tryParse(searchController.text)!=null)){
      return transaction.amount == double.parse(searchController.text);
    }
    return (transaction.category
        .toLowerCase()
        .contains(searchController.text.toLowerCase())) ||

        (transaction.desc.toLowerCase().contains(
            searchController.text.toLowerCase()) ||
            searchController.text.trim().isEmpty)

        ||
        ( transaction.amount.toString().contains(searchController.text)  );

  }

  void filterOut(){
    transactions = widget.transactions.where((element) => matchFilters(element)).toList();
    setContainerAmounts(transactions);
    setState(() {});
  }

  void onSignSelection(String sign){

    if(selectedSign!='both' && selectedSign!=sign){
      selectedSign=sign;
      filterOut();
      return;
    }

    if(selectedSign==sign){
      selectedSign='both';
      filterOut();
      return;
    }

    selectedSign = sign;
    transactions.removeWhere((element) => element.transactionSign != selectedSign);
    // setContainerAmounts(transactions);
    setState(() {});
  }

}
