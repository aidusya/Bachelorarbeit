import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:listipede/domain/entities/shopping_list.dart';
import 'package:listipede/domain/repositories/list_share_repository.dart';
import 'package:listipede/domain/repositories/list_of_lists_repository.dart';

void shoppingListBottomSheet(BuildContext context, ShoppingList shoppingList) {
  final bool canLeaveList = shoppingList.userIds.length > 1;
  if (Platform.isAndroid) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        final List<Widget> tiles = [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Liste umbenennen'),
            onTap: () {
              ListOfListsRepository()
                  .listRenameDialog(context, shoppingList.id);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Nutzer verwalten'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/list-users',
                  arguments: shoppingList);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Liste löschen'),
            onTap: () {
              ListOfListsRepository()
                  .listDeleteDialog(context, shoppingList.id);
            },
          ),
        ];
        if (canLeaveList) {
          tiles.add(
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Liste verlassen'),
              onTap: () {
                ListOfListsRepository()
                    .listLeaveDialog(context, shoppingList.id);
              },
            ),
          );
        }
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
              ListOfListsRepository()
                  .listRenameDialog(context, shoppingList.id);
            },
            child: const Text('Liste umbenennen'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/list-users',
                  arguments: shoppingList);
            },
            child: const Text('Nutzer verwalten'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              ListOfListsRepository()
                  .listDeleteDialog(context, shoppingList.id);
            },
            child: const Text('Liste löschen'),
          ),
        ];
        if (canLeaveList) {
          tiles.add(
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                ListOfListsRepository()
                    .listLeaveDialog(context, shoppingList.id);
              },
              child: const Text('Liste verlassen'),
            ),
          );
        }
        return CupertinoActionSheet(
          actions: tiles,
        );
      },
    );
  }
}
