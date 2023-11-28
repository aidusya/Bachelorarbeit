import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:listipede/domain/entities/shopping_list.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ListOfListsRepository {
  final DatabaseReference shoppingListsReference =
      FirebaseDatabase.instance.ref().child('shoppinglists');

  Stream<List<ShoppingList>> shoppingListsStreamForUser(String userId) {
    return shoppingListsReference.onValue.map((event) {
      final dynamic data = event.snapshot.value;
      final List<ShoppingList> shoppingLists = [];

      if (data is Map<dynamic, dynamic>) {
        data.forEach((key, value) {
          if (value is Map<dynamic, dynamic> &&
              value.containsKey('name') &&
              value.containsKey('userIds') &&
              value['userIds'][userId] == true) {
            shoppingLists.add(
              ShoppingList(
                id: key,
                name: value['name'],
                userIds: List<String>.from(value['userIds'].keys),
              ),
            );
          }
        });
      }

      return shoppingLists;
    });
  }

  Future<void> deleteShoppingList(String shoppingListId) async {
    final ref = shoppingListsReference.child(shoppingListId);
    final event = await ref.once();
    if (event.snapshot.exists) {
      await ref.remove();
    }
  }

  Future<void> listDeleteDialog(BuildContext context, String listId) async {
    return showPlatformDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PlatformAlertDialog(
          title: const Text('Liste löschen'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Möchtest du diese Liste wirklich löschen? Damit wird sie für ALLE Nutzer gelöscht.'),
              ],
            ),
          ),
          actions: <Widget>[
            PlatformDialogAction(
              child: const Text('Abbrechen'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            PlatformDialogAction(
              child: const Text('Löschen'),
              onPressed: () {
                deleteShoppingList(listId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> listLeaveDialog(BuildContext context, String listId) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    return showPlatformDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PlatformAlertDialog(
          title: const Text('Liste löschen'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Möchtest du diese Liste wirklich verlassen? Du kannst ihr jederzeit wieder beitreten, wenn du eingeladen wirst.'),
              ],
            ),
          ),
          actions: <Widget>[
            PlatformDialogAction(
              child: const Text('Abbrechen'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            PlatformDialogAction(
              child: const Text('OK'),
              onPressed: () {
                removeUserFromShoppingList(listId, currentUserId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> removeUserFromShoppingList(
      String shoppingListId, String userId) async {
    final ref = shoppingListsReference.child('$shoppingListId/userIds/$userId');
    await ref.remove();
  }

  Future<void> renameList(String shoppingListId, String newName) async {
    final ref = shoppingListsReference.child(shoppingListId);
    final event = await ref.once();
    if (event.snapshot.exists) {
      await ref.update({'name': newName});
    }
  }

  Future<void> listRenameDialog(BuildContext context, String listId) async {
    final TextEditingController listNameController = TextEditingController();
    return showPlatformDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PlatformAlertDialog(
          title: const Text('Liste umbenennen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PlatformTextFormField(
                controller: listNameController,
                hintText: 'Name der Liste',
              ),
            ],
          ),
          actions: <Widget>[
            PlatformDialogAction(
              child: const Text('Abbrechen'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            PlatformDialogAction(
              child: const Text('OK'),
              onPressed: () {
                renameList(listId, listNameController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
