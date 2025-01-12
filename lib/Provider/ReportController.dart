import 'package:hcms_sep/Domain/Booking.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportController {
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

  // bookings with status "Completed"
  Future<List<Map<String, String>>> getBookingsNeedingApproval() async {
    String userId = await _getUserId();

    if (userId.isEmpty) {
      return []; // Return empty list if userId is not found
    }

    QuerySnapshot booking = await FirebaseFirestore.instance
        .collection('bookings')
        .where('bookingStatus', isEqualTo: 'Completed')
        .where('userId', isEqualTo: userId)
        .get();

    return _processBookings(booking);
  }

  //  bookings with status "Approved"
  Future<List<Map<String, String>>> getApprovedBookings() async {
    String userId = await _getUserId();

    if (userId.isEmpty) {
      return []; // Return empty list if userId is not found
    }

    QuerySnapshot booking = await FirebaseFirestore.instance
        .collection('bookings')
        .where('bookingStatus', isEqualTo: 'Approved')
        .where('userId', isEqualTo: userId)
        .get();

    return _processBookings(booking);
  }

  //  bookings and homestay details
  Future<List<Map<String, String>>> _processBookings(QuerySnapshot booking) async {
    List<Map<String, String>> homestayDetailsList = [];

    for (var doc in booking.docs) {
      Map<String, dynamic> bookingData = doc.data() as Map<String, dynamic>;
      final homestayDetails = await getHomestay(bookingData['homestayId']);

      if (homestayDetails.isNotEmpty) {
        String activities = homestayDetails['activities'].values
            .expand((activityList) => activityList)
            .join(", ");

        homestayDetailsList.add({
          "bookingId": bookingData['bookingId'],
          "houseName": homestayDetails['houseName'],
          "sessionDate": bookingData['sessionDate'],
          "activities": activities,
        });
      }
    }
    return homestayDetailsList;
  }

  // homestay details by homestayId
  Future<Map<String, dynamic>> getHomestay(String homestayId) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('homestays')
        .doc(homestayId)
        .get();

    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      List<dynamic> rooms = data['rooms'] ?? [];

      Map<String, List<String>> activitiesByRoom = {};
      for (var room in rooms) {
        String roomType = room['roomType'];
        List<String> activities = List<String>.from(room['activities']);
        activitiesByRoom[roomType] = activities;
      }

      return {
        "houseName": data['houseName'],
        "activities": activitiesByRoom,
      };
    } else {
      return {}; // Return an empty map if homestay not found
    }
  }

  // Update booking status
  Future<void> updateBookingStatusToApproved(String bookingId) async {
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
        'bookingStatus': 'Approved',
      });
      print('Booking status updated to Approved');
    } catch (e) {
      print('Error updating booking status: $e');
    }
  }
}
