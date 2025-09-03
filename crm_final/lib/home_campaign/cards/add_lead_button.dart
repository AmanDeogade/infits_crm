import 'package:flutter/material.dart';

/// Grey rounded button: 📝 Add Lead (matching Create New button style)
class AddLeadButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddLeadButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey.shade200, // light‑grey fill (same as Create New)
      borderRadius: BorderRadius.circular(18), // pill corners (same as Create New)
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.person_add, size: 15, color: Colors.black), // black icon (same as Create New)
              SizedBox(width: 3), // same spacing as Create New
              Text(
                'Add Lead',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black, // black text (same as Create New)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 