import 'package:flutter/material.dart';
import 'package:funds_minder/Widget/Budgeting/single_budget_bar.dart';
import '../../View_Model/expenses.dart';
import 'package:provider/provider.dart';
import 'package:funds_minder/Model/expense.dart';

class BudgetWidget extends StatelessWidget {
  final DateTime firstDate, lastDate;
  final bool isBudgetSet;

  const BudgetWidget(this.firstDate, this.lastDate, this.isBudgetSet,
      {super.key});

  List<double> findMaxtotal(
      Map<IconData, double> mp, Map<Category, double> bp) {
    List<double> valuesOfExpenses = mp.values.toList();
    List<double> valuesOfBudgets = bp.values.toList();
    List<double> mainList = [];

    for (int i = 0; i < valuesOfExpenses.length; i++) {
      (valuesOfBudgets[i] > 0 && valuesOfExpenses[i] <= 0)
          ? (valuesOfBudgets[i] > valuesOfExpenses[i].abs())
              ? mainList.add(valuesOfBudgets[i])
              : mainList.add(valuesOfExpenses[i].abs())
          : mainList.add(0);
    }

    return mainList;
  }

  @override
  Widget build(BuildContext context) {
    final isDrkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return (!isBudgetSet)
        ? Center(
            child: Text(
              ' no budget yet! set some budgets...',
              style: TextStyle(
                color: isDrkMode ? Colors.white : Colors.black,
              ),
            ),
          )
        : ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: 9,
            itemBuilder: (ctx, i) {
              final provExpense = Provider.of<Expenses>(context, listen: false);

              provExpense.getExpenseBydaysCount(
                  firstDate, lastDate); //this line to change Filtered Expense
              provExpense.totalExpenseMap();
              provExpense.totalBudgetMap();

              final tm = provExpense.total;
              final tmBudget = provExpense.totalBudget;

              List<double> currntMax = findMaxtotal(tm, tmBudget);

              return FittedBox(
                child: Column(
                  children: [
                    Column(
                      children: [
                        SingleBudgetBar(
                            (currntMax[i] == 0)
                                ? 0
                                : (tm.values.elementAt(i).abs() / currntMax[i]),
                            (currntMax[i] == 0)
                                ? 0
                                : (tmBudget.values.elementAt(i) /
                                    currntMax[i]), //budgetfill
                            tm.values.elementAt(i),
                            tmBudget.values.elementAt(
                                i), //budgettotal tmBudget.values.elementAt(i)
                            tm.keys.elementAt(i)),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          tmBudget.keys.elementAt(i).name,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    )
                  ],
                ),
              );
            });
  }
}
