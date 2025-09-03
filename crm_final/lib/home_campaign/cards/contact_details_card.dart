import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:crm_final/models/lead.dart';

class ContactCard extends StatelessWidget {
  final Lead? lead;

  const ContactCard({super.key, this.lead});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.lightBlue.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header: Name + Fresh Chip + Stars + Menu
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lead != null
                            ? '${lead!.firstName ?? ''} ${lead!.lastName ?? ''}'
                                .trim()
                            : 'No lead selected',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Chip(
                            label: Text(lead?.currentStatus ?? 'Fresh'),
                            backgroundColor: Color(0xFFD6F2FA),
                            labelStyle: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          SizedBox(width: 12),
                          for (int i = 0; i < 5; i++)
                            Icon(
                              i < (lead?.rating ?? 0)
                                  ? Icons.star
                                  : Icons.star_border,
                              color:
                                  i < (lead?.rating ?? 0) ? Colors.amber : null,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_vert),
              ],
            ),
            const Divider(height: 32),

            /// Email
            const Row(
              children: [
                Icon(Icons.email_outlined, size: 18),
                SizedBox(width: 8),
                Text('Email', style: TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 26, top: 4, bottom: 12),
              child: Text(lead?.email ?? 'No email provided'),
            ),

            /// Phone
            const Row(
              children: [
                Icon(Icons.phone_outlined, size: 18),
                SizedBox(width: 8),
                Text('Phone', style: TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 26, top: 4, bottom: 12),
              child: Text(lead?.phone ?? 'No phone number provided'),
            ),

            /// Alternate Phone
            const Row(
              children: [
                Icon(Icons.phone_outlined, size: 18, color: Colors.grey),
                SizedBox(width: 8),
                Text('Alternate phone', style: TextStyle(color: Colors.grey)),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 26, top: 4, bottom: 12),
              child: Text(
                lead?.altPhone ?? 'No alternate phone number provided',
                style: TextStyle(color: Colors.grey),
              ),
            ),

            /// Address
            const Row(
              children: [
                Text('Address', style: TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 0, top: 4, bottom: 12),
              child: Text(lead?.addressLine ?? 'No address provided'),
            ),

            /// State
            const Row(
              children: [
                Text('State', style: TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 0, top: 4, bottom: 12),
              child: Text(lead?.state ?? 'No state provided'),
            ),

            /// Bottom Bar
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFD6F2FA),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _ContactAction(icon: Icons.call, label: 'Call'),
                  _ContactAction(icon: Icons.access_time, label: 'Call Later'),
                  _ContactAction(
                    icon: FontAwesomeIcons.whatsapp,
                    label: 'WhatsApp',
                  ),
                  _ContactAction(icon: Icons.sms_outlined, label: 'SMS'),
                  _ContactAction(icon: Icons.note_alt_outlined, label: 'Notes'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactAction extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ContactAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
