import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:listipede/config/style.dart';
import 'package:listipede/presentation/widgets/shopping_list_view.dart';
import 'package:listipede/domain/repositories/list_of_lists_repository.dart';
import 'package:listipede/domain/entities/shopping_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:listipede/presentation/widgets/list_creation_popup.dart';
import 'package:listipede/presentation/widgets/main_popup_menu.dart';
import 'package:listipede/presentation/widgets/main_app_bar.dart';

class ListOfListsScreen extends StatefulWidget {
  const ListOfListsScreen({super.key});

  @override
  ListOfListsScreenState createState() => ListOfListsScreenState();
}

class ListOfListsScreenState extends State<ListOfListsScreen> {
  late Stream<List<ShoppingList>> _shoppingListsStream;
  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pushNamed(context, '/sign-in');
    } else {
      _shoppingListsStream =
          ListOfListsRepository().shoppingListsStreamForUser(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            MainAppBar(),
          ];
        },
        body: StreamBuilder<List<ShoppingList>>(
          stream: _shoppingListsStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: PlatformCircularProgressIndicator());
            }

            final shoppingLists = snapshot.data;
            if (shoppingLists == null || shoppingLists.isEmpty) {
              return const Center(
                  child: Text(
                      "Keine Einkaufslisten vorhanden... Mach doch eine!"));
            }
            return ShoppingListView(shoppingLists: shoppingLists);
          },
        ),
      ),
      material: (_, __) => MaterialScaffoldData(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showPlatformDialog(
              context: context,
              builder: (context) => ListCreationDialog(),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
