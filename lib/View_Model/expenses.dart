import 'dart:convert';

import 'package:funds_minder/Model/budget.dart';
import 'package:funds_minder/Widget/FinInsights/Saving_Opportunities/saving_opportunities.dart';
import 'package:intl/intl.dart';
import '../DB/dbhelper.dart';
import '../Model/expense.dart';
import 'package:flutter/material.dart';
import '../Model/report.dart';
import '../Widget/ExpenseTracker/home_screen.dart';

class Expenses with ChangeNotifier {
  List<Expense> _expenses = [];
  List<Report> _reports = [];
  List<Expense> _filteredExpenses = [];
  List<Budget> _budgets = [];
  List<int> _slideValues = [50, 50, 50, 50, 50, 50, 50, 50, 50];
  double totalDeal = 0.0,
      totalEarning = 0.0,
      totalExpense = 0.0,
      liveDeal = 0.0,
      liveExpense = 0.0,
      liveEarn = 0.0;

  String currentCurrency = '\$';

  late Expense _currentExpense = Expense(
      id: 'default',
      title: '',
      amount: 0,
      date: DateTime.now(),
      category: Category.food,
      expenseSymbol: '');

  Map<IconData, double> total = {
    Icons.school: 0,
    Icons.lunch_dining: 0,
    Icons.movie: 0,
    Icons.medical_services: 0,
    Icons.miscellaneous_services: 0,
    Icons.flight_takeoff: 0,
    Icons.business: 0,
    Icons.work: 0,
    Icons.home: 0,
  };
  Map<Category, double> totalBudget = {
    Category.education: 0,
    Category.food: 0,
    Category.leisure: 0,
    Category.medical: 0,
    Category.other: 0,
    Category.travel: 0,
    Category.business: 0,
    Category.job: 0,
    Category.utilities: 0
  };
  Map<IconData, double> totalPrev = {
    Icons.school: 0,
    Icons.lunch_dining: 0,
    Icons.movie: 0,
    Icons.medical_services: 0,
    Icons.miscellaneous_services: 0,
    Icons.flight_takeoff: 0,
    Icons.business: 0,
    Icons.work: 0,
    Icons.home: 0,
  };

  void addExpense(Expense exp, String symb) {
    _expenses.insert(0, exp);
    currentCurrency = symb;

    notifyListeners();

    _currentExpense = exp;

    DBhelper.insert(DBhelper.tableName, {
      'id': exp.id,
      'title': exp.title,
      'amount': exp.amount,
      'date': exp.date.toIso8601String(),
      'category': exp.category.name,
      'currency': symb,
      'expense': exp.expenseSymbol,
    });
//    DBhelper.updateTable(DBhelper.tableName, {'currency': symb}, null, null);
  }

  void addSlideValues(int i, int newVal) {
    _slideValues[i] = newVal;
    notifyListeners();
    String slideValuesJson = json.encode(_slideValues);
    DBhelper.insert(DBhelper.sliderValues, {'svalues': slideValuesJson});
  }

  void updateSlideValues(int i, int updateVal) {
    _slideValues[i] = updateVal;
    notifyListeners();
    String slideValuesJson = json.encode(_slideValues);
    DBhelper.updateTable(
        DBhelper.sliderValues, {'svalues': slideValuesJson}, null, null);
  }

  void addBudget(Budget budget, DateTime firstDate, DateTime lastDate) {
    Budget budg = budget;

    if (_budgets.isNotEmpty) {
      budg = _budgets.firstWhere(
        (element) => element.category == budget.category,
        orElse: () => budget,
      );
    }
    (budg.id == budget.id)
        ? _budgets.add(budg)
        : _budgets[_budgets.indexWhere((element) => element.id == budg.id)]
            .amount = budget.amount;

    notifyListeners();

    (budg.id == budget.id)
        ? DBhelper.insert(DBhelper.budgetTableName, {
            'id': budget.id,
            'amount': budget.amount,
            'firstdate': firstDate.toIso8601String(),
            'lastdate': lastDate.toIso8601String(),
            'category': budget.category.name
          })
        : DBhelper.updateTable(DBhelper.budgetTableName,
                {'amount': budget.amount}, 'id', budg.id.toString())
            .catchError((err) {});
  }

