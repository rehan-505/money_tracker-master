import 'dart:ui';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_tracker/models/category.dart';
import 'package:money_tracker/widgets/category_tile.dart';
import 'package:uuid/uuid.dart';

import '../utils/collection_names.dart';


class ManageCategoriesScreen extends StatelessWidget {
  const ManageCategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Categories"), centerTitle: true,),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(Collections.categories).orderBy('createdAt')
                .snapshots(),
            builder: (context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: Text("No categories to show"),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Text("Loading categories"),
                );
              }

              if (snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text("No categories to show"),
                );
              }

              // List<QueryDocumentSnapshot> documents = snapshot.data!.docs.sort()

              return ListView.builder(
                  itemCount: snapshot.data!.size ,
                  itemBuilder: (context, index) {
                    return CategoryTile(category: CategoryModel.fromMap(snapshot.data!.docs[index].data()));
                  });
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          TextEditingController controller = TextEditingController();
          await showDialog(
              context: context,
              barrierColor: Colors.transparent,
              builder: (BuildContext ctx) {
                return BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                  child: AlertDialog(
                    elevation: 10,
                    title: Text("Add new category"),
                    content: TextFormField(
                      controller: controller,
                      decoration: const InputDecoration(
                        labelText: "Category Title",
                        isDense: true,
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(),
                      ),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child:
                          const Text('Cancel', style: TextStyle(color: Colors.blue))),
                      TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            if(controller.text.isNotEmpty){
                              CategoryModel categoryModel = CategoryModel(title: controller.text, uid: const Uuid().v4(), createdAt: Timestamp.now(), colorCode: (math.Random().nextDouble() * 0xFFFFFF).toInt());
                              try{
                                await FirebaseFirestore.instance
                                    .collection(Collections.categories)
                                    .doc(categoryModel.uid)
                                    .set(categoryModel.toMap());
                              }
                              catch(e){
                                print(e);
                                Get.snackbar("Error", e.toString());
                              }
                            }
                          },
                          child: const Text(
                            'Add',
                            style: TextStyle(color: Colors.blue),
                          )),
                    ],
                  ),
                );
              });
          // Get.to(AddUserScreen());
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
