import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:listipede/domain/entities/list_entry.dart';
import 'package:listipede/domain/repositories/list_entry_repository.dart';
import 'package:listipede/presentation/widgets/list_entry_card.dart';
import 'package:listipede/domain/entities/shopping_list.dart';
import 'package:listipede/presentation/widgets/end_shopping_button.dart';

class ListEntriesView extends StatelessWidget {
  final List<ListEntry> listEntries;
  final ShoppingList shoppingList;
  final bool shoppingMode;
  const ListEntriesView({
    Key? key,
    required this.listEntries,
    required this.shoppingList,
    required this.shoppingMode,
  });

  @override
  Widget build(BuildContext context) {
    if (shoppingMode) {
      return ReorderableListView(
        onReorder: (int oldIndex, int newIndex) {
          if (listEntries[oldIndex].isDone == true) {
            ListEntryRepository().setNewTickNumber(
                listEntries[oldIndex], newIndex, shoppingList.id);
          } else {
            debugPrint(
                'Tried to move an entry with isDone false. This should not be possible!');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Artikel können nur verschoben werden, wenn sie bereits abgehakt wurden.'),
              ),
            );
          }
        },
        children: [
          ...listEntries.asMap().entries.map((entry) {
            final index = entry.key;
            final listEntry = entry.value;
            return Row(
              key: Key(listEntry.id),
              children: [
                if (listEntry.isDone)
                  ReorderableDragStartListener(
                    index: index,
                    key: Key(listEntry.id),
                    child: PlatformIconButton(
                      materialIcon: Icon(Icons.drag_handle),
                      cupertinoIcon: Icon(CupertinoIcons.bars),
                      onPressed: () {},
                      cupertino: (_, __) =>
                          CupertinoIconButtonData(padding: EdgeInsets.zero),
                    ),
                  ),
                Expanded(
                  child: ListEntryCard(
                    entry: listEntry,
                    onDismissed: () {
                      ListEntryRepository().delete(listEntry.id);
                    },
                    shoppingList: shoppingList,
                    shoppingMode: shoppingMode,
                  ),
                ),
              ],
            );
          }).toList(),
          EndShoppingButton(
            key: Key('endShoppingButton'),
            shoppingList: shoppingList,
          ),
          PlatformElevatedButton(
            key: Key('testButton'),
            onPressed: () {
              ListEntryRepository().toggleDoneRandomly(shoppingList);
            },
            child: Text('Test-Durchgang'),
          ),
          SizedBox(height: 80, key: Key('box'))
        ],
      );
    } else {
      return ListView.builder(
        itemCount: listEntries.length,
        itemBuilder: (context, index) {
          final entry = listEntries[index];
          return ListEntryCard(
            entry: entry,
            onDismissed: () {
              ListEntryRepository().delete(entry.id);
            },
            shoppingList: shoppingList,
            shoppingMode: shoppingMode,
          );
        },
      );
    }
  }
}
