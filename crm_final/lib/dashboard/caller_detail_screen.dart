import 'package:crm_final/home_campaign/bars/side_bar.dart';
import 'package:flutter/material.dart';
import '../models/caller.dart';
import '../models/caller_details.dart';
import '../models/call_metrics.dart';
import '../services/caller_details_service.dart';
import '../services/call_metrics_service.dart';

class CallerDetailScreen extends StatelessWidget {
  final Caller caller;

  const CallerDetailScreen({super.key, required this.caller});

  Widget buildMetricTile(
    String title,
    String value, {
    IconData? icon,
    Color? iconColor,
  }) {
    return Container(
      width: 293,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade200, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          if (icon != null) Icon(icon, size: 20, color: iconColor),
          if (icon != null) const SizedBox(width: 8),
          Expanded(child: Text(title)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }

  Widget buildHorizontalMetricRow(List<Widget> tiles) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            tiles
                .map(
                  (tile) =>
                      Padding(padding: const EdgeInsets.all(8), child: tile),
                )
                .toList(),
      ),
    );
  }

  Widget buildGridMetrics(List<Widget> tiles) {
    return Wrap(spacing: 12, runSpacing: 12, children: tiles);
  }

  Widget buildLeadStageTag(String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade200, width: 1.5),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 12),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, size: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final callerDetailsService = CallerDetailsService();
    final callMetricsService = CallMetricsService();
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      body: Row(
        children: [
          SideBar(),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: Future.wait([
                callerDetailsService.getByCallerId(caller.id!),
                callMetricsService.getByUserId(caller.id!),
              ]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          'Error loading data',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${snapshot.error}',
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Refresh the data
                            //setState(() {});
                          },
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: Text('No data found'));
                }

                final List<CallerDetails> detailsList =
                    snapshot.data![0] as List<CallerDetails>;
                final List<CallMetrics> metricsList =
                    snapshot.data![1] as List<CallMetrics>;
                final CallerDetails? details =
                    detailsList.isNotEmpty ? detailsList.first : null;
                final CallMetrics? metrics =
                    metricsList.isNotEmpty ? metricsList.first : null;

                // Check if we have call metrics data
                if (metrics == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.phone_disabled,
                          size: 64,
                          color: Colors.orange,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No Call Data Available',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'No call metrics found for ${caller.name}.\nThis could mean:\n• No calls have been made yet\n• Call data hasn\'t been recorded\n• Database needs to be updated',
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        // Debug information
                        Container(
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Debug Information:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text('Caller ID: ${caller.id}'),
                              Text('Details found: ${detailsList.length}'),
                              Text('Metrics found: ${metricsList.length}'),
                              if (detailsList.isNotEmpty)
                                Text(
                                  'First details: ${detailsList.first.toString()}',
                                ),
                              if (metricsList.isNotEmpty)
                                Text(
                                  'First metrics: ${metricsList.first.toString()}',
                                ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Refresh the data
                            //setState(() {});
                          },
                          child: Text('Refresh'),
                        ),
                      ],
                    ),
                  );
                }
                // Lead stage values
                final leadStages = [
                  {
                    'label': 'Fresh',
                    'value': details?.stageFresh?.toString() ?? '-',
                    'color': Colors.blue,
                  },
                  {
                    'label': 'Interested',
                    'value': details?.stageInterested?.toString() ?? '-',
                    'color': Colors.teal,
                  },
                  {
                    'label': 'Committed',
                    'value': details?.stageCommitted?.toString() ?? '-',
                    'color': Colors.orange,
                  },
                  {
                    'label': 'Not Interested',
                    'value': details?.stageNotInterested?.toString() ?? '-',
                    'color': Colors.brown,
                  },
                  {
                    'label': 'Not Connected',
                    'value': details?.stageNotConnected?.toString() ?? '-',
                    'color': Colors.amber,
                  },
                  {
                    'label': 'Call Back',
                    'value': details?.stageCallback?.toString() ?? '-',
                    'color': Colors.purple,
                  },
                  {
                    'label': 'Temple Visit',
                    'value': details?.stageTempleVisit?.toString() ?? '-',
                    'color': Colors.indigo,
                  },
                  {
                    'label': 'Temple Donar',
                    'value': details?.stageTempleDonor?.toString() ?? '-',
                    'color': Colors.cyan,
                  },
                  {
                    'label': 'Lost',
                    'value': details?.stageLost?.toString() ?? '-',
                    'color': Colors.red,
                  },
                  {
                    'label': 'Won',
                    'value': details?.stageWon?.toString() ?? '-',
                    'color': Colors.green,
                  },
                ];
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 8,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Activity & Performance / Overall States / ${caller.name} (caller)',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        // Header section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.blue.shade200,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 36,
                                backgroundColor: Color(0xFFE0E0E0),
                              ),
                              const SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    caller.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    caller.email ?? '-',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Metrics Grid (2 columns)
                        buildGridMetrics([
                          buildMetricTile(
                            "Call Made",
                            metrics?.totalCalls?.toString() ?? '-',
                            icon: Icons.call,
                            iconColor: Colors.black,
                          ),
                          buildMetricTile(
                            "Last Call",
                            'N/A',
                            icon: Icons.call_end,
                            iconColor: Colors.black,
                          ),
                          buildMetricTile(
                            "All Calls",
                            metrics?.totalCalls?.toString() ?? '-',
                            icon: Icons.call,
                            iconColor: Colors.black,
                          ),
                          buildMetricTile(
                            "Incoming Calls",
                            metrics?.incomingCalls?.toString() ?? '-',
                            icon: Icons.call,
                            iconColor: Colors.green,
                          ),
                          buildMetricTile(
                            "Outgoing Calls",
                            metrics?.outgoingCalls?.toString() ?? '-',
                            icon: Icons.call_made,
                            iconColor: Colors.blue,
                          ),
                          buildMetricTile(
                            "Missed Calls",
                            metrics?.missedCalls?.toString() ?? '-',
                            icon: Icons.call_missed,
                            iconColor: Colors.red,
                          ),
                          buildMetricTile(
                            "Connected Calls",
                            metrics?.connectedCalls?.toString() ?? '-',
                            icon: Icons.call,
                            iconColor: Colors.green,
                          ),
                          buildMetricTile(
                            "Not Connected Calls",
                            'N/A',
                            icon: Icons.call_end,
                            iconColor: Colors.red,
                          ),
                          buildMetricTile(
                            "Attempted Calls",
                            metrics?.attemptedCalls?.toString() ?? '-',
                            icon: Icons.phone_forwarded,
                            iconColor: Colors.black,
                          ),
                          buildMetricTile(
                            "Total Duration",
                            metrics?.totalDurationSeconds?.toString() ?? '-',
                            icon: Icons.timer,
                            iconColor: Colors.black,
                          ),
                        ]),
                        const SizedBox(height: 24),
                        // Tasks
                        const Text(
                          "Tasks",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        buildHorizontalMetricRow([
                          buildMetricTile(
                            "Late",
                            details?.tasksLate?.toString() ?? '-',
                            icon: Icons.schedule,
                            iconColor: Colors.black,
                          ),
                          buildMetricTile(
                            "Pending",
                            details?.tasksPending?.toString() ?? '-',
                            icon: Icons.calendar_today,
                            iconColor: Colors.black,
                          ),
                          buildMetricTile(
                            "Done",
                            details?.tasksDone?.toString() ?? '-',
                            icon: Icons.check_circle_outline,
                            iconColor: Colors.black,
                          ),
                          buildMetricTile(
                            "Created",
                            details?.tasksCreated?.toString() ?? '-',
                            icon: Icons.create,
                            iconColor: Colors.black,
                          ),
                        ]),
                        const SizedBox(height: 24),
                        // WhatsApp
                        const Text(
                          "WhatsApp",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        buildHorizontalMetricRow([
                          buildMetricTile(
                            "Incoming WhatsApp",
                            details?.whatsappIncoming?.toString() ?? '-',
                            icon: Icons.call,
                            iconColor: Colors.green,
                          ),
                          buildMetricTile(
                            "Outgoing WhatsApp",
                            details?.whatsappOutgoing?.toString() ?? '-',
                            icon: Icons.call_made,
                            iconColor: Colors.blue,
                          ),
                        ]),
                        const SizedBox(height: 24),
                        // Lead Stage
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Lead Stage",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.filter_list, size: 18),
                              label: const Text("Filter"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[200],
                                foregroundColor: Colors.black,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 24,
                          runSpacing: 16,
                          children: [
                            buildLeadStageTag(
                              'Fresh',
                              leadStages[0]['value'] as String,
                              const Color(0xFF1A237E),
                            ),
                            buildLeadStageTag(
                              'Interested',
                              leadStages[1]['value'] as String,
                              const Color(0xFF26A69A),
                            ),
                            buildLeadStageTag(
                              'Committed',
                              leadStages[2]['value'] as String,
                              const Color(0xFFFFB300),
                            ),
                            buildLeadStageTag(
                              'Not Interested',
                              leadStages[3]['value'] as String,
                              const Color(0xFF8D6E63),
                            ),
                            buildLeadStageTag(
                              'Not Connected',
                              leadStages[4]['value'] as String,
                              const Color(0xFFFFD54F),
                            ),
                            buildLeadStageTag(
                              'Call Back',
                              leadStages[5]['value'] as String,
                              const Color(0xFF8E24AA),
                            ),
                            buildLeadStageTag(
                              'Temple Visit',
                              leadStages[6]['value'] as String,
                              const Color(0xFF1976D2),
                            ),
                            buildLeadStageTag(
                              'Temple Donar',
                              leadStages[7]['value'] as String,
                              const Color(0xFF64B5F6),
                            ),
                            buildLeadStageTag(
                              'Lost',
                              leadStages[8]['value'] as String,
                              const Color(0xFFD32F2F),
                            ),
                            buildLeadStageTag(
                              'Won',
                              leadStages[9]['value'] as String,
                              const Color(0xFF388E3C),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
