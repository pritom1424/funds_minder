import 'package:flutter/material.dart';
import 'package:funds_minder/Model/expense.dart';
import 'package:funds_minder/View_Model/expenses.dart';
import 'package:funds_minder/Widget/Budgeting/single_budget_item.dart';

class BudgetList extends StatelessWidget {
  final Expenses bList;
  final DateTime firstDate, lastDate;

  const BudgetList(this.bList, this.firstDate, this.lastDate, {super.key});

  Map<Category, IconData> catNIcon() {
    Map<Category, IconData> icList = {
      Category.education: Icons.school,
      Category.food: Icons.lunch_dining,
      Category.leisure: Icons.movie,
      Category.medical: Icons.medical_services,
      Category.other: Icons.miscellaneous_services,
      Category.travel: Icons.flight_takeoff,
      Category.business: Icons.business,
      Category.job: Icons.work,
      Category.utilities: Icons.home,
    };
    return icList;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        itemCount: Category.values.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 15,
            childAspectRatio: 2),
        itemBuilder: (ctx, i) {
          List<Expense> budgs = bList
              .getExpenseBydaysCount(firstDate, lastDate)
              .where(
                  (element) => element.category == catNIcon().keys.elementAt(i))
              .toList();
          return (SingleBudgetItem(
              catNIcon().values.elementAt(i),
              catNIcon().keys.elementAt(i).name,
              budgs,
              bList.currentCurrency,
              bList.getTotalExpenseByCategory(catNIcon().keys.elementAt(i))));
        });
  }
}
