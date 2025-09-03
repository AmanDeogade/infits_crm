import 'package:flutter/material.dart';
import 'package:crm_final/home_campaign/bars/side_bar.dart';
import 'package:crm_final/home_campaign/bars/top_bar.dart';

class FollowUpsScreen extends StatefulWidget {
  const FollowUpsScreen({super.key});

  @override
  State<FollowUpsScreen> createState() => _FollowUpsScreenState();
}

class _FollowUpsScreenState extends State<FollowUpsScreen> {
  String selectedFilter = 'All';
  bool hasFollowUps = false; // Toggle this to test both states

  final List<String> filterOptions = [
    'All',
    'Assignee',
    'Upcoming',
    'Late',
    'Done',
    'Cancel',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          const SideBar(),
          Expanded(
            child: Column(
              children: [
                const TopBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        // Filter Categories Section
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: filterOptions.map((filter) {
                              return _buildFilterChip(filter);
                            }).toList(),
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Conditional Content: Either Follow-up List or Add Button
                        if (hasFollowUps) ...[
                          // Show follow-up list when there are follow-ups
                          Expanded(
                            child: Center(
                              child: Text(
                                'Follow-up list would go here',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          // Show add button when no follow-ups exist
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFCCF0FF), // Light blue color
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    size: 40,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Add follow-up',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        const Spacer(),
                      ],
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

  Widget _buildFilterChip(String filter) {
    final isSelected = selectedFilter == filter;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFCCF0FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFCCF0FF) : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              filter,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.black : Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: isSelected ? Colors.black : Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }
}
