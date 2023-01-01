import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../main.dart';
import '../models/category.dart';
import '../utils/collection_names.dart';

class CategoryController extends GetxController{
  Rx<bool> orderChanged = false.obs;



  List<CategoryModel> orderCategories = [];

  Rx<bool> loading = false.obs;

  uploadDoc() async{

    loading.value = true;
    Map<String,dynamic> map = {};
    for (int i=0; i<orderCategories.length; i++) {
      map[i.toString()] = orderCategories[i].uid.toString();
    }

    categoryOrderMapGlobal = map;

    await FirebaseFirestore.instance.collection('categories_order').doc('doc_order').set(map);
    loading.value = false;
    orderChanged = false.obs;

  }

  Future<void> addCategory(CategoryModel categoryModel) async{
    try{
      loading.value = true;
      // await Future.delayed(const Duration(seconds: 3));
      await FirebaseFirestore.instance
          .collection(Collections.categories)
          .doc(categoryModel.uid)
          .set(categoryModel.toMap());

      categoryOrderMapGlobal[orderCategories.length.toString()] = categoryModel.uid;
      orderCategories.add(categoryModel);

      Get.snackbar("Success", "New Category Added", backgroundColor: Colors.white);
      loading.value = false;

    }
    catch(e){
      print(e);
      Get.snackbar("Error", e.toString());
    }

  }

  static uploadDocGlobal(List<CategoryModel> orderCategories) async{

    Map<String,dynamic> map = {};
    for (int i=0; i<orderCategories.length; i++) {
      map[i.toString()] = orderCategories[i].uid.toString();
    }

    categoryOrderMapGlobal = map;

    await FirebaseFirestore.instance.collection('categories_order').doc('doc_order').set(map);

  }


}
