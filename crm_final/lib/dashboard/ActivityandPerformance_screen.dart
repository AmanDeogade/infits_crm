import 'dart:convert';
import 'package:crm_final/home_campaign/bars/side_bar.dart';
import 'package:crm_final/home_campaign/bars/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/caller.dart';
import '../services/caller_service.dart';
import 'caller_detail_screen.dart';

class ActivityPerformanceScreen extends StatefulWidget {
  const ActivityPerformanceScreen({super.key});

  @override
  State<ActivityPerformanceScreen> createState() =>
      _ActivityPerformanceScreenState();
}

class _ActivityPerformanceScreenState extends State<ActivityPerformanceScreen> {
  bool isSidebarOpen = false;
  List<Caller> callers = [];
  bool isLoading = true;
  String? error;

  void toggleSidebar() {
    setState(() {
      isSidebarOpen = !isSidebarOpen;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchCallers();
  }

  Future<void> fetchCallers() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      callers = await CallerService.fetchCallers();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load callers: \\${e.toString()}';
        isLoading = false;
      });
    }
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
                TopBar(),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Activity & Performance / Overall States',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child:
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : error != null
                          ? Center(child: Text(error!))
                          : callers.isEmpty
                          ? const Center(child: Text('No callers found'))
                          : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: callers.length,
                            itemBuilder: (context, index) {
                              final caller = callers[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: const Color(0xFFd2f1ff),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFd2f1ff),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.person, size: 24),
                                          const SizedBox(width: 8),
                                          Text(
                                            caller.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Text(
                                            'Caller',
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            'First call: ${caller.firstCallTime ?? '-'}  |  Last call: ${caller.lastCallTime ?? '-'}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        MetricColumn(
                                          '${caller.totalCalls ?? 0}',
                                          'Total Calls',
                                        ),
                                        const MetricSeparator(),
                                        MetricColumn(
                                          '${caller.connectedCalls ?? 0}',
                                          'Connected',
                                        ),
                                        const MetricSeparator(),
                                        MetricColumn(
                                          '${caller.notConnectedCalls ?? 0}',
                                          'Not Connected',
                                        ),
                                        const MetricSeparator(),
                                        MetricColumn(
                                          '${caller.totalDurationMinutes ?? 0}',
                                          'Duration',
                                        ),
                                        const MetricSeparator(),
                                        MetricColumn(
                                          '${caller.durationRaisePercentage?.toStringAsFixed(2) ?? '0.00'}',
                                          'Duration Raise',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        right: 16,
                                        bottom: 12,
                                      ),
                                      child: Align(
                                        alignment: Alignment.bottomRight,
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) =>
                                                        CallerDetailScreen(
                                                          caller: caller,
                                                        ),
                                              ),
                                            );
                                          },
                                          child: const Text('See details'),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
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

class MetricColumn extends StatelessWidget {
  final String value;
  final String label;

  const MetricColumn(this.value, this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.black54)),
      ],
    );
  }
}

class MetricSeparator extends StatelessWidget {
  const MetricSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      '|',
      style: TextStyle(
        fontSize: 18,
        color: Colors.grey.shade600,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
