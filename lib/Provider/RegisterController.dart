import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> registerUser({
    required String fullName,
    required String username,
    required String email,
    required String password,
    required String phoneNumber,
    required String address,
    required String role,
  }) async {
    try {
      // Create user with Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // After successful registration, add the user to the Firestore
      if (role == 'Cleaner') {
        // Register Cleaner
        await _firestore.collection('User').doc(userCredential.user?.uid).set({
          'Name': fullName,
          'Username': username,
          'Email': email,
          'Phone Number': phoneNumber,
          'Address': address,
          'Password': password,
          'Role': 'Cleaner',
          'Status': 'active',  // Example of additional field
          'Experience': 'N/A', // Cleaner-specific field
        });
      } else if (role == 'House Owner') {
        // Register HouseOwner
        await _firestore.collection('User').doc(userCredential.user?.uid).set({
          'Name': fullName,
          'Username': username,
          'Email': email,
          'Phone Number': phoneNumber,
          'Address': address,
          'Password': password,
          'Role': 'House Owner',
          'Status': 'active',  // Example of additional field
        });
      } else {
        return 'Invalid role selected.';
      }

      return null;  // Registration successful
    } catch (e) {
      return 'An error occurred: $e';
    }
  }
}