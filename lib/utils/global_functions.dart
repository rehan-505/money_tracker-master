import 'package:flutter/material.dart';

import '../main.dart';
import '../models/category.dart';


///build
Widget amountContainer(
    String title, double amount, double totalAdded, double totalWithdrawal) {
  return SizedBox(
    width: double.infinity,
    child: Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(
              height: 20,
            ),
            Text(
              amount.toStringAsFixed(1),
              style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Added:",

                        style: TextStyle(fontSize: 12),

                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        totalAdded.toStringAsFixed(1),
                        style: const TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold,
                            fontSize: 12

                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      const Text("Withdrawn:",
                        style: TextStyle(fontSize: 12),

                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        totalWithdrawal.toStringAsFixed(1),
                        style: const TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold,
                            fontSize: 12
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

///order the category list according to globalMapCategoryOrder
List<CategoryModel> reorderList(List<CategoryModel> categoriesList){

  if(categoriesList.isEmpty){
    return categoriesList;
  }

  Map<String,CategoryModel> categoryAndIdMap = {};
  for (var element in categoriesList) {
    categoryAndIdMap[element.uid] = element;
  }

  List<CategoryModel> orderCategories = categoriesList;

  for (var index in categoryOrderMapGlobal.keys) {
    orderCategories[int.parse(index)] = categoryAndIdMap[categoryOrderMapGlobal[index]]!;
  }

  return orderCategories;

}