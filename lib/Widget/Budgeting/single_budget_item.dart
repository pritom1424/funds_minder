import 'package:flutter/material.dart';
import 'package:funds_minder/Model/expense.dart';
import 'package:funds_minder/Widget/Budgeting/budget_list_details.dart';

class SingleBudgetItem extends StatelessWidget {
  final IconData icon;
  final String labelText;
  final List<Expense> expenseList;
  final String currency;
  final double ttl;
  const SingleBudgetItem(
      this.icon, this.labelText, this.expenseList, this.currency, this.ttl,
      {super.key});

  @override
  Widget build(BuildContext context) {
    final scSize = MediaQuery.of(context).size;
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          gradient: LinearGradient(colors: [
            (isDarkMode)
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Theme.of(context).colorScheme.primary.withOpacity(0.8),
            Theme.of(context).colorScheme.primary.withOpacity(0.3)
          ])),
      child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    BudgetListDetails(expenseList, currency, ttl)));
          },
          icon: CircleAvatar(
            radius: 10,
            child: Icon(
              icon,
              size: 15,
            ),
          ),
          label: Text(
            labelText,
            style: TextStyle(
                color: Colors.white,
                fontSize: (scSize.height > 600) ? 12 : 10,
                fontWeight: FontWeight.bold),
          )),
    );
  }
}
