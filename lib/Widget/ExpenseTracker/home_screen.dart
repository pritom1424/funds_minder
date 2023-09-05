import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:funds_minder/Widget/ExpenseTracker/scan_screen.dart';
import 'package:intl/intl.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'chart_widget.dart';
import 'new_expense.dart';
import 'report_widget.dart';
import 'expense_list.dart';

enum Filteroptions { all, yearly, monthly, weekly, daily }

class HomeScreen extends StatefulWidget {
  static String homeRoute = '/home_screen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  var authId = FirebaseAuth.instance.currentUser?.uid ?? "";
  late AnimationController _animationController;
  late Animation<double> opacityAnimation;
  Filteroptions _selectedFilter = Filteroptions.all;
  void showNewPop(BuildContext ct, Widget widg) {
    showModalBottomSheet(
        transitionAnimationController: _animationController,
        useSafeArea: true,
        isScrollControlled: true,
        context: ct,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        builder: (ctx) => widg);
  }

  DateFormat filterToFormat(Filteroptions fOP) {
    switch (fOP) {
      case Filteroptions.yearly:
        return DateFormat.y();
      case Filteroptions.monthly:
        return DateFormat.yMMM();
      case Filteroptions.weekly:
        return DateFormat.yMMM();
      case Filteroptions.daily:
        return DateFormat.yMMMd();
      default:
        return DateFormat.M();
    }
  }

  purchaseConfigure() async {
    if (authId != "") {
      await Purchases.setLogLevel(LogLevel.debug);
      await Purchases.configure(
          PurchasesConfiguration("goog_YGwsrYGePglbcfONwkYxAIPrsEL")
            ..appUserID = authId
            ..observerMode = false);
    } else {
      print("Auth Id not found during purchase");
    }
  }

  Future<bool> didCustomerExist() async {
    final customInfo = await Purchases.getCustomerInfo();
    if (customInfo.entitlements.active['pro'] != null) {
      return customInfo.entitlements.active['pro']!.isActive;
    }
    return false;
  }

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    opacityAnimation = CurvedAnimation(
        parent: Tween<double>(begin: 1, end: 0).animate(_animationController),
        curve: Curves.linear);

    purchaseConfigure();

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

    final isDrkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Funds Minder",
        ),
        actions: [
          DropdownButton(
              value: _selectedFilter,
              dropdownColor: !isDrkMode
                  ? Theme.of(context).colorScheme.primary
                  : Colors.black,
              iconEnabledColor: Colors.white,
              items: Filteroptions.values
                  .map((filter) => DropdownMenuItem(
                      value: filter,
                      child: Text(
                        filter.name.toUpperCase(),
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
                  _selectedFilter = val;
                });
              }),
          IconButton(
              onPressed: () {
                showNewPop(context, const NewExpense());
              },
              icon: const Icon(Icons.add)),
          if (authId != "")
            FutureBuilder(
              future: didCustomerExist(),
              builder: (context, snapShot) =>
                  (snapShot.connectionState == ConnectionState.waiting)
                      ? CircularProgressIndicator()
                      : (snapShot.data != null && snapShot.data == true)
                          ? IconButton(
                              onPressed: () {
                                showNewPop(context, const ScanScreen());
                              },
                              icon: const Icon(
                                Icons.photo_camera_rounded,
                                color: Colors.yellow,
                              ),
                            )
                          : IconButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                        "Please purchase premium to get this!")));
                              },
                              icon: Icon(
                                Icons.photo_camera_rounded,
                                color: Colors.grey,
                              )),
            )
        ],
      ),
      body: (height <= 600)
          ? Row(
              children: [
                Expanded(
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3),
                          Theme.of(context).colorScheme.primary.withOpacity(0.1)
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: ChartWidget(
                        filterToFormat(_selectedFilter), _selectedFilter),
                  ),
                ),
                Expanded(
                  child: ExpenseList(
                      filterToFormat(_selectedFilter), _selectedFilter),
                ),
              ],
            )
          : Column(
              children: [
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                  width: double.infinity,
                  height: height * 0.25,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: ChartWidget(
                      filterToFormat(_selectedFilter), _selectedFilter),
                ),
                Text(
                  (_selectedFilter == Filteroptions.all)
                      ? 'All Time Report'
                      : (_selectedFilter == Filteroptions.weekly)
                          ? 'This Week Report'
                          : "${filterToFormat(_selectedFilter).format(DateTime.now())} Report",
                  style: TextStyle(
                      color: isDrkMode ? Colors.lightBlue : Colors.blue,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.end,
                ),
                Expanded(
                  child: ExpenseList(
                      filterToFormat(_selectedFilter), _selectedFilter),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showNewPop(
            context,
            Column(
              children: [
                const Expanded(child: ReportWidget()),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Close"))
              ],
            ),
          );
        },
        child: const Icon(Icons.bar_chart),
      ),
    );
  }
}
