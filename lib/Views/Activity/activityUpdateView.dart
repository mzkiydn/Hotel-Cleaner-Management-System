import 'package:flutter/material.dart';

class ActivityUpdateView extends StatelessWidget {
  const ActivityUpdateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCheckboxList('Master Bedroom', ['Change the bedsheet', 'Sweeping the floor', 'Cleaning dustbin', 'Cleaning closet']),
          _buildCheckboxList('Bedroom 2', ['Change the bedsheet', 'Sweeping the floor', 'Cleaning dustbin', 'Cleaning closet']),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Comment',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.camera_alt),
            label: const Text('Upload Image'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxList(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ...items.map((item) => CheckboxListTile(
              title: Text(item),
              value: false,
              onChanged: (value) {},
            )),
      ],
    );
  }
}
