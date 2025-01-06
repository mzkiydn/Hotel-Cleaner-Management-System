import 'package:flutter/material.dart';
import 'package:hcms_sep/Provider/HomestayRegistrationController.dart';

class HomestayRegistration extends StatefulWidget {
  const HomestayRegistration({super.key});

  @override
  State<HomestayRegistration> createState() => _HomestayRegistrationState();
}

class _HomestayRegistrationState extends State<HomestayRegistration> {
  final HomestayRegistrationController controller = HomestayRegistrationController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Homestay Registration')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // House Name Input
              TextField(
                controller: controller.houseNameController,
                decoration: const InputDecoration(labelText: 'House Name'),
              ),
              const SizedBox(height: 10),

              // House Type Dropdown
              DropdownButton<String>(
                value: controller.selectedHouseType,
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

              // Room List
              const Text('Rooms', style: TextStyle(fontWeight: FontWeight.bold)),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.rooms.length,
                itemBuilder: (context, index) {
                  final room = controller.rooms[index];
                  return ListTile(
                    title: Text(room['roomType']),
                    subtitle: Text(room['activities'].join(', ')),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            showRoomDetailDialog(context, index);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              controller.removeRoom(index);
                            });
                          },
                        ),
                      ],
                    ),
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
                    showRoomDetailDialog(context, null);
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
                    onPressed: () {
                      if (controller.validateRegistration()) {
                        print(controller.getRegistrationData());
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
    final room = index != null ? controller.rooms[index] : null;
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
