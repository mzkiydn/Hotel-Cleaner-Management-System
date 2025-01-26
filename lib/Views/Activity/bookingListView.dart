import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bookingRescheduleView.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingListView extends StatelessWidget {
  Future<String> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    return userId ?? ''; // Return empty string if userId is not found
  }

  // session
  Future<Map<String, String>> getSessionDetails() async {
    String userId = await _getUserId();

    if (userId.isEmpty) {
      return {'username': 'Unknown', 'sessionId': 'Unknown', 'role': 'Unknown'};
    }

    // Fetch username and role from Firestore using userId
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('User').doc(userId).get();

      if (userDoc.exists) {
        String username = userDoc.get('Username') ?? 'Unknown';
        String role = userDoc.get('Role') ?? 'Unknown';

        if (role != 'Cleaner') {
          return {'username': 'Unauthorized', 'sessionId': 'Unknown', 'role': 'Unauthorized'};
        }

        return {'username': username, 'sessionId': userId, 'role': role}; // Returning userId and role
      } else {
        return {'username': 'Unknown', 'sessionId': 'Unknown', 'role': 'Unknown'};
      }
    } catch (e) {
      print('Error fetching user details: $e');
      return {'username': 'Unknown', 'sessionId': 'Unknown', 'role': 'Unknown'};
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: getSessionDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          final sessionDetails = snapshot.data!;
          if (sessionDetails['role'] != 'Cleaner') {
            // Redirect or show message if user is not a Cleaner
            return const Center(child: Text('You do not have permission to access this page.'));
          }

          // If the role is "Cleaner", continue with the BookingListView
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.deepPurple,
                title: const Text(
                  'My Booking',
                  style: TextStyle(color: Colors.white),
                ),
                centerTitle: true,
                automaticallyImplyLeading: false,
                bottom: const TabBar(
                  indicatorColor: Color.fromARGB(255, 233, 220, 255),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(text: 'Upcoming'),
                    Tab(text: 'Completed'),
                  ],
                ),
              ),
              body: const TabBarView(
                children: [
                  BookingList(statusFilter: ['Pending', 'Confirmed']),
                  BookingList(statusFilter: ['Completed']),
                ],
              ),
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.grey[300],
                selectedItemColor: Colors.blue,
                unselectedItemColor: Colors.black54,
                currentIndex: 1,
                onTap: (index) {
                  if (index == 0) {
                    Navigator.pushNamed(context, '/bookinglistview');
                  } else if (index == 1) {
                    Navigator.pushNamed(context, '/activity');
                  } else if (index == 2) {
                    Navigator.pushNamed(context, '/report');
                  }
                },
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ''),
                  BottomNavigationBarItem(icon: Icon(Icons.list), label: ''),
                  BottomNavigationBarItem(icon: Icon(Icons.report), label: ''),
                ],
              ),
            ),
          );
        } else {
          return const Center(child: Text('Failed to load session details.'));
        }
      },
    );
  }
}

class BookingList extends StatelessWidget {
  final List<String> statusFilter;

  const BookingList({required this.statusFilter});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Booking').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No Bookings Found'));
        }

        final bookings = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return statusFilter.contains(data['bookingStatus']);
        }).toList();

        if (bookings.isEmpty) {
          return const Center(child: Text('No Bookings Found'));
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: bookings.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('Homestays')
                      .doc(data['homestayID'])
                      .get(),
                  builder: (context, homestaySnapshot) {
                    if (homestaySnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!homestaySnapshot.hasData || !homestaySnapshot.data!.exists) {
                      return const Center(child: Text('Homestay not found'));
                    }

                    final homestayData = homestaySnapshot.data!.data() as Map<String, dynamic>;
                    final houseName = homestayData['House Name'] ?? 'Unknown';

                    return FutureBuilder<String?>(
                      future: _fetchCleanerName(data['cleanerId']),
                      builder: (context, cleanerSnapshot) {
                        if (cleanerSnapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        final cleanerName = cleanerSnapshot.data ?? '-';

                        return BookingCard(
                          bookingId: doc.id,
                          sessionDate: data['sessionDate'],
                          sessionTime: data['sessionTime'],
                          sessionDuration: data['sessionDuration'],
                          bookingStatus: data['bookingStatus'],
                          cleanerName: cleanerName,
                          price: data['price'],
                          houseName: houseName,
                        );
                      },
                    );
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  // Function to fetch cleaner name from the User collection
  Future<String?> _fetchCleanerName(String cleanerId) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('User')
        .doc(cleanerId)
        .get();
    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      final role = userData['Role'];
      if (role == 'Cleaner') {
        return userData['Name'];
      }
    }
    return null;
  }
}

class BookingCard extends StatelessWidget {
  final String bookingId;
  final String sessionDate;
  final String sessionTime;
  final String sessionDuration;
  final String bookingStatus;
  final String? cleanerName;
  final double price;
  final String houseName;

  const BookingCard({
    required this.bookingId,
    required this.sessionDate,
    required this.sessionTime,
    required this.sessionDuration,
    required this.bookingStatus,
    required this.price,
    required this.houseName,
    this.cleanerName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 129, 56, 255),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(10),
              ),
            ),
            child: Text(
              houseName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Date\n$sessionDate'),
                    Text('Time\n$sessionTime'),
                  ],
                ),
                const Divider(height: 32, thickness: 1),
                Text('Session duration: $sessionDuration'),
                const SizedBox(height: 8),
                if (cleanerName != null) Text('Cleaner: $cleanerName'),
                const SizedBox(height: 8),
                if (bookingStatus != 'Cancelled') // Hide button if status is 'Cancelled'
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (bookingStatus == 'Completed') {
                          print('Submit review for booking');
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BookingRescheduleView(bookingId: bookingId),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: bookingStatus == 'Completed'
                            ? Colors.green
                            : Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        bookingStatus == 'Completed'
                            ? 'Submit My Review'
                            : 'Reschedule Booking',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
