import 'package:flutter/material.dart';

class ContactDeveloper extends StatelessWidget {
  const ContactDeveloper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: Text("TEMPORARY APK EXPIRED, CONTACT DEVELOPER:\n+923244564754"),
        ),
      ),
    );
  }
}