import 'package:flutter/material.dart';

class SingleReport extends StatelessWidget {
  final String barName;
  final double total;
  const SingleReport(this.fill, this.total, this.barName, {super.key});
  final double fill;

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      width:
          screenSize.height < 600 ? screenSize.width / 4 : screenSize.width / 2,
      height: screenSize.height < 600
          ? screenSize.height * 0.7
          : screenSize.height * 0.3,
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              decoration: const BoxDecoration(
                //color: Colors.black,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.bottomCenter,
                heightFactor: fill,
                widthFactor: 0.5,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(8)),
                    color: isDarkMode
                        ? (total > 0)
                            ? Theme.of(context).colorScheme.secondary
                            : Colors.red.shade100
                        : (total > 0)
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.65)
                            : Colors.red.withOpacity(0.65),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            total.toStringAsFixed(2),
            style: TextStyle(color: (isDarkMode) ? Colors.white : Colors.black),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: Text(
              barName,
              style:
                  TextStyle(color: (isDarkMode) ? Colors.white : Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
