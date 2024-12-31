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
        await _firestore.collection('users').doc(userCredential.user?.uid).set({
          'fullName': fullName,
          'username': username,
          'email': email,
          'phoneNumber': phoneNumber,
          'address': address,
          'role': 'Cleaner',
          'status': 'active',  // Example of additional field
          'cleaningExperience': 'N/A', // Cleaner-specific field
        });
      } else if (role == 'HouseOwner') {
        // Register HouseOwner
        await _firestore.collection('users').doc(userCredential.user?.uid).set({
          'fullName': fullName,
          'username': username,
          'email': email,
          'phoneNumber': phoneNumber,
          'address': address,
          'role': 'HouseOwner',
          'status': 'active',  // Example of additional field
          'propertyList': [],  // HouseOwner-specific field
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
