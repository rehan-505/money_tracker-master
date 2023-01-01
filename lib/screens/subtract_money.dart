import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_tracker/models/total_amount.dart';
import 'package:money_tracker/models/transaction.dart';
import 'package:money_tracker/models/user.dart';
import 'package:money_tracker/utils/collection_names.dart';
import 'package:money_tracker/utils/db_operations.dart';
import 'package:money_tracker/widgets/dropdown_button.dart';
import 'package:uuid/uuid.dart';
import '../utils/global_constants.dart';
import '../utils/global_functions.dart';
import 'home_screen.dart';
import 'package:money_tracker/models/category.dart';


class SubtractMoneyScreen extends StatefulWidget {
  const SubtractMoneyScreen({Key? key}) : super(key: key);

  @override
  State<SubtractMoneyScreen> createState() => _SubtractMoneyScreenState();
}

class _SubtractMoneyScreenState extends State<SubtractMoneyScreen> {
  final TextEditingController amountController = TextEditingController();

  final TextEditingController descController = TextEditingController();

  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  bool loading = false;

  String? selectedCategory;
  String? selectedPaymentMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Withdraw Money"), centerTitle: true,
        actions:  const [
          // InkWell(
          //     onTap: ()async{
          //       await FirebaseAuth.instance.signOut();
          //       Get.offAll(()=>Login());
          //     },
          //     child: Icon(Icons.logout)),
          // SizedBox(width: 20,),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _key,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Kitaab',
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Field is required";
                    }
                    return null;
                  },
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Enter Amount',
                    labelStyle:  TextStyle(color: Colors.black.withOpacity(0.5)),
                      enabledBorder: OutlineInputBorder(
                        borderSide:  BorderSide(
                            width: 1.5, color: Theme.of(context).primaryColor),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:  BorderSide(
                            width: 1.5, color: Theme.of(context).primaryColor),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    border: OutlineInputBorder(
                      borderSide:  BorderSide(
                          width: 1.5, color: Theme.of(context).primaryColor),
                      borderRadius: BorderRadius.circular(15),
                    ),

                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return "Field is required";
                  //   }
                  //   return null;
                  // },
                  controller: descController,
                  decoration: InputDecoration(
                      labelText: 'Enter Note',
                      labelStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
                      enabledBorder: OutlineInputBorder(
                        borderSide:  BorderSide(
                            width: 1.5, color: Theme.of(context).primaryColor),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:  BorderSide(
                            width: 1.5, color: Theme.of(context).primaryColor),
                        borderRadius: BorderRadius.circular(15),
                      )

                  ),
                ),
                const SizedBox(
                  height: 15,
                ),

                FutureBuilder(
                    future: FirebaseFirestore.instance.collection(Collections.categories).orderBy('createdAt').get(),
                    builder: (context,AsyncSnapshot<QuerySnapshot<Map<String,dynamic>>> snapshot) {

                      final Map<String,Color> colorsMap = {};
                      List<String> stringCategories = [];
                      if((snapshot.hasData) && (!(snapshot.connectionState==ConnectionState.waiting))){
                        List<CategoryModel> categories = snapshot.data!.docs.map((DocumentSnapshot<Map<String,dynamic>> document) => CategoryModel.fromMap(document.data()!) ).toList();
                        categories = reorderList(categories);
                        stringCategories = categories.map((c) => c.title ).toList();


                        for (var category in categories) {

                          colorsMap[category.title] = Color(category.colorCode).withOpacity(1);
                        }

                      }



                      return MyDropDownButton(dropdownValue: selectedCategory, items: stringCategories, function: (String v) { selectedCategory=v; }, hintText: "Select Category",colorsMap: colorsMap,);
                    }
                ),

                const SizedBox(
                  height: 15,
                ),



                MyDropDownButton(dropdownValue: selectedPaymentMode, items: const ["cash","card","bank"], function: (String v) { selectedPaymentMode = v ;},hintText: "Select Payment Mode"),

                const SizedBox(
                  height: 15,
                ),

                loading
                    ? const SizedBox(
                  height: 40,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
                    :

                ElevatedButton(
                  onPressed: () async {
                    if (_key.currentState!.validate()) {
                      if(selectedCategory == null){
                        Get.snackbar("Request Denied", "Add Category");
                        return;
                      }
                      else if(selectedPaymentMode==null){
                        Get.snackbar("Request Denied", "Add Payment Mode");
                        return;
                      }
                      await _subtractMoney();
                    }
                  },
                  child: const Text(
                    'SUBMIT',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                //   SizedBox(height: 60,),
                //   InkWell(
                //     onTap: (){
                //       Get.to(PasswordResetScreen());
                //     },
                //     child: Row(
                //       children: [
                //         Text("Forgot Password? Click Here", style: TextStyle(fontSize: 16, color: Colors.brown, fontWeight: FontWeight.bold),),
                //       ],
                //     ),
                //   )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _subtractMoney() async {
    setState(() {
      loading = true;
    });
    TotalAmount totalAmount = await DBOperations.getTotalAmount();
   if ( ((selectedPaymentMode=='card')  && (double.parse(amountController.text)<=totalAmount.card)) || ((selectedPaymentMode=='cash')  && (double.parse(amountController.text)<=totalAmount.cash))
   || ((selectedPaymentMode=='bank')  && (double.parse(amountController.text)<=totalAmount.bank))

   ) {
      try {
        final String id = const Uuid().v4();
        final AppUser currentUser = (await DBOperations.getCurrentUser())!;
        final TransactionModel transactionModel = TransactionModel(
            createdAt: Timestamp.now(),
            category: selectedCategory!,
            desc: descController.text,
            transactionType: selectedPaymentMode!,
            transactionSign: "-",
            createdBy: currentUser,
            amount: double.parse(amountController.text),
            id: id);
        await FirebaseFirestore.instance
            .collection(Collections.transactions)
            .doc(id)
            .set(transactionModel.toMap());
        await DBOperations.subtractCash(
            selectedPaymentMode!, double.parse(amountController.text));
        await sendMoneyWithdrawNotification(currentUser.name);
        Get.offAll(() => const HomeScreen());
      } catch (e) {
        Get.snackbar("Error", e.toString());
        print(e);
        // rethrow;
      }
    }
   else{
     Get.snackbar("Transaction Failed", "Not enough money in $selectedPaymentMode", backgroundColor: Colors.white);
   }
    setState(() {
      loading = false;
    });
  }

  sendMoneyWithdrawNotification(String username)async{
    try{
      DocumentSnapshot<Map<String,dynamic>> documentSnapshot = await FirebaseFirestore.instance.collection(Collections.users).doc(adminId).get();
      Map map = documentSnapshot.data()!;
      await DBOperations.sendNotification(
          registrationIds: map['fcmTokens'], text: "$username withdrew ${amountController.text} Rs by $selectedPaymentMode.", title:"Money Withdrawal" );
    }
    catch(e){
      print(e);
      // rethrow;
    }
  }

}