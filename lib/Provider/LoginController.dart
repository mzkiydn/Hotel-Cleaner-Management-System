import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hcms_sep/Views/Activity/bookingListView.dart';
import 'package:hcms_sep/Views/Register/homestayRegistration.dart';
import 'package:hcms_sep/Views/Report/reportView.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> loginUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      // Attempt to sign in with Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user data from Firestore
      DocumentSnapshot userDoc = await _firestore.collection('User').doc(userCredential.user?.uid).get();

      if (!userDoc.exists) return 'User data not found';

      var userData = userDoc.data() as Map<String, dynamic>;

      // Check if the account is active
      if (userData['Status']?.toLowerCase() != 'active') {
        return 'User account is not active';
      }

      String userId = userCredential.user?.uid ?? '';
      if (userId.isEmpty) return 'User ID is missing';

      // Store userId in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId);

      // Navigate based on Role
      switch (userData['Role']) {
        case 'Cleaner':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BookingListView()),
          );
          break;
        case 'House Owner':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ReportView()),
          );
          break;
        default:
          return 'Unknown role: ${userData['Role']}';
      }
      return null; // No errors
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'User not found';
      } else if (e.code == 'wrong-password') {
        return 'Incorrect password';
      } else {
        return e.message ?? 'An error occurred';
      }
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }
}
