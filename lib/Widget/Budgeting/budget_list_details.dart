import 'package:flutter/material.dart';
import 'package:funds_minder/Model/expense.dart';
import 'package:funds_minder/Widget/ExpenseTracker/single_expense.dart';

class BudgetListDetails extends StatelessWidget {
  static String budgetDetailsRoute = '/budget_details_screen';
  final List<Expense> expns;
  final double total;
  final String currentCurrency;
  const BudgetListDetails(this.expns, this.currentCurrency, this.total,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Funds Minder",
        ),
      ),
      body: Column(
        children: [
          Text(
            'Total: $total',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Expanded(
            flex: 2,
            child: ListView.builder(
                itemCount: expns.length,
                itemBuilder: (ctx, i) {
                  return SingleExpense(
                    expns[i],
                    currentCurrency,
                  );
                }),
          )
        ],
      ),
    );
  }
}
