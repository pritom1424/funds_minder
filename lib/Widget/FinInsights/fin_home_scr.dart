import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:funds_minder/Model/chart_data.dart';
import 'package:funds_minder/Model/expense.dart';
import 'package:funds_minder/View_Model/expenses.dart';
import 'package:funds_minder/Widget/ExpenseTracker/home_screen.dart';
import 'package:funds_minder/Widget/FinInsights/Data_Analysis/data_analysis_scr.dart';
import 'package:funds_minder/Widget/FinInsights/Saving_Opportunities/saving_opportunities.dart';
import 'package:funds_minder/Widget/FinInsights/Spending_Pattern/spending_patterns_scr.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class FinHomeScr extends StatelessWidget {
  static String homeRoute = '/fin_home_screen';

  const FinHomeScr({super.key});

  DateFormat filterToFormat(Filteroptions fOP) {
    switch (fOP) {
      case Filteroptions.yearly:
        return DateFormat.y();
      case Filteroptions.monthly:
        return DateFormat.yMMM();
      case Filteroptions.weekly:
        return DateFormat.yMMM();
      case Filteroptions.daily:
        return DateFormat.yMMMd();
      default:
        return DateFormat.M();
    }
  }

  List<ChartData> tListToCListConverter(List<Expense> exps) {
    List<ChartData> cList = [];
    if (exps.isEmpty) {
      return [];
    }

    for (var cat in Category.values) {
      double expAmount = 0, earnAmount = 0;
      for (var element in exps) {
        if (element.category == cat) {
          if (element.expenseSymbol == '-') {
            expAmount += element.amount;
          } else {
            earnAmount += element.amount;
          }
        }
      }

      cList.add(ChartData(cat.name, expAmount, earnAmount));
    }

    return cList;
  }

  purchaseConfigure(String authId) async {
    if (authId != "") {
      await Purchases.setLogLevel(LogLevel.debug);
      await Purchases.configure(
          PurchasesConfiguration("goog_YGwsrYGePglbcfONwkYxAIPrsEL")
            ..appUserID = authId
            ..observerMode = false);
    } else {
      print("Auth Id not found during purchase");
    }
  }

  Future<bool> didCustomerExist() async {
    final customInfo = await Purchases.getCustomerInfo();
    if (customInfo.entitlements.active['pro'] != null) {
      return customInfo.entitlements.active['pro']!.isActive;
    }
    return false;
  }

  Map<Filteroptions, List<ChartData>> chartMapData(Expenses expns) {
    Map<Filteroptions, List<ChartData>> ttl = {
      Filteroptions.all: tListToCListConverter(expns.getExpense(
          filterToFormat(Filteroptions.all), Filteroptions.all, 0, 0, 0)),
      Filteroptions.yearly: tListToCListConverter(expns.getExpense(
          filterToFormat(Filteroptions.yearly), Filteroptions.yearly, 0, 0, 0)),
      Filteroptions.monthly: tListToCListConverter(expns.getExpense(
          filterToFormat(Filteroptions.monthly),
          Filteroptions.monthly,
          0,
          0,
          0)),
      Filteroptions.weekly: tListToCListConverter(expns.getExpense(
          filterToFormat(Filteroptions.weekly), Filteroptions.weekly, 0, 0, 0)),
      Filteroptions.daily: tListToCListConverter(expns.getExpense(
          filterToFormat(Filteroptions.daily), Filteroptions.daily, 0, 0, 0)),
    };

    return ttl;
  }

  List<Widget> finWidgetsChildren(
      Size screenSize,
      BuildContext context,
      Map<Filteroptions, List<ChartData>> chartMap,
      List<Expense> expList,
      double btnRad,
      double heightFraction,
      double widthFraction,
      isDrkMode,
      String aId) {
    return [
      Container(
        height: screenSize.height * heightFraction,
        width: screenSize.width * widthFraction,
        padding: const EdgeInsets.all(10),
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => DataAnalysisScr(chartMap, expList),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: (isDrkMode)
                ? Colors.white
                : const Color.fromARGB(255, 30, 30, 30),
            backgroundColor: (!isDrkMode)
                ? Colors.white
                : const Color.fromARGB(255, 30, 30, 30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(btnRad),
            ),
          ),
          child: const Text(
            'Data Analysis',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontFamily: 'RobotoCRegular'),
          ),
        ),
      ),
      if (aId != "")
        Container(
            padding: const EdgeInsets.all(10),
            height: screenSize.height * heightFraction,
            width: screenSize.width * widthFraction,
            child: FutureBuilder(
              future: didCustomerExist(),
              builder: (context, didExistSnapshot) =>
                  (didExistSnapshot.connectionState == ConnectionState.waiting)
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ((didExistSnapshot.data != null &&
                                    didExistSnapshot.data == true))
                                ? Navigator.of(context).push(MaterialPageRoute(
                                    builder: (ctx) =>
                                        SpendingPatternsScr(chartMap, expList)))
                                : ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            "Please purchase premium to get this!")));
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 10,
                            // shadowColor: Colors.transparent,
                            backgroundColor: (!isDrkMode)
                                ? ((didExistSnapshot.data != null &&
                                        didExistSnapshot.data == true))
                                    ? Colors.white
                                    : const Color.fromARGB(255, 165, 157, 157)
                                : ((didExistSnapshot.data != null &&
                                        didExistSnapshot.data == true))
                                    ? const Color.fromARGB(255, 30, 30, 30)
                                    : Color.fromARGB(255, 15, 2, 1),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(btnRad)),
                          ),
                          child: Text(
                            'Spending Patterns',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'RobotoCMedium',
                              color: (isDrkMode) ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
            )),
      if (aId != "")
        Container(
            padding: const EdgeInsets.all(10),
            height: screenSize.height * heightFraction,
            width: screenSize.width * widthFraction,
            child: FutureBuilder(
              future: didCustomerExist(),
              builder: (context, didExistSnapshot) =>
                  (didExistSnapshot.connectionState == ConnectionState.waiting)
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ((didExistSnapshot.data != null &&
                                    didExistSnapshot.data == true))
                                ? Navigator.of(context).push(MaterialPageRoute(
                                    builder: (ctx) =>
                                        SavingOpportunities(chartMap)))
                                : ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            "Please purchase premium to get this!")));
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 10,
                            //shadowColor: Colors.transparent,
                            backgroundColor: (!isDrkMode)
                                ? ((didExistSnapshot.data != null &&
                                        didExistSnapshot.data == true))
                                    ? Colors.white
                                    : const Color.fromARGB(255, 165, 157, 157)
                                : ((didExistSnapshot.data != null &&
                                        didExistSnapshot.data == true))
                                    ? const Color.fromARGB(255, 30, 30, 30)
                                    : Color.fromARGB(255, 15, 2, 1),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(btnRad)),
                          ),
                          child: Text(
                            'Saving Oppurtunities',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'RobotoCMedium',
                              color: (isDrkMode) ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
            ))
    ];
  }

  Widget finWidgets(
      BuildContext context,
      Size screenSize,
      Map<Filteroptions, List<ChartData>> chartMap,
      List<Expense> expList,
      double btnRad,
      bool isDrkMode,
      String _authId) {
    return SizedBox(
      width: screenSize.width,
      height: screenSize.height,
      child: (screenSize.height <= 600)
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: finWidgetsChildren(screenSize, context, chartMap,
                  expList, btnRad, 0.5, 0.25, isDrkMode, _authId),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: screenSize.height * 0.3,
                    padding: const EdgeInsets.only(bottom: 50, top: 10),
                    child: ListTile(
                      titleTextStyle: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                      minVerticalPadding: 20,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      title: const Text(
                        'Financial Insights',
                      ),
                      subtitle: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'Get valuable Financial Insights through data analysis, spending patterns, and personalized saving opportunities. Take control of your finances for a more secure future.',
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GridView(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 40,
                              crossAxisSpacing: 40,
                              childAspectRatio: 1),
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) =>
                                    DataAnalysisScr(chartMap, expList),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 10,
                            backgroundColor: (!isDrkMode)
                                ? Colors.white
                                : const Color.fromARGB(255, 30, 30, 30),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(btnRad)),
                          ),
                          child: Text(
                            'Data Analysis',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'RobotoCMedium',
                              color: (isDrkMode) ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        if (_authId != "")
                          FutureBuilder(
                            future: didCustomerExist(),
                            builder: (context, didExistSnapshot) =>
                                (didExistSnapshot.connectionState ==
                                        ConnectionState.waiting)
                                    ? CircularProgressIndicator()
                                    : ElevatedButton(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context)
                                              .clearSnackBars();
                                          ((didExistSnapshot.data != null &&
                                                  didExistSnapshot.data ==
                                                      true))
                                              ? Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (ctx) =>
                                                          SpendingPatternsScr(
                                                              chartMap,
                                                              expList)))
                                              : ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content: Text(
                                                          "Please purchase premium to get this!")));
                                        },
                                        style: ElevatedButton.styleFrom(
                                          elevation: 10,
                                          // shadowColor: Colors.transparent,
                                          backgroundColor: (!isDrkMode)
                                              ? ((didExistSnapshot.data !=
                                                          null &&
                                                      didExistSnapshot.data ==
                                                          true))
                                                  ? Colors.white
                                                  : const Color.fromARGB(
                                                      255, 165, 157, 157)
                                              : ((didExistSnapshot.data !=
                                                          null &&
                                                      didExistSnapshot.data ==
                                                          true))
                                                  ? const Color.fromARGB(
                                                      255, 30, 30, 30)
                                                  : Color.fromARGB(
                                                      255, 15, 2, 1),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      btnRad)),
                                        ),
                                        child: Text(
                                          'Spending Patterns',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontFamily: 'RobotoCMedium',
                                            color: (isDrkMode)
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                          ),
                        if (_authId != "")
                          FutureBuilder(
                            future: didCustomerExist(),
                            builder: (context, didExistSnapshot) =>
                                (didExistSnapshot.connectionState ==
                                        ConnectionState.waiting)
                                    ? CircularProgressIndicator()
                                    : ElevatedButton(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context)
                                              .clearSnackBars();
                                          ((didExistSnapshot.data != null &&
                                                  didExistSnapshot.data ==
                                                      true))
                                              ? Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (ctx) =>
                                                          SavingOpportunities(
                                                              chartMap)))
                                              : ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content: Text(
                                                          "Please purchase premium to get this!")));
                                        },
                                        style: ElevatedButton.styleFrom(
                                          elevation: 10,
                                          //shadowColor: Colors.transparent,
                                          backgroundColor: (!isDrkMode)
                                              ? ((didExistSnapshot.data !=
                                                          null &&
                                                      didExistSnapshot.data ==
                                                          true))
                                                  ? Colors.white
                                                  : const Color.fromARGB(
                                                      255, 165, 157, 157)
                                              : ((didExistSnapshot.data !=
                                                          null &&
                                                      didExistSnapshot.data ==
                                                          true))
                                                  ? const Color.fromARGB(
                                                      255, 30, 30, 30)
                                                  : Color.fromARGB(
                                                      255, 15, 2, 1),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      btnRad)),
                                        ),
                                        child: Text(
                                          'Saving Oppurtunities',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontFamily: 'RobotoCMedium',
                                            color: (isDrkMode)
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                          )
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double btnRad = 10;
    final screenSize = MediaQuery.of(context).size;
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    var _authId = FirebaseAuth.instance.currentUser?.uid ?? "";
    purchaseConfigure(_authId);
    return Scaffold(
      appBar: AppBar(title: const Text('Funds Minder')),
      body: FutureBuilder(
        future: Provider.of<Expenses>(context, listen: false).fetchExpense(),
        builder: (ctx, snapshot) =>
            (snapshot.connectionState == ConnectionState.waiting)
                ? const Center(child: Text('Loading..'))
                : Consumer<Expenses>(
                    child: Text('still no chart',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        )),
                    builder: (ctx, expns, ch) {
                      final chartMap = chartMapData(expns);

                      final expList = expns.getExpense(
                          filterToFormat(Filteroptions.all),
                          Filteroptions.all,
                          0,
                          0,
                          0);

                      return finWidgets(context, screenSize, chartMap, expList,
                          btnRad, isDarkMode, _authId);
                    }),
      ),
    );
  }
}
