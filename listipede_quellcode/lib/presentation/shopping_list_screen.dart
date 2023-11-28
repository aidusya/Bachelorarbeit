import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:listipede/domain/entities/shopping_list.dart';
import 'package:listipede/domain/entities/list_entry.dart';
import 'package:listipede/domain/repositories/list_entry_repository.dart';
import 'package:listipede/presentation/widgets/list_entries_view.dart';
import 'package:listipede/presentation/widgets/list_entry_creation_dialog.dart';
import 'package:listipede/presentation/widgets/shop_indicator.dart';

class ShoppingListScreen extends StatelessWidget {
  static const routeName = '/shopping-list';
  final ShoppingList shoppingList;
  ShoppingListScreen({super.key, required this.shoppingList});
  late Stream<List<ListEntry>> _listEntriesStream;
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(
          shoppingList.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        material: (_, __) => MaterialAppBarData(
          centerTitle: true,
        ),
        cupertino: (_, __) => CupertinoNavigationBarData(
            previousPageTitle: 'Listen',
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(CupertinoIcons.add),
              onPressed: () {
                showPlatformDialog(
                  context: context,
                  builder: (context) =>
                      EntryCreationDialog(shoppingList: shoppingList),
                );
              },
            )),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                child: StreamBuilder<List<ListEntry>>(
              stream: _listEntriesStream =
                  ListEntryRepository().entriesForList(shoppingList),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Fehler: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: PlatformCircularProgressIndicator());
                }

                final listEntries = snapshot.data;
                if (listEntries == null || listEntries.isEmpty) {
                  return const Center(
                      child: Text(
                          "Diese Liste ist leer. Füge doch Einträge hinzu!"));
                }
                return ListEntriesView(
                    listEntries: listEntries,
                    shoppingList: shoppingList,
                    shoppingMode: false);
              },
            )),
            ShopIndicator(
              shoppingList: shoppingList,
              shoppingMode: false,
            ),
          ],
        ),
      ),
      material: (_, __) => MaterialScaffoldData(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 45.0),
          child: FloatingActionButton(
            onPressed: () {
              showPlatformDialog(
                context: context,
                builder: (context) =>
                    EntryCreationDialog(shoppingList: shoppingList),
              );
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
