import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:listipede/domain/entities/shopping_list.dart';

class ShoppingListRepository {
  Future<void> createShoppingList(ShoppingList shoppingList) async {
    print('Creating shopping list...');
    final listId = shoppingList.id;
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final DatabaseReference listsRef =
        FirebaseDatabase.instance.ref().child('shoppinglists/$listId/');
    print('List ID: $listId, User ID: $userId');
    try {
      await listsRef.set({
        'name': shoppingList.name,
        'userIds': {'$userId': true},
      });
      print('Shopping list created successfully!');
    } catch (e) {
      print('Error creating shopping list: $e');
    }
  }
}
