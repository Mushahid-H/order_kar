import 'package:flutter/material.dart';
import 'package:orderkar/common_widget/popular_resutaurant_row.dart';
import 'package:orderkar/common_widget/round_textfield.dart';
import 'package:orderkar/view/menu/menu_items_view.dart';

class ViewAllItems extends StatefulWidget {
  final List<Map<String, dynamic>> popArr;
  final String title;
  const ViewAllItems({super.key, required this.title, required this.popArr});

  @override
  State<ViewAllItems> createState() => _ViewAllItemsState();
}

class _ViewAllItemsState extends State<ViewAllItems> {
  TextEditingController txtSearch = TextEditingController();

  List<Map<String, dynamic>> _searchResult = [];

  @override
  void initState() {
    _searchResult = widget.popArr;
    super.initState();
  }

  void search(String query) {
    List<Map<String, dynamic>> searchList = [];

    if (query.isEmpty) {
      searchList = widget.popArr;
    } else {
      searchList = widget.popArr.where((element) {
        return element["name"].toLowerCase().contains(query.toLowerCase());
      }).toList();
    }

    setState(() {
      _searchResult = searchList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            Text(
              widget.title,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w800),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              color: Colors.black,
              thickness: 1,
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: RoundTextfield(
                hintText: "Search Restaurant",
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
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _searchResult.length,
              itemBuilder: ((context, index) {
                var pObj = _searchResult[index] as Map? ?? {};
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
          ],
        ),
      ),
    );
  }
}
