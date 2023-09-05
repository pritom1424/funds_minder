import 'package:background_fetch/background_fetch.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:funds_minder/Background_tasks/background_handler.dart';
import 'package:funds_minder/Background_tasks/firebase_push.dart';
import 'package:funds_minder/DB/dbhelper.dart';
import 'package:funds_minder/Login/auth.dart';
import 'package:funds_minder/Login/auth_screen.dart';
import 'package:funds_minder/Premium/home_premium.dart';
import 'package:funds_minder/View_Model/goals.dart';
import 'package:funds_minder/Widget/FinInsights/fin_home_scr.dart';
import 'package:funds_minder/Widget/GoalSettings/goal_settings_scr.dart';
import 'package:funds_minder/Widget/first_screen.dart';
import 'package:funds_minder/Widget/Budgeting/home_budget_scr.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'View_Model/expenses.dart';
import 'Widget/ExpenseTracker/home_screen.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

var kColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 169, 162, 255),
);
var kDarkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 169, 162, 255),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBhelper.database();
  await Firebase.initializeApp();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => Expenses()),
      ChangeNotifierProvider(create: (_) => Goals()),
      ChangeNotifierProvider(create: (_) => Auth()),
    ],
    child: const MyApp(),
  ));
  final notifyStat = await Permission.notification.status;
  if (notifyStat.isGranted) {
    await BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 480, // Minimum interval in minutes
        stopOnTerminate: false,
        enableHeadless: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: NetworkType.ANY,
      ),
      backgroundFetchHandler,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //initialize in app purchase

    return MaterialApp(
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 18, 18),
        colorScheme: kDarkColorScheme,
        cardTheme: const CardTheme().copyWith(
          color: kDarkColorScheme.secondaryContainer,
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kDarkColorScheme.onSecondaryContainer,
            foregroundColor: kDarkColorScheme.secondaryContainer,
          ),
        ),
        textTheme: ThemeData().textTheme.copyWith(
            titleLarge: TextStyle(
              fontWeight: FontWeight.normal,
              fontFamily: 'RobotoCRegular',
              color: kDarkColorScheme.onSecondaryContainer,
              fontSize: 18,
            ),
            headlineSmall:
                TextStyle(color: kDarkColorScheme.onSecondaryContainer),
            bodyLarge: TextStyle(
              fontWeight: FontWeight.bold,
              color: kDarkColorScheme.onSecondaryContainer,
              fontSize: 16,
            ),
            bodyMedium: TextStyle(
              fontWeight: FontWeight.normal,
              fontFamily: 'QuickSand-Medium',
              color: kDarkColorScheme.onSecondaryContainer,
              fontSize: 15,
            ),
            bodySmall: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'QuickSand-Medium', //Advent-Lt1
              color: kDarkColorScheme.onSecondaryContainer,
              fontSize: 12,
            ),
            labelSmall: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              fontFamily: 'QuickSand-Medium',
              color: kDarkColorScheme.onSecondaryContainer,
              fontSize: 9,
            ),
            displaySmall: TextStyle(
                fontWeight: FontWeight.normal,
                fontFamily: 'QuickSand-Medium',
                color: kDarkColorScheme.onSecondaryContainer,
                fontSize: 16,
                wordSpacing: 1.2,
                height: 1.4),
            displayLarge: TextStyle(
              fontWeight: FontWeight.normal,
              fontFamily: 'QuickSand-Medium',
              color: kDarkColorScheme.onSecondaryContainer,
              fontSize: 25,
            )),
      ),
      theme: ThemeData().copyWith(
        colorScheme: kColorScheme,
        appBarTheme: const AppBarTheme().copyWith(
          backgroundColor: kColorScheme.primary.withOpacity(0.8),
          foregroundColor: kColorScheme.primaryContainer,
        ),
        cardTheme: const CardTheme().copyWith(
          color: kColorScheme.primaryContainer.withOpacity(0.5),
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: kColorScheme.onSecondaryContainer,
              foregroundColor: kColorScheme.secondaryContainer,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)))),
        ),
        textTheme: ThemeData().textTheme.copyWith(
            titleLarge: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'RobotoCRegular',
              color: kColorScheme.onSecondaryContainer,
              fontSize: 23,
            ),
            bodyMedium: TextStyle(
              fontWeight: FontWeight.normal,
              fontFamily: 'QuickSand-Medium',
              color: kColorScheme.onSecondaryContainer,
              fontSize: 15,
            ),
            bodyLarge: TextStyle(
              fontWeight: FontWeight.bold,
              color: kColorScheme.onSecondaryContainer,
              fontSize: 16,
            ),
            bodySmall: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'QuickSand-Medium',
              color: kColorScheme.onSecondaryContainer,
              fontSize: 14,
            ),
            labelSmall: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              fontFamily: 'QuickSand-Medium',
              color: kColorScheme.onSecondaryContainer,
              fontSize: 9,
            ),
            displaySmall: TextStyle(
                fontWeight: FontWeight.normal,
                fontFamily: 'QuickSand-Medium',
                color: kColorScheme.onSecondaryContainer,
                fontSize: 16,
                wordSpacing: 1.2,
                height: 1.4),
            displayLarge: TextStyle(
              fontWeight: FontWeight.normal,
              fontFamily: 'QuickSand-Medium',
              color: kColorScheme.onSecondaryContainer,
              fontSize: 25,
            )),
      ),
      routes: {
        HomeScreen.homeRoute: (context) => const HomeScreen(),
        HomeBudgetScreen.budgetRoute: (context) => const HomeBudgetScreen(),
        GoalSettingsScreen.goalScreenRoute: (context) =>
            const GoalSettingsScreen(),
        FinHomeScr.homeRoute: (context) => const FinHomeScr(),
        HomePremium.homeRoute: (context) => const HomePremium(),
        AuthScreen.routeName: (context) => const AuthScreen(),
      },
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return const FirstScreen();
  }
}

void backgroundFetchHandler(String taskId) async {
  await Firebase.initializeApp();
  // Your background task logic goes here...
  bool isBudgetConditionMet = await BackgroundHandler.current.isBudgetCross();
  bool isGoalConditionMet = await BackgroundHandler.current.isGoalCrossed();
  if (isBudgetConditionMet) {
    await FirebasePush.current.sendLegacyPushNotification(
        'Budget Alert!', 'Your budget is crossing the limit! Take a look');
    displayNotification(1);
  }
  if (isGoalConditionMet) {
    await FirebasePush.current.sendLegacyPushNotification(
        'Goal Alert!', 'Your Goal will expire soon! Take a look');
    displayNotification(2);
  }

  // IMPORTANT: You must signal that the task is complete to avoid background fetch timeouts.
  BackgroundFetch.finish(taskId);
}

void displayNotification(int channelID) {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/launcher_icon');

  final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id', 'Alert',
      channelDescription: 'CrossLimitAlert',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      icon: initializationSettingsAndroid.defaultIcon);

  final platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    flutterLocalNotificationsPlugin.show(
      channelID,
      message.notification!.title,
      message.notification!.body,
      platformChannelSpecifics,
      payload: message.data[
          'your_custom_data'], // Add any custom data you want to pass to the onSelectNotification callback
    );
  });
}
