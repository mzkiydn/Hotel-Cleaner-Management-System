import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hcms_sep/Provider/PaymentController.dart';

class PaymentForm extends StatefulWidget {
  const PaymentForm({super.key});

  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  final String bookingId = "iej8dYWo5FPpZ1cPkmUi";
  Map<String, dynamic>? bookingData;

  @override
  void initState() {
    super.initState();
    fetchBookingData();
  }

  Future<void> fetchBookingData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Booking')
          .doc(bookingId)
          .get();

      if (snapshot.exists) {
        setState(() {
          bookingData = snapshot.data() as Map<String, dynamic>;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch booking data: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (bookingData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Payment Details"),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Address",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(bookingData!['address'] ?? 'N/A'),
            const SizedBox(height: 20),
            const Text(
              "Modify session’s date",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: bookingData!['sessionDate'],
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    initialValue: bookingData!['sessionTime'],
                    decoration: const InputDecoration(
                      labelText: 'Time',
                      prefixIcon: Icon(Icons.access_time),
                    ),
                    readOnly: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Other details",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text("Session duration: ${bookingData!['sessionDuration']} hours"),
            Text("Cleaner ID: ${bookingData!['cleanerId']}"),
            const SizedBox(height: 20),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Payment:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "RM ${bookingData!['price']}",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                //PaymentController.instance.pay();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.green,
              ),
              child: const Text("Pay"),
            ),
          ],
        ),
      ),
    );
  }
}
