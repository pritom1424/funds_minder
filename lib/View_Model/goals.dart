import 'package:flutter/material.dart';
import 'package:funds_minder/DB/dbhelper.dart';
import 'package:funds_minder/Model/goal.dart';

class Goals with ChangeNotifier {
  List<Goal> _goals = [];

  void addGoals(Goal goal) {
    _goals.insert(0, goal);

    notifyListeners();
    DBhelper.insert(DBhelper.goalTableName, {
      'id': goal.id,
      'title': goal.title,
      'date': goal.expiredDate.toIso8601String(),
      'amount': goal.amount,
      'savings': goal.savings,
    });
  }

  void updateGoal(String goalId, double savedAmount) {
    var curr = _goals[_goals.indexWhere((goal) => goal.id == goalId)].savings +=
        savedAmount;
    notifyListeners();
    DBhelper.updateTable(
        DBhelper.goalTableName, {'savings': curr}, 'id', goalId);
  }

  void removeGoal(String goalId) async {
    _goals.removeWhere((goal) => goal.id == goalId);
    notifyListeners();
    await DBhelper.deleteData(DBhelper.goalTableName, 'id', goalId);
  }

  Future<void> fetchGoal() async {
    final goalList = await DBhelper.getData(DBhelper.goalTableName);
    _goals = [];
    if (goalList.isNotEmpty) {
      _goals = goalList
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
    }

    notifyListeners();
  }

  List<Goal> get getGoals {
    return [..._goals];
  }
}
