import 'package:flutter/material.dart';
import 'package:hcms_sep/Provider/HomestayRegistrationController.dart';
import 'package:hcms_sep/Provider/ActivityController.dart';
import 'package:hcms_sep/Views/Activity/activityListView.dart';

import 'homestayListView.dart';

class HomestayRegistration extends StatefulWidget {
  const HomestayRegistration({super.key});

  @override
  State<HomestayRegistration> createState() => _HomestayRegistrationState();
}

class _HomestayRegistrationState extends State<HomestayRegistration> {
  final HomestayRegistrationController controller = HomestayRegistrationController();
  String sessionId = 'Loading...';
  String username = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchSessionDetails();
  }

  Future<void> _fetchSessionDetails() async {
    Map<String, String> details = await controller.getSessionDetails();
    setState(() {
      sessionId = details['sessionId']!;
      username = details['username']!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple, // Match previous AppBar styling
        title: const Text('Homestay Registration'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // House Name Input
              TextField(
                controller: controller.houseNameController,
                decoration: const InputDecoration(
                  labelText: 'House Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.houseAddressController,
                decoration: const InputDecoration(
                  labelText: 'House Address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // House Type Dropdown
              DropdownButtonFormField<String>(
                value: controller.selectedHouseType,
                decoration: const InputDecoration(
                  labelText: 'House Type',
                  border: OutlineInputBorder(),
                ),
                items: controller.houseTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      controller.selectedHouseType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              // Room List - Display the rooms added so far
              const Text('Rooms', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.getRooms().length,
                itemBuilder: (context, index) {
                  final room = controller.getRooms()[index];
                  return ListTile(
                    leading: const Icon(Icons.room, color: Colors.deepPurple),
                    title: Text(room['roomType']),
                    subtitle: Text(room['activities'].join(', ')),
                    onTap: () {
                      showRoomDetailDialog(context, index);  // Pass the index to edit room
                    },
                  );
                },
              ),
              const SizedBox(height: 10),

              // Add Room Button
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Room'),
                  onPressed: () {
                    showRoomDetailDialog(context, null);  // Pass null to add new room
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      setState(() {
                        controller.clearAll();
                      });
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (controller.validateRegistration()) {
                        try {
                          // Register homestay with rooms
                          await controller.registerHomestay(
                            houseName: controller.houseNameController.text,
                            houseAddress: controller.houseAddressController.text,
                            houseType: controller.selectedHouseType,
                            rooms: controller.getRooms(),
                          );

                          // Show success message and refresh
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Homestay registered successfully')),
                          );

                          setState(() {
                            // Clear rooms after successful registration
                            controller.clearAll();
                          });
                          final activityController = ActivityController();
                          // Navigate to ActivityListView
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomestayListView(),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error saving data: $e')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please complete the form')),
                        );
                      }
                    },
                    child: const Text('Register'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showRoomDetailDialog(BuildContext context, int? index) {
    final room = index != null ? controller.getRooms()[index] : null;
    String selectedRoomType = room?['roomType'] ?? 'Living Room';
    List<String> selectedActivities = room?['activities']?.cast<String>() ?? [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(index == null ? 'Add Room' : 'Edit Room'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: selectedRoomType,
                    items: controller.roomTypes.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedRoomType = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  ...controller.cleaningActivities.map((activity) {
                    return CheckboxListTile(
                      title: Text(activity),
                      value: selectedActivities.contains(activity),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedActivities.add(activity);
                          } else {
                            selectedActivities.remove(activity);
                          }
                        });
                      },
                    );
                  }),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (index != null) {
                        controller.updateRoom(index, selectedRoomType, selectedActivities);
                      } else {
                        controller.addRoom(selectedRoomType, selectedActivities);
                      }
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text(index == null ? 'Add' : 'Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
