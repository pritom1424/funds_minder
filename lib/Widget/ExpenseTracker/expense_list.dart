import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Model/expense.dart';
import 'home_screen.dart';
import 'new_expense.dart';
import 'package:provider/provider.dart';
import '../../View_Model/expenses.dart';
import 'single_expense.dart';

class ExpenseList extends StatefulWidget {
  final Filteroptions filteroptions;
  final DateFormat df;

  const ExpenseList(this.df, this.filteroptions, {super.key});

  @override
  State<ExpenseList> createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  final ScrollController _scrollController = ScrollController();

  void scroll(double scrollDistance) {
    _scrollController.animateTo(scrollDistance,
        duration: const Duration(seconds: 1), curve: Curves.fastOutSlowIn);
  }

  String getCopyName(String expnsTitle) {
    var namePlate = expnsTitle;
    String copyNumberStr = (namePlate.contains(RegExp(r'[0-9]')))
        ? namePlate.replaceAll(RegExp(r'[^0-9]'), '')
        : '0';
    int copyNumber = int.parse(copyNumberStr) + 1;
    namePlate =
        '${namePlate.replaceAll(RegExp(r'[0-9]'), '').trim()} ${copyNumber.toString()}';
    return namePlate;
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return FutureBuilder(
      future: Provider.of<Expenses>(context, listen: false).fetchExpense(),
      builder: (ctx, snapShot) => (snapShot.connectionState ==
              ConnectionState.waiting)
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Consumer<Expenses>(
              child: Center(
                  child: Text(
                'No entry yet. Add some entries to start! ',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              )),
              builder: (ctx, expns, ch) => (expns
                      .getExpense(widget.df, widget.filteroptions, 0, 0, 0)
                      .isEmpty)
                  ? ch!
                  : Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              onPressed: () {
                                scroll(
                                    _scrollController.position.maxScrollExtent);
                              },
                              icon: CircleAvatar(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                child: const Icon(
                                  Icons.arrow_downward,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                String namePlate = expns.allExpenses[0].title;

                                namePlate = getCopyName(namePlate);

                                expns.addExpense(
                                    Expense(
                                        id: uuid.v4(),
                                        title: namePlate,
                                        amount: expns.allExpenses[0].amount,
                                        date: DateTime.now(),
                                        category: expns.allExpenses[0].category,
                                        expenseSymbol:
                                            expns.allExpenses[0].expenseSymbol),
                                    expns.currentCurrency);
                                ScaffoldMessenger.of(context)
                                    .removeCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    duration: const Duration(seconds: 2),
                                    content: const Text(
                                      'New record added!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                );
                              },
                              icon: CircleAvatar(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                child: const Icon(
                                  Icons.add,
                                ),
                              ),
                              iconSize: 20,
                            ),
                            IconButton(
                              onPressed: () {
                                scroll(
                                    _scrollController.position.minScrollExtent);
                              },
                              icon: CircleAvatar(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                child: const Icon(
                                  Icons.arrow_upward,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          flex: 2,
                          child: ListView.builder(
                              controller: _scrollController,
                              itemCount: expns.filteredExpense.length,
                              itemBuilder: (ctx, i) {
                                return Dismissible(
                                  confirmDismiss: (direction) {
                                    return showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                              title:
                                                  const Text("Are you sure?"),
                                              content: Text(
                                                "Do you want to delete this transaction?",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium,
                                              ),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(true);
                                                    },
                                                    child: const Text("Yes")),
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(false);
                                                    },
                                                    child: const Text("No"))
                                              ],
                                            ));
                                  },
                                  onDismissed: (dir) {
                                    expns.removeExpense(expns.getExpense(
                                        widget.df,
                                        widget.filteroptions,
                                        0,
                                        0,
                                        0)[i]);
                                  },
                                  key: ValueKey(expns.getExpense(widget.df,
                                      widget.filteroptions, 0, 0, 0)[i]),
                                  child: SingleExpense(
                                    expns.getExpense(widget.df,
                                        widget.filteroptions, 0, 0, 0)[i],
                                    expns.currentCurrency,
                                  ),
                                );
                              }),
                        ),
                      ],
                    ),
            ),
    );
  }
}
