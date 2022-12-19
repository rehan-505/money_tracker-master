import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiHandling {
  static sendNotification()async{
    var url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    Map body = {
      "registration_ids": [
        "cJLzF2cnS3yFaQJai_A10W:APA91bFLD-uqyam6QriztEZMhpBi6ycodXccETl2WJ9Gd6Zdqc1aIm16Kazj_ZNo96vB_-Mz94GrBWkv80nvwOb0qmN8vGUIK8wYzZjOf2NTiWqiVuPMtMO1_LH3dToa3g89fd6_SBNo"
      ],
      "notification": {
        "body": "New Video has been uploaded",
        "title": "Inventorcode",
        "android_channel_id": "moneytrackerapp",
        "sound": false
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
}