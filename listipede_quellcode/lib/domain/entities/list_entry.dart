class ListEntry {
  final String productId;
  final String shoppingListId;
  final String id;
  final String name;
  bool isDone;
  num sortIndex;
  num? tickIndex;
  String? amount;
  String? amountType;
  String? note;

  ListEntry(
      {required this.productId,
      required this.shoppingListId,
      required this.id,
      required this.name,
      required this.isDone,
      required this.sortIndex,
      this.tickIndex,
      this.amount,
      this.amountType,
      this.note});
}
