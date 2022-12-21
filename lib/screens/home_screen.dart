import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker/controllers/logout_controller.dart';
import 'package:money_tracker/models/transaction.dart';
import 'package:money_tracker/screens/add_money_screen.dart';
import 'package:money_tracker/screens/login_screen.dart';
import 'package:money_tracker/screens/positive_transactions_screen.dart';
import 'package:money_tracker/screens/show_users_screen.dart';
import 'package:money_tracker/screens/subtract_money.dart';
import 'package:money_tracker/screens/transactions_screen.dart';
import 'package:money_tracker/utils/collection_names.dart';
import 'package:money_tracker/utils/db_operations.dart';
import 'package:money_tracker/widgets/drawer.dart';
import 'package:money_tracker/widgets/transaction_card.dart';
import '../controllers/transaction_screen_amount_controller.dart';
import '../notification_service/local_notification_service.dart';
import '../utils/global_constants.dart';
import '../utils/global_functions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    if (FirebaseAuth.instance.currentUser!.email!
        .contains(RegExp("admin@dl"))) {
      isAdmin = true;
      print("idAdmin is true");
    } else {
      isAdmin = false;
    }

    /// 1. This method call when app in terminated state and you get a notification
    /// when you click on notification app open from terminated state and you can get notification data in this method

    FirebaseMessaging.instance.getInitialMessage().then(
      (message) {
        print("FirebaseMessaging.instance.getInitialMessage");
        if (message != null) {
          print("New Notification");
          print(message.notification?.title);
          print(message.notification?.body);

          // if (message.data['_id'] != null) {
          //   Navigator.of(context).push(
          //     MaterialPageRoute(
          //       builder: (context) => DemoScreen(
          //         id: message.data['_id'],
          //       ),
          //     ),
          //   );
          // }
        }
      },
    );

    /// 2. This method only call when App in forground it mean app must be opened
    FirebaseMessaging.onMessage.listen(
      (message) {
        print("FirebaseMessaging.onMessage.listen");
        if (message.notification != null) {
          print(message.notification!.title);
          print(message.notification!.body);
          print("message.data11 ${message.data}");
          LocalNotificationService.createanddisplaynotification(message);
        }
      },
    );

    /// 3. This method only call when App in background and not terminated(not closed)
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        print("FirebaseMessaging.onMessageOpenedApp.listen");
        if (message.notification != null) {
          print(message.notification!.title);
          print(message.notification!.body);
          print("message.data22 ${message.data['_id']}");
        }
      },
    );
  }

  final TransactionScreenAmountController amountController =
  TransactionScreenAmountController();


  @override
  Widget build(BuildContext context) {



    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        title: const Text("Kitaab"),
        centerTitle: true,
        actions: [
          InkWell(child: Icon(Icons.refresh_outlined),
          onTap: (){
            setState(() {

            });
          },
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            isAdmin
                ?FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection(Collections.transactions)
                    .orderBy("createdAt", descending: true)
                    .get(),
                builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                  amountController.reset();
                  if(snapshot.hasData && (!(snapshot.connectionState==ConnectionState.waiting)) ){
                    int count = 0;
                    for(int i=0; i< snapshot.data!.docs.length; i++){
                      TransactionModel transaction = TransactionModel.fromMap(snapshot.data!.docs[i].data());
                      if (DateFormat('dd-MM-yyyy').format(DateTime.fromMillisecondsSinceEpoch(transaction.createdAt.millisecondsSinceEpoch)) == DateFormat('dd-MM-yyyy').format(DateTime.now())){
                        count++;
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
                }
            )                : SizedBox(),
            const SizedBox(
              height: 20,
            ),
            buttonsRow(),
            const SizedBox(height: 20),
            const Text("Recent Transactions",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection(Collections.transactions)
                      .orderBy("createdAt", descending: true)
                      .get(),
                  builder: (context,
                      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                          snapshot) {

                    double userCount = 0;


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

                    // List<QueryDocumentSnapshot> documents = snapshot.data!.docs.sort()

                    return ListView.builder(
                      // shrinkWrap: true,
                        cacheExtent: isAdmin ? null : 2000,
                        itemCount: isAdmin ? snapshot.data!.size : snapshot.data!.size,
                        itemBuilder: (context, index) {

                          TransactionModel transaction =
                              TransactionModel.fromMap(
                                  snapshot.data!.docs[index].data());



                          if ((!isAdmin) &&
                              (transaction.createdBy.id !=
                                  FirebaseAuth.instance.currentUser!.uid)) {

                            return const SizedBox();

                          }

                          if(DateFormat('dd-MM-yyyy').format(DateTime.fromMillisecondsSinceEpoch(transaction.createdAt.millisecondsSinceEpoch)) != DateFormat('dd-MM-yyyy').format(DateTime.now())){
                            return SizedBox();
                          }

                          if(!isAdmin && userCount>9){
                            return SizedBox();
                          }

                          if(!isAdmin){
                            userCount = userCount + 1;
                          }




                          return TransactionCard(
                            transactionModel: transaction,
                           onTransactionDelete: (){
                              setState(() {

                              });
                           },
                          );
                        });
                  }),
            )
          ],
        ),
      ),
    );
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
                      Get.to(() => const AddMoneyScreen());
                    },
                      onLongPress: (){
                        // Get.to(() =>  const SpecificSignedTransactionsScreen(transactionSign: '+'));
                      },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Add Money"),
                        SizedBox(width: 10,),
                        Text('+', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 40),)
                      ],
                    ))),
            const SizedBox(
              width: 15,
            ),
            Expanded(
                child: ElevatedButton(
                    onPressed: () {
                      Get.to(() => SubtractMoneyScreen());
                    },
                    onLongPress: (){
                      // Get.to(() =>  const SpecificSignedTransactionsScreen(transactionSign: '-'));
                    },

                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Subtract Money"),
                        SizedBox(width: 10,),
                        Text('-', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 40),)
                      ],
                    )))
          ],
        ),
        // const SizedBox(height: 10,),
        ///Users and Transaction Button
        isAdmin
            ? Row(
                children: [
                  Expanded(
                      child: ElevatedButton(
                          onPressed: () {
                            Get.to(const UsersListScreen());
                          },
                          child: const Text("Users"))),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                      child: ElevatedButton(
                          onPressed: () {
                            Get.to(const TransactionsScreen());
                          },
                          child: const Text("Transactions")))
                ],
              )
            : const SizedBox(),
      ],
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

