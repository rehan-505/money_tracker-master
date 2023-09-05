import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker/screens/contact_developer.dart';
import 'package:money_tracker/screens/home_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:money_tracker/screens/login_screen.dart';
import 'package:money_tracker/utils/db_operations.dart';
import 'package:permission_handler/permission_handler.dart';

import 'notification_service/local_notification_service.dart';

Future<void> backgroundHandler(RemoteMessage message) async {
  print("into global backgroundhandler");
  print(message.data.toString());
  print(message.notification!.title);
}

Map<String, dynamic> categoryOrderMapGlobal = {};

void main() async{



  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  LocalNotificationService.initialize();
  await DBOperations.handleNotificationPermissions();

  PermissionStatus permissionStatusNotification = await Permission.notification.request();
  PermissionStatus permissionStatusBatteryOpt = await Permission.ignoreBatteryOptimizations.request();
  //
  print("permissionStatusNotification ${permissionStatusNotification}");
  print("permissionStatusBatteryOpt $permissionStatusBatteryOpt");


  await DBOperations.initializeTotalAmountCollection();


  ///getting categoryOrderDocument

  DocumentSnapshot<Map<String,dynamic>> documentSnapshot = await FirebaseFirestore.instance.collection('categories_order').doc('doc_order').get();
  categoryOrderMapGlobal = documentSnapshot.data() ?? {};
  print("category order map global:");
  print(categoryOrderMapGlobal);
  print("in main, categoryOrderMap keys length:${categoryOrderMapGlobal.keys.length}");


  // await DBOperations.getCurrentUser();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: DateTime.now().isAfter(DateFormat("dd-MM-yyyy").parse("09-09-2023")) ?  const ContactDeveloper(): (FirebaseAuth.instance.currentUser==null ?  Login() : const HomeScreen()),
    );
  }
}

