import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:money_tracker/models/category.dart';
import 'package:money_tracker/utils/collection_names.dart';
import 'package:money_tracker/utils/db_operations.dart';

class CategoryTile extends StatelessWidget {
  const CategoryTile({Key? key, required this.category}) : super(key: key);

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {

    // print(DBOperations.hexToColor(category.colorCode.toString()));

    print(int.parse("0x${category.colorCode}"));

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Material(
        elevation: 2,
        child: Container(
          margin: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.category,color: Color(category.colorCode).withOpacity(1)),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(category.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(category.colorCode).withOpacity(1)),),
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
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                                          await FirebaseFirestore.instance
                                              .collection(Collections.categories)
                                              .doc(category.uid)
                                              .delete();

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
              )
            ],
          ),
        ),
      ),
    );
  }
}