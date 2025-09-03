import 'package:flutter/material.dart';

const kSidebarBlue = Color(0xFFCEF3FF); // very light blue for sidebar + top bar
const kBorderBlue = Color(0xFFB8E9FF); // outlines
const kAccentGreen = Color(0xFF1EAA36);

class ReportTile extends StatefulWidget {
  final String title;
  const ReportTile(this.title);
  @override
  State<ReportTile> createState() => _ReportTileState();
}

class _ReportTileState extends State<ReportTile> {
  //bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        border: Border.all(color: kBorderBlue),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        widget.title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    );
  }
}
