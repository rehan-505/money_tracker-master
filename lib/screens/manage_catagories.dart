import 'dart:ui';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_tracker/controllers/category_controller.dart';
import 'package:money_tracker/main.dart';
import 'package:money_tracker/models/category.dart';
import 'package:money_tracker/widgets/category_tile.dart';
import 'package:uuid/uuid.dart';

import '../utils/collection_names.dart';


class ManageCategoriesScreen extends StatelessWidget {

  List<CategoryModel> categories = [];

  ///turn it false to generate Document
  bool docUploaded = true;
  CategoryController categoryController = CategoryController();


  ManageCategoriesScreen({super.key});



  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(title: const Text("Manage Categories"), centerTitle: true,
      actions:  [
        Obx(() => InkWell(
          onTap: (((categoryController.orderChanged.value)) && !(categoryController.loading.value)) ? ()async{
            await categoryController.uploadDoc();
          } : null,
          child: Icon(Icons.save,
            color: (((categoryController.orderChanged.value)) && !(categoryController.loading.value)) ? Colors.white : Colors.grey,
          ),
        )),
        const SizedBox(width: 20,)
      ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
        child: FutureBuilder(
            future: FirebaseFirestore.instance
                .collection(Collections.categories).get(),
            builder: (context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                snapshot) {


              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Text("Loading categories"),
                );
              }


              if (!snapshot.hasData) {
                return const Center(
                  child: Text("No categories to show"),
                );
              }


              if (snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text("No categories to show"),
                );
              }

              // List<QueryDocumentSnapshot> documents = snapshot.data!.docs.sort()
              categories =  snapshot.data!.docs.map((e) => CategoryModel.fromMap(e.data())).toList();

              print('categories length: ${categories.length}');

              Map<String,CategoryModel> categoryAndIdMap = {};
              for (var element in categories) {
                categoryAndIdMap[element.uid] = element;
              }


              ///to generate order saving document
              if(!docUploaded){
                uploadDoc();
              }
              return ReorderableCategoriesList(categories: categories, categoryAndIdMap: categoryAndIdMap, categoryController: categoryController,);

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
                              await categoryController.addCategory(categoryModel);

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
        child: const Icon(Icons.add),
      ),

    );
  }

  // Future<Map> getCategoriesOrderMap() async{
  //  return categoryController.categoryOrderMap;
  // }

  uploadDoc() async{
    docUploaded = true;

    Map<String,dynamic> map = {};
    for (var element in categories) {
      map[element.index.toString()] = element.uid.toString();
    }

    await FirebaseFirestore.instance.collection('categories_order').doc('doc_order').set(map);

  }

}

class ReorderableCategoriesList extends StatefulWidget {
  const ReorderableCategoriesList({Key? key, required this.categories, required this.categoryAndIdMap, required this.categoryController}) : super(key: key);

  final List<CategoryModel> categories;
  final Map<String,CategoryModel> categoryAndIdMap;
  final CategoryController categoryController;

  @override
  State<ReorderableCategoriesList> createState() => _ReorderableCategoriesListState();
}

class _ReorderableCategoriesListState extends State<ReorderableCategoriesList> {


  @override
  void initState() {
    widget.categoryController.loading.value = false;
    widget.categoryController.orderCategories = widget.categories;

    print("in init state, categoryOrderMap keys length:${categoryOrderMapGlobal.keys.length}");
    print("in init state, category and id map: keys length:${categoryOrderMapGlobal.keys.length}");
    print("category and id map:");
    print(widget.categoryAndIdMap);
    for (var index in categoryOrderMapGlobal.keys) {
      if(widget.categoryAndIdMap[categoryOrderMapGlobal[index]]==null){
        print(categoryOrderMapGlobal[index] + " is null in category and ID map");
      }
      // print("category id")
      widget.categoryController.orderCategories[int.parse(index)] = widget.categoryAndIdMap[categoryOrderMapGlobal[index]]!;
    }


    super.initState();
  }


  @override
  Widget build(BuildContext context) {


    // print("order in ordered list:");
    // for (var element in orderCategories) {
    //   print(element.uid);
    // }

    return Obx(() => Container(
      child: widget.categoryController.loading.value ? const Center(child: CircularProgressIndicator(
        color: Colors.orange,
      )) : Padding(
        padding: const EdgeInsets.only(bottom: 18.0),
        child: ReorderableList(


          shrinkWrap: true,
          itemCount: widget.categoryController.orderCategories.length,
          itemBuilder: (context, index) {
            return Container(
                key: ValueKey(index),
                child: CategoryTile(category: widget.categoryController.orderCategories[index], index: index, orderedCategories: widget.categoryController.orderCategories,));
          }, onReorder: (int oldIndex, int newIndex) async{
          // CategoryModel categoryModel = widget.categories.removeAt(oldIndex);
          // widget.categories.insert( newIndex > oldIndex ?   newIndex-1 : newIndex, categoryModel);

          widget.categoryController.orderChanged.value = true;

          if(newIndex > oldIndex){

            newIndex = newIndex - 1;

            CategoryModel tempCategoryModel = widget.categoryController.orderCategories[newIndex];
            widget.categoryController.orderCategories[newIndex] = widget.categoryController.orderCategories[oldIndex];
            print("*************");
            print("category at order $newIndex");
            print(widget.categoryController.orderCategories[newIndex].uid);
            print("*************");


            for (int i=oldIndex;i<newIndex;i++){
              widget.categoryController.orderCategories[i] = widget.categoryController.orderCategories[i+1];
            }
            widget.categoryController.orderCategories[newIndex-1] = tempCategoryModel;
          }

          else if (newIndex < oldIndex){

            CategoryModel tempCategoryModel = widget.categoryController.orderCategories[newIndex];
            widget.categoryController.orderCategories[newIndex] = widget.categoryController.orderCategories[oldIndex];
            for (int i=oldIndex;i>newIndex;i--){
              widget.categoryController.orderCategories[i] = widget.categoryController.orderCategories[i-1];
            }
            widget.categoryController.orderCategories[newIndex+1] = tempCategoryModel;


          }

          print("old index is $oldIndex");
          print("new index is $newIndex");


        },),
      ),
    ));
  }

}