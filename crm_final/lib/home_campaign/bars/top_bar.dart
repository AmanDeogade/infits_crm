import 'package:crm_final/home_campaign/bars/side_bar.dart';
import 'package:crm_final/screens/profile_screen.dart';
import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  const TopBar();

  @override
  Widget build(BuildContext context) {
    // "John Doe"

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: 64,
      decoration: BoxDecoration(
        color: kSidebarBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // avatar toggle & name
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade400, width: 2),
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Name',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(width: 352),
          // search bar
          Expanded(
            child: SizedBox(
              height: 36,
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, size: 18),
                  hintText: 'Search here…',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: kBorderBlue),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          _CircleIcon(Icons.access_time),
          _CircleIcon(Icons.add_alert_outlined),
          _CircleIcon(
            Icons.settings,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          _CircleIcon(
            Icons.person,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}



class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _CircleIcon(this.icon, {this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Material(
        shape: const CircleBorder(),
        color: Colors.white,
        child: IconButton(
          onPressed: onPressed ?? () {},
          icon: Icon(icon, size: 18),
          splashRadius: 22,
        ),
      ),
    );
  }
}
