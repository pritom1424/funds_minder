import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../Model/expense.dart';
import '../../View_Model/expenses.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class NewScanRecord extends StatefulWidget {
  final String? defaultTitle, defaultAmount;
  final DateTime? defaultDateTime;
  final Category defaultCat;
  const NewScanRecord(this.defaultTitle, this.defaultAmount,
      this.defaultDateTime, this.defaultCat,
      {super.key});

  @override
  State<NewScanRecord> createState() => _NewScanRecordState();
}

class _NewScanRecordState extends State<NewScanRecord> {
  Category _selectedCat = Category.leisure;

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final formatter = DateFormat.yMd();
  DateTime? _pickedDate = DateTime.now();
  var symbol = '\$';
  var expSymbol = '-';
  String _expenseString = 'expense';

  void showCalender(BuildContext ct) async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month - 1, 1);
    final selectedDate = await showDatePicker(
        context: ct, initialDate: now, firstDate: firstDate, lastDate: now);

    if (selectedDate != null) {
      setState(() {
        _pickedDate = selectedDate;
      });
    }
  }

  Row customRow(List<Widget> childreWidg) {
    return Row(
      children: childreWidg,
    );
  }

  void saveExpense() {
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
                  "Recheck valid title, amount, date, category",
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

    Expense newExp = Expense(
        id: uuid.v4(),
        title: _titleController.text,
        amount: enteredAmount,
        date: _pickedDate!,
        category: _selectedCat,
        expenseSymbol: expSymbol);
    final provider = Provider.of<Expenses>(context, listen: false);
    provider.addExpense(newExp, symbol);

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    symbol = Provider.of<Expenses>(context, listen: false).currentCurrency;
    _titleController.text = widget.defaultTitle ?? "";
    _amountController.text = widget.defaultAmount!;
    _selectedCat = widget.defaultCat;
    _pickedDate = widget.defaultDateTime;

    super.initState();
  }

  @override
  void didUpdateWidget(covariant NewScanRecord oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    final isDrkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return SingleChildScrollView(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        width: (height > 600) ? width * 1 : width * 0.54,
        padding: const EdgeInsets.fromLTRB(8, 50, 8, 8),
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(3), topRight: Radius.circular(3)),
            gradient: LinearGradient(colors: [
              isDrkMode
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : Theme.of(context).colorScheme.primary.withOpacity(0.8),
              Theme.of(context).colorScheme.primary.withOpacity(0.3)
            ])),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
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
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _expenseString == "expense"
                            ? _expenseString = 'earn'
                            : _expenseString = 'expense';

                        _expenseString == 'expense'
                            ? expSymbol = '-'
                            : expSymbol = '+';
                      });
                    },
                    child: Text(
                      _expenseString,
                    )),
              ],
            ),
            customRow([
              Expanded(
                child: TextField(
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      prefixText: symbol,
                      label: const Text(
                        'Amount',
                        style: TextStyle(color: Colors.white),
                      )),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  TextButton(
                      onPressed: () {
                        showCurrencyPicker(
                            theme: CurrencyPickerThemeData(
                                titleTextStyle: TextStyle(
                                    color: isDrkMode
                                        ? Colors.white
                                        : Colors.black),
                                subtitleTextStyle: TextStyle(
                                    color: isDrkMode
                                        ? Colors.orange
                                        : Colors.blue),
                                currencySignTextStyle: TextStyle(
                                    color: isDrkMode
                                        ? Colors.white
                                        : Colors.black)),
                            context: context,
                            onSelect: (Currency currency) {
                              setState(() {
                                symbol = currency.symbol;
                              });
                            });
                      },
                      child: const Text(
                        "change currency",
                        style: TextStyle(color: Colors.white),
                      )),
                  Text(
                    formatter.format(_pickedDate!),
                    style: const TextStyle(
                      color: Colors.white,
                    ),
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
              if (height <= 600 && width > 600)
                DropdownButton(
                    value: _selectedCat,
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
            ]),
            const SizedBox(
              height: 20,
            ),
            customRow(
              [
                if (height > 600 || width <= 600)
                  DropdownButton(
                      value: _selectedCat,
                      iconEnabledColor: Colors.white,
                      dropdownColor: (isDrkMode)
                          ? Colors.black
                          : Theme.of(context).colorScheme.primary,
                      items: Category.values
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(
                                  category.name.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val == null) {
                          return;
                        }
                        setState(() {
                          _selectedCat = val;
                        });
                      }),
                const Spacer(),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel')),
                ElevatedButton(
                    onPressed: saveExpense, child: const Text("Save")),
              ],
            )
          ],
        ),
      ),
    );
  }
}
