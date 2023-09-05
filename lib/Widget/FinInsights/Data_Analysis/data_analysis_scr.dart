import 'package:flutter/material.dart';
import 'package:funds_minder/Model/chart_data.dart';
import 'package:funds_minder/Model/expense.dart';
import 'package:funds_minder/Widget/ExpenseTracker/home_screen.dart';
import 'package:funds_minder/Widget/FinInsights/Data_Analysis/data_analysis_itm.dart';

class DataAnalysisScr extends StatelessWidget {
  final Map<Filteroptions, List<ChartData>> chartMap;
  final List<Expense> expns;
  const DataAnalysisScr(this.chartMap, this.expns, {super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    List<String> reportName = [
      'All time report',
      'Yearly Report',
      'Monthly Report',
      'Weekly Report',
      'Daily Report'
    ];
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Funds Minder"),
      ),
      body: Center(
        child: expns.isEmpty
            ? Text('still no chart',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ))
            : Container(
                child: (screenSize.height > 600)
                    ? ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: chartMap.length,
                        itemBuilder: (ctx, i) => (chartMap.values
                                .elementAt(i)
                                .isEmpty)
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                      'Not enough ${reportName[i]} data available'),
                                ),
                              )
                            : DataAnalysisItem(
                                chartMap.values.elementAt(i), reportName[i]),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: chartMap.length,
                        itemBuilder: (ctx, i) => (chartMap.values
                                .elementAt(i)
                                .isEmpty)
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                      'Not enough ${reportName[i]} data available'),
                                ),
                              )
                            : DataAnalysisItem(
                                chartMap.values.elementAt(i), reportName[i]),
                      ),
              ),
      ),
    );
  }
}
