import 'dart:ui';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_tracker/models/category.dart';
import 'package:money_tracker/widgets/category_tile.dart';
import 'package:uuid/uuid.dart';

import '../utils/collection_names.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({Key? key}) : super(key: key);

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {

  List<CategoryModel> categories = [];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Manage Categories"), centerTitle: true,),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(Collections.categories).orderBy('index')
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

               categories =  snapshot.data!.docs.map((e) => CategoryModel.fromMap(e.data())).toList();

              return ReorderableCategoriesList(categories: categories);


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
                    title: const Text("Add new category"),
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
                              CategoryModel categoryModel = CategoryModel(title: controller.text, uid: const Uuid().v4(), createdAt: Timestamp.now(), colorCode: (math.Random().nextDouble() * 0xFFFFFF).toInt(), index: categories.length);
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

class ReorderableCategoriesList extends StatefulWidget {
  const ReorderableCategoriesList({Key? key, required this.categories}) : super(key: key);

  final List<CategoryModel> categories;

  @override
  State<ReorderableCategoriesList> createState() => _ReorderableCategoriesListState();
}

class _ReorderableCategoriesListState extends State<ReorderableCategoriesList> {
  @override
  Widget build(BuildContext context) {
    return ReorderableList(
      shrinkWrap: true,
      itemCount: widget.categories.length ,
      itemBuilder: (context, index) {
        return Container(
            key: ValueKey(index),
            child: CategoryTile(category: widget.categories[index], index: index,));
      }, onReorder: (int oldIndex, int newIndex) async{
      // CategoryModel categoryModel = widget.categories.removeAt(oldIndex);
      // widget.categories.insert( newIndex > oldIndex ?   newIndex-1 : newIndex, categoryModel);


      FirebaseFirestore.instance.collection('categories').doc(widget.categories[oldIndex].uid).update({
        'index' : newIndex
      });

      FirebaseFirestore.instance.collection('categories').doc(widget.categories[newIndex].uid).update({
        'index' : oldIndex
      });

    },);
  }
}

