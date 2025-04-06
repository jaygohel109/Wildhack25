import 'package:flutter/material.dart';
import '../components/task_flashcard.dart';
import '../components/task_detail_modal.dart';

class VolunteerHomePage extends StatefulWidget {
  const VolunteerHomePage({super.key});

  @override
  State<VolunteerHomePage> createState() => _VolunteerHomePageState();
}

class _VolunteerHomePageState extends State<VolunteerHomePage> with TickerProviderStateMixin {
  List<Map<String, String>> suggestedTasks = [
    {
      'title': '📱 Set up Phone',
      'subtitle': 'Assist with smartphone configuration for Mr. Mehta.',
    },
    {
      'title': '💡 Replace Bulbs',
      'subtitle': 'Change bulbs in kitchen for Ms. Lata.',
    },
    {
      'title': '🛍️ Grocery Pickup',
      'subtitle': 'Pickup groceries for Mrs. Rao from local store.',
    },
  ];

  Map<String, String>? currentTask = {
    'title': '🏥 Doctor Appointment',
    'details': 'Assist Mr. Sharma to the clinic at 4 PM.',
  };

  void _onSwipeUp() async {
    if (suggestedTasks.isNotEmpty) {
      final task = suggestedTasks.removeAt(0);
      setState(() {
        suggestedTasks.add(task);
      });
    }
  }

  void _showTaskDetailsModal(Map<String, String> task, {bool isCurrent = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: TaskDetailModal(
          task: task,
          showActions: !isCurrent,
          onApprove: !isCurrent
              ? () {
                  Navigator.pop(context);
                  setState(() {
                    suggestedTasks.remove(task);
                    currentTask = task;
                  });
                }
              : null,
          onReject: !isCurrent
              ? () {
                  Navigator.pop(context);
                  setState(() {
                    suggestedTasks.remove(task);
                  });
                }
              : null,
        ),
      ),
    );
  }

  Widget _buildHistoryCard(String title, String customer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("Customer: $customer"),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF13547A),
        elevation: 0,
        title: const Text("Good Morning 👋"),
        actions: [
          IconButton(icon: const Icon(Icons.chat_bubble_outline), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Suggested Tasks", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: Stack(
              clipBehavior: Clip.none,
              children: suggestedTasks.asMap().entries.toList().reversed.map((entry) {
                final index = entry.key;
                final task = entry.value;
                final int offset = suggestedTasks.length - 1 - index;
                final bool isTop = index == 0;

                return Positioned(
                  top: offset * 18,
                  left: 0,
                  right: 0,
                  child: TaskFlashCard(
                    title: task['title']!,
                    subtitle: task['subtitle']!,
                    elevation: 5 - offset.toDouble(),
                    isTopCard: isTop,
                    onSwipeUp: _onSwipeUp,
                    onTap: () => _showTaskDetailsModal(task),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 30),
          if (currentTask != null) ...[
            const Text("Current Task", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _showTaskDetailsModal(currentTask!, isCurrent: true),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentTask!['title']!,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text("In Progress", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),

          ],
          const SizedBox(height: 30),
          const Text("History", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildHistoryCard("Call Doctor", "Mr. Joshi"),
          _buildHistoryCard("Install WhatsApp", "Mrs. Sharma"),
        ],
      ),
    );
  }
}
