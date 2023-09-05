import 'package:flutter/material.dart';
import 'package:funds_minder/View_Model/expenses.dart';
import 'package:funds_minder/Widget/FinInsights/Saving_Opportunities/saving_opportunities.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class SliderElement extends StatefulWidget {
  int defaultval;
  int index;
  final String catName;
  SliderElement(this.catName, this.defaultval, this.index);

  @override
  State<SliderElement> createState() => _SliderElementState();
}

class _SliderElementState extends State<SliderElement> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      width: 200,
      child: Column(
        children: [
          Slider(
              value: widget.defaultval.toDouble(),
              label: '${widget.defaultval.toString()}%',
              min: 0,
              max: 100,
              divisions: 10,
              onChanged: (double newVal) {
                setState(() {
                  widget.defaultval = newVal.toInt();
                  SavingOpportunities.slideCategoryValues[widget.index] =
                      newVal.toInt();
                });

                (!SavingOpportunities.isExist)
                    ? Provider.of<Expenses>(context, listen: false)
                        .addSlideValues(widget.index, newVal.toInt())
                    : Provider.of<Expenses>(context, listen: false)
                        .updateSlideValues(widget.index, newVal.toInt());
              }),
          Text(widget.catName),
        ],
      ),
    );
  }
}
