import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../Model/report.dart';
import 'single_report.dart';
import '../../View_Model/expenses.dart';

class ReportWidget extends StatelessWidget {
  const ReportWidget({super.key});

  double findMaxtotal(double exp, double earn) {
    double currMax = 0;

    return currMax;
  }

  Map<String, dynamic> reporttransMapbyIndex(List<Report> rp, int ind) {
    Map<String, double> tMap = {
      'Expense': -rp[ind].expense,
      'Earning': rp[ind].earning
    };
    return tMap;
  }

  List<Widget> reportWidgets(BuildContext context, double height, double width,
      bool isDarkMode, int reportMapIndex, int dayToSubtract) {
    return [
      Consumer<Expenses>(
          child: const Center(
            child: Text('No report till now...'),
          ),
          builder: (ctx, expns, ch) {
            final reports = expns.getReports;
            return (expns.getReports.isEmpty)
                ? ch!
                : Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    width: (height < 600) ? width * 0.42 : width,
                    height: (height) < 600 ? 0.5 * height : height * 0.22,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3),
                          Theme.of(context).colorScheme.primary.withOpacity(0.0)
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 2,
                        itemBuilder: (ctx, i) {
                          expns.totalExpenseMap();
                          if (i == 0) {
                            expns.updateTotalExpense();
                          }

                          final transMap =
                              reporttransMapbyIndex(reports, reportMapIndex);
                          double currntMax = max(
                              reports[reportMapIndex].expense,
                              reports[reportMapIndex].earning);
                          return FittedBox(
                            fit: BoxFit.fill,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    if (i == 0)
                                      Text(
                                        'Profit: ${reports[reportMapIndex].profit.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: isDarkMode
                                              ? (reports[reportMapIndex]
                                                          .profit >
                                                      0)
                                                  ? Colors.lightGreen.shade200
                                                  : Colors.red.shade200
                                              : (reports[reportMapIndex]
                                                          .profit >
                                                      0)
                                                  ? Colors.green.shade900
                                                  : Colors.deepOrange.shade900,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                                SingleReport(
                                    (currntMax == 0)
                                        ? 0
                                        : (transMap.values.elementAt(i).abs() /
                                            currntMax),
                                    transMap.values.elementAt(i),
                                    transMap.keys.elementAt(i)),
                              ],
                            ),
                          );
                        }),
                  );
          }),
      Text(
        'Monthly Report: ${DateFormat.yMMM().format(DateTime.now().subtract(Duration(days: dayToSubtract)))}',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          width: double.infinity,
          height: height * 0.1,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.3),
                Theme.of(context).colorScheme.primary.withOpacity(0.0)
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          child: Text("Reports Summary",
              style: Theme.of(context).textTheme.titleLarge),
        ),
        Expanded(
            child: height < 600
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: reportWidgets(
                            context, height, width, isDarkMode, 0, 0),
                      ),
                      Column(
                        children: reportWidgets(
                            context, height, width, isDarkMode, 1, 30),
                      )
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: reportWidgets(
                            context, height, width, isDarkMode, 0, 0),
                      ),
                      Column(
                        children: reportWidgets(
                            context, height, width, isDarkMode, 1, 30),
                      )
                    ],
                  ))
      ],
    );
  }
}
