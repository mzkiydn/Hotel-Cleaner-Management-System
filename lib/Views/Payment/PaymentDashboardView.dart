import 'package:flutter/material.dart';
import 'package:hcms_sep/Views/Payment/PaymentScreen.dart';


void main() {
  runApp(const CheckoutBooking());
}

class CheckoutBooking extends StatelessWidget {
  const CheckoutBooking({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CreateBookingScreen(),
    );
  }
}

class CreateBookingScreen extends StatefulWidget {
  const CreateBookingScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CreateBookingScreenState createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  final TextEditingController _addressController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _selectedHours = 1;
  int _selectedCleaners = 1;
  final int _ratePerHourPerCleaner = 30;

  int get totalPayment => _selectedHours * _selectedCleaners * _ratePerHourPerCleaner;

String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Booking'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Enter Date',
                    border: const OutlineInputBorder(),
                    hintText: _selectedDate == null
                        ? 'Select a date'
                        : formatDate(_selectedDate!),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickTime,
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Select Time',
                    border: const OutlineInputBorder(),
                    hintText: _selectedTime == null
                        ? 'Select a time'
                        : _selectedTime!.format(context),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedHours,
              decoration: const InputDecoration(
                labelText: 'How many hours?',
                border: OutlineInputBorder(),
              ),
              items: List.generate(10, (index) => index + 1)
                  .map((hours) => DropdownMenuItem(
                        value: hours,
                        child: Text('$hours hour(s)'),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedHours = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedCleaners,
              decoration: const InputDecoration(
                labelText: 'How many cleaner(s)?',
                border: OutlineInputBorder(),
              ),
              items: List.generate(5, (index) => index + 1)
                  .map((cleaners) => DropdownMenuItem(
                        value: cleaners,
                        child: Text('$cleaners cleaner(s)'),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCleaners = value!;
                });
              },
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Payment:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'RM $totalPayment.00',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Handle proceed action
                if (_addressController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter an address.')),
                  );
                  return;
                }
                if (_selectedDate == null || _selectedTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select date and time.')),
                  );
                  return;
                }
                // Proceed with the booking
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking successful!')),
                );

                // Simulated payment URL from your backend or payment gateway
            String paymentUrl = "https://example.com/payment";

              Navigator.push(
                context,
                MaterialPageRoute(
                builder: (context) => PaymentScreen(paymentUrl: paymentUrl),
                ),
                ).then((result) {
                // Handle the result of the payment
                if (result == 'success') {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment Successful!')),
                    );
                } else if (result == 'failed') {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment Failed!')),
                    );
                }
                });

              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Center(
                child: Text('Proceed'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
