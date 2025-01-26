import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hcms_sep/baseScaffold.dart';
import 'homestayRegistration.dart';

class HomestayListView extends StatefulWidget {
  const HomestayListView({Key? key}) : super(key: key);

  @override
  State<HomestayListView> createState() => _HomestayListViewState();
}

class _HomestayListViewState extends State<HomestayListView> {
  late Future<List<Map<String, dynamic>>> _homestaysFuture;

  // Retrieve the user ID from shared preferences
  Future<String> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') ?? '';
  }

  // Fetch homestay data from Firestore
  Future<List<Map<String, dynamic>>> _fetchHomestays() async {
    String userId = await _getUserId();

    if (userId.isEmpty) {
      return []; // Return empty list if user ID is not available
    }

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Homestays')
          .where('UserId', isEqualTo: userId)
          .orderBy('Timestamp', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'houseName': doc['House Name'] ?? 'Unknown',
          'houseType': doc['House Type'] ?? 'Unknown',
          'address': doc['Address'] ?? 'Unknown',
          'status': doc['Status'] ?? 'Unavailable',
          'rooms': doc['Rooms'] ?? [],
        };
      }).toList();
    } catch (e) {
      print('Error fetching homestays: $e');
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    _homestaysFuture = _fetchHomestays();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('My Homestays'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _homestaysFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No homestays found.'),
            );
          } else {
            final homestays = snapshot.data!;
            return ListView.builder(
              itemCount: homestays.length,
              itemBuilder: (context, index) {
                final homestay = homestays[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(homestay['houseName']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Type: ${homestay['houseType']}'),
                        Text('Address: ${homestay['address']}'),
                        Text('Status: ${homestay['status']}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.arrow_forward, color: Colors.deepPurple),
                      onPressed: () {
                        // Navigate to homestay details or actions
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomestayDetailView(homestay: homestay),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
        onPressed: () {
          // Navigate to the HomestayRegistration screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HomestayRegistration(),
            ),
          ).then((value) {
            // Refresh the homestay list when returning from the registration page
            setState(() {
              _homestaysFuture = _fetchHomestays();
            });
          });
        },
      ),
    );
  }
}

// Example HomestayDetailView (You can replace or expand it with your implementation)
class HomestayDetailView extends StatelessWidget {
  final Map<String, dynamic> homestay;

  const HomestayDetailView({Key? key, required this.homestay}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(homestay['houseName']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('House Name: ${homestay['houseName']}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Type: ${homestay['houseType']}'),
            const SizedBox(height: 8),
            Text('Address: ${homestay['address']}'),
            const SizedBox(height: 8),
            Text('Status: ${homestay['status']}'),
            const SizedBox(height: 16),
            const Text('Rooms:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: homestay['rooms'].length,
                itemBuilder: (context, index) {
                  final room = homestay['rooms'][index];
                  return ListTile(
                    title: Text(room['roomType']),
                    subtitle: Text('Completed: ${room['completed']}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
