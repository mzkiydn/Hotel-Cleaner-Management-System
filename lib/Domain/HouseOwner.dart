import 'package:cloud_firestore/cloud_firestore.dart';

class HouseOwner {
  String fullName;
  String username;
  String email;
  String password;
  String phoneNumber;
  String address;
  String role;

  HouseOwner({
    required this.fullName,
    required this.username,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.address,
    this.role = 'House Owner',
  });

  // Convert HouseOwner object to Firestore format (Map)
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'username': username,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'address': address,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Create HouseOwner object from Firestore data
  factory HouseOwner.fromMap(Map<String, dynamic> map) {
    return HouseOwner(
      fullName: map['fullName'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      phoneNumber: map['phoneNumber'],
      address: map['address'],
      role: map['role'],
    );
  }
}