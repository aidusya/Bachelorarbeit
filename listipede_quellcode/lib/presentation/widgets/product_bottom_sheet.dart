import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:listipede/domain/entities/product.dart';
import 'package:listipede/domain/repositories/product_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

void showProductBottomSheet(
    BuildContext context, Product product, Function refreshCallback) {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  if (Platform.isAndroid) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        final List<Widget> tiles = [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Produkt umbenennen'),
            onTap: () {
              Navigator.pop(context);
              ProductRepository()
                  .productRenameDialog(context, product.id, refreshCallback);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Produkt löschen'),
            onTap: () {
              Navigator.pop(context);
              ProductRepository()
                  .deleteProductDialog(context, userId, refreshCallback);
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
              ProductRepository()
                  .productRenameDialog(context, product.id, refreshCallback);
            },
            child: const Text('Produkt umbenennen'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              ProductRepository()
                  .deleteProductDialog(context, userId, refreshCallback);
            },
            child: const Text('Produkt löschen'),
          ),
        ];
        return CupertinoActionSheet(
          actions: tiles,
        );
      },
    );
  }
}
