import 'package:crm_final/models/campaign.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

const kSidebarBlue = Color(0xFFCEF3FF); // very light blue for sidebar + top bar
const kBorderBlue = Color(0xFFB8E9FF); // outlines
const kAccentGreen = Color(0xFF1EAA36); // 80 % circle

class CampaignCard extends StatelessWidget {
  const CampaignCard({super.key, required this.campaign});

  final Campaign campaign;

  @override
  Widget build(BuildContext context) {
    final pctText = '${(campaign.progressPct * 1).round()}%';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: kBorderBlue),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // ─── LEFT COLUMN ────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // campaign name row
                Row(
                  children: [
                    const Icon(Icons.alternate_email, size: 16),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        campaign.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // total leads row
                Row(
                  children: [
                    const Icon(Icons.people_alt_rounded, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      campaign.totalLeads.toString(),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // overlapping avatars / add button
                Row(
                  children: List.generate(4, (index) {
                    return Transform.translate(
                      offset: Offset(index * -12, 0),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: kBorderBlue, width: 2),
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
                ),
              ],
            ),
          ),

          // ─── RIGHT COLUMN ───────────────────────────────────────────────
          Column(
            children: [
              Row(
                children: [
                  // circular progress
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularPercentIndicator(
                          radius: 20.0,
                          lineWidth: 3.0,
                          percent: (campaign.progressPct / 100).clamp(0.0, 1.0),
                          center: Text(
                            '${campaign.progressPct.toStringAsFixed(0)}%',
                            style: const TextStyle(fontSize: 12),
                          ),
                          progressColor: Colors.green,
                          backgroundColor: Colors.grey.shade300,
                        ),
                        Center(
                          child: Text(
                            pctText,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  // call button
                  Material(
                    shape: const CircleBorder(),
                    color: kSidebarBlue,
                    child: IconButton(
                      icon: const Icon(Icons.call),
                      splashRadius: 24,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
