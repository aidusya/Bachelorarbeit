import 'package:flutter/material.dart';
import 'package:listipede/domain/entities/list_entry.dart';
import 'package:listipede/domain/repositories/list_entry_repository.dart';
import 'package:listipede/domain/repositories/shopping_list_repository.dart';
import 'package:listipede/domain/entities/shopping_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ListEntryCard extends StatelessWidget {
  final ListEntry entry;
  final VoidCallback onDismissed;
  final ShoppingList shoppingList;
  final bool shoppingMode;
  final key;

  const ListEntryCard({
    required this.entry,
    required this.onDismissed,
    required this.shoppingList,
    required this.shoppingMode,
    this.key,
  });

  @override
  Widget build(BuildContext context) {
    String amountWithType = entry.amount.toString();
    if (entry.amountType != null && entry.amountType != '') {
      amountWithType += ' ${entry.amountType}';
    }
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            ListEntryRepository().editDialog(context, entry);
          },
          child: Dismissible(
            key: Key(entry.id),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              onDismissed();
            },
            child: PlatformListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // if (!entry.isDone && shoppingMode) SizedBox(width: 48),
                      Column(children: [
                        Container(
                          width: shoppingMode && entry.isDone
                              ? MediaQuery.of(context).size.width * 0.4
                              : MediaQuery.of(context).size.width * 0.55,
                          child: Text(
                            "${entry.name} ${entry.productId}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (entry.note != null && entry.note != '')
                          Container(
                            width: shoppingMode && entry.isDone
                                ? MediaQuery.of(context).size.width * 0.4
                                : MediaQuery.of(context).size.width * 0.55,
                            child: Text(
                              '${entry.note}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ),
                      ]),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: Text(
                          amountWithType,
                          style: TextStyle(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                      ),
                      PlatformIconButton(
                        cupertinoIcon: entry.isDone
                            ? const Icon(
                                CupertinoIcons.check_mark_circled,
                                size: 30,
                              )
                            : const Icon(
                                CupertinoIcons.circle,
                                size: 30,
                              ),
                        materialIcon: entry.isDone
                            ? const Icon(
                                Icons.check_box,
                                size: 30,
                              )
                            : const Icon(
                                Icons.check_box_outline_blank,
                                size: 30,
                              ),
                        onPressed: () {
                          if (!shoppingMode) {
                            ListEntryRepository()
                                .ShopModeDialog(context, entry, shoppingList);
                          } else {
                            ListEntryRepository().toggleDone(entry);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!shoppingMode || !entry.isDone)
          Divider(
              thickness: 1,
              indent: MediaQuery.of(context).size.width * 0.1,
              endIndent: MediaQuery.of(context).size.width * 0.1),
        if (shoppingMode && entry.isDone)
          Divider(
              thickness: 1, endIndent: MediaQuery.of(context).size.width * 0.1),
      ],
    );
  }
}
