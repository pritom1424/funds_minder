import 'package:flutter/material.dart';

class SingleChartBar extends StatelessWidget {
  final IconData icon;
  final double total;
  const SingleChartBar(this.fill, this.total, this.icon, {super.key});
  final double fill;

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      width: (height <= 600) ? width * 0.15 : width * 0.25,
      height: (height <= 600) ? height * 0.55 : height * 0.25,
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
                              ? Colors.blue.shade300
                              : Theme.of(context).colorScheme.primary
                          : (total > 0)
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.8)
                              : Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.4)),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            total.toStringAsFixed(2),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
