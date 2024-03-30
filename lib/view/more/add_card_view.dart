import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:orderkar/common/color_extension.dart';
import 'package:orderkar/common/extension.dart';
import 'package:orderkar/common/globs.dart';
import 'package:orderkar/common_widget/round_icon_button.dart';
import 'package:orderkar/common_widget/round_textfield.dart';

class AddCardView extends StatefulWidget {
  final Function onCardAdded;

  const AddCardView({super.key, required this.onCardAdded});

  @override
  State<AddCardView> createState() => _AddCardViewState();
}

class _AddCardViewState extends State<AddCardView> {
  TextEditingController txtCardNumber = TextEditingController();
  TextEditingController txtCardMonth = TextEditingController();
  TextEditingController txtCardYear = TextEditingController();
  TextEditingController txtCardCode = TextEditingController();
  TextEditingController txtFirstName = TextEditingController();
  TextEditingController txtLastName = TextEditingController();
  bool isAnyTime = false;

  void checkEmpty() {
    bool hasEmptyValues = false;
    if (txtCardNumber.text.isEmpty) {
      mdShowAlert(Globs.appName, MSG.enterCardNm, () {});
      hasEmptyValues = true;
      return;
    }
    if (txtCardNumber.text.length != 16) {
      mdShowAlert(Globs.appName, MSG.cardLenth, () {});
      hasEmptyValues = true;

      return;
    }
    if (txtCardMonth.text.isEmpty) {
      mdShowAlert(Globs.appName, MSG.enterCardMn, () {});
      hasEmptyValues = true;

      return;
    }
    if (txtCardYear.text.isEmpty) {
      mdShowAlert(Globs.appName, MSG.enterCardYr, () {});
      hasEmptyValues = true;

      return;
    }
    if (txtCardCode.text.isEmpty) {
      mdShowAlert(Globs.appName, MSG.enterCardCode, () {});
      hasEmptyValues = true;

      return;
    }
    if (txtFirstName.text.isEmpty) {
      mdShowAlert(Globs.appName, MSG.enterFName, () {});
      hasEmptyValues = true;

      return;
    }
    if (txtLastName.text.isEmpty) {
      mdShowAlert(Globs.appName, MSG.enterLName, () {});
      hasEmptyValues = true;

      return;
    }
    if (!hasEmptyValues) {
      _addDataToFirestore(
        isAnyTime,
        txtCardNumber.text,
        int.parse(txtCardMonth.text),
        int.parse(txtCardYear.text),
        int.parse(txtCardCode.text),
        txtFirstName.text,
        txtLastName.text,
      );
    }
    endEditing();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 22),
      width: media.width,
      decoration: BoxDecoration(
          color: TColor.white,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Add Credit/Debit Card",
                style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w700),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.close,
                  color: TColor.primaryText,
                  size: 25,
                ),
              )
            ],
          ),
          Divider(
            color: TColor.secondaryText.withOpacity(0.4),
            height: 1,
          ),
          const SizedBox(
            height: 15,
          ),
          RoundTextfield(
            hintText: "Card Number",
            controller: txtCardNumber,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            children: [
              Text(
                "Expiry",
                style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              SizedBox(
                width: 100,
                child: RoundTextfield(
                  hintText: "MM",
                  controller: txtCardMonth,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 25),
              SizedBox(
                width: 100,
                child: RoundTextfield(
                  hintText: "YYYY",
                  controller: txtCardYear,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          RoundTextfield(
            hintText: "Card Security Code",
            controller: txtCardCode,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(
            height: 15,
          ),
          RoundTextfield(
            hintText: "First Name",
            controller: txtFirstName,
          ),
          const SizedBox(
            height: 15,
          ),
          RoundTextfield(
            hintText: "Last Name",
            controller: txtLastName,
          ),
          const SizedBox(
            height: 15,
          ),
          Row(children: [
            Text(
              "You can remove this card at anytime",
              style: TextStyle(
                  color: TColor.secondaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Switch(
                value: isAnyTime,
                activeColor: TColor.primary,
                onChanged: (newVal) {
                  setState(() {
                    isAnyTime = newVal;
                  });
                }),
          ]),
          const SizedBox(
            height: 25,
          ),
          RoundIconButton(
              title: "Add Card",
              icon: "assets/img/add.png",
              color: TColor.primary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              onPressed: () {
                checkEmpty();
              }),
          const SizedBox(
            height: 25,
          ),
        ],
      ),
    );
  }

  Future<void> _addDataToFirestore(
      bool isAnytime,
      String txtCardNumber,
      int txtCardMonth,
      int txtCardYear,
      int txtCardCode,
      String txtFirstName,
      String txtLastName) async {
    try {
      // Get a reference to the Firestore collection
      CollectionReference collectionRef =
          FirebaseFirestore.instance.collection('users');

      // Add a new document with a generated ID
      await collectionRef.doc('card_info').set({
        'card_number': txtCardNumber,
        'card_month': txtCardMonth,
        'card_year': txtCardYear,
        'card_code': txtCardCode,
        'first_name': txtFirstName,
        'last_name': txtLastName,
        'delete_anytime': isAnytime,
      });

      mdShowAlert(Globs.appName, "Card Added Successfully", () {
        setState(() {
          widget.onCardAdded();
          Navigator.pop(context);
        });
      });
    } catch (e) {
      // Display an error message if something goes wrong

      mdShowAlert(Globs.appName, "Error Occured", () {
        setState(() {});
      });
    }
  }
}
