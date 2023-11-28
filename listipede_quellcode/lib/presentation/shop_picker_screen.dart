import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:listipede/config/style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:listipede/domain/repositories/shop_repository.dart';
import 'package:listipede/domain/entities/shop.dart';
import 'package:listipede/presentation/widgets/shop_card.dart';

class ShopPickerScreen extends StatefulWidget {
  static const routeName = '/shop-picker';
  final String listId;
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  ShopPickerScreen({super.key, required this.listId});

  @override
  _ShopPickerScreenState createState() =>
      _ShopPickerScreenState(listId: listId, userId: userId);
}

class _ShopPickerScreenState extends State<ShopPickerScreen> {
  List<Shop> shops = [];
  final String listId;
  final String userId;
  _ShopPickerScreenState({required this.listId, required this.userId});

  @override
  void initState() {
    super.initState();
  }

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text('Ladenauswahl'),
        material: (_, __) => MaterialAppBarData(
          centerTitle: true,
        ),
        cupertino: (_, __) => CupertinoNavigationBarData(
            previousPageTitle: 'Zurück',
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(CupertinoIcons.add),
              onPressed: () async {
                await ShopRepository()
                    .shopCreateDialogue(context, userId, refresh);
              },
            )),
      ),
      body: FutureBuilder<List<Shop>>(
        future: ShopRepository().getUserShops(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: PlatformCircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          }

          List<Shop> shops = snapshot.data ?? [];

          return FutureBuilder<String>(
            future: ShopRepository().getCurrentShopId(userId, listId),
            builder: (context, shopIdSnapshot) {
              if (shopIdSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: PlatformCircularProgressIndicator());
              }

              if (shopIdSnapshot.hasError) {
                return Center(child: Text('Fehler: ${shopIdSnapshot.error}'));
              }

              String currentShopId = shopIdSnapshot.data ?? '';

              return ListView.builder(
                itemCount: shops.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ShopCard(
                      shop: Shop(
                          id: '',
                          creatorId: '',
                          name: 'Kein Laden (ohne Sortierung)'),
                      listId: listId,
                      isActiveShop: currentShopId == '',
                      refreshCallback: refresh,
                    );
                  } else {
                    return ShopCard(
                      shop: shops[index - 1],
                      listId: listId,
                      isActiveShop: shops[index - 1].id == currentShopId,
                      refreshCallback: refresh,
                    );
                  }
                },
              );
            },
          );
        },
      ),
      material: (_, __) => MaterialScaffoldData(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await ShopRepository().shopCreateDialogue(context, userId, refresh);
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
