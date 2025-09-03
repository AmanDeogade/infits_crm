import 'package:flutter/material.dart';
import 'package:crm_final/home_campaign/campaign_detail_screen.dart';
import 'package:crm_final/models/campaign.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:percent_indicator/percent_indicator.dart';
import '../constants.dart';

class CampaignTablePage extends StatefulWidget {
  const CampaignTablePage({super.key});

  @override
  State<CampaignTablePage> createState() => _CampaignTablePageState();
}

class _CampaignTablePageState extends State<CampaignTablePage> {
  List<Campaign> _campaigns = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCampaigns();
  }

  Future<void> _fetchCampaigns() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await http.get(Uri.parse('$baseUrl/campaigns'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List campaignsJson = data['campaigns'] ?? [];
        setState(() {
          _campaigns =
              campaignsJson.map((json) => Campaign.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load campaigns';
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: const EdgeInsets.all(10),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              /// Filters Row
              SizedBox(
                height: 44,
                child: Row(
                  children: [
                    Expanded(child: _dropdown('Search here...')),
                    const SizedBox(width: 8),
                    Expanded(child: _dropdown('Date')),
                    const SizedBox(width: 8),
                    Expanded(child: _dropdown('Select assignee')),
                    const SizedBox(width: 8),
                    Expanded(child: _dropdown('Select created by')),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              /// Table
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.lightBlue.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _tableHeader(),
                      const Divider(height: 0),
                      Expanded(
                        child:
                            _isLoading
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : _error != null
                                ? Center(child: Text(_error!))
                                : _campaigns.isEmpty
                                ? const Center(
                                  child: Text('No campaigns found'),
                                )
                                : ListView.builder(
                                  itemCount: _campaigns.length,
                                  itemBuilder:
                                      (_, idx) => _CampaignRow(
                                        campaign: _campaigns[idx],
                                      ),
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dropdown(String label) {
    return DropdownButtonFormField<String>(
      value: label,
      items: [DropdownMenuItem(value: label, child: Text(label))],
      onChanged: (_) {},
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.lightBlue.shade50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: const Row(
        children: [
          _TableCell('Name', flex: 2),
          _TableCell('Assignee'),
          _TableCell('Total Leads'),
          _TableCell('Progress'),
          _TableCell('Created On'),
          _TableCell('Actions'),
        ],
      ),
    );
  }
}

class _CampaignRow extends StatelessWidget {
  final Campaign campaign;
  const _CampaignRow({required this.campaign});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:
          () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CampaignDetailPage(campaign: campaign),
              //CampaignDetailsPage(campaign: campaign)
            ),
          ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              children: [
                _TableCell(campaign.name, flex: 2),
                const _TableCell(_AssigneeGroup()),
                const SizedBox(width: 30),
                _TableCell(campaign.totalLeads.toString()),
                _TableCell(
                  Transform.translate(
                    offset: const Offset(-70, 0),
                    child: CircularPercentIndicator(
                      radius: 18.0,
                      lineWidth: 3.0,
                      percent: (campaign.progressPct / 100).clamp(0.0, 1.0),
                      center: Text(
                        '${campaign.progressPct.toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 12),
                      ),
                      progressColor: Colors.green,
                      backgroundColor: Colors.grey.shade300,
                    ),
                  ),
                ),
                _TableCell(_formatDate(campaign.createdAt)),
                const _TableCell(_Actions()),
              ],
            ),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _AssigneeGroup extends StatelessWidget {
  const _AssigneeGroup();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (index) {
        return Transform.translate(
          offset: Offset(index * -12, 0),
          child: CircleAvatar(
            radius: 15,
            backgroundColor: Colors.white,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFBEE6FB), width: 2),
              ),
              child: Center(
                child: Icon(
                  index < 3 ? Icons.person : Icons.add,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          color: Colors.grey.shade200,
          child: const Icon(Icons.bar_chart, size: 20),
        ),
        const SizedBox(width: 8),
        Container(
          color: Colors.grey.shade200,
          child: const Icon(Icons.refresh, size: 20),
        ),
        const SizedBox(width: 8),
        Container(
          color: Colors.grey.shade200,
          child: const Icon(Icons.delete_outline, size: 20),
        ),
      ],
    );
  }
}

class _TableCell extends StatelessWidget {
  final dynamic child;
  final int flex;
  const _TableCell(this.child, {this.flex = 1});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: child is String ? Text(child as String) : (child as Widget),
    );
  }
}
