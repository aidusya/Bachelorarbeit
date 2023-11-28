import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:listipede/domain/entities/shopping_list.dart';
import 'package:listipede/domain/repositories/product_search_repository.dart';
import 'package:listipede/domain/repositories/list_entry_repository.dart';

class EntryCreationDialog extends StatefulWidget {
  final ShoppingList shoppingList;

  EntryCreationDialog({required this.shoppingList});

  @override
  _EntryCreationDialogState createState() => _EntryCreationDialogState();
}

class _EntryCreationDialogState extends State<EntryCreationDialog> {
  late FocusNode focusNode;
  late Stream<List<String>> suggestionsStream;
  final TextEditingController textEditingController = TextEditingController();
  final ListEntryRepository _listEntryRepository = ListEntryRepository();

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    suggestionsStream = searchSuggestionsStream('');

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(focusNode);
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  void _handleSuggestionTap(String suggestion) async {
    await _listEntryRepository.handleSuggestionTap(
      suggestion: suggestion,
      shoppingListId: widget.shoppingList.id,
      textEditingController: textEditingController,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PlatformTextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  onChanged: (query) {
                    setState(() {
                      suggestionsStream = searchSuggestionsStream(query);
                    });
                  },
                  material: (_, __) => MaterialTextFieldData(
                        decoration: InputDecoration(
                          labelText: "Produkt",
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.search),
                        ),
                      ),
                  cupertino: (_, __) => CupertinoTextFieldData(
                        placeholder: "Produkt",
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: CupertinoColors.systemGrey,
                            width: 0.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      )),
              SizedBox(height: 16),
              StreamBuilder<List<String>>(
                stream: suggestionsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return PlatformCircularProgressIndicator();
                  }

                  List<String>? suggestions = snapshot.data;

                  return Column(
                    children: suggestions?.map((suggestion) {
                          return PlatformListTile(
                            title: Text(suggestion),
                            onTap: () {
                              _handleSuggestionTap(suggestion);
                            },
                          );
                        }).toList() ??
                        [],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
