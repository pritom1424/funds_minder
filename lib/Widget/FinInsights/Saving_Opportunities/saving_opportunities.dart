import 'package:flutter/material.dart';
import 'package:funds_minder/Model/chart_data.dart';
import 'package:funds_minder/Model/expense.dart';
import 'package:funds_minder/View_Model/expenses.dart';
import 'package:funds_minder/Widget/ExpenseTracker/home_screen.dart';
import 'package:funds_minder/Widget/FinInsights/Saving_Opportunities/saving_op_report.dart';
import 'package:funds_minder/Widget/FinInsights/Saving_Opportunities/slider_element.dart';
import 'package:provider/provider.dart';

class SavingOpportunities extends StatefulWidget {
  final Map<Filteroptions, List<ChartData>> cMap;

  const SavingOpportunities(this.cMap, {super.key});
  static bool isExist = false;
  static List<int> slideCategoryValues = [];

  Category stringToCateGory(String catName) {
    return Category.values.firstWhere((element) => element.name == catName);
  }

  double chartDataTotal(List<ChartData> chData) {
    double total = 0;
    for (int i = 0; i < chData.length; i++) {
      total += chData[i].expenseAmount;
    }
    return total;
  }

  Map<Category, double> filterToThreshold(
      Map<Category, double> cMapD, double total) {
    if (cMapD.isEmpty) {
      return {};
    }
    List<Category> indexes = [];

    for (int i = 0; i < cMapD.values.toList().length; i++) {
      for (int j = 0; j < Category.values.length; j++) {
        if (cMapD.keys.toList()[i] == Category.values.elementAt(j)) {
          if ((slideCategoryValues[j] / 100) <
              (cMapD.values.toList()[i] / total)) {
            indexes.add(cMapD.keys.toList()[i]);
          }
        }
      }
    }

    cMapD.removeWhere((key, value) {
      bool removeExist = true;
      for (var element in indexes) {
        if (key == element) {
          removeExist = false;
          break;
        }
      }
      return removeExist;
    });
    return cMapD;
  }

  Map<Category, double> cMaptoCatL(List<ChartData> cM) {
    if (cM.isEmpty) {
      return {};
    }
    Map<Category, double> maxCatAm = {};
    cM.sort((b, a) => a.expenseAmount.compareTo(b.expenseAmount));

    for (int i = 0; i < cM.length; i++) {
      maxCatAm.addEntries(
          {stringToCateGory(cM[i].categoryName): cM[i].expenseAmount}.entries);
    }

    maxCatAm = filterToThreshold(maxCatAm, chartDataTotal(cM));

    return maxCatAm;
  }

  @override
  State<SavingOpportunities> createState() => _SavingOpportunitiesState();
}

class _SavingOpportunitiesState extends State<SavingOpportunities>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> opacityAnimation;
  void showNewPop(BuildContext ct, Widget widg) {
    showModalBottomSheet(
        transitionAnimationController: _animationController,
        useSafeArea: true,
        isScrollControlled: true,
        context: ct,
        builder: (ctx) => widg);
  }

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    opacityAnimation = CurvedAnimation(
        parent: Tween<double>(begin: 1, end: 0).animate(_animationController),
        curve: Curves.linear);

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget bodyWidget(
    Size screenSize,
    Widget sliderWidgets,
    String disclaimerText,
  ) {
    Provider.of<Expenses>(context, listen: false).fetchSliderValues();
    SavingOpportunities.slideCategoryValues =
        Provider.of<Expenses>(context, listen: false).slideValues;
    return (screenSize.height > 600)
        ? Column(
            children: [
              Container(
                margin: const EdgeInsets.all(5),
                width: screenSize.width,
                height: screenSize.height * 0.4,
                child: sliderWidgets,
              ),
              Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        showNewPop(
                            context,
                            SavingOpReport(
                                widget
                                    .cMaptoCatL(widget.cMap.values.toList()[1])
                                    .keys
                                    .toList(),
                                widget
                                    .cMaptoCatL(widget.cMap.values.toList()[2])
                                    .keys
                                    .toList(),
                                widget
                                    .cMaptoCatL(widget.cMap.values.toList()[3])
                                    .keys
                                    .toList()));
                      },
                      child: const Text('Get Saving Opportunities report')),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    disclaimerText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        height: 1.5),
                  )
                ],
              )
            ],
          )
        : Row(
            children: [
              Container(
                margin: const EdgeInsets.all(5),
                width: (screenSize.height > 600)
                    ? screenSize.width
                    : screenSize.width * 0.4,
                height: (screenSize.height > 600)
                    ? screenSize.height * 0.4
                    : screenSize.height,
                child: sliderWidgets,
              ),
              SizedBox(
                width: (screenSize.height > 600)
                    ? screenSize.width
                    : screenSize.width * 0.5,
                height: (screenSize.height > 600)
                    ? screenSize.height * 0.6
                    : screenSize.height,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          showNewPop(
                              context,
                              SavingOpReport(
                                  widget
                                      .cMaptoCatL(
                                          widget.cMap.values.toList()[1])
                                      .keys
                                      .toList(),
                                  widget
                                      .cMaptoCatL(
                                          widget.cMap.values.toList()[2])
                                      .keys
                                      .toList(),
                                  widget
                                      .cMaptoCatL(
                                          widget.cMap.values.toList()[3])
                                      .keys
                                      .toList()));
                        },
                        child: const Text('Get Saving Opportunities report')),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      disclaimerText,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.clip,
                      softWrap: true,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          height: 1.5),
                    )
                  ],
                ),
              )
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    String disclaimerText =
        'This report aims to identify potential saving opportunities based on your spending patterns. By analyzing your expenses over the past week,month,year. We have discovered areas where you can potentially reduce your spending and save money.';
    Widget sliderWidgets() {
      return Column(
        children: [
          const Text(
            'Adjust Expenses Threshold(%)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: GridView.builder(
              itemCount: 9,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing: 0.2, crossAxisSpacing: 0, crossAxisCount: 3),
              itemBuilder: (ctx, i) => SliderElement(
                  Category.values.elementAt(i).name,
                  SavingOpportunities.slideCategoryValues[i],
                  i),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Funds Minder'),
      ),
      body: FutureBuilder(
          future:
              Provider.of<Expenses>(context, listen: false).fetchSliderValues(),
          builder: (ctx, snapshot) {
            return (snapshot.connectionState == ConnectionState.waiting)
                ? const Text("Loading..")
                : bodyWidget(screenSize, sliderWidgets(), disclaimerText);
          }),
    );
  }
}
