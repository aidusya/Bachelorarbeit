import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:listipede/domain/entities/shopping_list.dart';
import 'package:listipede/domain/repositories/list_share_repository.dart';
import 'package:listipede/domain/repositories/list_of_lists_repository.dart';

class ListUsersScreen extends StatelessWidget {
  final ShoppingList shoppingList;
  ListUsersScreen({super.key, required this.shoppingList});

  @override
  Widget build(BuildContext context) {
    final _listUserIdsStream =
        ListShareRepository().usersForList(shoppingList.id);

    final bool canLeaveList = shoppingList.userIds.length > 1;
    return PlatformScaffold(
        appBar: PlatformAppBar(
          title: Text(
            'Nutzer von ${shoppingList.name}',
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
                ListShareRepository.handleShareButton(context, shoppingList.id);
              },
            ),
          ),
        ),
        body: StreamBuilder<List<String>>(
          stream: _listUserIdsStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: PlatformCircularProgressIndicator());
            }

            if (snapshot.data == null || snapshot.data!.isEmpty) {
              return const Center(
                  child:
                      Text("Keine Nutzer vorhanden... Eine Geisterliste! 👻"));
            }

            return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                if (snapshot.data![index] ==
                    FirebaseAuth.instance.currentUser!.uid) {
                  if (canLeaveList) {
                    return PlatformListTile(
                        title: Text(
                            'Du (${FirebaseAuth.instance.currentUser!.email})'),
                        trailing: PlatformIconButton(
                          cupertinoIcon:
                              Icon(CupertinoIcons.person_badge_minus),
                          materialIcon: Icon(Icons.exit_to_app),
                          onPressed: () async {
                            await ListOfListsRepository()
                                .listLeaveDialog(context, shoppingList.id);
                            Navigator.pushNamed(context, '/list-of-lists');
                          },
                        ));
                  } else {
                    return PlatformListTile(
                        title: Text(
                            'Du (${FirebaseAuth.instance.currentUser!.email})'));
                  }
                }

                return PlatformListTile(
                  title: FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(snapshot.data![index])
                        .get(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text(' ');
                      }

                      return Text(snapshot.data!['email']);
                    },
                  ),
                  trailing: PlatformIconButton(
                    cupertinoIcon: Icon(CupertinoIcons.person_badge_minus),
                    materialIcon: Icon(Icons.person_remove),
                    onPressed: () {
                      ListShareRepository.userRemovalDialogue(
                          context, shoppingList.id, snapshot.data![index]);
                    },
                  ),
                );
              },
            );
          },
        ),
        material: (_, __) => MaterialScaffoldData(
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  ListShareRepository.handleShareButton(
                      context, shoppingList.id);
                },
                child: const Icon(Icons.add),
              ),
            ));
  }
}
