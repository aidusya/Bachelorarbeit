import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:listipede/domain/entities/shopping_list.dart';
import 'package:listipede/domain/repositories/shop_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:listipede/config/style.dart';

class ShopIndicator extends StatefulWidget {
  final ShoppingList shoppingList;
  final bool shoppingMode;
  ShopIndicator({required this.shoppingList, required this.shoppingMode});

  @override
  _ShopIndicatorState createState() => _ShopIndicatorState();
}

class _ShopIndicatorState extends State<ShopIndicator> {
  late Stream<String> _shopNameStream;

  @override
  void initState() {
    super.initState();
    final String listId = widget.shoppingList.id;
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    _shopNameStream = ShopRepository().getCurrentShopNameStream(userId, listId);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: _shopNameStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color:
                Platform.isAndroid ? listipalette : CupertinoColors.systemGrey4,
            child: Center(
              child: PlatformCircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError ||
            snapshot.data == null ||
            snapshot.data!.isEmpty) {
          if (widget.shoppingMode == false) {
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/shop-picker',
                    arguments: widget.shoppingList.id);
              },
              child: Container(
                padding: EdgeInsets.all(8.0),
                color: Platform.isAndroid
                    ? listipalette
                    : CupertinoColors.systemGrey4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Einkaufen ohne Sortierung ',
                      style: TextStyle(
                          color:
                              Platform.isAndroid ? Colors.white : Colors.black,
                          fontSize: 18),
                    ),
                    if (Platform.isAndroid)
                      Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 18,
                      )
                    else if (Platform.isIOS)
                      Icon(
                        CupertinoIcons.pencil,
                        color: Colors.black,
                        size: 18,
                      )
                  ],
                ),
              ),
            );
          } else if (widget.shoppingMode == true) {
            return Container(
              padding: EdgeInsets.all(8.0),
              color: Platform.isAndroid
                  ? listipalette
                  : CupertinoColors.systemGrey4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Einkaufen ohne Sortierung',
                    style: TextStyle(
                        color: Platform.isAndroid ? Colors.white : Colors.black,
                        fontSize: 18),
                  ),
                ],
              ),
            );
          }
        }

        String shopName = snapshot.data!;
        if (widget.shoppingMode == false) {
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/shop-picker',
                  arguments: widget.shoppingList.id);
            },
            child: Container(
              padding: EdgeInsets.all(16.0),
              color: Platform.isAndroid
                  ? listipalette
                  : CupertinoColors.systemGrey4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Einkaufen in: ',
                    style: TextStyle(
                        color: Platform.isAndroid ? Colors.white : Colors.black,
                        fontSize: 18),
                  ),
                  Text(
                    '$shopName ',
                    style: TextStyle(
                        color: Platform.isAndroid ? Colors.white : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  if (Platform.isAndroid)
                    Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 18,
                    )
                  else if (Platform.isIOS)
                    Icon(
                      CupertinoIcons.pencil,
                      color: Colors.black,
                      size: 18,
                    )
                ],
              ),
            ),
          );
        } else {
          return Container(
            padding: EdgeInsets.all(8.0),
            color:
                Platform.isAndroid ? listipalette : CupertinoColors.systemGrey4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Einkaufen in: ',
                  style: TextStyle(
                      color: Platform.isAndroid ? Colors.white : Colors.black,
                      fontSize: 18),
                ),
                Text(
                  '$shopName',
                  style: TextStyle(
                      color: Platform.isAndroid ? Colors.white : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
