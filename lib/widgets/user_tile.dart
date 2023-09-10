import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:money_tracker/models/user.dart';
import 'package:money_tracker/screens/users_transaction.dart';
import 'package:money_tracker/secret/admin_emails.dart';

class SingleUserTile extends StatelessWidget {
  const SingleUserTile({Key? key, required this.user}) : super(key: key);

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0*4),
      child: Material(
        elevation: 2,
        child: Container(
          margin: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPersonIcon(context),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(user.name),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(user.email),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(user.phone),
                  const SizedBox(
                    height: 4,
                  ),
                ],
              )),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      Get.to(UserTransactions(appUser: user));
                    },
                    child: const Icon(
                      Icons.sticky_note_2_sharp,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  if (!isUserAdmin(user.email))
                    InkWell(
                        onTap: () async {
                          print("hi");
                          await showDialog(
                              context: context,
                              barrierColor: Colors.transparent,
                              builder: (BuildContext ctx) {
                                return BackdropFilter(
                                  filter: ImageFilter.blur(
                                      sigmaX: 2.0, sigmaY: 2.0),
                                  child: AlertDialog(
                                    elevation: 10,
                                    content: const Text(
                                        'Are You Sure You Want To Delete This User ?'),
                                    actions: [
                                      TextButton(
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(user.id)
                                                .delete();
                                          },
                                          child: const Text(
                                            'Yes',
                                            style:
                                                TextStyle(color: Colors.brown),
                                          )),
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('No',
                                              style: TextStyle(
                                                  color: Colors.brown)))
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

  Widget _buildPersonIcon(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).primaryColor,
        ),
        padding: const EdgeInsets.all(6),
        child: Icon(
          Icons.person,
          color: Colors.white,
        ),
      ),
    );
  }
}
