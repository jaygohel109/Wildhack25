import 'package:flutter/material.dart';

class TaskFlashCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double elevation;
  final bool isTopCard;
  final VoidCallback onSwipeUp;
  final VoidCallback onTap;

  const TaskFlashCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.elevation,
    required this.isTopCard,
    required this.onSwipeUp,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        // Detect upward drag
        if (details.delta.dy < -10 && isTopCard) {
          onSwipeUp();
        }
      },
      onTap: isTopCard ? onTap : null,
      child: SizedBox(
        height: 120,
        child: Card(
          elevation: elevation,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: isTopCard
                ? const BorderSide(color: Colors.teal, width: 2)
                : BorderSide.none,
          ),
          color: isTopCard ? const Color(0xFFE0F7FA) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
