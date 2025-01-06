import 'package:flutter/material.dart';
import 'package:hcms_sep/Provider/ReportController.dart';
import 'package:hcms_sep/baseScaffold.dart';
import 'reportDetail.dart';

class ReportView extends StatefulWidget {
  @override
  _ReportViewState createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> {
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
    final reports = _reportController.getReports();

    return BaseScaffold(
      customBarTitle: 'Username: $username',
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(reports[index]["homestay"]!),
            trailing: Text(reports[index]["date"]!),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReportDetail(report: reports[index]),
                ),
              );
            },
          );
        },
        separatorBuilder: (_, __) => const Divider(),
      ),
      currentIndex: 3,
      onItemTapped: (index) {
        // Handle bottom navigation actions if needed
      },
    );
  }
}
