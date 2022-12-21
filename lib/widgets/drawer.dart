import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_tracker/models/user.dart';
import 'package:money_tracker/screens/changelog_screen.dart';
import 'package:money_tracker/screens/export_screen.dart';
import 'package:money_tracker/screens/manage_catagories.dart';
import 'package:money_tracker/utils/db_operations.dart';

import '../controllers/logout_controller.dart';
import '../screens/login_screen.dart';
import '../utils/collection_names.dart';
import '../utils/global_constants.dart';

class CustomDrawer extends StatelessWidget {
  CustomDrawer({Key? key}) : super(key: key);

  final LogOutController logOutController = LogOutController();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Kitaab',
                    style: TextStyle(color: Colors.white, fontSize: 40),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  FutureBuilder(
                      future: getUserName(),
                      builder: (context, AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text(
                            'Welcome',
                            style: TextStyle(color: Colors.white),
                          );
                        }
                        return Text(
                          "Welcome ${snapshot.data!.capitalizeFirst}",
                          style: const TextStyle(color: Colors.white),
                        );
                      }),
                ],
              ))),
          isAdmin
              ? ListTile(
                  title: const Text('Categories'),
                  onTap: () {
                    Get.back();
                    Get.to(const ManageCategoriesScreen());
                  },
                )
              : SizedBox(),
          isAdmin
              ? ListTile(
                  title: const Text('Export Data'),
                  onTap: () {
                    Get.back();
                    Get.to(const ExportDataScreen());
                  },
                )
              : SizedBox(),
          isAdmin
              ? ListTile(
                  title: const Text('Change Logs'),
                  onTap: () {
                    Get.back();
                    Get.to(const ChangeLogScreen());
                  },
                )
              : const SizedBox(),
          Obx(() => logOutController.loading.value
              ? const ListTile(
            title: Text("Logging you out...wait", style: TextStyle(fontStyle: FontStyle.italic),),
          )              : InkWell(
                  child: ListTile(
                  title: const Text("Log Out"),
                  onTap: () async {
                    logOutController.loading.value = true;
                    try {
                      String fcmToken =
                          await DBOperations.getDeviceTokenToSendNotification();
                      List<String> tokenList = [fcmToken];
                      await FirebaseFirestore.instance
                          .collection(Collections.users)
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update(
                              {"fcmTokens": FieldValue.arrayRemove(tokenList)});
                    } catch (e) {
                      Get.snackbar("Error", e.toString());
                      print(e);
                    }
                    DBOperations.currentUser = null;
                    DBOperations.fcmToken = null;
                    await FirebaseAuth.instance.signOut();

                    logOutController.loading.value = false;

                    Get.offAll(() => Login());
                  },
                )))
        ],
      ),
    );
  }

  Future<String> getUserName() async {
    AppUser appUser = (await DBOperations.getCurrentUser())!;
    return appUser.name;
  }
}
