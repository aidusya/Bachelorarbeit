import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:listipede/domain/entities/shop.dart';
import 'package:listipede/domain/repositories/shop_repository.dart';
import 'package:listipede/presentation/widgets/shop_bottom_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShopCard extends StatelessWidget {
  final Shop shop;
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final String listId;
  bool isActiveShop;
  final Function() refreshCallback;

  ShopCard(
      {required this.shop,
      required this.isActiveShop,
      required this.listId,
      required this.refreshCallback});

  @override
  Widget build(BuildContext context) {
    if (shop.id == '') {
      return PlatformListTile(
        title: Text(shop.name),
        leading: isActiveShop
            ? PlatformIconButton(
                materialIcon: Icon(Icons.radio_button_checked),
                cupertinoIcon: Icon(CupertinoIcons.check_mark_circled),
                cupertino: (_, __) =>
                    CupertinoIconButtonData(padding: EdgeInsets.zero),
                onPressed: () async {
                  await ShopRepository().setShopAsCurrent(
                    userId,
                    listId,
                    shop.id,
                  );
                  refreshCallback();
                  Navigator.pop(context);
                },
              )
            : PlatformIconButton(
                materialIcon: Icon(Icons.radio_button_unchecked),
                cupertinoIcon: Icon(CupertinoIcons.circle),
                cupertino: (_, __) =>
                    CupertinoIconButtonData(padding: EdgeInsets.zero),
                onPressed: () async {
                  await ShopRepository().setShopAsCurrent(
                    userId,
                    listId,
                    shop.id,
                  );
                  refreshCallback();
                  Navigator.pop(context);
                },
              ),
      );
    } else {
      return PlatformListTile(
        title: Text(shop.name),
        trailing: PlatformIconButton(
          materialIcon: const Icon(Icons.more_vert),
          cupertinoIcon: const Icon(CupertinoIcons.ellipsis_vertical),
          cupertino: (_, __) =>
              CupertinoIconButtonData(padding: EdgeInsets.zero),
          onPressed: () {
            showShopBottomSheet(context, shop, refreshCallback);
          },
        ),
        leading: isActiveShop
            ? PlatformIconButton(
                materialIcon: Icon(Icons.radio_button_checked),
                cupertinoIcon: Icon(CupertinoIcons.check_mark_circled),
                cupertino: (_, __) =>
                    CupertinoIconButtonData(padding: EdgeInsets.zero),
                onPressed: () async {
                  await ShopRepository().setShopAsCurrent(
                    userId,
                    listId,
                    shop.id,
                  );
                  refreshCallback();
                  Navigator.pop(context);
                },
              )
            : PlatformIconButton(
                materialIcon: Icon(Icons.radio_button_unchecked),
                cupertinoIcon: Icon(CupertinoIcons.circle),
                cupertino: (_, __) =>
                    CupertinoIconButtonData(padding: EdgeInsets.zero),
                onPressed: () async {
                  await ShopRepository().setShopAsCurrent(
                    userId,
                    listId,
                    shop.id,
                  );
                  refreshCallback();
                  Navigator.pop(context);
                },
              ),
      );
    }
  }
}
