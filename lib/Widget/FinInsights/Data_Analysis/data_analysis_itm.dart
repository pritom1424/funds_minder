import 'package:flutter/material.dart';
import 'package:funds_minder/Model/chart_data.dart';

import 'package:syncfusion_flutter_charts/charts.dart';

class DataAnalysisItem extends StatelessWidget {
  final List<ChartData> cExpenseData;
  final String graphReportName;

  const DataAnalysisItem(this.cExpenseData, this.graphReportName, {super.key});

  @override
  Widget build(BuildContext context) {
    String minCatName = '', maxCatName = '';

    List<double> minAvgMaxCounter() {
      if (cExpenseData.isEmpty) {
        return [];
      }
      List<double> exList = [];
      for (var element in cExpenseData) {
        exList.add(element.expenseAmount);
      }

      double max = exList.reduce((curr, next) => (curr > next) ? curr : next);
      double min = exList.reduce((curr, next) => (curr < next) ? curr : next);
      double avg = exList.reduce((returnVal, item) => (returnVal + item)) /
          exList.length;
      if (min != 0) {
        minCatName = cExpenseData[cExpenseData
                .indexWhere((element) => element.expenseAmount == min)]
            .categoryName;
      }
      if (max != 0) {
        maxCatName = cExpenseData[cExpenseData
                .indexWhere((element) => element.expenseAmount == max)]
            .categoryName;
      }

      return [min, avg, max];
    }

    final screenSize = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: (screenSize.height > 600)
              ? screenSize.width
              : screenSize.width * 0.5,
          height: (screenSize.height > 600)
              ? screenSize.height * 0.4
              : screenSize.height * 0.5,
          child: SfCartesianChart(
              legend: const Legend(
                position: LegendPosition.top,
                isVisible: true,
              ),
              primaryXAxis: CategoryAxis(
                title: AxisTitle(text: 'Category'),
              ),
              primaryYAxis:
                  NumericAxis(title: AxisTitle(text: 'Transaction Amount')),
              series: <ChartSeries>[
                ColumnSeries<ChartData, String>(
                    name: 'Earnings',
                    dataSource: cExpenseData,
                    xValueMapper: (ChartData data, _) =>
                        data.categoryName.substring(0, 3),
                    yValueMapper: (ChartData data, _) => data.earnAmount),
                ColumnSeries<ChartData, String>(
                    name: 'Expenses',
                    dataSource: cExpenseData,
                    xValueMapper: (ChartData data, _) =>
                        data.categoryName.substring(0, 3),
                    yValueMapper: (ChartData data, _) => data.expenseAmount,
                    xAxisName: 'xAxis',
                    yAxisName: 'yAxis')
              ]),
        ),
        SizedBox(
          //    width: screenSize.width * 0.3,
          height: (screenSize.height > 600)
              ? screenSize.height * 0.1
              : screenSize.height * 0.25,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(graphReportName.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                  'max expense:${minAvgMaxCounter()[2].toStringAsFixed(1)} ${maxCatName.toUpperCase()}',
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                'min expense:${minAvgMaxCounter()[0].toStringAsFixed(1)} ${minCatName.toUpperCase()}',
                textAlign: TextAlign.left,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('avg expense:${minAvgMaxCounter()[1].toStringAsFixed(1)}',
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontWeight: FontWeight.bold))
            ],
          ),
        )
      ],
    );
  }
}
