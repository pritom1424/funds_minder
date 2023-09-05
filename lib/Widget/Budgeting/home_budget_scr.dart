import 'package:flutter/material.dart';
import 'package:funds_minder/DB/dbhelper.dart';
import 'package:funds_minder/Model/budget.dart';
import 'package:funds_minder/View_Model/expenses.dart';
import 'package:funds_minder/Widget/Budgeting/budget_list.dart';
import 'package:funds_minder/Widget/Budgeting/budget_widget.dart';
import 'package:funds_minder/Widget/Budgeting/new_budget.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomeBudgetScreen extends StatefulWidget {
  static String budgetRoute = '/budget_screen';
  const HomeBudgetScreen({super.key});

  @override
  State<HomeBudgetScreen> createState() => _HomeBudgetScreenState();
}

class _HomeBudgetScreenState extends State<HomeBudgetScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> opacityAnimation;
  final formatter = DateFormat.yMd();

  Widget bodyWidget(double height, bool isSetBudget, Expenses expns) {
    return (height <= 600)
        ? Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3),
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.0)
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: BudgetWidget(
                          Budget.firstdate, Budget.lastDate, isSetBudget),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          height: 30,
                          width: 50,
                          child: FractionallySizedBox(
                            heightFactor: 0.2,
                            widthFactor: 1,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(8)),
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                        ),
                        Text(
                          'Budget Amount',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        SizedBox(
                          height: 40,
                          width: 50,
                          child: FractionallySizedBox(
                            heightFactor: 0.2,
                            widthFactor: 1,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(8)),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.4)),
                            ),
                          ),
                        ),
                        Text(
                          'Expense Amount',
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: ElevatedButton(
                          onPressed: () {
                            showNewPop(context,
                                NewBudget(Budget.firstdate, Budget.lastDate));
                          },
                          child: const Text('Set Budget')),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: BudgetList(
                            expns, Budget.firstdate, Budget.lastDate),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          )
        : Column(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        Theme.of(context).colorScheme.primary.withOpacity(0.0)
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  child: BudgetWidget(
                      Budget.firstdate, Budget.lastDate, isSetBudget),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: 30,
                    width: 50,
                    child: FractionallySizedBox(
                      heightFactor: 0.2,
                      widthFactor: 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8)),
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ),
                  Text(
                    'Budget Amount',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  SizedBox(
                    height: 40,
                    width: 50,
                    child: FractionallySizedBox(
                      heightFactor: 0.2,
                      widthFactor: 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8)),
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.4)),
                      ),
                    ),
                  ),
                  Text(
                    'Expense Amount',
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                ],
              ),
              ElevatedButton(
                  onPressed: () {
                    showNewPop(
                        context, NewBudget(Budget.firstdate, Budget.lastDate));
                  },
                  child: const Text('Set Budget')),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: BudgetList(expns, Budget.firstdate, Budget.lastDate),
                ),
              ),
            ],
          );
  }

  List<Widget> actionWidgets(BuildContext ctx) {
    return [
      Row(
        children: [
          SizedBox(
            height: 25,
            width: 25,
            child: IconButton(
                iconSize: 12,
                onPressed: () {
                  showCalenderRange(context, false);
                },
                icon: const Icon(
                  Icons.date_range,
                  color: Colors.lightBlue,
                )),
          ),
          Text(
            formatter.format(Budget.firstdate),
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          const SizedBox(
            width: 10,
          ),
          const Text(
            'TO',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.orange,
                fontSize: 10,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
      Row(
        children: [
          SizedBox(
            height: 25,
            width: 25,
            child: IconButton(
                iconSize: 12,
                onPressed: () {
                  showCalenderRange(context, true);
                },
                icon: const Icon(Icons.date_range, color: Colors.lightGreen)),
          ),
          Text(
            formatter.format(Budget.lastDate),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          )
        ],
      )
    ];
  }

  void showNewPop(BuildContext ct, Widget widg) {
    showModalBottomSheet(
        transitionAnimationController: _animationController,
        useSafeArea: true,
        isScrollControlled: true,
        context: ct,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (ctx) => widg);
  }

  showCalenderRange(BuildContext cont, bool isLastSelected) async {
    final now = (!isLastSelected) ? Budget.firstdate : Budget.lastDate;
    final firstDate =
        (!isLastSelected) ? DateTime(now.year, 1, 1) : Budget.firstdate;
    final lastDate = DateTime(now.year + 2, 1, 1);

    final selectedDate = await showDatePicker(
        context: cont,
        initialDate: now,
        firstDate: firstDate,
        lastDate: lastDate);
    if (selectedDate != null) {
      (!isLastSelected)
          ? (Budget.firstdate = selectedDate)
          : (Budget.lastDate = selectedDate);
      setState(() {}); //updating
      DBhelper.updateTable(
          DBhelper.budgetTableName,
          {
            'firstdate': Budget.firstdate.toIso8601String(),
            'lastdate': Budget.lastDate.toIso8601String()
          },
          null,
          null);
    }
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

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return FutureBuilder(
      future: Provider.of<Expenses>(context, listen: false).fetchExpense(),
      builder: (context, expSnapshot) => (expSnapshot.connectionState ==
              ConnectionState.waiting)
          ? Scaffold(
              appBar: AppBar(
                title: const Text(
                  "Funds Minder",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              body: const Center(child: Text("Expenses Loading..")),
            )
          : FutureBuilder(
              future:
                  Provider.of<Expenses>(context, listen: false).fetchBudget(),
              builder: (context, snapShot) {
                return Scaffold(
                  appBar: AppBar(
                    title: const Text(
                      "Funds Minder",
                      style: TextStyle(fontSize: 15),
                    ),
                    actions: (Provider.of<Expenses>(context).budgets.isEmpty)
                        ? []
                        : actionWidgets(
                            context,
                          ),
                  ),
                  body: (snapShot.connectionState == ConnectionState.waiting)
                      ? const Text("Budgets Loading..")
                      : Consumer<Expenses>(builder: (ctx, expns, ch) {
                          return (expns.budgets.isEmpty)
                              ? bodyWidget(height, false, expns)
                              : bodyWidget(height, true, expns);
                        }),
                );
              }),
    );
  }
}
