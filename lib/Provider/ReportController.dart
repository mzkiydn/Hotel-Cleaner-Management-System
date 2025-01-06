import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportController {
  Future<Map<String, String>> getSessionDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId == null) {
      return {'username': 'Unknown'};
    }

    // Fetch username from Firestore
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    String username = userDoc.exists ? userDoc.get('username') : 'Unknown';

    return {'username': username};
  }

  List<Map<String, String>> getReports() {
    return [
      {"homestay": "Vintage House", "date": "10/12/2024"},
      {"homestay": "SunShine House", "date": "07/11/2024"},
      {"homestay": "Sky Hive", "date": "05/11/2024"},
    ];
  }
}
