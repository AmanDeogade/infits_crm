import 'package:crm_final/dashboard/dashboard_screen.dart' as dashboard;
import 'package:crm_final/dashboard/all_users_screen.dart';
import 'package:crm_final/home_campaign/home_campaign_screen.dart';
import 'package:crm_final/home_campaign/add_filter_screen.dart';
import 'package:flutter/material.dart';
import 'package:crm_final/services/auth_service.dart';
import 'package:crm_final/authentication/login_screen.dart';
import 'package:crm_final/home_campaign/donation_details_screen.dart';
import 'package:crm_final/home_campaign/prasadam_details_screen.dart';
import 'package:crm_final/screens/profile_screen.dart';

// ===== COLOR PALETTE (tuned to match screenshot) =====
const kSidebarBlue = Color(0xFFCCF0FF); // very light blue for sidebar + top bar
const kBorderBlue = Color(0xFFCCF0FF); // outlines
const kAccentGreen = Color(0xFF1EAA36); // 80 % circle

class SideBar extends StatelessWidget {
  const SideBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Container(
        width: 260,
        decoration: const BoxDecoration(
          color: kSidebarBlue,
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section (fixed)
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.chevron_left_rounded),
                    onPressed: () {},
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Logo',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                // Scrollable menu section
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _NavItem(
                          'Dashboard',
                          Icons.dashboard_rounded,
                          //isActive: true,
                          onTap:
                              () => Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder:
                                      (context) => const dashboard.DashboardScreen(),
                                ),
                              ),
                        ),
                        const _NavItem('Lead & Filter', Icons.filter_alt_outlined),
                        _NavItem(
                          'Users',
                          Icons.people_outline,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const AllUsersScreen(),
                            ),
                          ),
                        ),
                        _NavItem(
                          'Campaign',
                          Icons.mail_outline_rounded,
                          onTap:
                              () => Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          Home_Campaign(), // Replace with your actual Campaign screen widget
                                ),
                              ),
                        ),
                        _NavItem(
                          'Add Filter',
                          Icons.filter_list,
                          onTap:
                              () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const AddFilterScreen(),
                                ),
                              ),
                        ),
                        const _NavItem('Message Templates', Icons.chat_outlined),
                        const _NavItem('Reports', Icons.insert_chart_outlined_rounded),
                        // Settings navigation to Profile Screen
                        _NavItem(
                          'Settings',
                          Icons.settings_outlined,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          ),
                        ),
                        _NavItem(
                          'Donation Details',
                          Icons.monetization_on_outlined,
                          onTap:
                              () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const DonationDetailsScreen(),
                                ),
                              ),
                        ),
                        _NavItem(
                          'Prasadam Details',
                          Icons.restaurant_menu_outlined,
                          onTap:
                              () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const PrasadamDetailsScreen(),
                                ),
                              ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                // Logout section (fixed at bottom)
                _NavItem(
                  'Log out',
                  Icons.logout,
                  onTap: () => AuthService.logoutWithConfirmation(context),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback? onTap;

  const _NavItem(this.label, this.icon, {this.isActive = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bgColor = isActive ? Colors.black : Colors.transparent;
    final fgColor = isActive ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(icon, size: 18, color: fgColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: fgColor,
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
