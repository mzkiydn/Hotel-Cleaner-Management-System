import 'package:flutter/material.dart';
import 'package:hcms_sep/Provider/ReportController.dart';
import 'package:hcms_sep/baseScaffold.dart';

class ReportDetail extends StatefulWidget {
  final Map<String, String> report;

  const ReportDetail({super.key, required this.report});

  @override
  _ReportDetailState createState() => _ReportDetailState();
}

class _ReportDetailState extends State<ReportDetail> {
  final ReportController _reportController = ReportController();
  String sessionId = 'Loading...';
  String username = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchSessionDetails();
  }

  Future<void> _fetchSessionDetails() async {
    Map<String, String> details = await _reportController.getSessionDetails();
    setState(() {
      sessionId = details['sessionId']!;
      username = details['username']!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      customBarTitle: (widget.report['homestay'] ?? 'Report Details'),
      leftCustomBarAction: IconButton(
        icon: const Icon(Icons.arrow_left, color: Colors.white),
        onPressed: () {
          Navigator.pushNamed(context, '/report');
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Homestay: ${widget.report['homestay']}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Date: ${widget.report['date']}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            const Center(
              child: Icon(Icons.home, size: 100, color: Colors.deepPurple),
            ),
          ],
        ),
      ),
      currentIndex: 3,
      onItemTapped: (index) {
        // Handle bottom navigation actions if needed
      },
    );
  }
}
