import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportController {
  Future<Map<String, String>> getSessionDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId == null) {
      return {'username': 'Unknown', 'sessionId': 'Unknown'};
    }

    // Fetch username from Firestore using userId
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userDoc.exists) {
        String username = userDoc.get('username') ?? 'Unknown';
        // Optionally fetch session details here if available in Firestore.
        return {'username': username, 'sessionId': userId}; // Returning userId as sessionId
      } else {
        return {'username': 'Unknown', 'sessionId': 'Unknown'};
      }
    } catch (e) {
      print('Error fetching user details: $e');
      return {'username': 'Unknown', 'sessionId': 'Unknown'};
    }
  }

  List<Map<String, String>> getReports() {
    return [
      {"homestay": "Vintage House", "date": "10/12/2024"},
      {"homestay": "SunShine House", "date": "07/11/2024"},
      {"homestay": "Sky Hive", "date": "05/11/2024"},
    ];
  }
}

