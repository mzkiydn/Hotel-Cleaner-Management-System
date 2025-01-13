import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String userId;
  final String cleanerId;
  final String homestayId;
  final String bookingId;
  final String sessionDate;
  final double price;
  final String activities;
  final int rooms;
  final String description;

  Report({
    required this.userId,
    required this.cleanerId,
    required this.homestayId,
    required this.bookingId,
    required this.sessionDate,
    required this.price,
    required this.activities,
    required this.rooms,
    required this.description,
  });

  // Convert the Report object to a map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'cleanerId': cleanerId,
      'homestayId': homestayId,
      'bookingId': bookingId,
      'sessionDate': sessionDate,
      'price': price,
      'activities': activities,
      'rooms': rooms,
      'description': description,
    };
  }

  // Create a Report object from a map (useful when retrieving data from Firestore)
  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      userId: map['userId'],
      cleanerId: map['cleanerId'],
      homestayId: map['homestayId'],
      bookingId: map['bookingId'],
      sessionDate: map['sessionDate'],
      price: map['price'],
      activities: map['activities'],
      rooms: map['rooms'],
      description: map['description'],
    );
  }
}

