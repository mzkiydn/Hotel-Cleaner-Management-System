import 'package:flutter/material.dart';
import 'package:hcms_sep/baseScaffold.dart';

class ReportDetail extends StatelessWidget {
  final Map<String, String> report;

  const ReportDetail({Key? key, required this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      customBarTitle: (report['homestay'] ?? 'Report Details'),
      leftCustomBarAction: IconButton(
        icon: Icon(Icons.arrow_left, color: Colors.white),
        onPressed: () {
          Navigator.pushNamed(context, '/report');
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Homestay: ${report['homestay']}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Date: ${report['date']}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            const Center(
              child: Icon(Icons.home, size: 100, color: Colors.deepPurple),
            ),
          ],
        ),
      ),
      //selectedNavbar
      currentIndex: 3,
      // Set this based on the desired initial tab
      onItemTapped: (index) {
        // Handle bottom navigation actions if needed
      },
    );
  }
}
