import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:listipede/domain/entities/shop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ShopRepository {
  Future<List<Shop>> getUserShops() async {
    User? user = FirebaseAuth.instance.currentUser;
    List<Shop> shops = [];

    if (user != null) {
      QuerySnapshot<Map<String, dynamic>> shopSnapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .collection('shops')
          .get();

      shops = shopSnapshot.docs.map((doc) {
        return Shop(
          id: doc.id,
          creatorId: user.uid,
          name: doc.data()['name'] ?? '',
        );
      }).toList();
    }

    return shops;
  }

  Future<String> getCurrentShopId(String userId, String listId) async {
    DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(userId)
        .collection('usedLists')
        .doc(listId)
        .get();

    String currentShopId = doc.data()?['currentShopId'] ?? '';

    if (currentShopId.isNotEmpty) {
      DocumentSnapshot<Map<String, dynamic>> shopDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(userId)
          .collection('shops')
          .doc(currentShopId)
          .get();

      if (!shopDoc.exists) {
        currentShopId = '';
      }
    } else {
      currentShopId = '';
    }
    return currentShopId;
  }

  Future<String> getShopNameById(String userId, String shopId) async {
    DocumentSnapshot<Map<String, dynamic>> shopDoc = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(userId)
        .collection('shops')
        .doc(shopId)
        .get();

    return shopDoc.data()?['name'] ?? '';
  }

  Future<String> getCurrentShopName(String userId, String listId) async {
    String shopId = await getCurrentShopId(userId, listId);
    String shopName = await getShopNameById(userId, shopId);
    return shopName;
  }

  Future<void> setShopAsCurrent(
      String userId, String listId, String shopId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('usedLists')
        .doc(listId)
        .set({
      'currentShopId': shopId,
    }, SetOptions(merge: true));
  }

  Future<void> createShop(
      String userId, String shopName, Function refreshCallback) async {
    CollectionReference shopsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('shops');
    String shopId = shopsCollection.doc().id;
    await shopsCollection.doc(shopId).set({
      'name': shopName,
    });
    refreshCallback();
  }

  Future<void> shopCreateDialogue(
      BuildContext context, String userId, Function refreshCallback) async {
    final TextEditingController shopNameController = TextEditingController();
    return showPlatformDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PlatformAlertDialog(
          title: const Text('Laden erstellen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PlatformTextFormField(
                controller: shopNameController,
                hintText: 'Name des Ladens',
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
              onPressed: () async {
                final String newShopName = shopNameController.text;
                bool isDuplicate = await ShopRepository()
                    .isShopNameDuplicate(userId, newShopName);
                if (isDuplicate) {
                  Navigator.of(context).pop();
                  showPlatformDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return PlatformAlertDialog(
                        title: const Text('Fehler'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                                'Ein Laden mit diesem Namen existiert bereits.'),
                          ],
                        ),
                        actions: <Widget>[
                          PlatformDialogAction(
                            child: const Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  createShop(userId, newShopName, refreshCallback);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> renameShop(String userId, String shopId, String newName,
      Function refreshCallback) async {
    DocumentReference shopRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('shops')
        .doc(shopId);

    await shopRef.update({'name': newName});
    refreshCallback();
  }

  Future<void> shopRenameDialog(BuildContext context, String shopId,
      String userId, Function refreshCallback) async {
    final TextEditingController shopNameController = TextEditingController();
    return showPlatformDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PlatformAlertDialog(
          title: const Text('Laden umbenennen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PlatformTextFormField(
                controller: shopNameController,
                hintText: 'Name des Ladens',
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
                renameShop(
                    userId, shopId, shopNameController.text, refreshCallback);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteShop(
      String userId, String shopId, Function refreshCallback) async {
    DocumentReference shopRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('shops')
        .doc(shopId);

    await shopRef.delete();
    refreshCallback();
  }

  Future<void> shopDeleteDialog(BuildContext context, String userId,
      String shopId, Function refreshCallback) async {
    return showPlatformDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PlatformAlertDialog(
          title: const Text('Laden löschen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Möchtest du diesen Laden wirklich löschen?'),
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
                deleteShop(userId, shopId, refreshCallback);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Stream<String> getCurrentShopNameStream(String userId, String listId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('usedLists')
        .doc(listId)
        .snapshots()
        .asyncMap((snapshot) async {
      final currentShopId = snapshot.data()?['currentShopId'] ?? '';
      if (currentShopId.isNotEmpty) {
        return await getShopNameById(userId, currentShopId);
      } else {
        return '';
      }
    });
  }

  Stream<String> getCurrentShopIdStream(String userId, String listId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('usedLists')
        .doc(listId)
        .snapshots()
        .map((snapshot) {
      return snapshot.data()?['currentShopId'] ?? '';
    });
  }

  Future<bool> isShopNameDuplicate(String userId, String shopName) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('shops')
              .where('name', isEqualTo: shopName)
              .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Fehler bei Laden-Duplikat-Erkennung: $e');
      return true;
    }
  }
}
