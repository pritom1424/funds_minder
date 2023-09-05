import 'package:funds_minder/Model/budget.dart';
import 'package:funds_minder/View_Model/expenses.dart';
import 'package:funds_minder/main.dart';
import 'package:provider/provider.dart';
import '../../Model/expense.dart';
import 'package:flutter/material.dart';

class NewBudget extends StatefulWidget {
  final DateTime firstD, lastD;

  const NewBudget(this.firstD, this.lastD, {super.key});

  @override
  State<NewBudget> createState() => _NewBudgetState();
}

class _NewBudgetState extends State<NewBudget> {
  Category _selectedCat = Category.leisure;
  final _amountController = TextEditingController();

  Row customRow(List<Widget> childreWidg) {
    return Row(
      children: childreWidg,
    );
  }

  void saveBudget() {
    final enteredAmount = double.tryParse(_amountController.text);
    bool isAmountInvalid = (enteredAmount == null || enteredAmount < 0);
    if (isAmountInvalid) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: const Text("Invalid Input"),
                content: Text(
                  "Recheck valid amount,category",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Ok"))
                ],
              ));
      return;
    }

    Budget newBudget = Budget(
      id: uuid.v4(),
      amount: enteredAmount,
      category: _selectedCat,
    );
    final provider = Provider.of<Expenses>(context, listen: false);
    provider.addBudget(newBudget, widget.firstD, widget.lastD);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _amountController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //final height = MediaQuery.of(context).size.height;
    //final width = MediaQuery.of(context).size.width;

    final isDrkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return SingleChildScrollView(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
          padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                (isDrkMode)
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : Theme.of(context).colorScheme.primary.withOpacity(0.8),
                Theme.of(context).colorScheme.primary.withOpacity(0.3)
              ]),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          child: Column(
            children: [
              const Text(
                'Set Target Budget',
                style: TextStyle(fontSize: 30, color: Colors.white),
              ),
              TextField(
                style: const TextStyle(
                  color: Colors.white,
                ),
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    label: Text(
                  'Amount',
                  style: TextStyle(color: Colors.white),
                )),
              ),
              DropdownButton(
                  value: _selectedCat,
                  dropdownColor: (isDrkMode)
                      ? Colors.black
                      : Theme.of(context).colorScheme.primary,
                  iconEnabledColor: Colors.white,
                  items: Category.values
                      .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(
                            category.name.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          )))
                      .toList(),
                  onChanged: (val) {
                    if (val == null) {
                      return;
                    }
                    setState(() {
                      _selectedCat = val;
                    });
                  }),
              ElevatedButton(
                  onPressed: saveBudget, child: const Text('Set Budget')),
            ],
          )),
    );
  }
}
