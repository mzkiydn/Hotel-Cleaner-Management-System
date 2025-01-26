import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hcms_sep/Domain/Booking.dart';
import 'package:hcms_sep/Provider/BookingController.dart';
import 'MyBookingPage.dart';

class BookingForm extends StatefulWidget {
  const BookingForm({super.key});

  @override
  _BookingFormState createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  String? _selectedHours;
  String? _selectedHomestayId; // Store the selected homestay ID

  final Map<String, double> fixedRates = {
    '2 hour': 80.0,
    '4 hours': 150.0,
    '6 hours': 210.0,
  };

  double? _totalPrice;

  final BookingController _bookingController = BookingController();

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.year}-${picked.month}-${picked.day}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  void _calculatePrice() {
    if (_selectedHours != null) {
      setState(() {
        _totalPrice = fixedRates[_selectedHours];
      });
    }
  }

  Future<void> _showHomestaysDialog() async {
    QuerySnapshot homestaysSnapshot =
        await FirebaseFirestore.instance.collection('Homestays').get();

    if (homestaysSnapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No homestays available')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Homestay'),
          content: SizedBox(
            height: 300,
            width: 300,
            child: ListView.builder(
              itemCount: homestaysSnapshot.docs.length,
              itemBuilder: (context, index) {
                final homestay = homestaysSnapshot.docs[index];
                final homestayData = homestay.data() as Map<String, dynamic>;
                return ListTile(
                  title: Text(homestayData['Address']),
                  onTap: () {
                    setState(() {
                      _addressController.text = homestayData['Address'];
                      _selectedHomestayId = homestay.id;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitBooking() async {
    if (_addressController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _timeController.text.isEmpty ||
        _selectedHours == null ||
        _selectedHomestayId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields!'),
        ),
      );
      return;
    }

    final booking = await _bookingController.createBooking(
      address: _addressController.text,
      sessionDate: _dateController.text,
      sessionTime: _timeController.text,
      sessionDuration: _selectedHours!,
      price: _totalPrice ?? 0.0,
      homestayID: '',
    );

    if (booking == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create booking')),
      );
      return;
    }

    final updatedBooking = Booking(
      sessionDate: booking.sessionDate,
      sessionTime: booking.sessionTime,
      sessionDuration: booking.sessionDuration,
      price: booking.price,
      userId: booking.userId,
      address: booking.address,
      homestayID: _selectedHomestayId!,
    );

    final error = await _bookingController.addBooking(updatedBooking);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking Submitted!')),
      );

      // Navigate to MyBookingPage after a successful booking
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyBookingPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Create Booking',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Address',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              readOnly: true,
              onTap: _showHomestaysDialog,
              decoration: const InputDecoration(
                hintText: 'Select a homestay address',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Session's date",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _dateController,
              readOnly: true,
              onTap: () => _selectDate(context),
              decoration: const InputDecoration(
                hintText: 'Enter Date',
                suffixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _timeController,
              readOnly: true,
              onTap: () => _selectTime(context),
              decoration: const InputDecoration(
                hintText: 'Select time',
                suffixIcon: Icon(Icons.access_time),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                border: OutlineInputBorder(),
              ),
              hint: const Text('How many hours'),
              items: fixedRates.keys
                  .map((e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedHours = value;
                });
                _calculatePrice();
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Payment:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  _totalPrice != null
                      ? 'RM ${_totalPrice!.toStringAsFixed(2)}'
                      : 'RM 0.00',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Proceed'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
