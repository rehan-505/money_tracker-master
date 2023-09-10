import 'package:firebase_auth/firebase_auth.dart';

List<String> adminEmails = [
  "admin@dl.com",
  "new_admin@dl.com",
];

bool isUserAdmin(String email)=> adminEmails.any((element)=>element==email);

bool isCurrentUserAdmin()=> adminEmails.any((element)=>element==FirebaseAuth.instance.currentUser!.email!);