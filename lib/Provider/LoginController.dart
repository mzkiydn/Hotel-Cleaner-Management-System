import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> loginUser({required String email, required String password}) async {
    try {
      // Attempt to sign in with Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user data from Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userCredential.user?.uid).get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;

        // Check if the account is active
        if (userData['status'] == 'active') {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', userCredential.user?.uid ?? 'No user');

          // Check the user's role and perform corresponding logic
          if (userData['role'] == 'Cleaner') {
            // Handle logic for Cleaner
            // return 'Cleaner login successful';
          } else if (userData['role'] == 'HouseOwner') {
            // Handle logic for HouseOwner
            // return 'HouseOwner login successful';
          }
        } else {
          return 'User account is not active';
        }
      } else {
        return 'User data not found';
      }
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
