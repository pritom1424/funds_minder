import 'package:flutter/material.dart';
import 'package:funds_minder/View_Model/goals.dart';
import 'package:funds_minder/Widget/GoalSettings/update_goal.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SingleGoalItem extends StatefulWidget {
  final String gId;
  final double totalSavings, goalAmount;
  final String title;
  final DateTime expiredDate;
  const SingleGoalItem(this.gId, this.title, this.totalSavings, this.goalAmount,
      this.expiredDate,
      {super.key});

  @override
  State<SingleGoalItem> createState() => _SingleGoalItemState();
}

class _SingleGoalItemState extends State<SingleGoalItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> opacityAnimation;
  double getFraction() {
    double frac = 0;
    if (widget.goalAmount <= 0 || widget.totalSavings < 0) {
      return 0;
    }
    (widget.goalAmount > widget.totalSavings)
        ? frac = widget.totalSavings / widget.goalAmount
        : frac = 1;

    return frac;
  }

  void showNewPop(BuildContext ct, Widget widg) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        transitionAnimationController: _animationController,
        useSafeArea: true,
        isScrollControlled: true,
        context: ct,
        builder: (ctx) => widg);
  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);

    var totalDays = (to.difference(from).inHours / 24).round();
    return totalDays;
  }

  int goalStatus(double amount, double savings, int days) {
    if (savings < amount && days < 0) {
      return -1;
    } else if (savings >= amount && days >= 0) {
      return 1;
    }
    return 0;
  }

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    opacityAnimation = CurvedAnimation(
        parent: Tween<double>(begin: 1, end: 0).animate(_animationController),
        curve: Curves.linear);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final format = DateFormat.yMMMMd();
    final daysRemaining = daysBetween(DateTime.now(), widget.expiredDate);

    return SizedBox(
      width: width * 0.6,
      height: height * 0.4,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                (isDarkMode)
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : Theme.of(context).colorScheme.primary.withOpacity(0.8),
                Theme.of(context).colorScheme.primary.withOpacity(0.3)
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: height > 600
                    ? Text(
                        widget.title,
                        style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: isDarkMode
                                    ? Colors.tealAccent
                                    : Colors.white),
                          ),
                          Text(
                            'Last Date: ${format.format(widget.expiredDate)}',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Text(
                            'Total Savings: ${widget.totalSavings.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Text(
                            'Goal Amount: ${widget.goalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
              ),
              Text(
                (goalStatus(widget.goalAmount, widget.totalSavings,
                            daysRemaining)) ==
                        -1
                    ? 'Goal expired. Failed to achieve this goal'
                    : (goalStatus(widget.goalAmount, widget.totalSavings,
                                daysRemaining) ==
                            1)
                        ? 'Well done! This goal is completed successfully!!!'
                        : '${widget.goalAmount - widget.totalSavings} To  reach goal in $daysRemaining days',
                style: const TextStyle(color: Colors.white),
              ),
              Container(
                width: width * 0.6,
                height: height * 0.02,
                color: Colors.black45,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  heightFactor: 1,
                  widthFactor: getFraction(),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(8)),
                      color: isDarkMode
                          ? Colors.blue.shade100
                          : Colors.blue.withOpacity(1),
                    ),
                  ),
                ),
              ),
              if (height > 600)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    'Last Date: ${format.format(widget.expiredDate)}',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              if (height > 600)
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    'Total Savings: ${widget.totalSavings.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: Colors.yellow),
                  ),
                ),
              if (height > 600)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    'Goal Amount: ${widget.goalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: Colors.white),
                  ),
                ),
              (height > 600)
                  ? ElevatedButton(
                      onPressed: goalStatus(widget.goalAmount,
                                  widget.totalSavings, daysRemaining) !=
                              0
                          ? null
                          : () {
                              showNewPop(
                                  context,
                                  UpdateGoal(widget.gId, widget.title,
                                      widget.totalSavings));
                            },
                      child: const Text('Add Savings'))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: goalStatus(widget.goalAmount,
                                        widget.totalSavings, daysRemaining) !=
                                    0
                                ? null
                                : () {
                                    showNewPop(
                                      context,
                                      UpdateGoal(widget.gId, widget.title,
                                          widget.totalSavings),
                                    );
                                  },
                            child: const Text('Add Savings')),
                        TextButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                      title: const Text("Are you sure?"),
                                      content: Text(
                                        "Do you want to delete this goal?",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                              Provider.of<Goals>(context,
                                                      listen: false)
                                                  .removeGoal(widget.gId);
                                            },
                                            child: const Text("Yes")),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                            child: const Text("No"))
                                      ],
                                    ));
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
              if (height > 600)
                TextButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                              title: const Text("Are you sure?"),
                              content: Text(
                                "Do you want to delete this goal?",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                      Provider.of<Goals>(context, listen: false)
                                          .removeGoal(widget.gId);
                                    },
                                    child: const Text("Yes")),
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    child: const Text("No"))
                              ],
                            ));
                  },
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.white),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
