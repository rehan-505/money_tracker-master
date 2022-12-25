import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:money_tracker/controllers/category_controller.dart';
import 'package:money_tracker/main.dart';
import 'package:money_tracker/models/category.dart';
import 'package:money_tracker/utils/collection_names.dart';
import 'package:money_tracker/utils/db_operations.dart';

class CategoryTile extends StatefulWidget {
  const CategoryTile({Key? key, required this.category, required this.index, required this.orderedCategories, }) : super(key: key);

  final CategoryModel category;
  final int index;
  final List<CategoryModel> orderedCategories;

  @override
  State<CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<CategoryTile> {

  int index = 0;
  bool deleted = false;

  @override
  void initState() {
    index = widget.index;
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {



    // FirebaseFirestore.instance.collection('categories').doc(widget.category.uid).update({
    //     'index': index
    //   });

    // print(DBOperations.hexToColor(category.colorCode.toString()));

    // print(int.parse("0x${widget.category.colorCode}"));

    return deleted ? SizedBox() : Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Material(
        elevation: 2,
        child: Container(
          margin: const EdgeInsets.all(16),
          child: Row(
            children: [

              ReorderableDragStartListener(
                // key: ValueKey(index) ,
                  index: index,
                  child: const Icon(Icons.drag_indicator,size: 35,color: Colors.grey,)),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.category.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(widget.category.colorCode).withOpacity(1)),),
                      const SizedBox(
                        height: 4,
                      ),
                      // Text(user.email),
                      // const SizedBox(
                      //   height: 4,
                      // ),
                      // Text(user.phone),
                      // const SizedBox(
                      //   height: 4,
                      // ),
                    ],
                  )),
              InkWell(
                  onTap: ()async{
                    int colorCode = (await showColorPickerDialog(context, Color(widget.category.colorCode))).value;
                    updateColor(colorCode);

                  },
                  child: Icon(Icons.color_lens,color: Color(widget.category.colorCode).withOpacity(1))),
              const SizedBox(width: 20,),
              InkWell(
                  onTap: () async{
                    await showDialog(
                        context: context,
                        barrierColor: Colors.transparent,
                        builder: (BuildContext ctx) {
                          return                       BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                            child: AlertDialog(
                              elevation: 10,
                              content: const Text('Are you sure you want to delete this category ?'),
                              actions: [
                                TextButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      setState(() {
                                        deleted = true;
                                      });
                                      Get.snackbar("Success","Category deleted", backgroundColor: Colors.white);
                                      widget.orderedCategories.removeWhere((element) => element.uid==widget.category.uid);

                                      await FirebaseFirestore.instance
                                          .collection(Collections.categories)
                                          .doc(widget.category.uid)
                                          .delete();

                                      await CategoryController.uploadDocGlobal(widget.orderedCategories);

                                    },
                                    child: const Text(
                                      'Yes',
                                      style: TextStyle(color: Colors.brown),
                                    )),
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child:
                                    const Text('No', style: TextStyle(color: Colors.brown)))
                              ],
                            ),
                          );
                        });


                  },
                  child: const Icon(
                    Icons.delete_forever_sharp,
                    color: Colors.red,
                  ))
            ],
          ),
        ),
      ),
    );
  }

  updateColor(int colorCode) async{

    if(colorCode==widget.category.colorCode){
      print("color code is same");
      return;
    }

    setState(() {
      widget.category.colorCode = colorCode;
    });


    // print("into update color");
    FirebaseFirestore.instance.collection('categories').doc(widget.category.uid).update({
      'colorCode': colorCode
    });
  }
}