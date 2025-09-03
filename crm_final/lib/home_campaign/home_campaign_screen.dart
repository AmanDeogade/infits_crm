import 'package:crm_final/home_campaign/bars/side_bar.dart';
import 'package:crm_final/home_campaign/bars/top_bar.dart';
import 'package:crm_final/home_campaign/campaign_table_screen.dart';
import 'package:crm_final/home_campaign/cards/create_button.dart';
import 'package:crm_final/home_campaign/cards/add_lead_button.dart';
import 'package:crm_final/home_campaign/create_campaign_screen.dart';
import 'package:crm_final/home_campaign/upload_campaign/import_leads_wizard.dart';
import 'package:crm_final/home_campaign/add_lead_screen.dart';
import 'package:flutter/material.dart';

// ===== COLOR PALETTE (tuned to match screenshot) =====
const kSidebarBlue = Color(0xFFCEF3FF); // very light blue for sidebar + top bar
const kBorderBlue = Color(0xFFB8E9FF); // outlines
const kAccentGreen = Color(0xFF1EAA36); // 80 % circle

class Home_Campaign extends StatelessWidget {
  const Home_Campaign({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, fontFamily: 'Inter'),
      home: const CampaignDashboardScreen(),
    );
  }
}

class CampaignDashboardScreen extends StatelessWidget {
  const CampaignDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [const SideBar(), const Expanded(child: _PageArea())],
      ),
    );
  }
}

// =================== PAGE AREA =======================
class _PageArea extends StatelessWidget {
  const _PageArea();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TopBar(),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Row(
            children: [
              const Icon(Icons.arrow_back_ios_new, size: 18),
              const SizedBox(width: 6),
              const Text(
                'Campaign Dashboard',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              // Add Lead Button
              AddLeadButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AddLeadScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              // Create New Button
              CreateNewButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ImportLeadsWizard(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        // Remove 'const' since CampaignDashboardBody is not a const constructor
        const Expanded(child: CampaignTablePage()),
      ],
    );
  }
}
