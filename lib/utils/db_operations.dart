import 'dart:convert';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker/models/total_amount.dart';
import 'package:money_tracker/models/user.dart';
import 'package:money_tracker/utils/collection_names.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class DBOperations{

  static AppUser? currentUser;
  static String? fcmToken;
  static NotificationSettings? settings;

  static addMoney(){}


  static Future<AppUser?> getCurrentUser() async{
    try{

      if(currentUser!=null){
        return currentUser;
      }

      final DocumentSnapshot<Map<String,dynamic>> documentSnapshot = await FirebaseFirestore.instance.collection(Collections.users).doc(FirebaseAuth.instance.currentUser!.uid).get();
      final Map<String,dynamic> map = documentSnapshot.data()!;
      currentUser = AppUser.fromMap(map);
      return currentUser;
    }
    catch(e){
      Get.snackbar("Error", e.toString());
      return null;
    }
  }

  static Future<String> getDeviceTokenToSendNotification() async {

    if(fcmToken!=null){
      return fcmToken!;
    }

    final FirebaseMessaging fcm = FirebaseMessaging.instance;
    final token = await fcm.getToken();
    fcmToken = token.toString();
    print("Token Value $fcmToken");
    return fcmToken!;
  }

  static sendNotification({required List registrationIds,required String text, required String title}) async{
    var url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    Map body = {
      "registration_ids": registrationIds,
      "notification": {
        "body": text,
        "title": title,
        "android_channel_id": "moneytrackerapp",
        "sound": true
      }
    };

    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json", 'Authorization': 'key=AAAAFV0bVWw:APA91bF5tZhMfyhzoOp5W6_14Pm-dM423EBbW-hZa74IW5zsngTiYLqPU1yIcfQrZM5-tXWXJs3NTRKou53-1FqaWz8YwFAosnHb3_pafKcQcDamts-HKP2HPm8gOTG7GoAXFi3SyA0u',},
      body: json.encode(body),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

  }


  static Color hexToColor(String code) {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  static Future<bool> addCash(String paymentMode, double amount) async{
    try{
      String allTimeAdded = '';
      if(paymentMode.toLowerCase()=="cash"){
        allTimeAdded = "cashAllTimeAdded";
      }
      else if(paymentMode.toLowerCase()=="bank"){
        allTimeAdded = "bankAllTimeAdded";
      }
      else {
        allTimeAdded = "cardAllTimeAdded";
      }


      await FirebaseFirestore.instance.collection(Collections.totalAmount).doc(DateFormat('dd-MM-yyyy').format(DateTime.now())).update({
        paymentMode : FieldValue.increment(amount),
        allTimeAdded : FieldValue.increment(amount)
      });
      return true;
    }
    catch(e){
      print(e);
      return false;
    }
  }

  static Future<bool> subtractCash(String category, double amount) async{
    try{
      String allTimeWithdraw = '';
      if(category.toLowerCase()=="cash"){
        allTimeWithdraw = "cashAllTimeWithdraw";
      }
      else if(category.toLowerCase()=="bank"){
        allTimeWithdraw = "bankAllTimeWithdraw";
      }
      else {
        allTimeWithdraw = "cardAllTimeWithdraw";
      }

      await FirebaseFirestore.instance.collection(Collections.totalAmount).doc(DateFormat('dd-MM-yyyy').format(DateTime.now())).update({
        category : FieldValue.increment(0-amount),
        allTimeWithdraw : FieldValue.increment(amount)

      });
      return true;
    }
    catch(e){
      print(e);
      return false;
    }
  }

  static Future initializeTotalAmountCollection() async{
    try{
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection(Collections.totalAmount).doc(DateFormat('dd-MM-yyyy').format(DateTime.now())).get();
      if(!documentSnapshot.exists){
        FirebaseFirestore.instance.collection(Collections.totalAmount).doc(DateFormat('dd-MM-yyyy').format(DateTime.now())).set(const TotalAmount(cash: 0, card: 0,cardAllTimeAdded: 0,cardAllTimeWithdraw: 0,cashAllTimeAdded: 0,cashAllTimeWithdraw: 0,bank: 0,bankAllTimeAdded: 0,bankAllTimeWithdraw: 0).toMap());
      }
    }
    catch(e){
      print(e);
      rethrow;
    }
  }

  static Future getTotalAmount()async{
    try{
      DocumentSnapshot<Map<String,dynamic>> documentSnapshot = await FirebaseFirestore.instance.collection(Collections.totalAmount).doc(DateFormat('dd-MM-yyyy').format(DateTime.now())).get();
      return TotalAmount.fromMap(documentSnapshot.data()!);
    }
    catch(e){
      print(e);
    }
  }

  static Future handleNotificationPermissions() async{
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.getNotificationSettings();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('permissions are not granted. requesting now');
      DBOperations.settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }
  }
}