import 'package:flutter/material.dart';
import 'package:hcms_sep/Provider/ReportController.dart';
import 'package:hcms_sep/Views/Report/reportPreview.dart';
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
  Map<String, dynamic> homestayDetails = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSessionDetails();
    _fetchHomestayDetails();
  }

  // session
  Future<void> _fetchSessionDetails() async {
    Map<String, String> details = await _reportController.getSessionDetails();
    setState(() {
      sessionId = details['sessionId']!;
      username = details['username']!;
    });
  }

  // homestay details
  Future<void> _fetchHomestayDetails() async {
    setState(() {
      isLoading = true;
    });

    // Fetch homestay details using the report's 'houseName' or 'bookingId'
    Map<String, dynamic> homestay = await _reportController.getHomestay(widget.report['bookingId']!);
    setState(() {
      homestayDetails = homestay;
      isLoading = false;
    });
  }

  // change status
  Future<void> _approveReport() async {
    await _reportController.updateBookingStatusToApproved(widget.report['bookingId']!);
    Navigator.pop(context);
  }

  // Navigate to Print Preview screen
  void _printReport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportPreview(report: widget.report),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return BaseScaffold(
      customBarTitle: widget.report['houseName'] ?? 'Report Details',
      leftCustomBarAction: IconButton(
        icon: const Icon(Icons.arrow_left, color: Colors.white),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // House name and session date
            Text('Homestay: ${widget.report['houseName']}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Date: ${widget.report['sessionDate']}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Status: ${widget.report['status']}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),

            // House description
            Text('House Description:', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Number of rooms: ${homestayDetails['rooms']?.length ?? 0}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),

            // Displaying room details and activities
            Text('Room Details and Activities:', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: homestayDetails['rooms']?.length ?? 0,
              itemBuilder: (context, index) {
                var room = homestayDetails['rooms'][index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Room Type: ${room['roomType']}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('Activities: ${room['activities'].join(', ')}', style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),

            // Approve button
            if (widget.report['status'] == 'Completed')
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: ElevatedButton(
                  onPressed: _approveReport,
                  child: const Text('Approve Report'),
                ),
              ),

            // Print button for approved reports
            if (widget.report['status'] == 'Approved')
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: ElevatedButton(
                  onPressed: _printReport,
                  child: const Text('Print Report'),
                ),
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
