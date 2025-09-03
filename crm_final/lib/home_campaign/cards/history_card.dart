import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            const Text(
              'History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            /// Filters + Clear
            Row(
              children: [
                DropdownButton<String>(
                  value: 'All Actions',
                  items: [
                    DropdownMenuItem(
                      value: 'All Actions',
                      child: Text('All Actions'),
                    ),
                    DropdownMenuItem(value: 'Status', child: Text('Status')),
                    DropdownMenuItem(value: 'Notes', child: Text('Notes')),
                  ],
                  onChanged: null, // Static for now
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: 'Time',
                  items: [DropdownMenuItem(value: 'Time', child: Text('Time'))],
                  onChanged: null,
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: 'Team',
                  items: [DropdownMenuItem(value: 'Team', child: Text('Team'))],
                  onChanged: null,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Clear filter',
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            /// History List
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.lightBlue.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: const [
                  HistoryItem(
                    text: 'Status changed from  Fresh → Not Interested',
                  ),
                  Divider(height: 1),
                  HistoryItem(text: 'Note added'),
                  Divider(height: 1),
                  HistoryItem(
                    text: 'Status changed from  Fresh → Not Interested',
                  ),
                  Divider(height: 1),
                  HistoryItem(
                    text: 'Status changed from  Fresh → Not Interested',
                  ),
                  Divider(height: 1),
                  HistoryItem(
                    text: 'Status changed from  Fresh → Not Interested',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryItem extends StatelessWidget {
  final String text;
  const HistoryItem({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Row(
        children: [
          const Icon(Icons.star_border, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
