import 'package:get/get.dart';

class SearchScreenAmountController extends GetxController{
  Rx<double> totalAmountCash = 0.0.obs;
  Rx<double> totalAmountCard = 0.0.obs;
  Rx<double> totalAddedCash = 0.0.obs;
  Rx<double> totalWithdrawCash = 0.0.obs;
  Rx<double> totalAddedCard = 0.0.obs;
  Rx<double> totalWithdrawCard = 0.0.obs;

}