import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'home_screen.dart';
import 'single_chart_bar.dart';
import '../../View_Model/expenses.dart';
import 'package:provider/provider.dart';

class ChartWidget extends StatelessWidget {
  final Filteroptions filteroptions;
  final DateFormat df;
  const ChartWidget(this.df, this.filteroptions, {super.key});

  double findMaxtotal(Map<IconData, double> mp) {
    double currMax = 0;
    if (mp.isEmpty) {
      return 0;
    }

    mp.forEach((icn, amnt) {
      if (currMax < amnt.abs()) {
        currMax = amnt.abs();
      }
    });

    return currMax;
  }

  String totalAmountFormatter(double amount) {
    double formattedAmount = 0;
    String formattedString = '';

    if (amount.abs() >= 1000 && amount.abs() < 1000000) {
      formattedAmount = amount / 1000;
      formattedString = '${formattedAmount.toStringAsFixed(1)}K';
    } else if (amount.abs() >= 1000000 && amount.abs() < 1000000000) {
      formattedAmount = amount / 1000000;
      formattedString = '${formattedAmount.toStringAsFixed(1)}M';
    } else if (amount.abs() >= 1000000000 && amount.abs() < 1000000000000) {
      formattedAmount = amount / 1000000000;
      formattedString = '${formattedAmount.toStringAsFixed(1)}B';
    } else if (amount.abs() >= 1000000000000) {
      formattedAmount = amount / 1000000000000;
      formattedString = '${formattedAmount.toStringAsFixed(1)}T';
    } else {
      formattedString = amount.toStringAsFixed(1);
    }

    return formattedString;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return FutureBuilder(
      future: Provider.of<Expenses>(context, listen: false).fetchExpense(),
      builder: (ctx, snapShot) => (snapShot.connectionState ==
              ConnectionState.waiting)
          ? const Text("loading..")
          : Consumer<Expenses>(
              child: Center(
                child: Text(
                  'still no chart',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              builder: (ctx, expns, ch) =>
                  (expns.getExpense(df, filteroptions, 0, 0, 0).isEmpty)
                      ? ch!
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 9,
                          itemBuilder: (ctx, i) {
                            final provExpense =
                                Provider.of<Expenses>(context, listen: false);
                            var currentexpList = provExpense.getExpense(
                                df,
                                filteroptions,
                                0,
                                0,
                                0); //this line to update filtered expense

                            var expEarnProf =
                                provExpense.getTotalEarnExpense(currentexpList);

                            provExpense.totalExpenseMap();

                            final tm = provExpense.total;
                            final tmDeal = expEarnProf[2];
                            final tmExpense = expEarnProf[0];
                            final tmEarn = expEarnProf[1];

                            double currntMax = findMaxtotal(tm);
                            return FittedBox(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      if (i == 0)
                                        Text(
                                          'Profit: ${totalAmountFormatter(tmDeal)}',
                                          style: TextStyle(
                                            color: isDarkMode
                                                ? (tmDeal > 0)
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                    : Colors.red.shade200
                                                : (tmDeal > 0)
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                    : const Color.fromARGB(
                                                        255, 154, 43, 9),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      if (i == 1)
                                        const SizedBox(
                                          width: 10,
                                        ),
                                      if (i == 1)
                                        Text(
                                          'Expense: ${totalAmountFormatter(tmExpense)}',
                                          style: TextStyle(
                                            color: isDarkMode
                                                ? Colors.red.shade200
                                                : const Color.fromARGB(
                                                    255, 154, 43, 9),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      if (i == 2)
                                        const SizedBox(
                                          width: 10,
                                        ),
                                      if (i == 2)
                                        Text(
                                          'Earning: ${totalAmountFormatter(tmEarn)}',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                    ],
                                  ),
                                  SingleChartBar(
                                      (currntMax == 0)
                                          ? 0
                                          : (tm.values.elementAt(i).abs() /
                                              currntMax),
                                      tm.values.elementAt(i),
                                      tm.keys.elementAt(i)),
                                ],
                              ),
                            );
                          }),
            ),
    );
  }
}
