import 'package:flutter/material.dart';

class BookingListView extends StatelessWidget {
  const BookingListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookings')),
      body: ListView(
        children: [
          _buildBookingCard(context, 'Sky Hive', 'Vintage Enterprise', 'Zakiyuddin', '05/11/2024'),
          _buildBookingCard(context, 'Vintage House', 'Vintage Enterprise', 'Zakiyuddin', '10/12/2024'),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBookingCard(
    BuildContext context,
    String name,
    String owner,
    String cleaner,
    String date,
  ) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Owner: $owner'),
            Text('Cleaner: $cleaner'),
            Text('Date: $date'),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Bookings'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}
