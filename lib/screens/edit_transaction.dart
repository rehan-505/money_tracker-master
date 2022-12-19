import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_tracker/models/changelog.dart';
import 'package:money_tracker/models/transaction.dart';
import 'package:money_tracker/models/user.dart';
import 'package:money_tracker/utils/collection_names.dart';
import 'package:money_tracker/utils/db_operations.dart';
import 'package:money_tracker/utils/global_constants.dart';
import 'package:money_tracker/widgets/dropdown_button.dart';
import 'package:uuid/uuid.dart';
import '../models/category.dart';
import 'home_screen.dart';

class EditTransactionScreen extends StatefulWidget {
  const EditTransactionScreen({Key? key, required this.transactionModel}) : super(key: key);

  final TransactionModel transactionModel;

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {

  final TextEditingController amountController = TextEditingController();

  final TextEditingController descController = TextEditingController();

  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  bool loading = false;

  String? selectedCategory;



  bool loaded = false;
  String? selectedPaymentMode;

  List<String> categories = [];


  @override
  void initState(){

    amountController.text = widget.transactionModel.amount.toString();
    selectedPaymentMode = widget.transactionModel.transactionType;
    descController.text = widget.transactionModel.desc;
    selectedCategory = widget.transactionModel.category;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Transaction"), centerTitle: true,
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
                      borderSide: const BorderSide(
                          width: 1.5, color: Colors.blue),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          width: 1.5, color: Colors.blue),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                          width: 1.5, color: Colors.blue),
                      borderRadius: BorderRadius.circular(15),
                    ),

                  ),
                ),
                const SizedBox(
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
                        borderSide: const BorderSide(
                            width: 1.5, color: Colors.blue),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            width: 1.5, color: Colors.blue),
                        borderRadius: BorderRadius.circular(15),
                      )),
                ),
                const SizedBox(
                  height: 15,
                ),

                StreamBuilder(
                    stream: FirebaseFirestore.instance.collection(Collections.categories).orderBy('createdAt').snapshots(),
                    builder: (context,AsyncSnapshot<QuerySnapshot<Map<String,dynamic>>> snapshot) {

                      if(!(snapshot.hasData) || snapshot.connectionState==ConnectionState.waiting){
                        return MyDropDownButton(dropdownValue: loaded ? selectedCategory : null, items: categories, function: (String v) { selectedCategory=v; }, hintText: "Select Category");
                      }

                      loaded = true;



                      // if((snapshot.hasData) && (!(snapshot.connectionState==ConnectionState.waiting))){
                        categories = snapshot.data!.docs.map((DocumentSnapshot<Map<String,dynamic>> document) => CategoryModel.fromMap(document.data()!).title ).toList();

                      final Map<String,Color> colorsMap = {};

                      for (var snapshot in snapshot.data!.docs) {

                        CategoryModel model = CategoryModel.fromMap(snapshot.data());
                        colorsMap[model.title] = Color(model.colorCode).withOpacity(1);
                      }

                        if(!categories.contains(selectedCategory)){
                          selectedCategory = null;
                        }
                      // }
                      return MyDropDownButton(dropdownValue: selectedCategory, items: categories, function: (String v) { selectedCategory=v; }, hintText: "Select Category",colorsMap: colorsMap,);
                    }
                ),

                const SizedBox(
                  height: 15,
                ),



                MyDropDownButton(dropdownValue: selectedPaymentMode, items: const ["cash","card"], function: (String v) { selectedPaymentMode = v ;},hintText: "Select Payment Mode"),

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

                RaisedButton(
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
                      await _addMoney();
                    }
                  },
                  color: Colors.blue,
                  child: const Text(
                    'Save',
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

  _addMoney() async {
    setState(() {
      loading = true;
    });

    try {
      // final String id = const Uuid().v4();
      final AppUser currentUser = widget.transactionModel.createdBy;
      final TransactionModel transactionModel = TransactionModel(createdAt: widget.transactionModel.createdAt, category: selectedCategory!, desc: descController.text, transactionType: selectedPaymentMode!, transactionSign: widget.transactionModel.transactionSign, createdBy: currentUser, amount: double.parse(amountController.text),id: widget.transactionModel.id);
      await FirebaseFirestore.instance.collection(Collections.transactions).doc(widget.transactionModel.id).set(transactionModel.toMap());

      if(widget.transactionModel.transactionSign=='+'){
        await DBOperations.subtractCash(widget.transactionModel.transactionType, widget.transactionModel.amount);
        await DBOperations.addCash(transactionModel.transactionType, transactionModel.amount);
      }
      else{
        await DBOperations.addCash(widget.transactionModel.transactionType, widget.transactionModel.amount);
        await DBOperations.subtractCash(transactionModel.transactionType, transactionModel.amount);
      }

      String username = (await DBOperations.getCurrentUser())!.name;

      sendChangeNotification(username);
      await FirebaseFirestore.instance.collection("changeLogs").doc(Uuid().v4()).set(ChangeLog(message: "$username modified a transaction", createdAt: Timestamp.now(), previousTransaction: widget.transactionModel, updatedTransaction: transactionModel).toMap());

      // await DBOperations.addCash(selectedPaymentMode!, double.parse(amountController.text));
      // await sendMoneyAddedNotification(currentUser.name);

      Get.snackbar("Success", 'Changes Saved', backgroundColor: Colors.white);
      Get.offAll(() => const HomeScreen());
    } catch (e) {
      Get.snackbar("Error", e.toString());
      print(e);
      rethrow;
    }

    setState(() {
      loading = false;
    });
  }

  sendChangeNotification(String username)async{
    try{
      DocumentSnapshot<Map<String,dynamic>> documentSnapshot = await FirebaseFirestore.instance
          .collection(Collections.users).doc(adminId).get();
      Map map = documentSnapshot.data()!;
      await DBOperations.sendNotification(
          registrationIds: map['fcmTokens'], text: "$username updated a transaction to ${amountController.text} and $selectedCategory. See Logs for details.", title: "Transaction Updated");
    }
    catch(e){
      print(e);
      // rethrow;
    }
  }


}