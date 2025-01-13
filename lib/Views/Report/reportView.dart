import 'package:flutter/material.dart';
import 'package:hcms_sep/Domain/Report.dart';
import 'package:hcms_sep/Provider/ReportController.dart';
import 'package:hcms_sep/baseScaffold.dart';

class ReportView extends StatefulWidget {
  @override
  _ReportViewState createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> {
  final ReportController _reportController = ReportController();
  String sessionId = 'Loading...';
  String username = 'Loading...';
  List<Report> reportsNeedingApproval = [];
  List<Report> approvedReports = [];

  @override
  void initState() {
    super.initState();
    _fetchSessionDetails();
    _fetchReports();
  }

  Future<void> _fetchSessionDetails() async {
    Map<String, String> details = await _reportController.getSessionDetails();
    setState(() {
      sessionId = details['sessionId']!;
      username = details['username']!;
    });
  }

  Future<void> _fetchReports() async {
    try {
      print('Fetching reports needing approval...'); // Debug statement
      List<Report> needingApproval = await _reportController.getBookingsNeedingApproval();
      print('Reports needing approval: ${needingApproval.length}'); // Debug statement

      print('Fetching approved reports...'); // Debug statement
      List<Report> approved = await _reportController.getApprovedBookings();
      print('Approved reports: ${approved.length}'); // Debug statement

      setState(() {
        reportsNeedingApproval = needingApproval;
        approvedReports = approved;
      });
    } catch (e) {
      print('Error fetching reports: $e'); // Debug statement
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      customBarTitle: 'Username: $username',
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSectionTitle("Needing Approval"),
            _buildReportList(reportsNeedingApproval),

            _buildSectionTitle("Approved"),
            _buildReportList(approvedReports),
          ],
        ),
      ),
      currentIndex: 3,
      onItemTapped: (index) {
        // Handle bottom navigation actions if needed
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildReportList(List<Report> reports) {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];

        return FutureBuilder<Map<String, dynamic>>(
          future: _reportController.getHomestay(report.homestayId), // Use the controller to fetch homestay details
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              print('Loading homestay details for report...'); // Debug statement
              return ListTile(
                title: Text('Loading...'),
                trailing: Text(report.sessionDate),
              );
            } else if (snapshot.hasError) {
              print('Error loading homestay details: ${snapshot.error}'); // Debug statement
              return ListTile(
                title: Text('Error loading homestay name'),
                trailing: Text(report.sessionDate),
              );
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              String homestayName = snapshot.data!['houseName'] ?? 'Unknown Homestay';
              return ListTile(
                title: Text(homestayName),
                subtitle: Text(report.description),
                trailing: Text(report.sessionDate),
              );
            } else {
              return ListTile(
                title: Text('No Homestay Found'),
                trailing: Text(report.sessionDate),
              );
            }
          },
        );
      },
      separatorBuilder: (context, index) {
        return Divider();
      },
    );
  }
}
