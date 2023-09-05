import 'package:funds_minder/Model/expense.dart';
import 'package:flutter/material.dart';
import 'package:funds_minder/DB/saving_op_db.dart';

class SavingOpReport extends StatefulWidget {
  final List<Category> ycat, mCat, wCat;

  const SavingOpReport(this.ycat, this.mCat, this.wCat, {super.key});

  @override
  State<SavingOpReport> createState() => _SavingOpReportState();
}

class _SavingOpReportState extends State<SavingOpReport>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> opacityAnimation;
  List<String> catListToString(List<Category> cat) {
    List<String> cList = [];
    for (Category c in cat) {
      cList.add(c.name.toUpperCase());
    }
    return cList;
  }

  Widget personalRecReport(BuildContext context, double ht) {
    return Column(
      children: [
        SizedBox(
          height: ht * 0.1,
          width: double.infinity,
          child: Row(
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close)),
              Text(
                'Personal Recommendations',
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ],
          ),
        ),
        Expanded(
          flex: 5,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: uniqueCategoryList().length,
            itemBuilder: (ctx, i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                    style: Theme.of(context).textTheme.displaySmall,
                    children: [
                      TextSpan(
                          text:
                              '${uniqueCategoryList()[i].name.toUpperCase()}: ',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text: SavingOpDB.getCategoryWiseRecommendations(
                              uniqueCategoryList()[i])),
                    ]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void showNewPop(BuildContext ct, Widget widg) {
    showModalBottomSheet(
        transitionAnimationController: _animationController,
        useSafeArea: true,
        isScrollControlled: true,
        context: ct,
        builder: (ctx) => widg);
  }

  List<Category> uniqueCategoryList() {
    Set<Category> setOfCMap = {};
    List<Category> cMapList = widget.ycat + widget.mCat + widget.wCat;
    if (cMapList.isEmpty) {
      return [];
    }
    List<Category> uniqueList =
        cMapList.where((element) => setOfCMap.add(element)).toList();

    return uniqueList;
  }

  Widget reportSummary(BuildContext context, List<String> yearlyMajorExpenses,
      List<String> monthlyMajorExpenses, List<String> weeklyMajorExpenses) {
    String yExpenses = '';
    String mExpenses = '';
    String wExpenses = '';
    for (var yCat in yearlyMajorExpenses) {
      yExpenses += '$yCat, ';
    }
    for (var mCat in monthlyMajorExpenses) {
      mExpenses += '$mCat, ';
    }
    for (var wCat in weeklyMajorExpenses) {
      wExpenses += '$wCat, ';
    }
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            'Major Expense Categories',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (yearlyMajorExpenses.isNotEmpty)
            Text(
              'Yearly- $yExpenses',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (monthlyMajorExpenses.isNotEmpty)
            Text(
              'Monthly- $mExpenses',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (weeklyMajorExpenses.isNotEmpty)
            Text(
              'Weekly- $wExpenses',
              style: Theme.of(context).textTheme.bodySmall,
            )
        ],
      ),
    );
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
    Size scrSize = MediaQuery.of(context).size;

    String description =
        'During the analyzed period, you exhibited consistent spending in several key categories. Your major expense categories are summarized based on your past weekly, monthly, yearly spending patterns';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saving Opportunities Report'),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.close)),
      ),
      body: (widget.ycat.isEmpty && widget.mCat.isEmpty && widget.wCat.isEmpty)
          ? const Center(
              child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Center(
                child: Text(
                  'Expenses don\'t cross threshold. Adjust expenses threshold slider to get saving opportunities!!!',
                  textAlign: TextAlign.center,
                ),
              ),
            ))
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        description,
                        style: Theme.of(context).textTheme.displaySmall,
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    SizedBox(
                      width: scrSize.width,
                      height: scrSize.height * 0.3,
                      child: reportSummary(
                          context,
                          catListToString(widget.ycat),
                          catListToString(widget.mCat),
                          catListToString(widget.wCat)),
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            'Saving Opportunities',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: uniqueCategoryList().length,
                          itemBuilder: (ctx, i) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: RichText(
                              textAlign: TextAlign.justify,
                              text: TextSpan(
                                  style:
                                      Theme.of(context).textTheme.displaySmall,
                                  children: [
                                    TextSpan(
                                      text:
                                          '${uniqueCategoryList()[i].name.toUpperCase()}: ',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                        text: SavingOpDB
                                            .getCategoryWiseDescription(
                                                uniqueCategoryList()[i])),
                                  ]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showNewPop(context, personalRecReport(context, scrSize.height));
        },
        child: const Icon(Icons.lightbulb),
      ),
    );
  }
}
