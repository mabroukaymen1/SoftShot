import 'dart:async';
import 'package:baby/babyinfo/chose.dart';
import 'package:baby/home/activ/activity.dart';
import 'package:baby/sign_up_staff/daily.dart';
import 'package:baby/sign_up_staff/home_staff.dart';
import 'package:baby/sign_up_staff/log.dart';
import 'package:baby/sign_up_staff/parametre.dart';
import 'package:baby/sign_up_staff/profilel.dart';
import 'package:baby/sign_up_staff/sign_staff.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:baby/babyinfo/baby_provider.dart';
import 'package:baby/home/dar.dart';
import 'package:baby/home/guid.dart';
import 'package:baby/home/profile.dart';
import 'package:baby/home/step.dart';
import 'package:baby/log_in/languge.dart';
import 'package:baby/setting/notifscreen.dart';
import 'package:baby/setting/policy.dart';
import 'package:baby/setting/setting.dart';
import 'package:baby/sign_up/sign_up.dart';
import 'package:baby/home/chart.dart';
import 'package:baby/home/chat.dart';
import 'package:baby/log_in/login.dart';
import 'package:baby/setup/welcome.dart';
import 'package:baby/notifff/notif.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      await Firebase.initializeApp();
      print("Firebase initialized successfully");
    } catch (e) {
      print("Error initializing Firebase: $e");
    }

    NotificationService notificationService = NotificationService();
    await notificationService.init();
    NotificationManager notificationManager = NotificationManager();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) =>
                  ActivityManager(notificationManager: notificationManager)),
          ChangeNotifierProvider(create: (_) => BabyProvider()),
        ],
        child: MyApp(),
      ),
    );
  }, (error, stack) {
    print('Uncaught error: $error');
    print('Stack trace: $stack');
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = Locale('en');

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    String languageCode = prefs.getString('language_code') ?? 'fr';
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  Future<void> _changeLanguage(Locale locale) async {
    setState(() {
      _locale = locale;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baby Track',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      locale: _locale,
      supportedLocales: [
        Locale('en', ''),
        Locale('fr', ''),
        Locale('ar', ''),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomeScreen(),
        '/home': (context) => HomePage(onLocaleChange: _changeLanguage),
        '/homme': (context) => Home_Page(onLocaleChange: _changeLanguage),
        '/daily': (context) => DailyActivityPage(),
        '/dailly': (context) => DailyActivity_Page(),
        '/pain_tracking': (context) => PainTrackingPage(),
        '/chat': (context) => ChatScreen(onLocaleChange: _changeLanguage),
        '/register': (context) =>
            RegisterScreen(onLocaleChange: _changeLanguage),
        '/regisster': (context) =>
            Register_Screen(onLocaleChange: _changeLanguage),
        '/login': (context) => LoginPage(onLocaleChange: _changeLanguage),
        '/loginn': (context) => Login_Page(onLocaleChange: _changeLanguage),
        '/profile': (context) => ProfileScreen(),
        '/profille': (context) => Profile_Screen(),
        '/setting': (context) =>
            ParameterScreen(onLocaleChange: _changeLanguage),
        '/settting': (context) =>
            Parameter_Screen(onLocaleChange: _changeLanguage),
        '/notifScreen': (context) => NotificationScreen(),
        '/policy': (context) => PrivacyPolicyPage(),
        '/breastfeeding_guide': (context) => BreastfeedingGuidePage(),
      },
    );
  }
}
