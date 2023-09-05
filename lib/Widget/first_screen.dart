import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:funds_minder/InAppPurchase/inapp_purchase_system.dart';
import 'package:funds_minder/Login/auth.dart';
import 'package:funds_minder/Login/auth_screen.dart';
import 'package:funds_minder/Premium/home_premium.dart';
import 'package:funds_minder/Widget/Budgeting/home_budget_scr.dart';
import 'package:funds_minder/Widget/ExpenseTracker/home_screen.dart';
import 'package:funds_minder/Widget/FinInsights/fin_home_scr.dart';
import 'package:funds_minder/Widget/GoalSettings/goal_settings_scr.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirstScreen extends StatefulWidget {
  static bool isPermissionPopTriggered = false;

  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  showPermissionPop() async {
    final prfs = await SharedPreferences.getInstance();
    bool didAsk = prfs.getBool('didAsk') ?? false;
    if (!didAsk) {
      final notifyStat = await Permission.notification.status;

      Future.delayed(const Duration(seconds: 2), () async {
        if ((!notifyStat.isGranted) && !FirstScreen.isPermissionPopTriggered) {
          showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                    title: const Text("Permission Alert!"),
                    content: RichText(
                        text: TextSpan(children: <TextSpan>[
                      TextSpan(
                          text: "\n\nNotification Permission!",
                          style: Theme.of(context).textTheme.bodyLarge),
                      TextSpan(
                          text:
                              "If you do not allow this permission, you will not be able to get necessary alerts (ex:budget cross alert)!",
                          style: Theme.of(context).textTheme.bodyMedium)
                    ])),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Close")),
                      ElevatedButton(
                          onPressed: () {
                            openAppSettings();
                          },
                          child: const Text("Open Settings"))
                    ],
                  ));
          final prefs = await SharedPreferences.getInstance();
          prefs.setBool('didAsk', true);
        }
      });
    }
  }

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {}

  Widget screenButton(IconData icon, String buttonText, Function onButtonPress,
      Size scSize, BuildContext ctx, bool isDMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        width: scSize.width * 0.6,
        height:
            (scSize.height > 600) ? scSize.height * 0.06 : scSize.height * 0.2,
        margin: const EdgeInsets.all(4),
        child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.primary,
              backgroundColor: !isDMode
                  ? Colors.white
                  : const Color.fromARGB(255, 30, 30, 30),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              elevation: 10,
            ),
            onPressed: () {
              onButtonPress();
            },
            icon: Icon(icon),
            label: Text(buttonText, style: Theme.of(ctx).textTheme.bodyLarge)),
      ),
    );
  }

  List<Widget> landscapeBody(
      BuildContext context, Size scrSize, bool isDarkMode) {
    return [
      Container(
        width: scrSize.width * 0.4,
        height: scrSize.height * 1,
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.3)
                  ])),
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 80,
                child: Image.asset(
                  'assets/images/fmIcon.png',
                  alignment: Alignment.center,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Text(
              'Funds Minder App',
              style: Theme.of(context).textTheme.displayLarge,
            )
          ],
        ),
      ),
      Container(
        width: scrSize.width * 0.5,
        height: scrSize.height * 1,
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: ListView(
          children: [
            screenButton(
                Icons.assignment_add,
                'Expense Tracking',
                () => Navigator.of(context).pushNamed(HomeScreen.homeRoute),
                scrSize,
                context,
                isDarkMode),
            screenButton(
                Icons.account_balance_wallet,
                'Budgeting',
                () => Navigator.of(context)
                    .pushNamed(HomeBudgetScreen.budgetRoute),
                scrSize,
                context,
                isDarkMode),
            screenButton(
                Icons.savings,
                'Goal Settings',
                () => Navigator.of(context)
                    .pushNamed(GoalSettingsScreen.goalScreenRoute),
                scrSize,
                context,
                isDarkMode),
            screenButton(
                Icons.bar_chart,
                'Financial Insights',
                () => Navigator.of(context).pushNamed(FinHomeScr.homeRoute),
                scrSize,
                context,
                isDarkMode),

            /* screenButton(Icons.remove, 'Delete All Db', () =>
                          DBhelper.delete(),scrSize
                        ) */
          ],
        ),
      )
    ];
  }

  List<Widget> portraitBody(
      BuildContext context, Size scrSize, bool isDarkMode) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.3)
                  ])),
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: (scrSize.height > 600) ? 80 : 35,
                child: Image.asset(
                  'assets/images/fmIcon.png',
                  alignment: Alignment.center,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Text(
              'Funds Minder App',
              style: Theme.of(context).textTheme.displayLarge,
            )
          ],
        ),
      ),
      Container(
        height: scrSize.height * 0.5,
        width: scrSize.width * 1,
        alignment: Alignment.topCenter,
        child: GridView(
          padding: const EdgeInsets.all(15),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 1,
              crossAxisSpacing: 50,
              mainAxisSpacing: 50,
              crossAxisCount: 2),
          children: [
            screenButton(
                Icons.assignment_add,
                'Expense Tracking',
                () => Navigator.of(context).pushNamed(HomeScreen.homeRoute),
                scrSize,
                context,
                isDarkMode),
            screenButton(
                Icons.account_balance_wallet,
                'Budgeting',
                () => Navigator.of(context)
                    .pushNamed(HomeBudgetScreen.budgetRoute),
                scrSize,
                context,
                isDarkMode),
            screenButton(
                Icons.savings,
                'Goal Settings',
                () => Navigator.of(context)
                    .pushNamed(GoalSettingsScreen.goalScreenRoute),
                scrSize,
                context,
                isDarkMode),
            screenButton(
                Icons.bar_chart,
                'Financial Insights',
                () => Navigator.of(context).pushNamed(FinHomeScr.homeRoute),
                scrSize,
                context,
                isDarkMode),

            /* screenButton(Icons.remove, 'Delete All Db', () =>
                        DBhelper.delete(),scrSize
                      ) */
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          'Unlock Premium \'Sync with Server\' for seamless data backup and synchronization. Safeguard your financial records across devices and access your financial insights anytime, anywhere.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      )
    ];
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> onSelectNotification(String? payload) async {}

  @override
  Widget build(BuildContext context) {
    final scrSize = MediaQuery.of(context).size;
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    showPermissionPop();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Funds Minder"),
        actions: [
          StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (ctx, snapShot) => Consumer<Auth>(
              builder: (ctx, auth, _) => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.black,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  elevation: 10,
                ),
                onPressed: () async {
                  final didAuth = await auth.isLoggedIn();
                  // final didAuth = await FirebaseAuth.instance.currentUser!.uid;
                  (snapShot.hasData && didAuth)
                      ? Navigator.of(context).pushNamed(HomePremium.homeRoute)
                      : Navigator.of(context).pushNamed(AuthScreen.routeName);
                },
                child: const Text(
                  'Upgrade to Premium',
                  style: TextStyle(color: Colors.amber),
                ),
              ),
            ),
          )
        ],
      ),
      body: SizedBox(
        height: scrSize.height,
        width: scrSize.width,
        child: SingleChildScrollView(
            child: (scrSize.height > 600)
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: portraitBody(context, scrSize, isDarkMode))
                : Row(
                    children: landscapeBody(context, scrSize, isDarkMode),
                  )),
      ),
    );
  }
}
