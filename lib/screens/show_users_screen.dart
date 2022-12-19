import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_tracker/models/user.dart';
import 'package:money_tracker/screens/add_user_screen.dart';
import 'package:money_tracker/widgets/user_tile.dart';

import '../utils/collection_names.dart';

class UsersListScreen extends StatelessWidget {
  const UsersListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Users"), centerTitle: true,),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(Collections.users).orderBy("createdAt", descending: true)
                .snapshots(),
            builder: (context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: Text("No users to show"),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Text("Loading users"),
                );
              }

              if (snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text("No users to show"),
                );
              }

              // List<QueryDocumentSnapshot> documents = snapshot.data!.docs.sort()

              return ListView.builder(
                  itemCount: snapshot.data!.size ,
                  itemBuilder: (context, index) {
                    return SingleUserTile(user: AppUser.fromMap(snapshot.data!.docs[index].data()));
                  });
            }),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: (){
            Get.to(AddUserScreen());
          },
        child: Icon(Icons.add),
      ),
    );
  }
}

