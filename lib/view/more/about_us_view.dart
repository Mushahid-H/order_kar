import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:orderkar/common/color_extension.dart';

import 'my_order_view.dart';

class AboutUsView extends StatefulWidget {
  const AboutUsView({super.key});

  @override
  State<AboutUsView> createState() => _AboutUsViewState();
}

class _AboutUsViewState extends State<AboutUsView> {
  // "OrderKar is a food delivery app that connects you with the best restaurants in your city. We deliver food from your neighborhood local joints, your favorite cafes, luxurious & elite restaurants in your area, and also from chains like Dominos, KFC, Burger King, Pizza Hut, FreshMenu, Mc Donald’s, Subway, Faasos, Cafe Coffee Day, Taco Bell, and more. Exciting bit? We place no minimum order restrictions! Order in as little (or as much) as you’d like. We’ll OrderKar it to you! ",
  // "Food delivery is not just about food. It’s about the whole experience. That’s why we have a team of real people who are available 24/7 to support you with your orders. We believe that ordering food should be easy, fast, and definitely fun! We wanted something simpler, so we made it. OrderKar is a single window for ordering from a wide range of restaurants. We have our own exclusive fleet of delivery personnel to pick up orders from restaurants and deliver it to customers.",
  // "We are currently serving in the following cities: Bangalore, Hyderabad, Mumbai, Pune, Delhi, Gurgaon, Noida, Ghaziabad, Faridabad, Chandigarh, Mohali, Panchkula, Jaipur, Kolkata, Chennai, Ahmedabad, Coimbatore, Vizag, Vijayawada, Warangal, Tirupati, and more.",
  // "We are constantly working to improve our services and expand our reach. We are working hard to bring OrderKar to your city soon!",
  // "We are always looking for feedback from our customers. If you have any suggestions or feedback, please feel free to write to us at

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
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
                              "About Us",
                              style: TextStyle(
                                  color: TColor.primaryText,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const MyOrderView()));
                            },
                            icon: Image.asset(
                              "assets/img/shopping_cart.png",
                              width: 25,
                              height: 25,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('aboutus')
                          .doc('description')
                          .get(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator(); // Show loading indicator while fetching data
                        }

                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        if (snapshot.hasData && !snapshot.data!.exists) {
                          return const Text(
                              'Document does not exist'); // Handle case where document doesn't exist
                        }

                        // Extract text_description from the document
                        final String? textDescription =
                            snapshot.data!.get('text_desc');

                        return textDescription != null
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  textDescription,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black87,
                                    letterSpacing: 0.1,
                                    wordSpacing: 0.7,
                                    textBaseline: TextBaseline.alphabetic,
                                    decoration: TextDecoration.none,
                                    fontFamily: 'Metropolis',
                                  ),
                                  textAlign: TextAlign.left,
                                ))
                            : const Text(
                                'text_description not found'); // Handle case where field doesn't exist
                      },
                    ),
                  ],
                ))));
  }
}
