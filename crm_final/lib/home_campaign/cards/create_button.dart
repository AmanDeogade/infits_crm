import 'package:flutter/material.dart';

/// Grey rounded button:  ⊕  + Create New
class CreateNewButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CreateNewButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey.shade200, // light‑grey fill
      borderRadius: BorderRadius.circular(18), // pill corners
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.add, size: 15, color: Colors.black),
              SizedBox(width: 3),
              Text(
                'Create New',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
