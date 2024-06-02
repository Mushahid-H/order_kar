import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orderkar/common/color_extension.dart';
import 'package:orderkar/common/extension.dart';
import 'package:orderkar/common/globs.dart';
import 'package:orderkar/common_widget/round_button.dart';
import 'package:orderkar/view/Cart_Firebase.dart';
import 'package:orderkar/view/more/checkout_message_view.dart';

import 'checkout_view.dart';

class MyOrderView extends StatefulWidget {
  const MyOrderView({Key? key}) : super(key: key);

  @override
  State<MyOrderView> createState() => _MyOrderViewState();
}

class _MyOrderViewState extends State<MyOrderView> {
  FirestoreService firestoreService = FirestoreService();
  List<Map<String, dynamic>> itemArr = [];
  var deliveryCost = 5;
  double subTotal = 0.0;
  bool isSubUpdated = false;
  int selectMethod = -1;

  List paymentArr = [
    {"name": "Cash on delivery", "icon": "assets/img/cash.png"},

    // {"name": "test@gmail.com", "icon": "assets/img/paypal.png"},
  ];

  @override
  void initState() {
    super.initState();
    subTotal = 0;
    Future.delayed(const Duration(milliseconds: 150), () {
      setState(() {});
    });
  }

  File? _image;

  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 46,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Image.asset("assets/img/btn_back.png",
                          width: 20, height: 20),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Text(
                        "My Order",
                        style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 20,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
              // Container to display cart items
              Container(
                decoration: BoxDecoration(color: TColor.textfield),
                child: StreamBuilder<QuerySnapshot>(
                  stream: firestoreService.getCartItemsStream(
                      FirebaseAuth.instance.currentUser!.email),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    // subTotal = 0.0;

                    itemArr.clear();

                    snapshot.data!.docs.forEach((doc) {
                      itemArr.add(doc.data() as Map<String, dynamic>);
                    });

                    return ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: itemArr.length,
                      separatorBuilder: ((context, index) => Divider(
                            indent: 25,
                            endIndent: 25,
                            color: TColor.secondaryText.withOpacity(0.5),
                            height: 1,
                          )),
                      itemBuilder: ((context, index) {
                        var cObj = itemArr[index] as Map? ?? {};
                        subTotal = itemArr
                                .map((element) =>
                                    element["totalPrice"] as double)
                                .reduce((value, element) => value + element) *
                            cObj["qty"];

                        return Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 25),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  "${cObj["productName"].toString()} x ${cObj["qty"].toString()} ${cObj["productSize"] ?? "small"}",
                                  style: TextStyle(
                                      color: TColor.primaryText,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Text(
                                "Pkr ${cObj["totalPrice"].toString()}",
                                style: TextStyle(
                                    color: TColor.primaryText,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              IconButton(
                                onPressed: () {
                                  firestoreService.removeFromCart(
                                      FirebaseAuth.instance.currentUser!.email,
                                      cObj["productName"].toString());

                                  setState(() {
                                    subTotal -=
                                        itemArr[index]["totalPrice"] as double;
                                    itemArr.removeAt(index);
                                  });
                                  mdShowAlert(Globs.appName,
                                      "Item deleted successfully", () {
                                    if (itemArr.isEmpty) {
                                      subTotal = 0;
                                    }
                                    setState(() {});
                                  });
                                },
                                icon: const Icon(Icons.delete),
                              ),
                            ],
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
              // Container to display subtotal, delivery cost, and total
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Sub Total",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 13,
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          "Pkr ${subTotal.toString()}",
                          style: TextStyle(
                              color: TColor.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Delivery Cost",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 13,
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          "\$${subTotal > 0 ? deliveryCost : 0}",
                          style: TextStyle(
                              color: TColor.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Divider(
                      color: TColor.secondaryText.withOpacity(0.5),
                      height: 1,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 13,
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          "\$${subTotal + (subTotal > 0 ? deliveryCost : 0)}",
                          style: TextStyle(
                              color: TColor.primary,
                              fontSize: 22,
                              fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Payment method",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: TColor.secondaryText,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500),
                              ),
                              ElevatedButton(
                                  onPressed: () async {
                                    await LaunchApp.openApp(
                                        androidPackageName:
                                            'com.techlogix.mobilinkcustomer',
                                        openStore: true,
                                        appStoreLink:
                                            'https://play.google.com/store/apps/details?id=com.techlogix.mobilinkcustomer');
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(Colors
                                            .green), // Background color when the button is enabled
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.white),
                                    padding: MaterialStateProperty.all<
                                            EdgeInsetsGeometry>(
                                        const EdgeInsets.all(
                                            8)), // Padding around the button
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            8), // Button border radius
                                      ),
                                    ),
                                  ),
                                  child: const Text('Open Jazzcash')),
                            ],
                          ),
                          ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: paymentArr.length,
                              itemBuilder: (context, index) {
                                var pObj = paymentArr[index] as Map? ?? {};
                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 15.0),
                                  decoration: BoxDecoration(
                                      color: TColor.textfield,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                          color: TColor.secondaryText
                                              .withOpacity(0.2))),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          pObj["name"] ?? '',
                                          style: TextStyle(
                                              color: TColor.primaryText,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            selectMethod = index;
                                          });
                                        },
                                        child: Icon(
                                          selectMethod == index
                                              ? Icons.radio_button_on
                                              : Icons.radio_button_off,
                                          color: TColor.primary,
                                          size: 15,
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              })
                        ],
                      ),
                    ),
                    selectMethod == -1
                        ? Column(
                            children: <Widget>[
                              _image == null
                                  ? const Placeholder(
                                      fallbackWidth: 100,
                                      fallbackHeight: 100,
                                    )
                                  : Image.file(
                                      _image!,
                                      width: 200,
                                      height: 200,
                                    ),
                              const SizedBox(
                                height: 10,
                              ),
                              ElevatedButton(
                                onPressed: getImage,
                                child: const Text('Payment Screeshot'),
                              ),
                              const SizedBox(
                                height: 10,
                              )
                            ],
                          )
                        : Column(),
                    // RoundButton(
                    //   title: "Checkout",
                    //   onPressed: () {
                    //     print(itemArr);
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) =>
                    //             CheckoutView(itemArr: itemArr),
                    //       ),
                    //     );
                    //   },
                    // ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 25),
                      child: RoundButton(
                          title: "Check Out",
                          onPressed: () {
                            showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                builder: (context) {
                                  return CheckoutMessageView();
                                });
                          }),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
