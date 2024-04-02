import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:orderkar/common/color_extension.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orderkar/common/extension.dart';
import 'package:orderkar/common/globs.dart';

class DateTimePickerScreen extends StatefulWidget {
  final String restaurantId;
  const DateTimePickerScreen({super.key, required this.restaurantId});

  @override
  State<DateTimePickerScreen> createState() => _DateTimePickerScreenState();
}

class _DateTimePickerScreenState extends State<DateTimePickerScreen> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  int numberOfPeople = 1;

  @override
  void initState() {
    super.initState();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> makeReservation(String restaurantId, TimeOfDay time,
      DateTime date, int numberOfPeople, String? userId) async {
    try {
      // Reference to the restaurant document

      DateTime reservationDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      DocumentReference restaurantRef =
          _firestore.collection('restaurants').doc(restaurantId);

      // Create a reservations collection within the restaurant document
      CollectionReference reservationsRef =
          restaurantRef.collection('reservations');

      // Add a new document named after the userId with reservation data
      await reservationsRef.doc(userId).set({
        'dateTime': reservationDateTime,
        'numberOfPeople': numberOfPeople,
        'userId': userId, // Optionally, you can store the userId as well
      });
    } catch (e) {
      mdShowAlert(Globs.appName, "Failed to reserve", () {});
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Date and Time',
          style: TextStyle(
              color: TColor.primaryText,
              fontSize: 22,
              fontWeight: FontWeight.w800),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Selected Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 22,
                  fontWeight: FontWeight.w800),
            ),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.primary,
                foregroundColor: Colors.white,
                fixedSize: const Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text('Select Date'),
            ),
            const SizedBox(height: 20.0),
            Text(
              'Selected Time: ${selectedTime.hour}:${selectedTime.minute}',
              style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 22,
                  fontWeight: FontWeight.w800),
            ),
            ElevatedButton(
              onPressed: () => _selectTime(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.primary,
                foregroundColor: Colors.white,
                fixedSize: const Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text('Select Time'),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Number of People: $numberOfPeople',
                  style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 20,
                      fontWeight: FontWeight.w800),
                ),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      if (numberOfPeople > 1) numberOfPeople--;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      numberOfPeople++;
                    });
                  },
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                makeReservation(
                        widget.restaurantId,
                        selectedTime,
                        selectedDate,
                        numberOfPeople,
                        FirebaseAuth.instance.currentUser!.email)
                    .then((value) =>
                        mdShowAlert(Globs.appName, "Table Reserved", () {}))
                    .onError((error, stackTrace) =>
                        mdShowAlert(Globs.appName, "Failed to reserve", () {}));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.primary,
                foregroundColor: Colors.white,
                fixedSize: const Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}
