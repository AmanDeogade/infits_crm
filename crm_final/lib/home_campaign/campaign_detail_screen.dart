import 'package:crm_final/home_campaign/bars/side_bar.dart';
import 'package:crm_final/home_campaign/bars/top_bar.dart';
import 'package:crm_final/home_campaign/calling_report.dart';
import 'package:crm_final/home_campaign/cards/campaign_card.dart';
import 'package:crm_final/home_campaign/cards/report_tile.dart';
import 'package:crm_final/models/campaign.dart';
import 'package:flutter/material.dart';

const kSidebarBlue = Color(0xFFCEF3FF);
const kBorderBlue = Color(0xFFB8E9FF);
const kAccentGreen = Color(0xFF1EAA36);

class CampaignDetailPage extends StatelessWidget {
  final Campaign campaign;

  const CampaignDetailPage({super.key, required this.campaign});

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
        Expanded(child: CampaignDetail(campaign: campaign)),
      ],
    );
  }
}

class CampaignDetail extends StatefulWidget {
  final Campaign campaign;

  const CampaignDetail({super.key, required this.campaign});

  @override
  State<CampaignDetail> createState() => _CampaignDetailState();
}

class _CampaignDetailState extends State<CampaignDetail> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          InkWell(
            onTap:
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            CallingReportScreen(campaign: widget.campaign),
                    //CampaignDetailsPage(campaign: campaign)
                  ),
                ),
            child: CampaignCard(campaign: widget.campaign),
          ), // Update if you want to pass data here too
          const SizedBox(height: 20),
          ReportTile('${widget.campaign.name} Report'),
          const ReportTile('Campaign Calling Report'),

          InkWell(
            onTap:
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            CallingReportScreen(campaign: widget.campaign),
                    //CampaignDetailsPage(campaign: campaign)
                  ),
                ),
            child: ReportTile('Lead Status Report'),
          ),
        ],
      ),
    );
  }
}
