import 'package:flutter/material.dart';
import 'package:orderkar/common_widget/popular_resutaurant_row.dart';
import 'package:orderkar/view/menu/menu_items_view.dart';

class ViewAllItems extends StatelessWidget {
  final String title;
  final List popArr;
  const ViewAllItems({super.key, required this.title, required this.popArr});

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
              title,
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
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: popArr.length,
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
          ],
        ),
      ),
    );
  }
}
