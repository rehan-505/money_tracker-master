import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/collection_names.dart';
import '../utils/db_operations.dart';
import 'home_screen.dart';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _key,
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
                      controller: emailController,
                      decoration: InputDecoration(
                          labelText: 'Enter Email',
                          labelStyle: const TextStyle(color: Colors.black),
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
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Field is required";
                        }
                        return null;
                      },
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                          labelText: 'Enter Password',
                          labelStyle: TextStyle(color: Colors.black),
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
                    SizedBox(
                      height: 15,
                    ),

                    ElevatedButton(
                      onPressed: () async {
                        if (_key.currentState!.validate()) {
                          await _login();
                        }
                      },
                      child: Text(
                        'LOGIN',
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
    );
  }

  _login() async {
    setState(() {
      loading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      String fcmToken = await DBOperations.getDeviceTokenToSendNotification();
      List<String> tokenList = [fcmToken];
      await FirebaseFirestore.instance.collection(Collections.users).doc(FirebaseAuth.instance.currentUser!.uid).update({"fcmTokens":FieldValue.arrayUnion(tokenList)});
      Get.offAll(() => const HomeScreen());
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }

    setState(() {
      loading = false;
    });
  }
}
