import 'package:flutter/material.dart';

class SingleBudgetBar extends StatelessWidget {
  final IconData icon;
  final double expenseTotal;
  final double expenseFill;
  final double budgetFill;
  final double budgetTotal;
  const SingleBudgetBar(this.expenseFill, this.budgetFill, this.expenseTotal,
      this.budgetTotal, this.icon,
      {super.key});

  String totalAmountFormatter(double amount) {
    double formattedAmount = 0;
    String formattedString = '';

    if (amount.abs() >= 1000 && amount.abs() < 1000000) {
      formattedAmount = amount / 1000;
      formattedString = '${formattedAmount.toStringAsFixed(1)}K';
    } else if (amount.abs() >= 1000000 && amount.abs() < 1000000000) {
      formattedAmount = amount / 1000000;
      formattedString = '${formattedAmount.toStringAsFixed(1)}M';
    } else if (amount.abs() >= 1000000000 && amount.abs() < 1000000000000) {
      formattedAmount = amount / 1000000000;
      formattedString = '${formattedAmount.toStringAsFixed(1)}B';
    } else if (amount.abs() >= 1000000000000) {
      formattedAmount = amount / 1000000000000;
      formattedString = '${formattedAmount.toStringAsFixed(1)}T';
    } else {
      formattedString = amount.toStringAsFixed(1);
    }

    return formattedString;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      width: (height <= 600)
          ? width * 0.8
          : width * 0.6, //width * 0.15 : width * 0.25,
      height: (height <= 600)
          ? height * 0.2
          : height * 0.1, //height * 0.55 : height * 0.25,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  totalAmountFormatter(expenseTotal),
                  textAlign: TextAlign.center,
                  style: (height > 600)
                      ? Theme.of(context).textTheme.labelSmall
                      : Theme.of(context).textTheme.bodyMedium,
                ),
                Text(totalAmountFormatter(budgetTotal),
                    textAlign: TextAlign.start,
                    style: (height > 600)
                        ? Theme.of(context).textTheme.labelSmall
                        : Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              decoration: const BoxDecoration(
                //color: Colors.black,
                shape: BoxShape.rectangle,
                borderRadius:
                    BorderRadius.horizontal(right: Radius.circular(8)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 600,
                    height: 30,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      heightFactor: 0.6,
                      widthFactor: expenseFill,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8)),
                          color: !isDarkMode
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.4)
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 600,
                    height: 30,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      heightFactor: 0.6,
                      widthFactor: budgetFill,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8)),
                          color: isDarkMode
                              ? Colors.blue.shade300
                              : Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          CircleAvatar(
              radius: 14,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                icon,
                size: 14,
              )),
        ],
      ),
    );
  }
}
