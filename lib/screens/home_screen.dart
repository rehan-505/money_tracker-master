import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_tracker/models/total_amount.dart';
import 'package:money_tracker/models/transaction.dart';
import 'package:money_tracker/screens/add_money_screen.dart';
import 'package:money_tracker/screens/show_users_screen.dart';
import 'package:money_tracker/screens/subtract_money.dart';
import 'package:money_tracker/screens/transactions_screen.dart';
import 'package:money_tracker/utils/collection_names.dart';
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
      debugPrint("idAdmin is true");
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

  bool dataLoaded = false;
  bool fullScreen = false;

  List<TransactionModel> transactions = [];

  @override
  Widget build(BuildContext context) {
    DateTime currentDate = DateTime.now();

    return FutureBuilder(
        future: FirebaseFirestore.instance
            .collection(Collections.transactions)
            .where("createdAt",
                isGreaterThan: Timestamp.fromDate(DateTime(currentDate.year,
                    currentDate.month, (currentDate.day), 0, 0, 0)))
            .orderBy("createdAt", descending: true)
            .get(),
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          amountController.reset();
          if (snapshot.hasData &&
              (!(snapshot.connectionState == ConnectionState.waiting))) {
            debugPrint(
                'Today\'s transactions list length: ${snapshot.data!.docs.length}');
            transactions = snapshot.data!.docs
                .map((e) => TransactionModel.fromMap(e.data()))
                .toList();

            setContainerAmounts(transactions);

            dataLoaded = true;
          }

          return Scaffold(
            drawer: CustomDrawer(),
            appBar: AppBar(
              title: const Text("Kitaab"),
              centerTitle: true,
              actions: [
                InkWell(
                  child: const Icon(Icons.refresh_outlined),
                  onTap: () {
                    setState(() {});
                  },
                ),
                const SizedBox(
                  width: 20,
                ),
                if(isAdmin)
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: InkWell(
                    child:
                        Icon(fullScreen ? Icons.zoom_in_map : Icons.zoom_out_map),
                    onTap: () {
                      setState(() {
                        fullScreen = !fullScreen;
                      });
                    },
                  ),
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
                  if (isAdmin && !fullScreen)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Row(
                        children: [
                          Expanded(
                              child: amountContainer(
                            "Cash",
                            amountController.totalAmountCash,
                            amountController.totalAddedCash,
                            amountController.totalWithdrawCash,
                          )),
                          const SizedBox(
                            width: 15,
                          ),
                          Expanded(
                              child: amountContainer(
                            "Card",
                            amountController.totalAmountCard,
                            amountController.totalAddedCard,
                            amountController.totalWithdrawCard,
                          )),
                          const SizedBox(
                            width: 15,
                          ),
                          Expanded(
                              child: amountContainer(
                            "Bank",
                            amountController.totalAmountBank,
                            amountController.totalAddedBank,
                            amountController.totalWithdrawBank,
                          ))
                        ],
                      ),
                    ),
                  if (!fullScreen)
                  buttonsRow(),
                  const SizedBox(height: 20),
                  Text("Today's Transactions${isAdmin ? " (${snapshot.data?.size ?? 0})" : ""}",
                      style:  TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(
                    height: 5,
                  ),
                  Expanded(
                    child: Builder(
                        builder: (context,) {

                          if (!dataLoaded) {
                            return const Center(
                              child: Text("Loading Transactions"),
                            );
                          }

                          if (transactions.isEmpty) {
                            return const Center(
                              child: Text("No Transactions to show"),
                            );
                          }

                          if(!isAdmin){

                            List<TransactionModel> userTransactions = transactions.where((element) => element.createdBy.id == FirebaseAuth.instance.currentUser!.uid).toList();

                            return ListView.builder(
                                itemCount: userTransactions.length > 10 ? 10 : userTransactions.length,
                                itemBuilder: (context, index) {

                                  return TransactionCard(
                                    transactionModel: userTransactions[index],
                                    onTransactionDelete: () {
                                      setState(() {});
                                    },
                                  );
                                });
                          }

                          return
                            ListView.builder(
                              padding: EdgeInsets.zero,
                              // shrinkWrap: true,
                              // cacheExtent: isAdmin ? null : 2000,
                              itemCount: snapshot.data!.size,
                              itemBuilder: (context, index) {
                                TransactionModel transaction =
                                    TransactionModel.fromMap(
                                        snapshot.data!.docs[index].data());

                                return TransactionCard(
                                  transactionModel: transaction,
                                  onTransactionDelete: () {
                                    setState(() {});
                                  },
                                );
                              });
                        }),
                  )
                ],
              ),
            ),
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
                      Get.to(() => const AddMoneyScreen());
                    },
                    onLongPress: () {
                      // Get.to(() =>  const SpecificSignedTransactionsScreen(transactionSign: '+'));
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Add Money"),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          '+',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 40),
                        )
                      ],
                    ))),
            const SizedBox(
              width: 15,
            ),
            Expanded(
                child: ElevatedButton(
                    onPressed: () {
                      if (dataLoaded) {
                        Get.to(() => SubtractMoneyScreen(
                              totalAmount: TotalAmount(
                                  cash: amountController.totalAmountCash,
                                  cashAllTimeAdded:
                                      amountController.totalAddedCash,
                                  cashAllTimeWithdraw:
                                      amountController.totalWithdrawCash,
                                  card: amountController.totalAmountCard,
                                  cardAllTimeAdded:
                                      amountController.totalAddedCard,
                                  cardAllTimeWithdraw:
                                      amountController.totalWithdrawCard,
                                  bank: amountController.totalAmountBank,
                                  bankAllTimeAdded:
                                      amountController.totalAddedBank,
                                  bankAllTimeWithdraw:
                                      amountController.totalWithdrawBank),
                            ));
                      } else {
                        Get.snackbar("Please wait", "We are loading data",
                            backgroundColor: Colors.white);
                      }
                    },
                    onLongPress: () {
                      // Get.to(() =>  const SpecificSignedTransactionsScreen(transactionSign: '-'));
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Subtract Money"),
                        Spacer(),
                        Text(
                          '-',
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 40),
                        )
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
                            Get.to( TransactionsScreen());
                          },
                          child: const Text("Transactions")))
                ],
              )
            : const SizedBox(),
      ],
    );
  }

  void setContainerAmounts(List<TransactionModel> transactionsList) {
    for (int i = 0; i < transactionsList.length; i++) {
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
}
