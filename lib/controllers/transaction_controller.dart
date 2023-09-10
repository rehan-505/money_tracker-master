import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:flutter/material.dart';
import 'package:money_tracker/controllers/transaction_screen_amount_controller.dart';
import '../models/transaction.dart';

class TransactionController extends GetxController{
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  String selectedCategory = "All Categories";
  RxList<TransactionModel> allTransactions = <TransactionModel>[].obs;
  RxList<TransactionModel> filteredTransactions = <TransactionModel>[].obs;

  Rx<bool> searchByAmount = true.obs;

  final TransactionScreenAmountController amountController =
  TransactionScreenAmountController();

  Rx<bool> collapse = false.obs;

  String? selectedPaymentMode = 'All Payment Modes';

  String selectedSign = 'both';

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController startTimeController = TextEditingController();

  final TextEditingController endTimeController = TextEditingController();

  final TextEditingController searchController = TextEditingController();


  void filterList(){
    filteredTransactions.value = allTransactions.where((transaction) => matchFilters(transaction)).toList();
    setContainerAmounts(filteredTransactions);
    // setState(() {});
  }

  bool matchFilters(TransactionModel transaction) {

    DateTime createdAt = DateTime.fromMillisecondsSinceEpoch(transaction.createdAt.millisecondsSinceEpoch);

    bool match = ((transaction.category == selectedCategory) ||
        selectedCategory.toLowerCase() == 'all categories') &&
        ((transaction.transactionType == selectedPaymentMode) ||
            selectedPaymentMode!.toLowerCase() == 'all payment modes') &&
        (transaction.desc
            .toLowerCase()
            .contains(searchController.text.toLowerCase()) ||
            transaction.category
                .toLowerCase()
                .contains(searchController.text.toLowerCase())
            || filterByAmount(transaction)
        ) &&
        (transaction.transactionSign == selectedSign || selectedSign == 'both') &&
        createdAt.isAfter(selectedStartDate ?? DateTime(2000)) && createdAt.isBefore(selectedEndDate ?? DateTime.now());

    return match;

  }

  bool filterByAmount(TransactionModel transaction){
    if(searchByAmount.value){
      double? searchAmount = double.tryParse(searchController.text.trim());
      if(searchAmount!=null){
        return transaction.amount.toInt() == searchAmount.toInt();
      }
    }
    return false;
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

  void resetFilters(){
    selectedEndDate = null;
    selectedStartDate = null;
    startTimeController.text = '';
    endTimeController.text = '';
    selectedCategory = 'All Categories';
    selectedPaymentMode = 'All Payment Modes';
    selectedSign = 'both';
    filteredTransactions.value = List.from(allTransactions);
    setContainerAmounts(filteredTransactions);
    // transactions = List.from(transactionController.allTransactions);
    // setState(() {});
  }

  void onSignSelection(String sign){

    if(selectedSign=='both'){
      selectedSign = sign;
      filteredTransactions
          .removeWhere((element) => element.transactionSign != selectedSign);
      setContainerAmounts(filteredTransactions);
      // setState(() {});
    }

    else if(selectedSign==sign){
      selectedSign='both';
      filterList();
      return;
    }
    ///Different sign selected
    else{
      selectedSign=sign;
      filterList();
      return;
    }

  }


}