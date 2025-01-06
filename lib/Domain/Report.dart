import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  String duration;

  Report({
    required this.duration,
  });

  // Convert Cleaner object to Firestore format (Map)
  Map<String, dynamic> toMap() {
    return {
      'duration': duration,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Create Cleaner object from Firestore data
  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      duration: map['duration'],
    );
  }
}
