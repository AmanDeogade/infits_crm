import 'package:flutter/material.dart';

class DashboardTile extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback? onTap; // <-- New onTap callback
  final List<List<String>>? dataRows; // New: rows of data to display

  const DashboardTile({
    super.key,
    required this.title,
    required this.color,
    this.onTap,
    this.dataRows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: color.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Header row with title and icons
          Padding(
            padding: const EdgeInsets.only(left: 0, top: 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left color header with title and filters
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.dashboard_customize_outlined,
                            size: 18),
                        const SizedBox(width: 6),
                        Text(
                          title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "1s ago",
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.refresh, size: 16, color: Colors.grey),
                        const Spacer(),
                        const Icon(Icons.calendar_today_outlined, size: 16),
                        const SizedBox(width: 4),
                        const Text("Today", style: TextStyle(fontSize: 12)),
                        const Icon(Icons.keyboard_arrow_down, size: 16),
                      ],
                    ),
                  ),
                ),

                // Right corner actions: + and →
                Padding(
                  padding: const EdgeInsets.only(top: 8, right: 10),
                  child: Row(
                    children: [
                      _iconBox(icon: Icons.add),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: onTap,
                        child:
                            _iconBox(icon: Icons.arrow_forward_ios, size: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Body (mock data table or real data)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // Dynamic headers based on data type
                                            Row(
                            children: dataRows != null && dataRows!.isNotEmpty 
                                ? (dataRows![0].length == 5
                                    ? (title == 'Lead by Stages'
                                        ? const [
                                            // Lead by Stages headers (5 columns)
                                            _tableHeader("Assignee"),
                                            _tableHeader("Fresh"),
                                            _tableHeader("Active"),
                                            _tableHeader("Won"),
                                            _tableHeader("Loss"),
                                          ]
                                        : title == 'Follow-ups'
                                            ? const [
                                                // Follow-ups headers (5 columns)
                                                _tableHeader("Assignee"),
                                                _tableHeader("Fresh"),
                                                _tableHeader("Follow Up"),
                                                _tableHeader("Done"),
                                                _tableHeader("Cancel"),
                                              ]
                                            : const [
                                                // Caller data headers (5 columns)
                                                _tableHeader("Sales Rep"),
                                                _tableHeader("Total Calls"),
                                                _tableHeader("Duration"),
                                                _tableHeader("Connected"),
                                                _tableHeader("Not Connected"),
                                              ])
                                    : dataRows![0].length == 3
                                        ? const [
                                            // Follow-up data headers (3 columns)
                                            _tableHeader("Status"),
                                            _tableHeader("Count"),
                                            _tableHeader("Description"),
                                          ]
                                        : const [
                                            // Campaign data headers (4 columns)
                                            _tableHeader("Name"),
                                            _tableHeader("Total Leads"),
                                            _tableHeader("Assignees"),
                                            _tableHeader("Progress"),
                                          ])
                                : const [
                                    // Default headers (4 columns)
                                    _tableHeader("Name"),
                                    _tableHeader("Total Leads"),
                                    _tableHeader("Assignees"),
                                    _tableHeader("Progress"),
                                  ],
                          ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: dataRows != null && dataRows!.isNotEmpty
                        ? ListView.builder(
                            itemCount: dataRows!.length,
                            itemBuilder: (_, index) {
                              final row = dataRows![index];
                              if (row.length == 5) {
                                if (title == 'Lead by Stages') {
                                  // Lead by Stages data row (5 columns)
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        _tableCell(row.length > 0 ? row[0] : ""), // Assignee
                                        _tableCell(row.length > 1 ? row[1] : ""), // Fresh
                                        _tableCell(row.length > 2 ? row[2] : ""), // Active
                                        _tableCell(row.length > 3 ? row[3] : ""), // Won
                                        _tableCell(row.length > 4 ? row[4] : ""), // Loss
                                      ],
                                    ),
                                  );
                                } else if (title == 'Follow-ups') {
                                  // Follow-ups data row (5 columns)
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        _tableCell(row.length > 0 ? row[0] : ""), // Assignee
                                        _tableCell(row.length > 1 ? row[1] : ""), // Fresh
                                        _tableCell(row.length > 2 ? row[2] : ""), // Follow Up
                                        _tableCell(row.length > 3 ? row[3] : ""), // Done
                                        _tableCell(row.length > 4 ? row[4] : ""), // Cancel
                                      ],
                                    ),
                                  );
                                } else {
                                  // Caller data row (5 columns)
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        _tableCell(row.length > 0 ? row[0] : ""), // Sales Rep
                                        _tableCell(row.length > 1 ? row[1] : ""), // Total Calls
                                        _tableCell(row.length > 2 ? row[2] : ""), // Duration
                                        _tableCell(row.length > 3 ? row[3] : ""), // Connected
                                        _tableCell(row.length > 4 ? row[4] : ""), // Not Connected
                                      ],
                                    ),
                                  );
                                }
                              } else if (row.length == 3) {
                                // Follow-up data row (3 columns)
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      _tableCell(row.length > 0 ? row[0] : ""), // Status
                                      _tableCell(row.length > 1 ? row[1] : ""), // Count
                                      _tableCell(row.length > 2 ? row[2] : ""), // Description
                                    ],
                                  ),
                                );
                              } else {
                                // Campaign data row (4 columns)
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      _tableCell(row.length > 0 ? row[0] : ""), // Campaign Name
                                      _tableCell(row.length > 1 ? row[1] : ""), // Total Leads
                                      _tableCell(row.length > 2 ? row[2] : ""), // Assignees
                                      _tableCell(row.length > 3 ? row[3] : ""), // Progress
                                    ],
                                  ),
                                );
                              }
                            },
                          )
                        : _buildEmptyState(),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    // Show plus button for Follow-ups tile, info icon for others
    if (title == 'Follow-ups') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFCCF0FF), // Light blue color
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                size: 30,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Add follow-up',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      );
    } else if (title == 'Lead by Stages') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.analytics_outlined, size: 40, color: Colors.grey),
            const SizedBox(height: 10),
            const Text(
              "Lead stage data will appear here",
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 40, color: Colors.grey),
            const SizedBox(height: 10),
            const Text(
              "No data available for this tile.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _iconBox(icon: Icons.add, size: 24),
          ],
        ),
      );
    }
  }
}

// Reusable header cell
class _tableHeader extends StatelessWidget {
  final String title;
  const _tableHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
    );
  }
}

// Reusable table cell
class _tableCell extends StatelessWidget {
  final String text;
  const _tableCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(text,
          style: const TextStyle(fontSize: 12), textAlign: TextAlign.left),
    );
  }
}

// Circular icon buttons (e.g., + and →)
Widget _iconBox({required IconData icon, double size = 18}) {
  return Container(
    width: 30,
    height: 30,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black12),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(icon, size: size),
  );
}
