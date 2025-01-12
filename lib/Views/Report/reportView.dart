import 'package:flutter/material.dart';
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
  List<Map<String, String>> reportsNeedingApproval = [];
  List<Map<String, String>> approvedReports = [];

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
    List<Map<String, String>> needingApproval = await _reportController.getBookingsNeedingApproval();
    List<Map<String, String>> approved = await _reportController.getApprovedBookings();
    setState(() {
      reportsNeedingApproval = needingApproval;
      approvedReports = approved;
    });
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

  Widget _buildReportList(List<Map<String, String>> reports) {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(reports[index]["houseName"]!),
          trailing: Text(reports[index]["sessionDate"]!),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/reportDetail', // Define this route in the Routes class
              arguments: reports[index],
            );

          },
        );
      },
      separatorBuilder: (_, __) => const Divider(),
    );
  }

}
