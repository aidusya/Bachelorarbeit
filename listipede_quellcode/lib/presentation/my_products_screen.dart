import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:listipede/domain/repositories/product_repository.dart';
import 'package:listipede/domain/entities/product.dart';
import 'package:listipede/presentation/widgets/product_card.dart';

class MyProductsScreen extends StatefulWidget {
  static const routeName = '/my-products';
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  MyProductsScreen({super.key});

  @override
  _MyProductsScreenState createState() =>
      _MyProductsScreenState(userId: userId);
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  List<Product> products = [];
  final String userId;
  _MyProductsScreenState({required this.userId});

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
        title: Text('Meine Produkte'),
        material: (_, __) => MaterialAppBarData(
          centerTitle: true,
        ),
        cupertino: (_, __) =>
            CupertinoNavigationBarData(previousPageTitle: 'Listen'),
      ),
      body: FutureBuilder<List<Product>>(
        future: ProductRepository().getUserProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: PlatformCircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          }

          List<Product> products = snapshot.data ?? [];

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductCard(
                product: products[index],
                refreshCallback: refresh,
              );
            },
          );
        },
      ),
    );
  }
}
