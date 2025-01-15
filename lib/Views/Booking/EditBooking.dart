import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EditBooking extends StatefulWidget {
  final String bookingId;

  const EditBooking({required this.bookingId});

  @override
  _EditBookingState createState() => _EditBookingState();
}

class _EditBookingState extends State<EditBooking> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  String address = "";
  String sessionDuration = "";
  String totalPayment = "";
  String paymentMethod = "Debit Card";

  @override
  void initState() {
    super.initState();
    _fetchBookingDetails();
  }

  Future<void> _fetchBookingDetails() async {
    try {
      DocumentSnapshot bookingSnapshot = await FirebaseFirestore.instance
          .collection('Booking')
          .doc(widget.bookingId)
          .get();

      if (bookingSnapshot.exists) {
        Map<String, dynamic> bookingData =
            bookingSnapshot.data() as Map<String, dynamic>;

        setState(() {
          address = bookingData['address'] ?? "N/A";
          sessionDuration = bookingData['sessionDuration'] ?? "N/A";
          totalPayment = bookingData['price']?.toString() ?? "N/A";
          _dateController.text = bookingData['sessionDate'];
          _timeController.text = bookingData['sessionTime'];
        });
      }
    } catch (e) {
      print('Error fetching booking details: $e');
    }
  }

  Future<void> _updateBookingDetails() async {
    try {
      await FirebaseFirestore.instance
          .collection('Booking')
          .doc(widget.bookingId)
          .update({
        'sessionDate': _dateController.text,
        'sessionTime': _timeController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking updated successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      print('Error updating booking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update booking')),
      );
    }
  }

  Future<void> _cancelBooking() async {
    final bool confirm = await _showConfirmationDialog();

    if (confirm) {
      try {
        await FirebaseFirestore.instance
            .collection('Booking')
            .doc(widget.bookingId)
            .update({'bookingStatus': 'Cancelled'});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking canceled successfully')),
        );

        Navigator.pop(context);
      } catch (e) {
        print('Error canceling booking: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to cancel booking')),
        );
      }
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Confirm Cancel Booking'),
              content: const Text(
                'Are you sure you want to cancel this booking? This action cannot be undone.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('No'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Booking'),
        centerTitle: true, // Ensure the title is properly centered
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Address",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(address),
            const SizedBox(height: 20),
            const Text(
              "Modify session’s date",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Session Date',
                prefixIcon: const Icon(Icons.date_range),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );

                if (pickedDate != null) {
                  setState(() {
                    _dateController.text =
                        DateFormat('yyyy-M-dd').format(pickedDate);
                  });
                }
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _timeController,
              decoration: InputDecoration(
                labelText: 'Session Time',
                prefixIcon: const Icon(Icons.access_time),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              readOnly: true,
              onTap: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                if (pickedTime != null) {
                  final now = DateTime.now();
                  final formattedTime = DateFormat('hh:mm a').format(
                    DateTime(now.year, now.month, now.day, pickedTime.hour,
                        pickedTime.minute),
                  );
                  setState(() {
                    _timeController.text = formattedTime;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            const Text(
              "Other details",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text("Session duration: $sessionDuration"),
            const SizedBox(height: 20),
            Divider(color: Colors.grey[400]),
            const SizedBox(height: 10),
            Text("Total Payment: RM $totalPayment"),
            Text("Paid With: $paymentMethod"),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateBookingDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Confirm Edit',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _cancelBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Cancel Booking',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
