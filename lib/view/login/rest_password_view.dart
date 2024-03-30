import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orderkar/common/color_extension.dart';
import 'package:orderkar/common/extension.dart';
import 'package:orderkar/common_widget/round_button.dart';

import '../../common/globs.dart';

import '../../common_widget/round_textfield.dart';
import 'new_password_view.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  TextEditingController txtEmail = TextEditingController();

// reset functionality

  Future<void> _resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: txtEmail.text,
      );

      // Show a success message to the user
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              "Email Sent",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            content:
                const Text("Please check your email to reset your password."),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Handle password reset errors
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              "Password Reset Failed",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text("$e"),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
// main

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 64,
              ),
              Image.asset(
                'assets/img/orderkar_Logo.png',
                // width: media.width * 0.65,
                height: media.width * 0.5,
                fit: BoxFit.contain,
              ),
              const SizedBox(
                height: 64,
              ),
              Text(
                "Reset Password",
                style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 30,
                    fontWeight: FontWeight.w800),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                "Please enter your email to receive a\n reset code to create a new password via email",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 60,
              ),
              RoundTextfield(
                hintText: "Your Email",
                controller: txtEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(
                height: 30,
              ),
              RoundButton(
                  title: "Send",
                  onPressed: () {
                    // btnSubmit();
                    _resetPassword();
// delete it later
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NewPasswordView(nObj: {
                                'id': '1',
                                'reset_code': '12234',
                                'new_password': '3456678'
                              })),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }

  // Action
  void btnSubmit() {
    if (!txtEmail.text.isEmail) {
      mdShowAlert(Globs.appName, MSG.enterEmail, () {});
      return;
    }

    endEditing();

    // serviceCallForgotRequest({"email": txtEmail.text});
  }

  // ServiceCall

  // void serviceCallForgotRequest(Map<String, dynamic> parameter) {
  //   Globs.showHUD();

  //   ServiceCall.post(parameter, SVKey.svForgotPasswordRequest,
  //       withSuccess: (responseObj) async {
  //     Globs.hideHUD();
  //     if (responseObj[KKey.status] == "1") {
  //       Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //               builder: (context) => OTPView(email: txtEmail.text)));
  //     } else {
  //       mdShowAlert(Globs.appName,
  //           responseObj[KKey.message] as String? ?? MSG.fail, () {});
  //     }
  //   }, failure: (err) async {
  //     Globs.hideHUD();
  //     mdShowAlert(Globs.appName, err.toString(), () {});
  //   });
  // }
}
