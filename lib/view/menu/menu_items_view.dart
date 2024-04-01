import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:orderkar/common/color_extension.dart';
import 'package:orderkar/common/extension.dart';
import 'package:orderkar/common/globs.dart';
import 'package:orderkar/common_widget/round_textfield.dart';

import '../../common_widget/menu_item_row.dart';
import '../more/my_order_view.dart';
import 'item_details_view.dart';

class MenuItemsView extends StatefulWidget {
  final Map mObj;
  final bool tableReserve;
  const MenuItemsView(
      {super.key, required this.mObj, this.tableReserve = false});

  @override
  State<MenuItemsView> createState() => _MenuItemsViewState();
}

class _MenuItemsViewState extends State<MenuItemsView> {
  TextEditingController txtSearch = TextEditingController();
  List<Map<String, dynamic>> menuItemsArr = [];
  List<Map<String, dynamic>> mObjList = [];

  List<Map<String, dynamic>> _searchResult = [];
  List<String> documentIds = [];

  @override
  void initState() {
    super.initState();

    if (widget.mObj["name"] == "Promotions") {
      fetchPromotionData('Promotions', 'restaurants');
    } else {
      fetchData();
    }

    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _searchResult = List.from(mObjList);
      });
    });
  }

  // fetching promotional dataFuture<void> fetchRestaurantData() async {
  Future<List<Map<String, dynamic>>> fetchPromotionData(
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
      // Process the documents retrieved from the second collection
      List<Map<String, dynamic>> data =
          documents.map((doc) => doc.data() as Map<String, dynamic>).toList();

      menuItemsArr = data;

      return data;
    } catch (e) {
      print("Error fetching data from second collection: $e");
      return []; // Return empty list in case of error
    }
  }

// data form collection
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
      mdShowAlert(Globs.appName, "Error Occured while fetching data", () {});
    }
  }

// data from sub collection
  Future<void> fetchSubcollectionData(DocumentReference documentRef) async {
    try {
      // Get a reference to the subcollection
      CollectionReference subcollectionReference =
          documentRef.collection("foodItems");

      // Get documents from the subcollection
      QuerySnapshot subcollectionQuerySnapshot =
          await subcollectionReference.get();

      // Iterate through each document in the subcollection
      subcollectionQuerySnapshot.docs.forEach((DocumentSnapshot subDocument) {
        // Access fields of the subdocument
        Map<String, dynamic> subData =
            subDocument.data() as Map<String, dynamic>;

        setState(() {
          menuItemsArr.add(subData);
        });
      });
    } catch (e) {
      mdShowAlert(Globs.appName, "Error Occured while fetching data", () {});
    }
  }

// search functionality
  void search(String query) {
    if (query.isEmpty) {
      _searchResult = List.from(mObjList);
    } else {
      _searchResult.clear();
      _searchResult = mObjList.where((element) {
        return element["name"].toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mObj["name"] == "Promotions") {
      mObjList = menuItemsArr
          .where((item) => documentIds.contains(item["name"]))
          .toList();
    } else {
      mObjList = menuItemsArr
          .where((item) => item.containsValue(widget.mObj["name"]))
          .toList();
    }

    _searchResult = mObjList;
    print("helo $_searchResult");
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
                        widget.mObj["name"].toString(),
                        style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 20,
                            fontWeight: FontWeight.w800),
                      ),
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
                child: RoundTextfield(
                  hintText: "Search Food",
                  controller: txtSearch,
                  left: Container(
                    alignment: Alignment.center,
                    width: 30,
                    child: Image.asset(
                      "assets/img/search.png",
                      width: 20,
                      height: 20,
                    ),
                  ),
                  onChanged: (value) => search(value),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              if (widget.tableReserve)
                Column(
                  children: [
                    Text(
                      "Table Reservation",
                      style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 20,
                          fontWeight: FontWeight.w800),
                    ),
                    InkWell(
                      onTap: () => {},
                      child: Container(
                        decoration: BoxDecoration(
                          color: TColor.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(
                          Icons.table_restaurant_sharp,
                          color: TColor.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(
                height: 15,
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _searchResult.length,
                itemBuilder: ((context, index) {
                  return MenuItemRow(
                    mObj: _searchResult[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ItemDetailsView(
                                iobj: _searchResult[index],
                                name: widget.mObj["name"])),
                      );
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
