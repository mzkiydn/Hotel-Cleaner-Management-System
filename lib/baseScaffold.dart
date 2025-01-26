import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BaseScaffold extends StatefulWidget {
  final Widget body;
  final int currentIndex;
  final ValueChanged<int>? onItemTapped;
  final Widget? leftCustomBarAction;
  final Widget? rightCustomBarAction;
  final String customBarTitle;
  final bool showBottomNavigationBar;

  const BaseScaffold({
    Key? key,
    required this.body,
    required this.currentIndex,
    required this.onItemTapped,
    this.leftCustomBarAction,
    this.rightCustomBarAction,
    this.customBarTitle = " ",
    this.showBottomNavigationBar = true,
  }) : super(key: key);

  @override
  _BaseScaffoldState createState() => _BaseScaffoldState();
}

class _BaseScaffoldState extends State<BaseScaffold> {
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');  // Removes the 'userId' key from SharedPreferences
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);  // Navigate to the login screen
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushNamed(context, '/homelist');
    } else if (index == 1) {
      Navigator.pushNamed(context, '/booking');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/activity');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/report');
    } else if (index == 4) {
      _logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove back button
        title: Text('Homestay Cleaning'),
        backgroundColor: Colors.deepPurple,
      ),

      // Custom Bar
      body: Column(
        children: [
          Container(
            color: Colors.blueGrey,
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widget.leftCustomBarAction ?? SizedBox.shrink(),
                Text(
                  widget.customBarTitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                widget.rightCustomBarAction ?? SizedBox.shrink(),
              ],
            ),
          ),
          Expanded(child: widget.body),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: widget.showBottomNavigationBar
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
        currentIndex: widget.currentIndex,
        selectedItemColor: Colors.amber[800],
        onTap: (index) => _handleNavigation(context, index),
      )
          : null,
    );
  }
}
