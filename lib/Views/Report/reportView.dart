import 'package:flutter/material.dart';
import 'package:hcms_sep/baseScaffold.dart';
import 'reportDetail.dart';

class ReportView extends StatelessWidget {
  final List<Map<String, String>> reports = [
    {"homestay": "Vintage House", "date": "10/12/2024"},
    {"homestay": "SunShine House", "date": "07/11/2024"},
    {"homestay": "Sky Hive", "date": "05/11/2024"},
  ];

   ReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
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
                  builder: (context) =>
                      ReportDetail(report: reports[index]),
                ),
              );
            },
          );
        },
        separatorBuilder: (_, __) => const Divider(),
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
