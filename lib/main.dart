import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:orderkar/common/color_extension.dart';
import 'package:orderkar/common/locator.dart';
import 'package:orderkar/firebase_options.dart';

import 'package:orderkar/view/login/login_view.dart';
import 'package:orderkar/view/login/welcome_view.dart';
import 'package:orderkar/view/main_tabview/main_tabview.dart';
import 'package:orderkar/view/on_boarding/startup_view.dart';
import 'package:orderkar/view/more/notification_view.dart';

// import 'common/globs.dart';
import 'common/my_http_overrides.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  setUpLocator();
  HttpOverrides.global = MyHttpOverrides();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp(
    defaultHome: StartupView(),
  ));
}

void configLoading() {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.ring
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45.0
    ..radius = 5.0
    ..progressColor = TColor.primaryText
    ..backgroundColor = TColor.primary
    ..indicatorColor = Colors.yellow
    ..textColor = TColor.primaryText
    ..userInteractions = false
    ..dismissOnTap = false;
}

class MyApp extends StatefulWidget {
  final Widget defaultHome;
  const MyApp({super.key, required this.defaultHome});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ORDERKAR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Metropolis",
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
      ),
      navigatorKey: navigatorKey,
      home: widget.defaultHome,
      onGenerateRoute: (routeSettings) {
        switch (routeSettings.name) {
          case "welcome":
            return MaterialPageRoute(builder: (context) => const WelcomeView());
          case "Home":
            return MaterialPageRoute(builder: (context) => const MainTabView());
          default:
            return MaterialPageRoute(
                builder: (context) => Scaffold(
                      body: Center(
                          child: Text("No path for ${routeSettings.name}")),
                    ));
        }
      },
      routes: {
        NotificationsView.route: (context) => const NotificationsView(),
      },
      builder: (context, child) {
        return FlutterEasyLoading(child: child);
      },
    );
  }
}
