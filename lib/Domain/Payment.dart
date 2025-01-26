class Payment {
  final String bookingId;
  final double amount;
  final String paymentMethod;
  final DateTime paymentDate;
  final String paymentStatus;

  Payment({
    required this.bookingId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentDate,
    required this.paymentStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'paymentAmount': amount,
      'paymentMethod': paymentMethod,
      'paymentDate': paymentDate,
      'paymentStatus': paymentStatus,
    };
  }
}
