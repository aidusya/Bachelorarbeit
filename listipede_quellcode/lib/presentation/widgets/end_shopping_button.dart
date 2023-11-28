import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:listipede/domain/entities/shopping_list.dart';
import 'package:listipede/domain/repositories/list_entry_repository.dart';
import 'package:listipede/domain/repositories/shopping_list_repository.dart';

class EndShoppingButton extends StatelessWidget {
  final ShoppingList shoppingList;
  final Key key;

  const EndShoppingButton({
    required this.shoppingList,
    required this.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PlatformElevatedButton(
          onPressed: () async {
            ListEntryRepository().assignNewSortIndexes(shoppingList.id);
            //Navigator.of(context).pop();
          },
          child: Text('Einkauf beenden', style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }
}
