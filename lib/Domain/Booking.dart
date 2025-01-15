class Booking {
  final String sessionDate;
  final String sessionTime;
  final String sessionDuration;
  final double price;
  final String bookingStatus;
  final String? cleanerId;
  final String userId;
  final String address;
  final String homestayID;
  final String paymentMethod;

  Booking({
    required this.sessionDate,
    required this.sessionTime,
    required this.sessionDuration,
    required this.price,
    this.bookingStatus = "Pending", // Default to "Pending"
    this.cleanerId,
    required this.userId,
    required this.address,
    this.homestayID = "c7K5yQH58zNUabT2AZcD",
    this.paymentMethod = "Credit Card",
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
      'homestayID': homestayID,
      'paymentMethod': paymentMethod,
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
      address: map['address'],
      homestayID: map['homestayID'],
      paymentMethod: map['paymentMethod'],
    );
  }
}
