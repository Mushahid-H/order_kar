import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future<void> addToCart(String userId, String productName, double totalPrice,
      int quantity, String productSize) async {
    try {
      // Check if the cart item already exists
      DocumentReference cartItemRef =
          usersCollection.doc(userId).collection('cart').doc(productName);

      final cartItemDoc = await cartItemRef.get();

      if (cartItemDoc.exists) {
        // Update quantity if item already exists
        int newQuantity =
            (cartItemDoc.data() as Map<String, dynamic>)['qty'] + quantity;
        await cartItemRef.update({'qty': newQuantity});
      } else {
        // Add new cart item if it doesn't exist
        await cartItemRef.set({
          'productName': productName,
          'totalPrice': totalPrice,
          'qty': quantity,
          'productSize': productSize
        });
      }
    } catch (e) {
      print("Error adding to cart: $e");
      throw e;
    }
  }

  Future<void> removeFromCart(String? userId, String productName) async {
    try {
      await usersCollection
          .doc(userId)
          .collection('cart')
          .doc(productName)
          .delete();
    } catch (e) {
      print("Error removing from cart: $e");
      throw e;
    }
  }

  Stream<QuerySnapshot> getCartItemsStream(String? userId) {
    return usersCollection.doc(userId).collection('cart').snapshots();
  }
}
