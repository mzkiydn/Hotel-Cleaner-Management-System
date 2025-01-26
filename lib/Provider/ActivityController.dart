import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityController {
  // userId
  Future<String> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    return userId ?? ''; // Return empty string if userId is not found
  }

  // session
  Future<Map<String, String>> getSessionDetails() async {
    String userId = await _getUserId();

    if (userId.isEmpty) {
      return {'username': 'Unknown', 'sessionId': 'Unknown', 'role': 'Unknown'};
    }

    // Fetch username and role from Firestore using userId
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('User').doc(userId).get();

      if (userDoc.exists) {
        String username = userDoc.get('Username') ?? 'Unknown';
        String role = userDoc.get('Role') ?? 'Unknown';

        return {'username': username, 'sessionId': userId, 'role': role}; // Returning userId and role
      } else {
        return {'username': 'Unknown', 'sessionId': 'Unknown', 'role': 'Unknown'};
      }
    } catch (e) {
      print('Error fetching user details: $e');
      return {'username': 'Unknown', 'sessionId': 'Unknown', 'role': 'Unknown'};
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> activities = [];
  int _idCounter = 0; // Counter for generating unique integer IDs

  /// Clear the activities list
  void clearActivities() {
    activities.clear();
    _idCounter = 0; // Reset the ID counter
  }

  /// Fetch all activities from all homestays
  Future<void> fetchAllActivities() async {
    final sessionDetails = await getSessionDetails();
    String userRole = sessionDetails['role'] ?? 'Unknown';

    if (userRole != 'Cleaner') {
      print('Unauthorized access: Only Cleaners can fetch activities');
      return;
    }

    try {
      final snapshot = await _firestore.collection('Homestays').get();

      activities = snapshot.docs.map((doc) {
        final data = doc.data();
        final rooms = data['Rooms'] as List<dynamic>? ?? [];

        final formattedRooms = rooms.map((room) {
          final activitiesList = room['activities'] as List<dynamic>? ?? [];
          final roomType = room['roomType'] ?? 'Unknown Room';
          final completedStatus = room['completed'] ?? 'Pending';

          return {
            'roomType': roomType,
            'activities': activitiesList.map((activity) {
              return {
                'id': activity['id'] is int
                    ? activity['id']
                    : int.tryParse(activity['id'].toString()) ?? 0, // Ensure ID is an integer
                'name': activity['name'],
                'completed': activity['completed'] ?? 'Pending',
              };
            }).toList(),
            'completed': completedStatus == 'Completed' ? 'Completed' : 'Pending',
            'homestayId': doc.id,
          };
        }).toList();

        return {
          'houseName': data['House Name'] ?? 'Unknown House',
          'houseType': data['House Type'] ?? 'Unknown Type',
          'rooms': formattedRooms,
          'status': data['Status'] ?? 'Unknown Status',
        };
      }).toList();

      print('Fetched all activities: $activities');
    } catch (e) {
      print('Error fetching all activities: $e');
      throw e;
    }
  }

  /// Fetch activities for a specific homestay
  Future<void> fetchActivities(String homestayId) async {
    final sessionDetails = await getSessionDetails();
    String userRole = sessionDetails['role'] ?? 'Unknown';

    if (userRole != 'Cleaner') {
      print('Unauthorized access: Only Cleaners can fetch activities');
      return;
    }

    if (homestayId.isEmpty) {
      print('Error: homestayId is empty');
      return;
    }

    try {
      print('Fetching activities for homestayId: $homestayId');
      final snapshot = await _firestore.collection('Homestays').doc(homestayId).get();

      if (snapshot.exists) {
        final data = snapshot.data();
        print('Fetched data: $data');

        final roomsData = data?['Rooms'] as List<dynamic>? ?? [];
        print('Rooms data: $roomsData');

        activities.clear(); // Clear previous activities

        for (var room in roomsData) {
          final roomType = room['roomType'] ?? 'Unknown Room';
          final roomActivities = room['activities'] as List<dynamic>? ?? [];
          final completed = room['completed'] ?? 'Pending';

          for (var rawActivity in roomActivities) {
            if (rawActivity is Map<String, dynamic> &&
                rawActivity.containsKey('name') &&
                rawActivity['name'] is String) {
              activities.add({
                'roomType': roomType,
                'activity': rawActivity['name'],
                'completed': completed,
                'activityId': rawActivity['id'] is int
                    ? rawActivity['id']
                    : int.tryParse(rawActivity['id'].toString()) ?? _idCounter++,
              });
            } else {
              print('Invalid activity format: $rawActivity');
            }
          }
        }

        if (activities.isEmpty) {
          print('No activities found for this homestay.');
        } else {
          print('Fetched activities: $activities');
        }
      } else {
        print('No homestay found with ID: $homestayId');
      }
    } catch (e) {
      print('Error fetching activities: $e');
    }
  }

  /// Toggle activity completion status
  void toggleActivityCompletion(int activityId, bool isCompleted) {
    final activity = activities.firstWhere(
          (a) => a['activityId'] == activityId,
      orElse: () => {},
    );

    if (activity.isNotEmpty) {
      activity['completed'] = isCompleted ? 'Completed' : 'Pending';
    } else {
      print('Activity with ID $activityId not found.');
    }
  }

  /// Mark all activities as completed
  void completeAllActivities() {
    for (var activity in activities) {
      activity['completed'] = 'Completed';
    }
  }

  /// Update room completion based on activities
  void updateRoomCompletion(List<Map<String, dynamic>> rooms) {
    for (var room in rooms) {
      final roomActivities = room['activities'] as List<Map<String, dynamic>>? ?? [];
      // Check if all activities are completed
      final allCompleted = roomActivities.every((activity) => activity['completed'] == 'Completed');
      room['completed'] = allCompleted ? 'Completed' : 'Pending';
    }
  }

  /// Save updated activities to Firestore
  Future<void> saveActivities(String homestayId) async {
    final sessionDetails = await getSessionDetails();
    String userRole = sessionDetails['role'] ?? 'Unknown';

    if (userRole != 'Cleaner') {
      print('Unauthorized access: Only Cleaners can save activities');
      return;
    }

    try {
      final homestayRef = _firestore.collection('Homestays').doc(homestayId);

      final snapshot = await homestayRef.get();
      if (!snapshot.exists) {
        throw Exception('Homestay document does not exist');
      }

      final data = snapshot.data();
      final rooms = data?['Rooms'] as List<dynamic>? ?? [];

      for (var room in rooms) {
        final roomActivities = room['activities'] as List<dynamic>? ?? [];

        // Update activity statuses
        for (var activity in roomActivities) {
          final matchingActivity = activities.firstWhere(
                (a) => a['activityId'] == activity['id'],
            orElse: () => <String, dynamic>{},
          );

          if (matchingActivity.isNotEmpty) {
            activity['completed'] = matchingActivity['completed'];
          }
        }

        // Update room completion status
        final allActivitiesCompleted =
        roomActivities.every((activity) => activity['completed'] == 'Completed');
        room['completed'] = allActivitiesCompleted ? 'Completed' : 'Pending';
      }

      // Save updated rooms to Firestore
      await homestayRef.update({'Rooms': rooms});
      print('Activities and room statuses updated successfully');
    } catch (e) {
      print('Error saving activities: $e');
      throw Exception('Error saving activities: $e');
    }
  }
}
