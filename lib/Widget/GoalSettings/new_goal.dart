import 'package:flutter/material.dart';
import 'package:funds_minder/Model/goal.dart';
import 'package:funds_minder/View_Model/goals.dart';
import 'package:funds_minder/main.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NewGoal extends StatefulWidget {
  const NewGoal({super.key});

  @override
  State<NewGoal> createState() => _NewGoalState();
}

class _NewGoalState extends State<NewGoal> {
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  DateTime? _pickedDate = DateTime.now();
  void showCalender(BuildContext ct) async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month - 1, 1);
    final lastDate = DateTime(now.year + 2, 1, 1);
    final selectedDate = await showDatePicker(
        context: ct,
        initialDate: now,
        firstDate: firstDate,
        lastDate: lastDate);

    if (selectedDate != null) {
      setState(
        () {
          _pickedDate = selectedDate;
        },
      );
    }
  }

  void saveGoals() {
    final enteredAmount = double.tryParse(_amountController.text);
    bool isAmountInvalid = (enteredAmount == null || enteredAmount <= 0);
    if (_titleController.text.trim().isEmpty ||
        _titleController.text.trim().characters.length >= 20 ||
        isAmountInvalid ||
        _pickedDate == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Invalid Input"),
          content: Text(
            "Recheck valid title, amount, date",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Ok"))
          ],
        ),
      );
      return;
    }

    Goal newGoal = Goal(
        id: uuid.v4(),
        title: _titleController.text,
        expiredDate: _pickedDate!,
        amount: enteredAmount);
    Provider.of<Goals>(context, listen: false).addGoals(newGoal);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    final width = MediaQuery.of(context).size.width;

    final isDrkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final formatter = DateFormat.yMd();
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            gradient: LinearGradient(colors: [
              (isDrkMode)
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : Theme.of(context).colorScheme.primary.withOpacity(0.8),
              Theme.of(context).colorScheme.primary.withOpacity(0.3)
            ])),
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20),
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Set New Goal',
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontFamily: 'Advent-Lt1',
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: height * 0.1,
                width: width * 0.8,
                child: TextField(
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  controller: _titleController,
                  maxLength: 20,
                  decoration: const InputDecoration(
                      label: Text(
                        'Title',
                        style: TextStyle(color: Colors.white),
                      ),
                      helperText: 'not more than 20 characters',
                      helperStyle: TextStyle(color: Colors.white)),
                ),
              ),
              SizedBox(
                height: height * 0.15,
                child: Row(
                  children: [
                    SizedBox(
                      height: height * 0.1,
                      width: width * 0.5,
                      child: TextField(
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          label: Text(
                            'Amount',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      formatter.format(_pickedDate!),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                        onPressed: () {
                          showCalender(context);
                        },
                        icon: Icon(
                          Icons.calendar_month,
                          color: Theme.of(context).colorScheme.primary,
                        ))
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: saveGoals, child: const Text('Set New Goal')),
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
