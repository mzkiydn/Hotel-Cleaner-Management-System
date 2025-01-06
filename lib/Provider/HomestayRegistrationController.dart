import 'package:flutter/material.dart';

class HomestayRegistrationController {
  final TextEditingController houseNameController = TextEditingController();

  List<String> houseTypes = ['Apartment', 'Villa', 'Bungalow'];
  String selectedHouseType = 'Apartment';

  List<Map<String, dynamic>> rooms = [];
  List<String> roomTypes = ['Living Room', 'Bedroom', 'Bathroom', 'Kitchen'];
  List<String> cleaningActivities = ['Vacuuming', 'Dusting', 'Mopping', 'Sanitizing'];

  void addRoom(String roomType, List<String> activities) {
    rooms.add({'roomType': roomType, 'activities': activities});
    debugPrint('Room added: $roomType with activities: $activities');
  }

  void updateRoom(int index, String roomType, List<String> activities) {
    rooms[index] = {'roomType': roomType, 'activities': activities};
    debugPrint('Room updated: $roomType with activities: $activities');
  }

  void removeRoom(int index) {
    rooms.removeAt(index);
    debugPrint('Room removed at index: $index');
  }

  void clearAll() {
    houseNameController.clear();
    selectedHouseType = houseTypes[0];
    rooms.clear();
    debugPrint('All fields cleared.');
  }

  bool validateRegistration() {
    return houseNameController.text.isNotEmpty && rooms.isNotEmpty;
  }

  Map<String, dynamic> getRegistrationData() {
    return {
      'houseName': houseNameController.text,
      'houseType': selectedHouseType,
      'rooms': rooms,
    };
  }
}
