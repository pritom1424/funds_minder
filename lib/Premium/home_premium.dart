import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:funds_minder/DB/backuphelper.dart';
import 'package:funds_minder/InAppPurchase/inapp_purchase_system.dart';
import 'package:funds_minder/Login/auth.dart';
import 'package:funds_minder/Widget/ExpenseTracker/home_screen.dart';
import 'package:funds_minder/Widget/FinInsights/fin_home_scr.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class HomePremium extends StatefulWidget {
  static String homeRoute = '/prem_home_screen';
  const HomePremium({super.key});

  @override
  State<HomePremium> createState() => _HomePremiumState();
}

class _HomePremiumState extends State<HomePremium> {
  bool isBackUp = false, isRestore = false;
  String backUpText = "Backup Data", restoreText = 'Restore Data';

  Widget custmRowColumn(Size scSize, List<Widget> ch) {
    if (scSize.height < 600) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ch,
      );
    }
    return Column(
      children: ch,
    );
  }

  void showNewPop(BuildContext ct, Widget widg) {
    showModalBottomSheet(
        //     transitionAnimationController: _animationController,
        useSafeArea: true,
        isScrollControlled: true,
        context: ct,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        builder: (ctx) => widg);
  }

  purchaseConfigure() async {
    var authId = FirebaseAuth.instance.currentUser?.uid ?? "";
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
    purchaseConfigure();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size scSize = MediaQuery.of(context).size;
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Funds Minder Premium',
          style: TextStyle(color: Colors.amber),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Colors.black,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              elevation: 10,
            ),
            onPressed: () {
              Provider.of<Auth>(context, listen: false).logout();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.amber),
            ),
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            height: scSize.height * 0.25,
            child: DecoratedBox(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(colors: [
                    Colors.black,
                    Theme.of(context).colorScheme.primary
                  ])),
              child: ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                title: Text(
                  'PREMIUM MEMBER',
                  style: TextStyle(
                      fontSize: (scSize.height > 600) ? 25 : 20,
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'RobotoCRegular'),
                  textAlign: (scSize.height > 600)
                      ? TextAlign.start
                      : TextAlign.center,
                ),
                subtitle: Text(
                  'Welcome! Enjoy the premium features',
                  textAlign: (scSize.height > 600)
                      ? TextAlign.start
                      : TextAlign.center,
                  style: TextStyle(
                    fontSize: (scSize.height > 600) ? 15 : 10,
                    color: Colors.amber,
                  ),
                ),
                minVerticalPadding: 30,
              ),
            ),
          ),
          custmRowColumn(
            scSize,
            [
              Container(
                width: (scSize.height > 600)
                    ? scSize.width * 0.8
                    : scSize.width * 0.5,
                height: (scSize.height > 600)
                    ? scSize.height * 0.25
                    : scSize.height * 0.35,
                decoration: BoxDecoration(
                  border: Border.all(
                      width: 1, color: Theme.of(context).colorScheme.primary),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        'What will you get',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ),
                    RichText(
                      text: TextSpan(children: [
                        const WidgetSpan(child: Icon(Icons.done)),
                        TextSpan(
                          text: 'Back Up & Restore Data',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      ]),
                    ),
                    RichText(
                      text: TextSpan(children: [
                        const WidgetSpan(
                          child: Icon(Icons.done),
                        ),
                        TextSpan(
                          text: 'Scan Receipt and Record',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      ]),
                    ),
                    if (scSize.height < 600)
                      RichText(
                        text: TextSpan(children: [
                          const WidgetSpan(
                            child: Icon(Icons.done),
                          ),
                          TextSpan(
                            text: 'More...',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary),
                          ),
                        ]),
                      ),
                    if (scSize.height > 600)
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: '\n  Financial Insights Premium--\n',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold),
                          ),
                          const WidgetSpan(
                            child: Icon(Icons.done),
                          ),
                          if (scSize.height > 600)
                            TextSpan(
                              text: 'Spending Patterns Unlocked\n',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                          const WidgetSpan(
                            child: Icon(Icons.done),
                          ),
                          if (scSize.height > 600)
                            TextSpan(
                              text: 'Saving Opportunities Unlocked\n',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                        ]),
                      ),
                  ],
                ),
              ),
              SizedBox(
                height: (scSize.height > 600) ? 30 : 0,
                width: (scSize.height > 600) ? 0 : 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FutureBuilder(
                    future: didCustomerExist(),
                    builder: (context, snapShot) => (snapShot.connectionState ==
                            ConnectionState.waiting)
                        ? CircularProgressIndicator()
                        : Container(
                            height: (scSize.height > 600) ? 100 : 80,
                            width: (scSize.height > 600) ? 150 : 120,
                            color: Colors.transparent,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: LinearGradient(colors: [
                                    (!isDarkMode)
                                        ? const Color.fromARGB(255, 0, 62, 112)
                                            .withOpacity(0.8)
                                        : const Color.fromARGB(255, 40, 38, 38),
                                    (!isDarkMode)
                                        ? const Color.fromARGB(255, 0, 62, 112)
                                            .withOpacity(0.3)
                                        : const Color.fromARGB(255, 16, 16, 16),
                                  ])),
                              child: (isBackUp)
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : (snapShot.data != null &&
                                          snapShot.data == true)
                                      ? ElevatedButton(
                                          onPressed: (isRestore)
                                              ? null
                                              : () {
                                                  setState(() {
                                                    isBackUp = true;
                                                  });
                                                  BackUpHelper.backUpToServer()
                                                      .then((value) {
                                                    setState(() {
                                                      isBackUp = false;
                                                      backUpText = value;
                                                      restoreText =
                                                          'Restore Data';
                                                    });
                                                  });
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            side: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary),
                                          ),
                                          child: Text(
                                            backUpText,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ))
                                      : ElevatedButton(
                                          onPressed: () {
                                            ScaffoldMessenger.of(context)
                                                .clearSnackBars();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        "Please purchase premium to get this!")));
                                          },
                                          child: Text("Backup Data Disable")),
                            ),
                          ),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  FutureBuilder(
                    future: didCustomerExist(),
                    builder: (context, snapShot) => (snapShot.connectionState ==
                            ConnectionState.waiting)
                        ? CircularProgressIndicator()
                        : Container(
                            height: (scSize.height > 600) ? 100 : 80,
                            width: (scSize.height > 600) ? 150 : 120,
                            color: Colors.transparent,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: LinearGradient(colors: [
                                    (!isDarkMode)
                                        ? const Color.fromARGB(255, 86, 0, 112)
                                            .withOpacity(0.8)
                                        : const Color.fromARGB(255, 40, 38, 38),
                                    (!isDarkMode)
                                        ? const Color.fromARGB(255, 86, 0, 112)
                                            .withOpacity(0.3)
                                        : const Color.fromARGB(255, 16, 16, 16),
                                  ])),
                              child: (isRestore)
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : (snapShot.data != null &&
                                          snapShot.data == true)
                                      ? ElevatedButton(
                                          onPressed: (isBackUp)
                                              ? null
                                              : () {
                                                  setState(() {
                                                    isRestore = true;
                                                  });
                                                  BackUpHelper
                                                          .restoreFromServer()
                                                      .then((value) {
                                                    setState(() {
                                                      isRestore = false;
                                                      restoreText = value;
                                                      backUpText =
                                                          "Backup Data";
                                                    });
                                                  });
                                                },
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.transparent,
                                              shadowColor: Colors.transparent,
                                              side: BorderSide(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary)),
                                          child: Text(
                                            restoreText,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        )
                                      : ElevatedButton(
                                          onPressed: () {
                                            ScaffoldMessenger.of(context)
                                                .clearSnackBars();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        "Please purchase premium to get this!")));
                                          },
                                          child: Text("Restore Data Disable")),
                            ),
                          ),
                  )
                ],
              ),
              if (scSize.height > 600)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context)
                          .pushReplacementNamed(HomeScreen.homeRoute),
                      child: const Text("Scan Button"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context)
                          .pushReplacementNamed(FinHomeScr.homeRoute),
                      child: const Text("Spending Patterns"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context)
                          .pushReplacementNamed(FinHomeScr.homeRoute),
                      child: const Text("Saving Opportunities"),
                    )
                  ],
                )
            ],
          ),
          SizedBox(
            width: 300,
            height: (scSize.height > 600) ? 80 : 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 23, 21, 21),
                  side:
                      BorderSide(color: Theme.of(context).colorScheme.primary)),
              onPressed: () {
                showNewPop(context, InAppPurchaseSystem());
              },
              child: const Text(
                '\$2.00',
                style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25,
                    fontFamily: 'RobotoCRegular',
                    fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }
}
