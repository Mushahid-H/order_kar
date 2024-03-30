import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orderkar/common/globs.dart';
import 'package:orderkar/common_widget/round_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orderkar/view/login/login_view.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../common/color_extension.dart';
import '../../common_widget/round_textfield.dart';
import '../more/my_order_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ImagePicker picker = ImagePicker();
  XFile? image;
  File? _imageFile;
  late bool isImageLocal;

// function for fetching userData

  Future<Map<String, dynamic>> fetchUserData() async {
    Map<String, dynamic> userData = {};

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.email)
            .get();

        if (documentSnapshot.exists) {
          userData = documentSnapshot.data() as Map<String, dynamic>;
          txtName.text = userData['name'];
          txtEmail.text = userData['email'];
          txtAddress.text = userData['address'];
          txtMobile.text = userData['phoneNumber'];
          String? url = userData['profileImage'] ?? '';
          setState(() {
            isImageLocal = !url!.startsWith('http');
          });
        } else {
          print('Document does not exist for user: ${user.email}');
        }
      } else {
        print('No user is currently logged in');
      }
    } catch (e) {
      // Handle error
      print('Error fetching user data: $e');
      // You might want to throw the error or handle it differently based on your app's requirements
    }

    return userData;
  }

  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();

    fetchUserData().then((data) {
      setState(() {
        userData = data;
      });
    }).catchError((error) {
      print('Error fetching user data: $error');
    });
  }

// function for uploading image
  Future<void> _uploadImage() async {
    image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {});

    if (image != null) {
      setState(() {
        _imageFile = File(image!.path);
      });

      Reference ref = FirebaseStorage.instance
          .ref()
          .child('user_images/${FirebaseAuth.instance.currentUser!.email}');
      UploadTask uploadTask = ref.putFile(_imageFile!);
      await uploadTask.whenComplete(() => null);

      // Get the download URL
      String imageUrl = await ref.getDownloadURL();

      // Update the user document with the image URL
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.email)
          .update({
        'profileImage': imageUrl,
      });
    }
    setState(() {
      _imageFile = File(image!.path);
      isImageLocal = true;
    });
  }

// Function to sign out
  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginView()),
      );
      Globs.hideHUD();
    } catch (e) {
      print('Failed to sign out: $e');
      Globs.hideHUD();
    }
  }

  TextEditingController txtName = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtMobile = TextEditingController();
  TextEditingController txtAddress = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  TextEditingController txtConfirmPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const SizedBox(
            height: 46,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Profile",
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
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: TColor.placeholder,
              borderRadius: BorderRadius.circular(50),
            ),
            alignment: Alignment.center,
            child: image != null || userData.containsKey('profileImage')
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: isImageLocal
                        ? Image.file(_imageFile!,
                            width: 100, height: 100, fit: BoxFit.cover)
                        : Image.network(userData['profileImage'] ?? '',
                            width: 100, height: 100, fit: BoxFit.cover))
                : Icon(
                    Icons.person,
                    size: 65,
                    color: TColor.secondaryText,
                  ),
          ),
          TextButton.icon(
            onPressed: () async {
              _uploadImage();
            },
            icon: Icon(
              Icons.edit,
              color: TColor.primary,
              size: 12,
            ),
            label: Text(
              "Edit Profile",
              style: TextStyle(color: TColor.primary, fontSize: 12),
            ),
          ),
          Text(
            "Hi there ${userData["name"]}!",
            style: TextStyle(
                color: TColor.primaryText,
                fontSize: 16,
                fontWeight: FontWeight.w700),
          ),
          TextButton(
            onPressed: () {
              Globs.showHUD();
              signOut();
            },
            child: Text(
              "Sign Out",
              style: TextStyle(
                  color: TColor.secondaryText,
                  fontSize: 11,
                  fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            child: RoundTitleTextfield(
              title: "Name",
              hintText: "Enter Name",
              controller: txtName,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            child: RoundTitleTextfield(
              title: "Email",
              hintText: "Enter Email",
              keyboardType: TextInputType.emailAddress,
              controller: txtEmail,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            child: RoundTitleTextfield(
              title: "Mobile No",
              hintText: "Enter Mobile No",
              controller: txtMobile,
              keyboardType: TextInputType.phone,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            child: RoundTitleTextfield(
              title: "Address",
              hintText: "Enter Address",
              controller: txtAddress,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: RoundButton(
                title: "Save",
                onPressed: () {
                  Globs.showHUD();
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.email)
                        .update({
                      'name': txtName.text,
                      'email': txtEmail.text,
                      'phoneNumber': txtMobile.text,
                      'address': txtAddress.text,
                    }).then((value) {
                      Globs.hideHUD();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Profile updated successfully')));
                    }).catchError((error) {
                      Globs.hideHUD();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                        'Profile updation Failed',
                        style: TextStyle(color: Colors.red),
                      )));
                    });
                  }
                }),
          ),
          const SizedBox(
            height: 20,
          ),
        ]),
      ),
    ));
  }
}
