import 'package:listipede/domain/entities/list_entry.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:listipede/domain/entities/shopping_list.dart';
import 'package:listipede/domain/repositories/shop_repository.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:math';

class ListEntryRepository {
  final DatabaseReference entriesReference =
      FirebaseDatabase.instance.ref().child('entries');

  Stream<List<ListEntry>> entriesForList(ShoppingList shoppingList) {
    return entriesReference
        .orderByChild('shoppingListId')
        .equalTo(shoppingList.id)
        .onValue
        .switchMap((event) {
      final dynamic data = event.snapshot.value;
      final List<ListEntry> listEntries = [];

      if (data is Map<dynamic, dynamic>) {
        final sortIndexStreams = <Stream<double>>[];

        data.forEach((key, value) {
          if (value is Map<dynamic, dynamic>) {
            final productId = value['productId'];
            final sortIndexStream =
                sortIndexForProductInShopStream(productId, shoppingList.id);
            sortIndexStreams.add(sortIndexStream);

            final entry = ListEntry(
              id: key,
              name: value['name'],
              productId: productId,
              shoppingListId: shoppingList.id,
              amount: value['amount'],
              amountType: value['amountType'],
              isDone: value['isDone'] ?? false,
              note: value['note'],
              tickIndex: value['tickIndex'] ?? 0,
              sortIndex: 0,
            );

            listEntries.add(entry);
          }
        });

        return Rx.combineLatest(sortIndexStreams, (List<dynamic> sortIndices) {
          for (var i = 0; i < listEntries.length; i++) {
            listEntries[i].sortIndex = sortIndices[i] as double;
          }

          listEntries.sort((a, b) {
            if (a.isDone && b.isDone) {
              return a.tickIndex!.compareTo(b.tickIndex!);
            } else if (a.isDone) {
              return -1;
            } else if (b.isDone) {
              return 1;
            } else {
              return a.sortIndex.compareTo(b.sortIndex);
            }
          });

          return listEntries;
        });
      }

      return Stream.value(listEntries);
    });
  }

  Stream<double> sortIndexForProductInShopStream(
      String productId, String listId) {
    return ShopRepository()
        .getCurrentShopIdStream(FirebaseAuth.instance.currentUser!.uid, listId)
        .switchMap((currentShopId) {
      if (currentShopId == null || currentShopId == '') {
        return Stream.value(0.0);
      } else {
        return FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('shops')
            .doc(currentShopId)
            .collection('sortedProducts')
            .doc(productId)
            .snapshots()
            .map((snapshot) {
          final sortIndex = snapshot.data()?['sortIndex'];
          return sortIndex != null ? sortIndex.toDouble() : 0.0;
        });
      }
    });
  }

  Future<void> toggleDone(ListEntry entry) async {
    if (entry.isDone) {
      await entriesReference.child(entry.id).update({'isDone': false});
      await entriesReference.child(entry.id).update({'tickIndex': null});
      refreshTickNumbers(entry.shoppingListId);
    } else {
      await setNewestTickNumber(entry.shoppingListId).then((value) {
        entriesReference.child(entry.id).update({'tickIndex': value});
      });
      entriesReference.child(entry.id).update({'isDone': true});
    }
  }

  Future<void> toggleDoneRandomly(ShoppingList list) async {
    final Stream<List<ListEntry>> stream = entriesForList(list);
    final Random random = Random();
    List<ListEntry> snapshot = await stream.first;
    for (ListEntry entry in snapshot) {
      double randomValue = random.nextDouble();
      double chance = 0.66;
      if (randomValue < chance) {
        await toggleDone(entry);
      }
    }
  }

