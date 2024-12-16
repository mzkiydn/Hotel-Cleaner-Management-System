import 'package:flutter/material.dart';
import 'baseScaffold.dart';

class MasterScaffold extends StatefulWidget {
  @override
  _MasterScaffoldState createState() => _MasterScaffoldState();
}

class _MasterScaffoldState extends State<MasterScaffold> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
      // Navigate to Home
        break;
      case 1:
        Navigator.pushNamed(context, '/booking');
        break;
      case 2:
        Navigator.pushNamed(context, '/activity');
        break;
      case 3:
        Navigator.pushNamed(context, '/report');
        break;
      case 4:
      // Navigate to Profile
        break;
    }

  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: Center(child: Text('Current Index: $_selectedIndex')),
      currentIndex: _selectedIndex,
      onItemTapped: _onItemTapped,
    );
  }
}
