import 'package:flutter/material.dart';
import 'package:hcms_sep/Provider/ActivityController.dart';

class ActivityUpdateView extends StatefulWidget {
  final String homestayId;
  final ActivityController controller;

  const ActivityUpdateView({
    super.key,
    required this.homestayId,
    required this.controller,
  });

  @override
  _ActivityUpdateViewState createState() => _ActivityUpdateViewState();
}

class _ActivityUpdateViewState extends State<ActivityUpdateView> {
  final ActivityController _activityController = ActivityController();
  String sessionId = 'Loading...';
  String username = 'Loading...';
  bool _isLoading = true;
  String? _errorMessage;
  late Map<String, List<Map<String, dynamic>>> groupedActivities;
  bool _isAllChecked = false; // Flag to track if all activities are completed

  @override
  void initState() {
    super.initState();
    _loadActivities();
    _fetchSessionDetails();
  }

  Future<void> _fetchSessionDetails() async {
    Map<String, String> details = await _activityController.getSessionDetails();
    setState(() {
      sessionId = details['sessionId']!;
      username = details['username']!;
    });
  }

  // Load activities from Firestore
  Future<void> _loadActivities() async {
    try {
      await widget.controller.fetchActivities(widget.homestayId);
      _groupActivities();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error fetching activities: $e';
      });
    }
  }

  // Group activities by roomType
  void _groupActivities() {
    groupedActivities = {};
    for (var activity in widget.controller.activities) {
      final roomType = activity['roomType'] ?? 'Unknown Room';
      if (!groupedActivities.containsKey(roomType)) {
        groupedActivities[roomType] = [];
      }
      groupedActivities[roomType]!.add(activity);
    }
    _checkIfAllActivitiesCompleted(); // Check if all activities are marked as completed
  }

  // Handle activity completion toggle
  void _toggleActivityCompletion(Map<String, dynamic> activity, bool value) {
    setState(() {
      activity['completed'] = value ? 'Completed' : 'Pending';
    });
    _checkIfAllActivitiesCompleted(); // Recheck completion status
  }

  // Check if all activities are marked as completed
  void _checkIfAllActivitiesCompleted() {
    _isAllChecked = widget.controller.activities.every((activity) => activity['completed'] == 'Completed');
  }

  // Mark all activities as completed and save them to Firestore
  Future<void> _completeActivities() async {
    try {
      // Mark all activities as completed
      for (var activity in widget.controller.activities) {
        activity['completed'] = 'Completed';
      }

      // Save updated activities to Firestore
      await widget.controller.saveActivities(widget.homestayId);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All activities marked as completed')),
      );

      // Navigate back to the previous screen (ActivityListView)
      Navigator.pop(context);
    } catch (e) {
      // Show error message if something goes wrong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error completing activities: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple, // Same as BookingListView
        title: const Text('Activity Update', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        automaticallyImplyLeading: false, // Removes back button
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : ListView(
        children: groupedActivities.keys.map((roomType) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  roomType,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Column(
                children: groupedActivities[roomType]!
                    .map((activity) {
                  return CheckboxListTile(
                    title: Text(activity['activity'] ?? 'Unknown Activity'),
                    value: activity['completed'] == 'Completed',
                    onChanged: (value) {
                      _toggleActivityCompletion(activity, value ?? false);
                    },
                  );
                }).toList(),
              ),
            ],
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isAllChecked ? _completeActivities : null, // Enable only if all activities are checked
        child: const Icon(Icons.check),
        backgroundColor: _isAllChecked ? Colors.green : Colors.grey, // Change color based on state
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[300],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black54,
        currentIndex: 1, // Set this dynamically if needed
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/bookinglistview');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/activity');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/report');
          } else if (index == 4) {
            Navigator.pushNamed(context, '/profile');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
        ],
      ),
    );
  }
}