  Future<void> handleSuggestionTap({
    required String suggestion,
    required String shoppingListId,
    required TextEditingController textEditingController,
  }) async {
    final String searchName = suggestion.toLowerCase();
    final String inputText = textEditingController.text.toLowerCase();

    String productId;

    if (searchName == inputText) {
      final QuerySnapshot existingProduct = await FirebaseFirestore.instance
          .collection('products')
          .where('searchName', isEqualTo: searchName)
          .where('isCustom', isEqualTo: false)
          .get();

      if (existingProduct.docs.isNotEmpty) {
        productId = existingProduct.docs.first.id;
      } else {
        final QuerySnapshot existingCustomProduct = await FirebaseFirestore
            .instance
            .collection('products')
            .where('searchName', isEqualTo: searchName)
            .where('isCustom', isEqualTo: true)
            .where('createdBy',
                isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .get();

        if (existingCustomProduct.docs.isNotEmpty) {
          productId = existingCustomProduct.docs.first.id;
        } else {
          final DocumentReference newProductRef =
              await FirebaseFirestore.instance.collection('products').add({
            'name': suggestion,
            'isCustom': true,
            'searchName': searchName,
            'createdBy': FirebaseAuth.instance.currentUser!.uid,
          });

          productId = newProductRef.id;
        }
      }
    } else {
      final QuerySnapshot existingProduct = await FirebaseFirestore.instance
          .collection('products')
          .where('searchName', isEqualTo: searchName)
          .get();

      if (existingProduct.docs.isNotEmpty) {
        productId = existingProduct.docs.first.id;
      } else {
//TODO dieser fall
        throw Exception('Kein Produkt gefunden');
      }
    }

    final DatabaseReference newEntryRef =
        FirebaseDatabase.instance.ref().child('entries').push();

    await newEntryRef.set({
      'isDone': false,
      'shoppingListId': shoppingListId,
      'productId': productId,
      'name': suggestion,
      'amount': '',
      'amountType': '',
    });
  }

  Future<void> delete(String entryId) async {
    try {
      await entriesReference.child(entryId).remove();
    } catch (error) {
      //TODO fehler
    }
  }

  Future<void> editDialog(BuildContext context, ListEntry entry) {
    final TextEditingController _amountEditingController =
        TextEditingController(
      text: entry.amount != null ? entry.amount.toString() : '',
    );
    final TextEditingController _amountTypeEditingController =
        TextEditingController(
      text: entry.amountType != null ? entry.amountType.toString() : '',
    );
    final TextEditingController _noteEditingController = TextEditingController(
      text: entry.note != null ? entry.note.toString() : '',
    );
    return showPlatformDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PlatformAlertDialog(
          title: const Text('Eintrag bearbeiten'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Row(
                  children: [
                    Expanded(
                      child: PlatformTextField(
                        controller: _amountEditingController,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        hintText: 'Menge',
                      ),
                    ),
                    Expanded(
                      child: PlatformTextField(
                        controller: _amountTypeEditingController,
                        hintText: 'Einheit',
                      ),
                    ),
                  ],
                ),
                PlatformTextField(
                  controller: _noteEditingController,
                  maxLines: 3,
                  hintText: 'Notiz',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            PlatformDialogAction(
              child: const Text('Abbrechen'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            PlatformDialogAction(
              child: const Text('Speichern'),
              onPressed: () {
                String amountText = _amountEditingController.text.trim();
                String amountTypeText =
                    _amountTypeEditingController.text.trim();
                String noteText = _noteEditingController.text.trim();
                entriesReference.child(entry.id).update({
                  'note': noteText,
                  'amount': amountText,
                  'amountType': amountTypeText,
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> ShopModeDialog(BuildContext context, ListEntry tickedOffEntry,
      ShoppingList shoppingList) async {
    return showPlatformDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PlatformAlertDialog(
          title: const Text('Einkaufsmodus'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('In den Einkaufsmodus wechseln, um Einträge abzuhaken?'),
              ],
            ),
          ),
          actions: <Widget>[
            PlatformDialogAction(
              child: const Text('Abbrechen'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            PlatformDialogAction(
              child: const Text('OK'),
              onPressed: () async {
                bool anyDones = await anyDoneEntries(shoppingList.id);
                if (!anyDones) {
                  toggleDone(tickedOffEntry);
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/shopping-mode',
                      arguments: shoppingList);
                } else {
                  Navigator.of(context).pop();
                  someoneShoppingDialog(context, shoppingList);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> someoneShoppingDialog(
      BuildContext context, ShoppingList shoppingList) async {
    return showPlatformDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PlatformAlertDialog(
            title: const Text('Einkaufsmodus'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                      'Vermutlich kauft jemand gerade ein. Bitte warte, bis der Einkauf erledigt ist. Wenn niemand einkauft, kannst du die Haken zurücksetzen.'),
                  Text('Möchtest du alle Haken zurücksetzen?')
                ],
              ),
            ),
            actions: <Widget>[
              PlatformDialogAction(
                child: const Text('Abbrechen'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              PlatformDialogAction(
                child: const Text('OK'),
                onPressed: () {
                  ListEntryRepository().resetShoppingMode(shoppingList);
                  Navigator.of(context).pop();
                },
              ),
            ]);
      },
    );
  }

  Future<void> resetShoppingMode(ShoppingList shoppingList) async {
    final List<ListEntry> listEntries = await entriesForList(shoppingList)
        .first
        .timeout(const Duration(seconds: 5));
    listEntries.forEach((entry) {
      entriesReference.child(entry.id).update({
        'isDone': false,
      });
      if (entry.tickIndex != null) {
        entriesReference.child(entry.id).update({
          'tickIndex': null,
        });
      }
    });
  }

  Future<bool> anyDoneEntries(String shoppingListId) async {
    DataSnapshot snapshot = await entriesReference
        .orderByChild('shoppingListId')
        .equalTo(shoppingListId)
        .get();

    Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;

    if (values != null) {
      for (var entryKey in values.keys) {
        var entry = values[entryKey];
        if (entry['isDone'] == true) {
          return true;
        }
      }
    }

    return false;
  }

  Future<int> setNewestTickNumber(String shoppingListId) async {
    DataSnapshot snapshot = await entriesReference
        .orderByChild('shoppingListId')
        .equalTo(shoppingListId)
        .get();

    Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
    int amount = 0;
    debugPrint('Initial amount: $amount');
    if (values != null) {
      for (var entryKey in values.keys) {
        var entry = values[entryKey];
        debugPrint('Checking entry $entry');
        if (entry['isDone'] == true) {
          debugPrint('isDone detected, new amount:$amount');
          amount++;
        }
      }
    }
    debugPrint('I count $amount isDone entries! Assigned tickIndex $amount.');
    return amount;
  }

  Future<void> refreshTickNumbers(String shoppingListId) async {
    debugPrint('Re-ordering tick numbers...');
    DataSnapshot snapshot = await entriesReference
        .orderByChild('shoppingListId')
        .equalTo(shoppingListId)
        .get();

    Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;

    if (values != null) {
      List<MapEntry<dynamic, dynamic>> sortedEntries = values.entries.toList()
        ..sort((a, b) {
          num sortIndexA = a.value['tickIndex'] ?? 0;
          num sortIndexB = b.value['tickIndex'] ?? 0;
          return sortIndexA.compareTo(sortIndexB);
        });

      num tickIndex = 0;
      for (var entryPair in sortedEntries) {
        var entry = entryPair.value;
        if (entry['isDone'] == true) {
          await entriesReference
              .child(entryPair.key)
              .update({'tickIndex': tickIndex});
          debugPrint(
              'Entry ${entryPair.key} (${entry['name']}) now has tickIndex $tickIndex');
          tickIndex++;
        }
      }
      debugPrint('Done!');
    }
  }

  Future<void> setNewTickNumber(
      ListEntry entry, num newTickNumber, String shoppingListId) async {
    await entriesReference
        .child(entry.id)
        .update({'tickIndex': newTickNumber - 0.5});
    refreshTickNumbers(shoppingListId);
  }

  Future<void> assignNewSortIndexes(String shoppingListId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final currentShopId =
        await ShopRepository().getCurrentShopId(userId, shoppingListId);
    if (currentShopId == null || currentShopId == '') {
      debugPrint(
          'No current shop set for this list. My work here is done!!! -- \"(But you didn\'t do anything...)\"');
      return;
    }

    DataSnapshot snapshot = await entriesReference
        .orderByChild('shoppingListId')
        .equalTo(shoppingListId)
        .get();

    final dynamic data = snapshot.value;

    if (data is Map<dynamic, dynamic>) {
      final List<MapEntry<String, dynamic>> doneEntries = [];

      data.forEach((key, value) {
        if (value is Map<dynamic, dynamic> && value['isDone'] == true) {
          doneEntries.add(MapEntry(key, value));
        }
      });

      doneEntries.sort((a, b) {
        return a.value['tickIndex'].compareTo(b.value['tickIndex']);
      });

      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      final userSnapshot = await userDocRef.get();

      if (userSnapshot.exists) {
        final int totalDoneEntries = doneEntries.length;
        if (totalDoneEntries < 2) {
          return;
        }
//vorläufige sortierungslogik
        for (int i = 0; i < doneEntries.length; i++) {
          final entry = doneEntries[i];
          final productId = entry.value['productId'];
          final placementInTrip = i / (totalDoneEntries - 1);
          final docRef = userDocRef
              .collection('shops')
              .doc(currentShopId)
              .collection('sortedProducts')
              .doc(productId);

          final previousSortIndex = await docRef.get().then((value) {
            if (value.exists &&
                value.data() != null &&
                value.data()!['sortIndex'] != null) {
              return value.data()?['sortIndex'];
            } else {
              return placementInTrip;
            }
          });
          final delta = placementInTrip - previousSortIndex;
          if (delta == 0) {
            await docRef
                .set({'sortIndex': placementInTrip}, SetOptions(merge: true));
          } else {
            final deltaWithSortMagic =
                (delta.abs() / delta) * 0.6 * (delta * delta);
            final newSortIndex = previousSortIndex + deltaWithSortMagic;
            await docRef
                .set({'sortIndex': newSortIndex}, SetOptions(merge: true));
          }
        }
      }
    }
  }
}
