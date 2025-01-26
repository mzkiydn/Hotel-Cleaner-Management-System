import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hcms_sep/Provider/BookingController.dart';

class EditBooking extends StatefulWidget {
  final String bookingId;

  const EditBooking({required this.bookingId});

  @override
  _EditBookingState createState() => _EditBookingState();
}

class _EditBookingState extends State<EditBooking> {
  final BookingController _controller = BookingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  String address = "";
  String sessionDuration = "";
  String totalPayment = "";
  String paymentMethod = "";

  @override
  void initState() {
    super.initState();
    _fetchBookingDetails();
  }

  Future<void> _fetchBookingDetails() async {
    final booking = await _controller.fetchBookingDetails(widget.bookingId);
    if (booking != null) {
      setState(() {
        address = booking.address;
        sessionDuration = booking.sessionDuration;
        totalPayment = booking.price.toString();
        paymentMethod = booking.paymentMethod;
        _dateController.text = booking.sessionDate;
        _timeController.text = booking.sessionTime;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load booking details')),
      );
    }
  }

  Future<void> _updateBookingDetails() async {
    final error = await _controller.updateBookingDetails(
      widget.bookingId,
      _dateController.text,
      _timeController.text,
    );
    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking updated successfully')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  Future<void> _cancelBooking() async {
    final bool confirm = await _showConfirmationDialog();
    if (confirm) {
      final error = await _controller.cancelBooking(widget.bookingId);
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking canceled successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
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
        title: const Text(
          'Edit Booking',
          style: TextStyle(color: Colors.white), // Set the text color to white
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Handle back navigation
          },
        ),
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
                        DateFormat('yyyy-MM-dd').format(pickedDate);
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
                  setState(() {
                    _timeController.text = pickedTime.format(context);
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
            const SizedBox(height: 10),
            Divider(color: Colors.grey[400]),
            const SizedBox(height: 10),
            Text("Total Payment: RM $totalPayment"),
            Text("Paid With: $paymentMethod"),
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
