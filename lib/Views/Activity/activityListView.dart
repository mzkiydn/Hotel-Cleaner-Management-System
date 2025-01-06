import 'package:flutter/material.dart';

class ActivityListView extends StatelessWidget {
  const ActivityListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity')),
      body: ListView(
        children: [
          _buildActivityCard(
            context,
            'Sky Hive',
            'Vintage Enterprise',
            'Zakiyuddin',
            '05/11/2024',
            'Completed',
          ),
          _buildActivityCard(
            context,
            'Vintage House',
            'Vintage Enterprise',
            'Zakiyuddin',
            '10/12/2024',
            'In Progress',
            reschedule: true,
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildActivityCard(
    BuildContext context,
    String name,
    String owner,
    String cleaner,
    String date,
    String status, {
    bool reschedule = false,
  }) {
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
            Text('Status: $status', style: TextStyle(color: status == 'Completed' ? Colors.green : Colors.orange)),
            if (reschedule)
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/reschedule');
                  },
                  child: const Text('Reschedule'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Activities'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}
