import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:listipede/domain/entities/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ProductRepository {
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  Future<List<Product>> getUserProducts() async {
    User? user = FirebaseAuth.instance.currentUser;
    List<Product> products = [];

    if (user != null) {
      QuerySnapshot<Map<String, dynamic>> shopSnapshot = await FirebaseFirestore
          .instance
          .collection('products')
          .where('createdBy', isEqualTo: user.uid)
          .get();

      products = shopSnapshot.docs.map((doc) {
        return Product(
          id: doc.id,
          name: doc.data()['name'] ?? '',
        );
      }).toList();
    }

    return products;
  }

  Future<void> renameProduct(
      String productId, String newName, Function refreshCallback) async {
    DocumentReference productRef =
        firestore.collection('products').doc(productId);

    await productRef.update({
      'name': newName,
    });
    refreshCallback();
  }

  Future<void> productRenameDialog(
      BuildContext context, String productId, Function refreshCallback) async {
    final TextEditingController productNameController = TextEditingController();
    return showPlatformDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PlatformAlertDialog(
          title: const Text('Produkt umbenennen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PlatformTextFormField(
                controller: productNameController,
                hintText: 'Name des Produkts',
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
                renameProduct(
                    productId, productNameController.text, refreshCallback);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteProduct(String productId, Function refreshCallback) async {
    DocumentReference productRef =
        FirebaseFirestore.instance.collection('products').doc(productId);

    await productRef.delete();
    refreshCallback();
  }

  Future<void> deleteProductDialog(
      BuildContext context, String productId, Function refreshCallback) async {
    return showPlatformDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PlatformAlertDialog(
          title: const Text('Produkt löschen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Möchtest du dieses Produkt wirklich löschen?'),
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
                deleteProduct(productId, refreshCallback);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
