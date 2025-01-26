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
    this.bookingStatus = "Pending",
    this.cleanerId,
    required this.userId,
    required this.address,
    required this.homestayID, // Make required
    this.paymentMethod = "Credit Card",
  });

  Map<String, dynamic> toMap() {
    return {
      'sessionDate': sessionDate,
      'sessionTime': sessionTime,
      'sessionDuration': sessionDuration,
      'price': price,
      'bookingStatus': bookingStatus,
      'cleanerId': cleanerId ?? '',
      'userId': userId,
      'address': address,
      'homestayID': homestayID, // Ensure it's stored
      'paymentMethod': paymentMethod,
    };
  }

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
      homestayID: map['homestayID'], // Map it back
      paymentMethod: map['paymentMethod'],
    );
  }
}
