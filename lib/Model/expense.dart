enum Category {
  travel,
  food,
  utilities,
  medical,
  education,
  leisure,
  business,
  job,
  other,
}

class Expense {
  String id;
  String title;
  double amount;
  DateTime date;
  Category category;
  String expenseSymbol;

  Expense(
      {required this.id,
      required this.title,
      required this.amount,
      required this.date,
      required this.category,
      required this.expenseSymbol});
}
