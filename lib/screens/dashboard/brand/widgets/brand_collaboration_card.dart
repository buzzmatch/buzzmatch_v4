import 'package:flutter/material.dart';
import '../../../../models/collaboration_model.dart';

class BrandCollaborationCard extends StatelessWidget {
  final CollaborationModel collaboration;
  final VoidCallback onTap;

  const BrandCollaborationCard({
    Key? key,
    required this.collaboration,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              collaboration.name, // Assuming 'name' is a field in CollaborationModel
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Add more fields as necessary
          ],
        ),
      ),
    );
  }
} 