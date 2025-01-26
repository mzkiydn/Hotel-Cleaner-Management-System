import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomestayRegistrationController {
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
      return {'username': 'Unknown', 'sessionId': 'Unknown'};
    }

    // Fetch username from Firestore using userId
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('User').doc(userId).get();

      if (userDoc.exists) {
        String username = userDoc.get('Username') ?? 'Unknown';
        return {'username': username, 'sessionId': userId}; // Returning userId as sessionId
      } else {
        return {'username': 'Unknown', 'sessionId': 'Unknown'};
      }
    } catch (e) {
      print('Error fetching user details: $e');
      return {'username': 'Unknown', 'sessionId': 'Unknown'};
    }
  }
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers for text input fields
  final houseNameController = TextEditingController();
  final houseAddressController = TextEditingController();
  final houseTypeController = TextEditingController();

  // Dropdown values
  String selectedHouseType = 'Apartment'; // Default value for house type
  List<String> houseTypes = ['Apartment', 'Villa', 'Cottage']; // Available house types
  List<String> roomTypes = ['Living Room', 'Bedroom', 'Kitchen']; // Available room types

  // List to store cleaning activities
  List<String> cleaningActivities = [
    'Dusting',
    'Vacuuming',
    'Mopping',
    'Window Cleaning',
    'General Tidying',
  ];

  // For storing room types and activities
  List<Map<String, dynamic>> rooms = [];

  // Activity counter for generating unique integer IDs
  int _activityCounter = 0;

  // Method to clear form fields
  void clearAll() {
    houseNameController.clear();
    houseAddressController.clear();
    houseTypeController.clear();
    rooms.clear();
    _activityCounter = 0; // Reset the activity counter
  }

  // Method to validate the registration form
  bool validateRegistration() {
    return houseNameController.text.isNotEmpty && rooms.isNotEmpty;
  }

  // Add room to the list
  void addRoom(String roomType, List<String> activities) {
    rooms.add({
      'roomType': roomType,
      'activities': activities.map((activity) {
        return {
          'id': _activityCounter++, // Assign unique integer ID
          'name': activity,
        };
      }).toList(),
      'completed': 'Pending',
    });
  }

  // Get current rooms list
  List<Map<String, dynamic>> getRooms() {
    return rooms;
  }

  // Method to update a room
  void updateRoom(int index, String roomType, List<String> activities) {
    final existingActivities = rooms[index]['activities'] ?? [];
    rooms[index] = {
      'roomType': roomType,
      'activities': activities.map((activity) {
        final existingActivity = existingActivities.firstWhere(
              (a) => a['name'] == activity,
          orElse: () => null,
        );
        return {
          'id': existingActivity?['id'] ?? _activityCounter++, // Retain existing ID or assign new one
          'name': activity,
        };
      }).toList(),
      'completed': 'Pending',
    };
  }

  // Register homestay in Firestore
  Future<String?> registerHomestay({
    required String houseName,
    required String houseType,
    required String houseAddress, // Add houseAddress parameter
    required List<Map<String, dynamic>> rooms,
  }) async {
    try {
      // Retrieve the user ID
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('userId') ?? '';

      if (userId.isEmpty) {
        return 'User ID is missing. Please log in again.';
      }

      // Add homestay details to Firestore
      await _firestore.collection('Homestays').add({
        'UserId': userId, // Include the user ID
        'House Name': houseName,
        'House Type': houseType,
        'Address': houseAddress, // Add houseAddress to Firestore
        'Rooms': rooms.map((room) {
          return {
            'roomType': room['roomType'],
            'completed': room['completed'],
            'activities': (room['activities'] as List).map((activity) {
              return {
                'id': activity['id'] is int
                    ? activity['id']
                    : int.tryParse(activity['id'].toString()) ?? 0,
                'name': activity['name'],
              };
            }).toList(),
          };
        }).toList(),
        'Status': 'Available',
        'Timestamp': FieldValue.serverTimestamp(),
      });

      return null; // Registration successful
    } catch (e) {
      return 'An error occurred: $e';
    }
  }
}