  Future<void> removeExpense(Expense exp) async {
    _currentExpense = exp;
    _expenses.removeWhere((ex) {
      return ex.id == exp.id;
    });
    await DBhelper.deleteData(DBhelper.tableName, 'id', exp.id);
    /*  await DBhelper.deleteData(
        DBhelper.reportTableName, 'date', DateFormat.yMMM().format(exp.date)); */

    //await DBhelper.delete();

    notifyListeners();
  }

  Future<void> fetchBudget() async {
    final dataList = await DBhelper.getData(DBhelper.budgetTableName);
    int i = 0;
    _budgets = dataList.map((itm) {
      if (i == 0) {
        Budget.firstdate = DateTime.parse(itm['firstdate'].toString());
        Budget.lastDate = DateTime.parse(itm['lastdate'].toString());
        if (_yeartoDaysConvert(Budget.firstdate) >
            (_yeartoDaysConvert(Budget.lastDate))) {
          Budget.lastDate = Budget.firstdate;
        }
        i++;
      }

      return Budget(
          id: itm['id'].toString(),
          amount: itm['amount'] as double,
          category: stringToCategory(itm['category'].toString()));
    }).toList();
    notifyListeners();
  }

  Future<void> fetchSliderValues() async {
    final dataListJson = await DBhelper.getData(DBhelper.sliderValues);

    String temp = '';
    List<String> dataListString = [];
    final List<int> dataList = [];
    for (var element in dataListJson) {
      temp = element.values.toString();
    }
    if (temp.isNotEmpty) {
      dataListString = temp.split(',');
      dataListString[0] = dataListString[0].replaceAll(RegExp(r'[^0-9]'), '');
      dataListString[dataListString.length - 1] =
          dataListString[dataListString.length - 1]
              .replaceAll(RegExp(r'[^0-9]'), '');
    }

    if (dataListString.isNotEmpty) {
      for (int i = 0; i < dataListString.length; i++) {
        dataList.add(int.parse(dataListString[i]));
      }
    }

    if (dataList.isNotEmpty) {
      _slideValues.clear();
      _slideValues = dataList;
      SavingOpportunities.isExist = true;
    } else {
      SavingOpportunities.isExist = false;
    }
    notifyListeners();
  }

  Future<void> fetchExpense() async {
    var currExpSymb = '-';
    List<Map<String, Object?>> dataList =
        await DBhelper.getData(DBhelper.tableName);
    dataList = [...dataList];
    _expenses = dataList
        .map((itm) {
          if (currentCurrency != itm['currency'].toString() &&
              itm['currency'] != null) {
            currentCurrency = itm['currency'].toString();
          }
          if (currExpSymb != itm['expense'].toString() &&
              itm['expense'] != null) {
            currExpSymb = itm['expense'].toString();
          }

          return Expense(
              id: itm['id'].toString(),
              title: itm['title'].toString(),
              amount: itm['amount'] as double,
              date: DateTime.parse(itm['date'].toString()),
              category: stringToCategory(itm['category'].toString()),
              expenseSymbol: currExpSymb);
        })
        .toList()
        .reversed
        .toList();
    dataList.clear();
    final budgetList = await DBhelper.getData(DBhelper.budgetTableName);
    int i = 0;
    if (budgetList.isNotEmpty) {
      _budgets = budgetList.map((item) {
        if (i == 0) {
          Budget.firstdate = DateTime.parse(item['firstdate'].toString());
          Budget.lastDate = DateTime.parse(item['lastdate'].toString());
        }
        i++;
        return Budget(
            id: item['id'].toString(),
            amount: item['amount'] as double,
            category: stringToCategory(item['category'].toString()));
      }).toList();
    }

    totalExpenseMap();

    notifyListeners();
  }

  List<Expense> get allExpenses {
    return [..._expenses];
  }

  List<int> get slideValues {
    return [..._slideValues];
  }

