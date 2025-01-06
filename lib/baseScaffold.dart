import 'package:flutter/material.dart';

class BaseScaffold extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final ValueChanged<int>? onItemTapped;
  final Widget? leftCustomBarAction;
  final Widget? rightCustomBarAction;
  final String customBarTitle;
  final bool showBottomNavigationBar;

  const BaseScaffold({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.onItemTapped,
    this.leftCustomBarAction, // Initialize left button
    this.rightCustomBarAction, // Initialize right button
    this.customBarTitle = " ", // Default title if none provided
    this.showBottomNavigationBar = true,
  });

  void _handleNavigation(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushNamed(context, '/home');
    } else if (index == 1) {
      Navigator.pushNamed(context, '/booking');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/activity');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/report');
    } else if (index == 4) {
      Navigator.pushNamed(context, '/profile');
      // } else if (onItemTapped != null) {
      //   // Handle other navigation normally
      //   onItemTapped!(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //AppBar
      appBar: AppBar(
        // the top of the app
          automaticallyImplyLeading: false, // Remove back button
          title: const Text('Homestay Cleaning'),
          backgroundColor: Colors.deepPurple,
      ),

      //customBar
      body: Column(
        children: [
          // Custom bar with left and right actions
          Container(
            color: Colors.blueGrey,
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Display left action if provided, else empty space
                leftCustomBarAction ?? const SizedBox.shrink(),

                Text(
                  customBarTitle, // Display dynamic title
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Display right action if provided, else empty space
                rightCustomBarAction ?? const SizedBox.shrink(),
              ],
            ),
          ),
          // Main content
          Expanded(child: body),
        ],
      ),

      //NavBar
      bottomNavigationBar: showBottomNavigationBar
          ? BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.deepPurpleAccent,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Booking',
            backgroundColor: Colors.deepPurpleAccent,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Activity',
            backgroundColor: Colors.deepPurpleAccent,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Report',
            backgroundColor: Colors.deepPurpleAccent,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
            backgroundColor: Colors.deepPurpleAccent,
          ),
        ],
        currentIndex: currentIndex,
        selectedItemColor: Colors.amber[800],
        onTap: (index) => _handleNavigation(context, index),
      ) : null,
    );
  }
}
