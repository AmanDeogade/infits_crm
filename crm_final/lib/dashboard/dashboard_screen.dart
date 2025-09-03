import 'package:crm_final/dashboard/widgets/dashboard_tile.dart';
import 'package:crm_final/home_campaign/bars/side_bar.dart';
import 'package:crm_final/home_campaign/bars/top_bar.dart';
import 'package:flutter/material.dart';
import 'ActivityandPerformance_screen.dart';
import 'add_user_screen.dart';
import 'users_list_screen.dart';
import 'follow_ups_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<List<String>> campaignRows = [];
  List<List<String>> callerRows = [];
  List<List<String>> followUpRows = [];
  List<List<String>> assigneeLeadRows = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    setState(() => loading = true);
    fetchCampaignStats();
    fetchCallerStats();
    fetchFollowUpStats();
    fetchAssigneeLeadStats();
  }

  Future<void> fetchCampaignStats() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/campaigns/dashboard/stats'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List campaigns = data['campaigns'] ?? [];

        print('Fetched campaigns data: $campaigns'); // Debug log

        if (campaigns.isNotEmpty) {
          campaignRows =
              campaigns.map<List<String>>((c) {
                final row = [
                  (c['name'] ?? '').toString(), // Campaign Name
                  (c['total_leads'] ?? '0').toString(), // Total Leads
                  (c['assignee_count'] ?? '0').toString(), // Assignees
                  (c['progress_pct'] ?? '0').toString() + '%', // Progress
                ];
                print('Created campaign row: $row'); // Debug log
                return row;
              }).toList();

          print('Final campaignRows: $campaignRows'); // Debug log
        } else {
          campaignRows = [
            ['No campaigns found', '0', '0', '0%'],
          ];
        }
      } else {
        print('Failed to fetch campaigns: ${response.statusCode}');
        campaignRows = [
          ['Error loading data', '0', '0', '0%'],
        ];
      }
    } catch (e) {
      print('Error fetching campaign stats: $e');
      campaignRows = [
        ['Network error', '0', '0', '0%'],
      ];
    }
    setState(() {});
  }

  Future<void> fetchCallerStats() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/callers'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List callers = data['callers'] ?? [];
        callerRows =
            callers
                .map<List<String>>(
                  (c) => [
                    (c['name'] ?? '').toString(), // Sales Rep
                    (c['total_calls'] ?? '').toString(),
                    (c['total_duration_minutes'] ?? '').toString() + ' min',
                    (c['connected_calls'] ?? '').toString(),
                    (c['not_connected_calls'] ?? '').toString(),
                  ],
                )
                .toList();
      } else {
        callerRows = [
          ['Error loading data', '0', '0 min', '0', '0'],
        ];
      }
    } catch (e) {
      print('Error fetching caller stats: $e');
      callerRows = [
        ['Network error', '0', '0 min', '0', '0'],
      ];
    }
    setState(() {});
  }

  Future<void> fetchFollowUpStats() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/assignees/follow-up-stats'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List followUps = data['follow_ups'] ?? [];

        if (followUps.isNotEmpty) {
          followUpRows = followUps.map<List<String>>((f) {
            final row = [
              (f['assignee_name'] ?? 'Unknown').toString(), // Assignee Name
              (f['fresh_count'] ?? '0').toString(), // Fresh
              (f['follow_up_count'] ?? '0').toString(), // Follow Up
              (f['converted_count'] ?? '0').toString(), // Done/Converted
              (f['rejected_count'] ?? '0').toString(), // Cancel/Rejected
            ];
            return row;
          }).toList();
        } else {
          followUpRows = [
            ['No assignees found', '0', '0', '0', '0'],
          ];
        }
      } else {
        print('Failed to fetch follow-up stats: ${response.statusCode}');
        followUpRows = [
          ['Error loading data', '0', '0', '0', '0'],
        ];
      }
    } catch (e) {
      print('Error fetching follow-up stats: $e');
      followUpRows = [
        ['Network error', '0', '0', '0', '0'],
      ];
    }
    setState(() => loading = false);
  }

  Future<void> fetchAssigneeLeadStats() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/assignees/lead-stats'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Raw API response: $data'); // Debug log
        
        final assignees = data['assignees'];
        print('Assignees data type: ${assignees.runtimeType}'); // Debug log
        print('Assignees data: $assignees'); // Debug log
        
        if (assignees is List && assignees.isNotEmpty) {
          assigneeLeadRows = assignees.map<List<String>>((a) {
            final row = [
              (a['assignee_name'] ?? 'Unknown').toString(), // Assignee Name
              (a['fresh_leads'] ?? '0').toString(), // Fresh Leads
              (a['active_leads'] ?? '0').toString(), // Active Leads
              (a['won_leads'] ?? '0').toString(), // Won Leads
              (a['loss_leads'] ?? '0').toString(), // Loss Leads
            ];
            print('Created assignee lead row: $row'); // Debug log
            return row;
          }).toList();
          
          print('Final assigneeLeadRows: $assigneeLeadRows'); // Debug log
        } else {
          print('No assignees data or empty list');
          assigneeLeadRows = [
            ['No assignees found', '0', '0', '0', '0']
          ];
        }
      } else {
        print('Failed to fetch assignee lead stats: ${response.statusCode}');
        assigneeLeadRows = [
          ['Error loading data', '0', '0', '0', '0']
        ];
      }
    } catch (e) {
      print('Error fetching assignee lead stats: $e');
      print('Error details: ${e.toString()}'); // More detailed error
      assigneeLeadRows = [
        ['Network error', '0', '0', '0', '0']
      ];
    }
    setState(() {});
  }

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
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      const Icon(Icons.home_outlined),
                      const SizedBox(width: 8),
                      const Text(
                        'Dashboard',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(25),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const AddUserScreen(),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.person_add,
                                        color: Colors.black87,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Add User',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(25),
                                onTap: () {
                                  setState(() => loading = true);
                                  fetchCampaignStats();
                                  fetchCallerStats();
                                  fetchFollowUpStats();
                                  fetchAssigneeLeadStats();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.refresh,
                                        color: Colors.blue.shade700,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Refresh',
                                        style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.3,
                      children: [
                        DashboardTile(
                          title: 'Activity & Performance',
                          color: Colors.blueAccent,
                          dataRows: loading ? null : callerRows,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => const ActivityPerformanceScreen(),
                              ),
                            );
                          },
                        ),
                        DashboardTile(
                          title: 'Follow-ups',
                          color: Colors.lightBlue,
                          dataRows: loading ? null : followUpRows,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FollowUpsScreen(),
                              ),
                            );
                          },
                        ),
                        DashboardTile(
                          title: 'Calling Campaign',
                          color: Colors.lightGreen,
                          dataRows: loading ? null : campaignRows,
                          onTap: () {},
                        ),
                        DashboardTile(
                          title: 'Lead by Stages',
                          color: Color(0xFFA5D6A7),
                          dataRows: loading ? null : assigneeLeadRows,
                          onTap: () {},
                        ),
                        DashboardTile(
                          title: 'Filters',
                          color: Colors.orangeAccent,
                        ),
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
}