  List<Expense> getExpense(DateFormat df, Filteroptions fOp, int yearToSubtract,
      int monthtoSubtract, int daytoSubtract) {
    if (fOp == Filteroptions.daily ||
        fOp == Filteroptions.monthly ||
        fOp == Filteroptions.yearly) {
      _filteredExpenses = _expenses
          .where((element) => (df.format(element.date) ==
              df.format(DateTime(
                  DateTime.now().year - yearToSubtract,
                  DateTime.now().month - monthtoSubtract,
                  DateTime.now().day - daytoSubtract))))
          .toList();
    } else if (fOp == Filteroptions.weekly) {
      _filteredExpenses = _expenses
          .where((element) =>
              (df.format(element.date) == df.format(DateTime.now()) &&
                  element.date.day.toDouble() ~/ 7 ==
                      DateTime.now().day.toDouble() ~/ 7))
          .toList();
    } else {
      _filteredExpenses = _expenses;
    }

    return _filteredExpenses;
  }

  int _yeartoDaysConvert(DateTime date) {
    int days = (date.year * 372) + (date.month * 31) + date.day;
    return days;
  }

  List<Expense> getExpenseBydaysCount(DateTime? firstDate, DateTime? lastDate) {
    _filteredExpenses.clear();
    if (firstDate == null || lastDate == null) {
      _filteredExpenses = _expenses;
      return _filteredExpenses;
    }
    int firstDateNum = _yeartoDaysConvert(firstDate);
    int lastDateNum = _yeartoDaysConvert(lastDate);

    if (firstDateNum > lastDateNum) {
      _filteredExpenses = _expenses;
      return [];
    }

    _filteredExpenses = _expenses
        .where((element) =>
            _yeartoDaysConvert(element.date) >= firstDateNum &&
            _yeartoDaysConvert(element.date) <= lastDateNum)
        .toList();

    return _filteredExpenses;
  }

  List<Report> get getReports {
    return [..._reports];
  }

  void totalExpenseMap() {
    total = {
      Icons.school: getTotalExpenseByCategory(Category.education),
      Icons.lunch_dining: getTotalExpenseByCategory(Category.food),
      Icons.movie: getTotalExpenseByCategory(Category.leisure),
      Icons.medical_services: getTotalExpenseByCategory(Category.medical),
      Icons.miscellaneous_services: getTotalExpenseByCategory(Category.other),
      Icons.flight_takeoff: getTotalExpenseByCategory(Category.travel),
      Icons.business: getTotalExpenseByCategory(Category.business),
      Icons.work: getTotalExpenseByCategory(Category.job),
      Icons.home: getTotalExpenseByCategory(Category.utilities),
    };

    updateTotalExpense();
  }

  void totalBudgetMap() {
    totalBudget = {
      Category.education: getTotalBudgetByCategory(Category.education),
      Category.food: getTotalBudgetByCategory(Category.food),
      Category.leisure: getTotalBudgetByCategory(Category.leisure),
      Category.medical: getTotalBudgetByCategory(Category.medical),
      Category.other: getTotalBudgetByCategory(Category.other),
      Category.travel: getTotalBudgetByCategory(Category.travel),
      Category.business: getTotalBudgetByCategory(Category.business),
      Category.job: getTotalBudgetByCategory(Category.job),
      Category.utilities: getTotalBudgetByCategory(Category.utilities)
    };
  }

  double getTotalExpenseByCategory(Category cat) {
    double total = 0;
    if (_filteredExpenses.isEmpty) {
      return 0;
    }
    final tempExp = _filteredExpenses
        .where((element) => (element.category == cat))
        .toList();
    for (var element in tempExp) {
      if (element.expenseSymbol == '+') {
        total += element.amount;
      } else {
        total -= element.amount;
      }
    }
    return total;
  }

  double getTotalBudgetByCategory(Category cat) {
    double total = 0;

    if (_budgets.isEmpty) {
      return 0;
    }

    final tempBudg = _budgets.firstWhere(
      (element) => (element.category == cat),
      orElse: () =>
          Budget(id: 'default', amount: 0, category: Category.leisure),
    );

    total = tempBudg.amount;

    return total;
  }

  List<double> getTotalEarnExpense(List<Expense> tempExp) {
    double trExpense = 0, trEarn = 0;
    if (tempExp.isEmpty) {
      return [0, 0, 0];
    }

    for (var element in tempExp) {
      (element.expenseSymbol == '+')
          ? trEarn += element.amount
          : trExpense -= element.amount;
    }
    return [trExpense, trEarn, (trExpense + trEarn)];
  }

