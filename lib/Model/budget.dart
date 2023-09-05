import 'package:funds_minder/Model/expense.dart';

class Budget {
  String id;
  double amount;
  static DateTime firstdate = DateTime.now(), lastDate = DateTime.now();
  Category category;

  Budget({
    required this.id,
    required this.amount,
    required this.category,
  });
}
