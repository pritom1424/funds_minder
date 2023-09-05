import 'package:funds_minder/DB/dbhelper.dart';
import 'package:funds_minder/Model/budget.dart';
import 'package:funds_minder/Model/expense.dart';
import 'package:funds_minder/Model/goal.dart';

class BackgroundHandler {
  List<Budget> _bgBudgets = [];
  List<Expense> _bgExpenses = [];
  List<Expense> _filteredExpenses = [];
  List<Goal> _bgGoals = [];
  static BackgroundHandler current = BackgroundHandler();

  Future<bool> isGoalCrossed() async {
    var goalList = await DBhelper.getData(DBhelper.goalTableName);
    _bgGoals = [];
    if (goalList.isEmpty) {
      return false;
    }
    goalList = [...goalList];

    _bgGoals = goalList
        .map(
          (goal) {
            Goal fetchedGoal = Goal(
                id: goal['id'].toString(),
                title: goal['title'].toString(),
                expiredDate: DateTime.parse(goal['date'].toString()),
                amount: goal['amount'] as double);
            fetchedGoal.savings = goal['savings'] as double;
            return fetchedGoal;
          },
        )
        .toList()
        .reversed
        .toList();
    goalList.clear();

    for (Goal gl in _bgGoals) {
      if (gl.savings <= (gl.amount * 0.90) &&
          _daysBetween(DateTime.now(), gl.expiredDate) <= 2 &&
          _daysBetween(DateTime.now(), gl.expiredDate) >= -1) {
        return true;
      }
    }
    return false;
  }

  Future<bool> isBudgetCross() async {
    final budgetList = await DBhelper.getData(DBhelper.budgetTableName);

    int i = 0;
    if (budgetList.isEmpty) {
      return false;
    }
    _bgBudgets = [];
    _bgBudgets = budgetList.map((item) {
      if (i == 0) {
        Budget.firstdate = DateTime.parse(item['firstdate'].toString());
        Budget.lastDate = DateTime.parse(item['lastdate'].toString());
      }

      i++;
      return Budget(
          id: item['id'].toString(),
          amount: item['amount'] as double,
          category: _stringToCategory(item['category'].toString()));
    }).toList();

    var currExpSymb = '-';
    var dataList = await DBhelper.getData(DBhelper.tableName);
    dataList = [...dataList];
    if (dataList.isEmpty) {
      return false;
    }

    _bgExpenses = dataList
        .map((itm) {
          if (currExpSymb != itm['expense'].toString() &&
              itm['expense'] != null) {
            currExpSymb = itm['expense'].toString();
          }

          return Expense(
              id: itm['id'].toString(),
              title: itm['title'].toString(),
              amount: itm['amount'] as double,
              date: DateTime.parse(itm['date'].toString()),
              category: _stringToCategory(itm['category'].toString()),
              expenseSymbol: currExpSymb);
        })
        .toList()
        .reversed
        .toList();

    dataList.clear();
    _filteredExpenses =
        _getExpenseBydaysCount(Budget.firstdate, Budget.lastDate);
    if (_filteredExpenses.isEmpty) {
      return false;
    }

    for (Budget bdg in _bgBudgets) {
      if (_getTotalExpenseByCategory(bdg.category) < 0 &&
          _getTotalExpenseByCategory(bdg.category).abs() >=
              (bdg.amount * 0.95) &&
          _getTotalExpenseByCategory(bdg.category).abs() < (bdg.amount * 1)) {
        return true;
      }
    }
    return false;
  }

  Category _stringToCategory(String cat) {
    return Category.values.firstWhere((element) => cat == element.name);
  }

  int _yeartoDaysConvert(DateTime date) {
    int days = (date.year * 372) + (date.month * 31) + date.day;
    return days;
  }

  List<Expense> _getExpenseBydaysCount(
      DateTime? firstDate, DateTime? lastDate) {
    _filteredExpenses.clear();
    if (firstDate == null || lastDate == null) {
      _filteredExpenses = _bgExpenses;
      return _filteredExpenses;
    }
    int firstDateNum = _yeartoDaysConvert(firstDate);
    int lastDateNum = _yeartoDaysConvert(lastDate);

    if (firstDateNum > lastDateNum) {
      _filteredExpenses = _bgExpenses;
      //return _filteredExpenses;
      return [];
    }

    _filteredExpenses = _bgExpenses
        .where((element) =>
            _yeartoDaysConvert(element.date) >= firstDateNum &&
            _yeartoDaysConvert(element.date) <= lastDateNum)
        .toList();

    return _filteredExpenses;
  }

  double _getTotalExpenseByCategory(Category cat) {
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

  int _daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);

    var totalDays = (to.difference(from).inHours / 24).round();
    return totalDays;
  }
}
