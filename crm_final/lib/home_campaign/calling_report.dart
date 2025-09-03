import 'package:crm_final/home_campaign/bars/side_bar.dart';
import 'package:crm_final/home_campaign/bars/top_bar.dart';
import 'package:crm_final/home_campaign/cards/campaign_card.dart';
import 'package:crm_final/home_campaign/cards/contact_details_card.dart';
import 'package:crm_final/models/campaign.dart';
import 'package:crm_final/models/lead.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants.dart';

const kSidebarBlue = Color(0xFFCEF3FF); // very light blue for sidebar + top bar
const kBorderBlue = Color(0xFFB8E9FF); // outlines
const kAccentGreen = Color(0xFF1EAA36); // 80 % circle

class CallingReportScreen extends StatelessWidget {
  final Campaign campaign;

  const CallingReportScreen({super.key, required this.campaign});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, fontFamily: 'Inter'),
      home: DashboardScreen(campaign: campaign),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  final Campaign campaign;

  const DashboardScreen({super.key, required this.campaign});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          const SideBar(),
          Expanded(child: _PageArea(campaign: campaign)),
        ],
      ),
    );
  }
}

class _PageArea extends StatelessWidget {
  final Campaign campaign;

  const _PageArea({super.key, required this.campaign});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TopBar(),
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Row(
            children: [
              Icon(Icons.arrow_back_ios_new, size: 18),
              SizedBox(width: 6),
              Text(
                'Campaign Dashboard',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        Expanded(
          child: CampaignDashboard(
            campaignId: campaign.id ?? 0,
            campaign: campaign,
          ),
        ),
      ],
    );
  }
}

class CampaignDashboard extends StatefulWidget {
  final int campaignId;
  final Campaign campaign;
  const CampaignDashboard({
    super.key,
    required this.campaignId,
    required this.campaign,
  });

  @override
  State<CampaignDashboard> createState() => _CampaignDashboardState();
}

class _CampaignDashboardState extends State<CampaignDashboard> {
  List<Lead> _leads = [];
  bool _isLoading = true;
  String? _error;
  Lead? _selectedLead;

  @override
  void initState() {
    super.initState();
    _fetchLeads();
  }

  Future<void> _fetchLeads() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await http.get(Uri.parse('$baseUrl/leads'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List leadsJson = data['leads'] ?? [];
        setState(() {
          _leads =
              leadsJson
                  .map((json) => Lead.fromJson(json))
                  .where((lead) => lead.campaignId == widget.campaignId)
                  .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load leads';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: \\${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Sidebar
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 350,
                  color: Colors.white,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CampaignCard(campaign: widget.campaign),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Lead Status Report',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Main Content
              Row(
                children: [
                  // Leads List
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 350,
                      decoration: BoxDecoration(
                        border: Border.all(color: kBorderBlue),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            color: const Color(0xFFD8F1FF),
                            child: Row(
                              children: [
                                const Text(
                                  'Active',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  "(${widget.campaign.totalLeads})",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child:
                                _isLoading
                                    ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                    : _error != null
                                    ? Center(child: Text(_error!))
                                    : _leads.isEmpty
                                    ? const Center(
                                      child: Text('No leads found'),
                                    )
                                    : ListView.builder(
                                      itemCount: _leads.length,
                                      itemBuilder: (context, index) {
                                        final lead = _leads[index];
                                        return Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.lightBlue.shade200,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: ListTile(
                                            onTap: () {
                                              setState(() {
                                                _selectedLead = lead;
                                              });
                                            },
                                            title: Text(
                                              (lead.firstName ?? '') +
                                                  (lead.lastName != null
                                                      ? ' ${lead.lastName}'
                                                      : ''),
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (lead.phone != null)
                                                  Text(lead.phone!),
                                                Row(
                                                  children: [
                                                    const Text('Status: '),
                                                    Chip(
                                                      label: Text(
                                                        lead.currentStatus ??
                                                            'Unknown',
                                                      ),
                                                      backgroundColor:
                                                          const Color(
                                                            0xFFE8F4F8,
                                                          ),
                                                      labelStyle:
                                                          const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            trailing: const Icon(
                                              Icons.star_border,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Contact Detail & History
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 510,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [ContactCard(lead: _selectedLead)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
