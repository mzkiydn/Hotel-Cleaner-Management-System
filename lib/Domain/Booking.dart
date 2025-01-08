class Booking {
  final String sessionDate;
  final String sessionTime;
  final String sessionDuration;
  final double price;
  final String bookingStatus;
  final String? cleanerId; // Cleaner ID will be null initially
  final String userId; // User ID of the person who made the booking
  final String address; // Add address field

  Booking({
    required this.sessionDate,
    required this.sessionTime,
    required this.sessionDuration,
    required this.price,
    this.bookingStatus = "Pending", // Default to "Pending"
    this.cleanerId,
    required this.userId,
    required this.address, // Include address in the constructor
  });

  // Convert the Booking object to a Map to store in Firestore
  Map<String, dynamic> toMap() {
    return {
      'sessionDate': sessionDate,
      'sessionTime': sessionTime,
      'sessionDuration': sessionDuration,
      'price': price,
      'bookingStatus': bookingStatus,
      'cleanerId': cleanerId ?? '', // Default empty if no cleaner is assigned
      'userId': userId,
      'address': address, // Store address in Firestore
    };
  }

  // Convert Firestore document to Booking object
  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      sessionDate: map['sessionDate'],
      sessionTime: map['sessionTime'],
      sessionDuration: map['sessionDuration'],
      price: map['price'],
      bookingStatus: map['bookingStatus'],
      cleanerId: map['cleanerId'],
      userId: map['userId'],
      address: map['address'], // Convert address from Firestore
    );
  }
}