  Future<void> updateTotalExpense() async {
    totalDeal = 0;
    totalEarning = 0;
    totalExpense = 0;
    double totalDealPrev = 0;
    double totalExpensePrev = 0;
    double totalEarnPrev = 0;
    liveDeal = 0;
    liveEarn = 0;
    liveExpense = 0;

    List<double> prevExpEarnProfit = getTotalEarnExpense(
        getExpense(DateFormat.yMMM(), Filteroptions.monthly, 0, 1, 0));
    List<double> expEarnProfit = getTotalEarnExpense(
        getExpense(DateFormat.yMMM(), Filteroptions.monthly, 0, 0, 0));
    List<double> liveExpEarnProfit = getTotalEarnExpense(_filteredExpenses);

    totalExpense = expEarnProfit[0].abs();
    totalEarning = expEarnProfit[1];
    totalDeal = expEarnProfit[2];
    totalExpensePrev = prevExpEarnProfit[0].abs();
    totalEarnPrev = prevExpEarnProfit[1];
    totalDealPrev = prevExpEarnProfit[2];
    liveDeal = liveExpEarnProfit[2];
    liveEarn = liveExpEarnProfit[1];
    liveExpense = liveExpEarnProfit[0];
    //no database no record

    if (totalDeal == 0 &&
        totalEarning == 0 &&
        totalExpense == 0 &&
        totalDealPrev == 0 &&
        totalEarnPrev == 0 &&
        totalExpensePrev == 0 &&
        liveDeal == 0 &&
        liveEarn == 0 &&
        liveExpense == 0 &&
        _currentExpense.id == 'default') {
      return;
    }

    var reportList = [];
    reportList = await DBhelper.getData(DBhelper.reportTableName);
    //no database but have record
    if (reportList.isEmpty) {
      List<Map<String, dynamic>> tempMap = [
        {
          'id': 0,
          'date': DateFormat.yMMM().format(DateTime.now()),
          'profit': '0',
          'expense': '0',
          'earn': '0'
        },
        {
          'id': 1,
          'date': DateFormat.yMMM()
              .format(DateTime.now().subtract(const Duration(days: 30))),
          'profit': '0',
          'expense': '0',
          'earn': '0'
        }
      ];
      DBhelper.insert(DBhelper.reportTableName, tempMap[0]);
      DBhelper.insert(DBhelper.reportTableName, tempMap[1]);

      reportList = await DBhelper.getData(DBhelper.reportTableName);
    }

    if (_expenses.isNotEmpty && _currentExpense.id == 'default') {
      _currentExpense = _expenses.last;
    }

    _reports = reportList.map((rData) {
      if (rData['date'] == DateFormat.yMMM().format(_currentExpense.date)) {
        DBhelper.updateTable(
            DBhelper.reportTableName,
            {
              'profit':
                  (rData['date'] == DateFormat.yMMM().format(DateTime.now()))
                      ? totalDeal.toString()
                      : totalDealPrev.toString(),
              'expense':
                  (rData['date'] == DateFormat.yMMM().format(DateTime.now()))
                      ? totalExpense.toString()
                      : totalExpensePrev.toString(),
              'earn':
                  (rData['date'] == DateFormat.yMMM().format(DateTime.now()))
                      ? totalEarning.toString()
                      : totalEarnPrev.toString(),
            },
            'date',
            DateFormat.yMMM().format(_currentExpense.date));
      }

      return Report(
          id: (rData['id'] as int),
          date: rData['date'].toString(),
          profit: (rData['date'] == DateFormat.yMMM().format(DateTime.now()))
              ? totalDeal
              : totalDealPrev,
          expense: (rData['date'] == DateFormat.yMMM().format(DateTime.now()))
              ? totalExpense
              : totalExpensePrev,
          earning: (rData['date'] == DateFormat.yMMM().format(DateTime.now()))
              ? totalEarning
              : totalEarnPrev);
    }).toList();
  }

  Category stringToCategory(String cat) {
    return Category.values.firstWhere((element) => cat == element.name);
  }

  List<Expense> get filteredExpense {
    return [..._filteredExpenses];
  }

  List<Budget> get budgets {
    return [..._budgets];
  }
}
