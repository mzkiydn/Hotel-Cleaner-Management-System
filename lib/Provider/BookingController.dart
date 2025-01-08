import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hcms_sep/Domain/Booking.dart';

class BookingController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add a new booking to Firestore
  Future<String?> addBooking(Booking booking) async {
    try {
      // Get the current user's ID
      String userId = _auth.currentUser?.uid ?? '';

      if (userId.isEmpty) {
        return 'User not logged in';
      }

      // Add booking to the Firestore collection 'bookings'
      await _firestore.collection('bookings').add(booking.toMap());

      return null; // Booking added successfully
    } catch (e) {
      return 'Error adding booking: $e';
    }
  }
}
