import 'package:hcms_sep/Domain/Report.dart';
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

  // Get bookings needing approval
  Future<List<Report>> getBookingsNeedingApproval() async {
    String userId = await _getUserId();

    if (userId.isEmpty) {
      print('No Booking Made Yet');
      return []; // Return an empty list
    }

    QuerySnapshot booking = await FirebaseFirestore.instance
        .collection('Booking')
        .where('bookingStatus', isEqualTo: 'Completed')
        .where('userId', isEqualTo: userId)
        .get();

    if (booking.docs.isEmpty) {
      print('No Booking Made Yet');
      return []; // Return an empty list
    }

    return _processBookings(booking);
  }

  // Get approved bookings
  Future<List<Report>> getApprovedBookings() async {
    String userId = await _getUserId();

    if (userId.isEmpty) {
      print('No userId');
      return [];
    }

    QuerySnapshot booking = await FirebaseFirestore.instance
        .collection('Booking')
        .where('bookingStatus', isEqualTo: 'Approved')
        .where('userId', isEqualTo: userId)
        .get();

    if (booking.docs.isEmpty) {
      print('No Booking ');
      return [];
    }

    return _processBookings(booking);
  }

  // Process the bookings to get homestay details and create report entries
  Future<List<Report>> _processBookings(QuerySnapshot booking) async {
    print('Processing bookings...'); // Debug statement
    List<Report> reportList = [];

    for (var doc in booking.docs) {
      String bookingId = doc.id; // This is the booking ID
      Map<String, dynamic> bookingData = doc.data() as Map<String, dynamic>;

      final homestayDetails = await getHomestay(bookingData['homestayID']);

        String activities = homestayDetails['activities'] != null
            ? homestayDetails['activities'].values
            .expand((activityList) => (activityList as List<dynamic>).cast<String>())
            .join(", ")
            : 'No activities listed';

        Report report = Report(
          userId: bookingData['userId'],
          cleanerId: bookingData['cleanerId'],
          homestayID: bookingData['homestayID'],
          bookingId: bookingId,
          sessionDate: bookingData['sessionDate'],
          price: (bookingData['price'] as num).toDouble(), // Convert price to double
          activities: activities,
          rooms: homestayDetails['Rooms']?.length ?? 0, // Default to 0 if rooms is null
          description: 'Session Date: ${bookingData['sessionDate']}\n'
              'Price: \$${bookingData['price']}\n'
              'Activities: $activities\n'
              'Rooms: ${homestayDetails['Rooms']?.length ?? 0} Rooms\n'
              'User ID: ${bookingData['userId']}\n'
              'Cleaner ID: ${bookingData['cleanerId']}\n'
              'Booking ID: ${bookingData['bookingId']}\n'
              'Homestay ID: ${bookingData['homestayID']}',
        );

        reportList.add(report);
        await createReport(report);
    }

    print('Total reports processed: ${reportList.length}'); // Debug statement
    return reportList;
  }

  // Get homestay details by homestayId
  Future<Map<String, dynamic>> getHomestay(String homestayId) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('Homestays')
        .doc(homestayId)
        .get();

    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      List<dynamic> rooms = data['Rooms'] ?? [];

      Map<String, List<String>> activitiesByRoom = {};
      for (var room in rooms) {
        String roomType = room['roomType'];
        List<String> activities = List<String>.from(room['activities']);
        activitiesByRoom[roomType] = activities;
      }
      return {
        "House Name": data['House Name'] ?? 'Unknown Homestay',
        "House Type": data['House Type'] ?? 'Unknown Type',
        "activities": activitiesByRoom,
        "Rooms": rooms,
      };

    } else {
      return {}; // Return an empty map if homestay not found
    }
  }

  // Get homestay details by homestayId
  Future<Map<String, dynamic>> getBooking(String bookingId) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('Booking')
        .doc(bookingId)
        .get();

    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      return {
        "bookingStatus": data['bookingStatus'] ?? 'Unknown status',
      };
    } else {
      return {}; // Return an empty map if homestay not found
    }
  }

  // Create a new report entry in Firestore
  Future<void> createReport(Report report) async {
    try {
      // Check if a report for this booking already exists
      QuerySnapshot existingReport = await FirebaseFirestore.instance
          .collection('Report')
          .where('bookingId', isEqualTo: report.bookingId)
          .get();

      if (existingReport.docs.isEmpty) {
        // No existing report found, so create a new one
        await FirebaseFirestore.instance.collection('Report').add(report.toMap());
        print('Report created successfully for bookingId: ${report.bookingId}');
      } else {
        print('Report already exists for bookingId: ${report.bookingId}');
      }
    } catch (e) {
      print('Error creating report: $e');
    }
  }

  // Update booking status to approved
  Future<void> updateBookingStatusToApproved(String bookingId) async {
    try {
      await FirebaseFirestore.instance.collection('Booking').doc(bookingId).update({
        'bookingStatus': 'Approved',
      });
      print('Booking status updated to Approved');
    } catch (e) {
      print('Error updating booking status: $e');
    }
  }
}

