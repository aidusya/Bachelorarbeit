import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:listipede/domain/entities/shopping_list.dart';

class ListShareRepository {
  static Future<void> handleShareButton(
      BuildContext context, String shoppingListId) async {
    await inviteUserToShoppingList(context, shoppingListId);
  }

  static Future<void> inviteUserToShoppingList(
      BuildContext context, String shoppingListId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final email = await _showEmailInputDialog(context);
      if (email != null) {
        final emailUser = await _getUserByEmail(email);
        if (emailUser != null) {
          final userId = emailUser.id;
          final result = await _updateShoppingListUsers(shoppingListId, userId);
          final shoppingListName = await _getShoppingListName(shoppingListId);
          _handleResult(context, result, shoppingListId, userId, email);
        } else {
          final userId = 'NOT_FOUND';
          _handleResult(context, 'error', shoppingListId, '', email);
        }
      }
    }
  }

  static Future<void> removeUserFromShoppingList(
      BuildContext context, String shoppingListId, String userId) async {
    final ref = FirebaseDatabase.instance.ref('shoppinglists/$shoppingListId');
    final event = await ref.once();
    debugPrint('Attempting to remove user $userId from list $shoppingListId');
    final data = event.snapshot.value as Map;
    if (data['userIds'][userId] == true) {
      await ref.child('userIds').update({userId: null});
      debugPrint('Successfully removed user from list!');
    } else {
      debugPrint('User not found in this list');
    }
  }

  static Future<void> userRemovalDialogue(
      BuildContext context, String shoppingListId, String userId) async {
    final shoppingListName = await _getShoppingListName(shoppingListId);
    return showPlatformDialog(
      context: context,
      builder: (context) {
        return PlatformAlertDialog(
          title: const Text("Nutzer entfernen"),
          content: Text("Möchtest du diesen Nutzer wirklich entfernen?"),
          actions: <Widget>[
            PlatformDialogAction(
              child: const Text("Zurück"),
              onPressed: () => Navigator.pop(context),
            ),
            PlatformDialogAction(
              child: const Text("OK"),
              onPressed: () async {
                await removeUserFromShoppingList(
                    context, shoppingListId, userId);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Stream<List<String>> usersForList(String shoppingListId) {
    return FirebaseDatabase.instance
        .ref()
        .child('shoppinglists')
        .child(shoppingListId)
        .child('userIds')
        .onValue
        .map((event) {
      final dynamic data = event.snapshot.value;
      final List<String> listUserIds = [];

      if (data is Map<dynamic, dynamic>) {
        data.forEach((key, value) {
          listUserIds.add(key);
        });
      }

      return listUserIds;
    });
  }

  static Future<String?> _showEmailInputDialog(BuildContext context) async {
    String? email;
    await showPlatformDialog(
      context: context,
      builder: (context) {
        return PlatformAlertDialog(
          title: const Text("Nutzer hinzufügen"),
          content: PlatformTextFormField(
            hintText: "E-Mail",
            onChanged: (value) => email = value,
          ),
          actions: <Widget>[
            PlatformDialogAction(
              child: const Text("Zurück"),
              onPressed: () => Navigator.pop(context),
            ),
            PlatformDialogAction(
              child: const Text("OK"),
              onPressed: () => Navigator.pop(context, email),
            ),
          ],
        );
      },
    );
    return email;
  }

  static Future<DocumentSnapshot?> _getUserByEmail(String email) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first;
    } else {
      return null;
    }
  }

  static Future<String> _updateShoppingListUsers(
      String shoppingListId, String userId) async {
    final ref = FirebaseDatabase.instance.ref('shoppinglists/$shoppingListId');
    final event = await ref.once();
    if (event.snapshot.exists) {
      final data = event.snapshot.value as Map;
      if (data['userIds'][userId] == true) {
        return 'duplicate';
      } else if (userId == 'NOT_FOUND') {
        return 'error';
      }
      await ref.child('userIds').update({userId: true});
      return 'success';
    } else {
      return 'error';
    }
  }

  static void _handleResult(BuildContext context, String result,
      String shoppingListId, String userId, String email) {
    if (result == 'success') {
      _showSuccessMessage(context);
    } else if (result == 'duplicate') {
      _showErrorDuplicateMessage(context, shoppingListId, userId, email);
    } else if (result == 'error') {
      _showErrorMessage(context, email);
    }
  }

  static Future<void> _showSuccessMessage(BuildContext context) {
    return showPlatformDialog(
      context: context,
      builder: (context) {
        return PlatformAlertDialog(
          title: const Text("Nutzer hinzugefügt"),
          content: const Text("Der Nutzer wurde erfolgreich hinzugefügt!"),
          actions: <Widget>[
            PlatformDialogAction(
              child: const Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _showErrorDuplicateMessage(BuildContext context,
      String shoppingListId, String userId, String email) {
    return showPlatformDialog(
      context: context,
      builder: (context) {
        return PlatformAlertDialog(
          title: const Text("Fehler"),
          content: Text("Nutzer $email hat schon Zugriff auf diese Liste!"),
          actions: <Widget>[
            PlatformDialogAction(
              child: const Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _showErrorMessage(BuildContext context, String email) {
    return showPlatformDialog(
      context: context,
      builder: (context) {
        return PlatformAlertDialog(
          title: const Text("Fehler"),
          content: Text("Kein Nutzer mit der E-Mail $email vorhanden!"),
          actions: <Widget>[
            PlatformDialogAction(
              child: const Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  static Future<String> _getShoppingListName(String shoppingListId) async {
    final shoppingListDoc = await FirebaseFirestore.instance
        .collection('shoppinglists')
        .doc(shoppingListId)
        .get();
    if (shoppingListDoc.exists) {
      return shoppingListDoc.data()!['name'];
    }
    return 'Unbekannte Einkaufsliste';
  }
}
