import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:orderkar/common/color_extension.dart';

import 'package:orderkar/common_widget/viewAllItems.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:orderkar/view/menu/item_details_view.dart';
import 'package:orderkar/view/menu/menu_items_view.dart';

import '../../common_widget/popular_resutaurant_row.dart';
import '../../common_widget/recent_item_row.dart';
import '../../common_widget/view_all_title_row.dart';
import '../more/my_order_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  TextEditingController txtSearch = TextEditingController();
  List<Map<String, dynamic>> popArr = [];
  String userName = '';
  String userAddress = '';
  List promotDoc = [];
  List<String> documentIds = [];

// fetching restaurant data
  Future<void> fetchRestaurantData() async {
    List<Map<String, dynamic>> tempPopArr = [];

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('restaurants').get();

      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> restaurantData =
            doc.data() as Map<String, dynamic>;
        tempPopArr.add(restaurantData);
      });

      setState(() {
        popArr = tempPopArr;
      });
    } catch (e) {
      print("Error fetching restaurant data: $e");
      // Handle error as needed
    }
  }

  // fetching promotional dataFuture<void> fetchRestaurantData() async {
  Future<List> fetchPromotionData(
      String firstCollectionPath, String secondCollectionPath) async {
    try {
      // Get documents from the first collection
      QuerySnapshot firstCollectionSnapshot = await FirebaseFirestore.instance
          .collection(firstCollectionPath)
          .get();

      // Extract document IDs (names) from the first collection
      documentIds = firstCollectionSnapshot.docs.map((doc) => doc.id).toList();

      // Use the document IDs to construct queries for the second collection
      List<Future<DocumentSnapshot>> futureDocuments = documentIds.map((id) {
        return FirebaseFirestore.instance
            .collection(secondCollectionPath)
            .doc(id)
            .get();
      }).toList();

      // Wait for all documents to be retrieved
      List<DocumentSnapshot> documents = await Future.wait(futureDocuments);
      promotDoc = documents.map((e) => e.data()).toList();

      return documents;
    } catch (e) {
      print("Error fetching data from second collection: $e");
      return []; // Return empty list in case of error
    }
  }

  // Rearrange doc2 based on whether the document names from doc1 are present in doc2
  void rearrange() {
    List<Map<String, dynamic>> rearrangedDoc2 = [];

    // Add documents from doc2 that match document names from doc1
    for (var name in promotDoc) {
      var matchingDocs = popArr.where((doc) => doc['name'] == name["name"]);
      rearrangedDoc2.addAll(matchingDocs);
    }
    print(rearrangedDoc2.length);

    for (var doc in popArr) {
      if (!promotDoc
          .any((promotDocItem) => promotDocItem['name'] == doc['name'])) {
        rearrangedDoc2.add(doc);
      }
    }

    setState(() {
      popArr = rearrangedDoc2;
    });
    print(rearrangedDoc2.length);
  }

// getting username for display

  Future<void> fetchUserData() async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.email ?? '';
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        setState(() {
          userName = userSnapshot.get('name');
          userAddress = userSnapshot.get('address');
        });
      } else {
        print("User document does not exist.");
      }
    } catch (e) {
      print("Error fetching user data: $e");
      // Handle error as needed
    }
  }

  @override
  void initState() {
    super.initState();

    fetchRestaurantData();
    fetchPromotionData('Promotions', 'restaurants');
    fetchUserData();
    Future.delayed(const Duration(seconds: 2), () => rearrange());
    // rearrange();
  }

  List<Map<String, dynamic>> recentArr = [
    {
      "image": "assets/img/item_1.png",
      "name": "Mulberry Pizza by Josh",
      "rate": "4.9",
      "rating": "124",
      "type": "Cafa",
      "food_type": "Western Food"
    },
    {
      "image": "assets/img/item_2.png",
      "name": "Barita",
      "rate": "4.9",
      "rating": "124",
      "type": "Cafa",
      "food_type": "Western Food"
    },
    {
      "image": "assets/img/item_3.png",
      "name": "Pizza Rush Hour",
      "rate": "4.9",
      "rating": "124",
      "type": "Cafa",
      "food_type": "Western Food"
    },
    {
      "image": "assets/img/item_1.png",
      "name": "Mulberry Pizza by Josh",
      "rate": "4.9",
      "rating": "124",
      "type": "Cafa",
      "food_type": "Western Food"
    },
    {
      "image": "assets/img/item_2.png",
      "name": "Barita",
      "rate": "4.9",
      "rating": "124",
      "type": "Cafa",
      "food_type": "Western Food"
    },
    {
      "image": "assets/img/item_3.png",
      "name": "Pizza Rush Hour",
      "rate": "4.9",
      "rating": "124",
      "type": "Cafa",
      "food_type": "Western Food"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              const SizedBox(
                height: 46,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Welcome $userName!",
                      style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 20,
                          fontWeight: FontWeight.w800),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyOrderView()));
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
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Delivering to",
                      style:
                          TextStyle(color: TColor.secondaryText, fontSize: 11),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Location: $userAddress",
                          style: TextStyle(
                              color: TColor.secondaryText,
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(
                          width: 25,
                        ),
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(
                height: 30,
              ),

// Popular restaurant
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ViewAllTitleRow(
                  title: "Popular Restaurants",
                  onView: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ViewAllItems(
                                title: "All Restaurants", popArr: popArr)));
                  },
                ),
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount:
                    popArr.length > 2 ? popArr.length - 2 : popArr.length,
                itemBuilder: ((context, index) {
                  var pObj = popArr[index] as Map? ?? {};

                  return PopularRestaurantRow(
                    pObj: pObj,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MenuItemsView(
                                    mObj: pObj,
                                    tableReserve: true,
                                  )));
                    },
                  );
                }),
              ),

              // RECENT ITEMS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ViewAllTitleRow(
                  title: "Recent Items",
                  onView: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ViewAllItems(
                                title: "All Recent Items", popArr: recentArr)));
                  },
                ),
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                itemCount: 3,
                itemBuilder: ((context, index) {
                  var rObj = recentArr[index] as Map? ?? {};
                  return RecentItemRow(
                    rObj: rObj,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ItemDetailsView(
                                    iobj: rObj,
                                  )));
                    },
                  );
                }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
