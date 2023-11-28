import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:listipede/domain/repositories/shopping_list_repository.dart';
import 'package:listipede/domain/entities/shopping_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class ListCreationDialog extends StatelessWidget {
  final TextEditingController _listNameController = TextEditingController();

  ListCreationDialog({super.key});
  @override
  Widget build(BuildContext context) {
    return PlatformAlertDialog(
      title: const Text('Neue Einkaufsliste erstellen'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PlatformTextFormField(
            controller: _listNameController,
            hintText: 'Name der Liste',
          ),
        ],
      ),
      actions: [
        PlatformDialogAction(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Zurück'),
        ),
        PlatformDialogAction(
          onPressed: () async {
            final listId = const Uuid().v4();
            final listName = _listNameController.text;
            final user = FirebaseAuth.instance.currentUser;
            if (listName.isEmpty) {
              return; //TODO: Fehler Listenname leer
            }
            if (user == null) {
              return; //TODO Fehler kein user
            }
            final newShoppingList = ShoppingList(
              id: listId,
              name: listName,
              userIds: [user.uid],
            );
            await ShoppingListRepository().createShoppingList(newShoppingList);
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
