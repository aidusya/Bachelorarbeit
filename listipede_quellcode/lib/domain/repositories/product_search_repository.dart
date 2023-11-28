import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Stream<List<String>> searchSuggestionsStream(String searchQuery) {
  if (searchQuery.isEmpty) {
    return Stream.value([]);
  }
  String lowercaseQuery = searchQuery.toLowerCase();

  return FirebaseFirestore.instance
      .collection('products')
      .where(Filter.or(
          Filter.and(
              Filter("isCustom", isEqualTo: false),
              Filter('searchName', isGreaterThanOrEqualTo: lowercaseQuery),
              Filter('searchName',
                  isLessThanOrEqualTo: lowercaseQuery + '\uf8ff')),
          Filter.and(
            Filter('searchName', isGreaterThanOrEqualTo: lowercaseQuery),
            Filter('searchName',
                isLessThanOrEqualTo: lowercaseQuery + '\uf8ff'),
            Filter("isCustom", isEqualTo: true),
            Filter("createdBy",
                isEqualTo: FirebaseAuth.instance.currentUser?.uid),
          )))
      .limit(5)
      .snapshots()
      .map((snapshot) {
    List<String> suggestions = [];
    bool exactMatchFound = false;

    for (var doc in snapshot.docs) {
      var name = doc['name'];
      if (name.toLowerCase() == lowercaseQuery) {
        suggestions.add(name);
        exactMatchFound = true;
      } else {
        suggestions.add(name);
      }
    }

    if (!exactMatchFound) {
      suggestions.add(searchQuery);
    }

    return suggestions;
  });
}
