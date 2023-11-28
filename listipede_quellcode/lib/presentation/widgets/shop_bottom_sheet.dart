import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:listipede/domain/entities/shop.dart';
import 'package:listipede/domain/repositories/shop_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

void showShopBottomSheet(
    BuildContext context, Shop shop, Function refreshCallback) {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  if (Platform.isAndroid) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        final List<Widget> tiles = [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Laden umbenennen'),
            onTap: () {
              Navigator.pop(context);
              ShopRepository()
                  .shopRenameDialog(context, shop.id, userId, refreshCallback);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Laden löschen'),
            onTap: () {
              Navigator.pop(context);
              ShopRepository()
                  .shopDeleteDialog(context, userId, shop.id, refreshCallback);
            },
          ),
        ];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: tiles,
        );
      },
    );
  } else {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        final List<Widget> tiles = [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              ShopRepository()
                  .shopRenameDialog(context, shop.id, userId, refreshCallback);
            },
            child: const Text('Laden umbenennen'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              ShopRepository()
                  .shopDeleteDialog(context, userId, shop.id, refreshCallback);
            },
            child: const Text('Laden löschen'),
          ),
        ];
        return CupertinoActionSheet(
          actions: tiles,
        );
      },
    );
  }
}
