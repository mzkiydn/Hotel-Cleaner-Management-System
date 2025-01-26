import 'package:flutter/material.dart';
import 'package:hcms_sep/Provider/ActivityController.dart';
import 'package:hcms_sep/Views/Activity/activityUpdateView.dart';

class ActivityListView extends StatefulWidget {
  final ActivityController controller;

  const ActivityListView({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  _ActivityListViewState createState() => _ActivityListViewState();
}

class _ActivityListViewState extends State<ActivityListView> {
  final ActivityController _activityController = ActivityController();
  String sessionId = 'Loading...';
  String username = 'Loading...';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadActivities();
    _fetchSessionDetails();
  }

  // session
  Future<void> _fetchSessionDetails() async {
    Map<String, String> details = await _activityController.getSessionDetails();
    setState(() {
      sessionId = details['sessionId']!;
      username = details['username']!;
    });
  }

  // Load all activities from Firestore
  Future<void> _loadActivities() async {
    try {
      print('Fetching activities...');

      // Ensure the activities list is cleared before refetching (optional)
      widget.controller.clearActivities();

      // Fetch the activities once
      await widget.controller.fetchAllActivities();

      print('Fetched activities: ${widget.controller.activities}');

      setState(() {
        _isLoading = false;  // Stop loading once data is fetched
      });
    } catch (e) {
      print('Error fetching activities: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error fetching activities: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple, // Custom AppBar color
        title: const Text(
          'Activity List',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto', // Custom font
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false, // Removes the back button
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : widget.controller.activities.isEmpty
          ? const Center(child: Text('No activities available'))
          : ListView.builder(
        itemCount: widget.controller.activities.length,
        itemBuilder: (context, index) {
          var activityData = widget.controller.activities[index];
          var houseName = activityData['houseName'] ?? 'Unknown House';
          var houseType = activityData['houseType'] ?? 'Unknown Type';

          var rooms = activityData['rooms'] as List<dynamic>? ?? [];
          var roomCount = rooms.length;
          var firstRoom = rooms.isNotEmpty ? rooms[0] : {};
          var completed = firstRoom['completed'] ?? 'Pending';

          return _buildActivityCard(
            context,
            roomCount,
            completed,
            houseName,
            houseType,
            index,
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[300],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black54,
        currentIndex: 1, // Set this dynamically if needed (for now it's fixed)
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

  Widget _buildActivityCard(
      BuildContext context,
      int roomCount,  // Display room count
      String? completed,  // 'completed' should be a string (ensure it's not null)
      String houseName,  // Add houseName here
      String houseType,  // Add houseType here
      int index,
      ) {
    // Ensure 'completed' is never null, default to 'Pending' if null
    completed = completed ?? 'Pending';  // Make sure it's a String

    // Ensure 'roomType' is never null, use defaults if null
    roomCount = roomCount >= 0 ? roomCount : 0;

    var homestayId = widget.controller.activities[index]['rooms'][0]['homestayId'];  // Get homestayId for this activity

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 5, // Adding shadow for the card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners for the card
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display House Name and Type at the top
            Text(
              '$houseName ($houseType)',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple, // Custom text color
              ),
            ),
            const SizedBox(height: 8),

            // Display number of rooms
            Text(
              'Number of Rooms: $roomCount',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 8),

            // Display completed status
            Text(
              'Status: $completed',
              style: TextStyle(
                color: completed == 'Completed' ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: () {
                if (completed == 'Pending') {  // Check if the activity is not completed
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActivityUpdateView(
                        controller: widget.controller,
                        homestayId: homestayId,  // Pass the actual homestayId here
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple, // Background color for the button
                foregroundColor: Colors.white, // Text color for the button
              ),
              child: const Text('Update Activity'),
            ),
          ],
        ),
      ),
    );
  }
}
