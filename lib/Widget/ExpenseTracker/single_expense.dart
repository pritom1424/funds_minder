import 'package:flutter/material.dart';
import '../../Model/expense.dart';
import 'package:intl/intl.dart';

class SingleExpense extends StatelessWidget {
  final Expense _expense;
  final String currSymbol;

  final iconMaps = {
    Category.education: Icons.school,
    Category.food: Icons.lunch_dining,
    Category.leisure: Icons.movie,
    Category.medical: Icons.medical_services,
    Category.travel: Icons.flight_takeoff,
    Category.utilities: Icons.home,
    Category.business: Icons.business,
    Category.job: Icons.work,
    Category.other: Icons.miscellaneous_services,
  };
  SingleExpense(this._expense, this.currSymbol, {super.key});

  IconData getIcon(Category cat) {
    late IconData returnIcon;
    iconMaps.forEach((ct, icn) {
      if (ct == cat) {
        returnIcon = icn;
      }
    });
    return returnIcon;
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: (isDark)
          ? (_expense.expenseSymbol == '-')
              ? Theme.of(context).cardTheme.color?.withOpacity(0.7)
              : Theme.of(context).cardTheme.color
          : (_expense.expenseSymbol == '-')
              ? Theme.of(context).cardTheme.color?.withOpacity(0.7)
              : Theme.of(context).cardTheme.color,
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(
                  getIcon(_expense.category),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _expense.title,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    DateFormat.yMMMd().format(_expense.date),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                "${_expense.expenseSymbol}$currSymbol ${_expense.amount.toStringAsFixed(2)}",
                style: TextStyle(
                    fontFamily: 'QuickSand-Medium',
                    fontWeight: FontWeight.bold,
                    color: (isDark)
                        ? (_expense.expenseSymbol == '-')
                            ? Colors.red.shade200
                            : Colors.green.shade200
                        : (_expense.expenseSymbol == '-')
                            ? Colors.red.shade800
                            : Colors.green.shade800),
              ),
            ],
          )),
    );
  }
}
