import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orderkar/view/login/welcome_view.dart';
import 'package:orderkar/view/main_tabview/main_tabview.dart';

import '../../common/globs.dart';

class StartupView extends StatefulWidget {
  const StartupView({super.key});

  @override
  State<StartupView> createState() => _StarupViewState();
}

class _StarupViewState extends State<StartupView> {
  @override
  void initState() {
    super.initState();
    goWelcomePage();
  }

  void goWelcomePage() async {
    await Future.delayed(const Duration(seconds: 3));
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AuthWrapper()),
    );
  }

  // void welcomePage() {
  //   if (Globs.udValueBool(Globs.userLogin)) {
  //     Navigator.push(context,
  //  MaterialPageRoute(builder: (context) => const MainTabView()));
  //   } else {
  //     Navigator.push(context,
  //         MaterialPageRoute(builder: (context) => const WelcomeView()));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            "assets/img/splash_bg.png",
            width: media.width,
            height: media.height,
            fit: BoxFit.cover,
          ),
          Image.asset(
            "assets/img/orderkar_Logo.png",
            width: media.width * 0.7,
            height: media.width * 0.7,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            // User is not logged in
            // Navigator.push(context,
            //     MaterialPageRoute(builder: (context) => const WelcomeView()));
            return WelcomeView();
          } else {
            // User is logged in
            // Navigator.push(context,
            //     MaterialPageRoute(builder: (context) => const MainTabView()));
            return MainTabView();
          }
        } else {
          // Connection state is not active yet
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
