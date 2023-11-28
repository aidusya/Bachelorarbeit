import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:listipede/domain/entities/shopping_list.dart';
import 'package:listipede/presentation/widgets/shopping_list_bottom_sheet.dart';

class ShoppingListView extends StatelessWidget {
  final List<ShoppingList> shoppingLists;

  const ShoppingListView({super.key, required this.shoppingLists});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: shoppingLists.length,
      itemBuilder: (context, index) {
        final shoppingList = shoppingLists[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          // elevation: 4,
          margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: SizedBox(
            height: 100,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Center(
                child: ListTile(
                  title: Text(
                    shoppingList.name,
                    style: TextStyle(fontSize: 20),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: PlatformIconButton(
                    materialIcon: const Icon(Icons.more_vert),
                    cupertinoIcon: const Icon(CupertinoIcons.ellipsis_vertical),
                    onPressed: () {
                      shoppingListBottomSheet(context, shoppingList);
                    },
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/shopping-list',
                        arguments: shoppingList);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
