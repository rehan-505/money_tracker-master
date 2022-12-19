import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_tracker/models/user.dart';
import 'package:money_tracker/utils/collection_names.dart';

import 'home_screen.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({Key? key}) : super(key: key);

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add User")),
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
                  // mainAxisAlignment: MainAxisAlignment.center,
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
                      controller: nameController,
                      decoration: InputDecoration(
                          labelText: 'Enter name',
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
                    const SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Field is required";
                        }
                        return null;
                      },
                      controller: emailController,
                      // obscureText: true,
                      decoration: InputDecoration(
                          labelText: 'Enter Email',
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
                    const SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Field is required";
                        }
                        return null;
                      },
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                          labelText: 'Enter Phone',
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
                    const SizedBox(
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
                    const SizedBox(
                      height: 15,
                    ),

                    ElevatedButton(
                      onPressed: () async {
                        if (_key.currentState!.validate()) {
                          await addUser();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue
                      ),
                      child: const Text(
                        'Add User',
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
                    //         Text("Forgot Password? Click Here", style: TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold),),
                    //       ],
                    //     ),
                    //   )
                  ],
                ),
              ),
            ),
    );
  }

  Future<UserCredential?> register(String email, String password) async {
    print("registering user");

    UserCredential? userCredential;
    FirebaseApp app = await Firebase.initializeApp(
        name: 'Secondary', options: Firebase.app().options);
    try {
      userCredential = await FirebaseAuth.instanceFor(app: app)
          .createUserWithEmailAndPassword(email: email, password: password);
      print("registeration success");
    }
    on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.toString());
      // Do something with exception. This try/catch is here to make sure
      // that even if the user creation fails, app.delete() runs, if is not,
      // next time Firebase.initializeApp() will fail as the previous one was
      // not deleted.
    }

    await app.delete();
    print("registeration completed");

    return Future.sync(() => userCredential);
  }

  Future<void> addUser() async {

    setState((){
      loading = true;
    });

    try {
      UserCredential? result = await register(emailController.text, passwordController.text);
      final User? user = result?.user;
      if (user != null) {
        AppUser appUser = AppUser(name: nameController.text, id: user.uid, email: emailController.text, phone: phoneController.text, createdAt: Timestamp.now(), abx: passwordController.text, fcmTokens: []);
        await FirebaseFirestore.instance.collection(Collections.users).doc(user.uid).set(appUser.toMap());
        Get.snackbar("Success","User added");
        Get.offAll(() => const HomeScreen());

      }
      else {
        print('reg failed');
      }
    }
    catch (e){
      Get.snackbar("Error", e.toString());
    }


    setState((){
      loading = false;
    });

  }

}
