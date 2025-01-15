import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hcms_sep/Domain/Booking.dart';

class BookingController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add a new booking to Firestore
  Future<String?> addBooking(Booking booking) async {
    try {
      await _firestore.collection('Booking').add(booking.toMap());
      return null; // Booking added successfully
    } catch (e) {
      return 'Error adding booking: $e';
    }
  }

  // Create a Booking object
  Future<Booking?> createBooking({
    required String address,
    required String sessionDate,
    required String sessionTime,
    required String sessionDuration,
    required double price,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return null; // User not logged in
      }
      return Booking(
        sessionDate: sessionDate,
        sessionTime: sessionTime,
        sessionDuration: sessionDuration,
        price: price,
        userId: userId,
        address: address,
      );
    } catch (e) {
      return null; // Failed to create booking
    }
  }

  Stream<QuerySnapshot> getBookings() {
    return _firestore.collection('Booking').snapshots();
  }

  Future<DocumentSnapshot> getHomestayData(String homestayID) {
    return _firestore.collection('Homestays').doc(homestayID).get();
  }

  Future<String?> fetchCleanerName(String? cleanerId) async {
    if (cleanerId == null || cleanerId.isEmpty) {
      return null;
    }

    final userDoc = await _firestore.collection('User').doc(cleanerId).get();
    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      if (userData['Role'] == 'Cleaner') {
        return userData['Name'];
      }
    }
    return null;
  }

  Future<Booking?> fetchBookingDetails(String bookingId) async {
    try {
      final bookingSnapshot =
          await _firestore.collection('Booking').doc(bookingId).get();
      if (bookingSnapshot.exists) {
        return Booking.fromMap(bookingSnapshot.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error fetching booking details: $e');
    }
    return null;
  }

  Future<String?> updateBookingDetails(
      String bookingId, String date, String time) async {
    try {
      await _firestore.collection('Booking').doc(bookingId).update({
        'sessionDate': date,
        'sessionTime': time,
      });
      return null; // Success
    } catch (e) {
      return 'Error updating booking: $e';
    }
  }

  Future<String?> cancelBooking(String bookingId) async {
    try {
      await _firestore.collection('Booking').doc(bookingId).update({
        'bookingStatus': 'Cancelled',
      });
      return null; // Success
    } catch (e) {
      return 'Error canceling booking: $e';
    }
  }
}
