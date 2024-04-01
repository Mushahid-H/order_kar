import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:orderkar/common/color_extension.dart';
import 'package:orderkar/common_widget/round_button.dart';
import 'package:orderkar/view/menu/item_details_view.dart';

import '../../common_widget/popular_resutaurant_row.dart';
import '../more/my_order_view.dart';

class OfferView extends StatefulWidget {
  const OfferView({super.key});

  @override
  State<OfferView> createState() => _OfferViewState();
}

class _OfferViewState extends State<OfferView> {
  List<Map<String, dynamic>> dealsArr = [];

  Future<void> fetchData() async {
    try {
      // Get a reference to the collection
      CollectionReference collectionReference =
          FirebaseFirestore.instance.collection('restaurants');

      // Get documents from the collection
      QuerySnapshot querySnapshot = await collectionReference.get();

      // Iterate through each document
      querySnapshot.docs.forEach((DocumentSnapshot document) {
        fetchSubcollectionData(document.reference);
      });
    } catch (e) {
      print("Error adding to cart: $e");
    }
  }

// data from sub collection
  Future<void> fetchSubcollectionData(DocumentReference documentRef) async {
    try {
      // Get a reference to the subcollection
      CollectionReference subcollectionReference =
          documentRef.collection("Deals");

      // Get documents from the subcollection
      QuerySnapshot subcollectionQuerySnapshot =
          await subcollectionReference.get();

      // Iterate through each document in the subcollection
      subcollectionQuerySnapshot.docs.forEach((DocumentSnapshot subDocument) {
        // Access fields of the subdocument
        Map<String, dynamic> subData =
            subDocument.data() as Map<String, dynamic>;

        setState(() {
          dealsArr.add(subData);
        });
      });
    } catch (e) {
      print("Error adding to cart: $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Latest Offers",
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Find discounts, Offers special\nmeals and more!",
                      style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: 140,
                  height: 30,
                  child: RoundButton(
                      title: "check Offers", fontSize: 12, onPressed: () {}),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: dealsArr.length,
                itemBuilder: ((context, index) {
                  var pObj = dealsArr[index] as Map? ?? {};
                  return PopularRestaurantRow(
                    pObj: pObj,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ItemDetailsView(iobj: pObj)));
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
