import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  String paymentMethod;
  double paymentAmount;
  String paymentStatus;
  String paymentReference;
  DateTime paymentDate;

  Payment({
    required this.paymentMethod,
    required this.paymentAmount,
    required this.paymentReference,
    required this.paymentStatus,
    required this.paymentDate,
  });

  // Convert HouseOwner object to Firestore format (Map)
  Map<String, dynamic> toMap() {
    return {
      'paymentMethod': paymentMethod,
      'paymentAmount': paymentAmount,
      'paymentReference': paymentReference,
      'paymentStatus': paymentStatus,
      'paymentDate': paymentDate,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Create HouseOwner object from Firestore data
  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      paymentMethod: map['paymentMethod'],
      paymentAmount: map['paymentAmount'],
      paymentReference: map['paymentReference'],
      paymentStatus: map['paymentStatus'],
      paymentDate: map['paymentDate'],
    );
  }
}
