import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:listipede/domain/entities/product.dart';
import 'package:listipede/domain/repositories/product_repository.dart';
import 'package:listipede/presentation/widgets/product_bottom_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final Function() refreshCallback;

  ProductCard({required this.product, required this.refreshCallback});

  @override
  Widget build(BuildContext context) {
    return PlatformListTile(
      title: Text(product.name),
      trailing: PlatformIconButton(
        materialIcon: const Icon(Icons.more_vert),
        cupertinoIcon: const Icon(CupertinoIcons.ellipsis_vertical),
        cupertino: (_, __) => CupertinoIconButtonData(padding: EdgeInsets.zero),
        onPressed: () {
          showProductBottomSheet(context, product, refreshCallback);
        },
      ),
    );
  }
}
