import 'package:flutter/material.dart';
import '../component/task_flashcard.dart';

class VolunteerHomePage extends StatefulWidget {
  const VolunteerHomePage({super.key});

  @override
  State<VolunteerHomePage> createState() => _VolunteerHomePageState();
}

class _VolunteerHomePageState extends State<VolunteerHomePage> with TickerProviderStateMixin {
  List<Map<String, String>> suggestedTasks = [
    {
      'title': '📱 Set up Phone',
      'subtitle': 'Assist with smartphone configuration for an elderly user.',
    },
    {
      'title': '💡 Replace Bulbs',
      'subtitle': 'Help change light bulbs in the hallway and kitchen.',
    },
    {
      'title': '🛍️ Grocery Pickup',
      'subtitle': 'Buy daily essentials from the local store for Mrs. Rao.',
    },
  ];

  bool isAnimating = false;

  void _onSwipeUp() async {
    if (suggestedTasks.isNotEmpty && !isAnimating) {
      setState(() => isAnimating = true);

      await Future.delayed(const Duration(milliseconds: 300)); // wait for animation
      setState(() {
        final task = suggestedTasks.removeAt(0);
        suggestedTasks.add(task);
        isAnimating = false;
      });
    }
  }

  void _onTaskTap(Map<String, String> task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 40,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Text(task['title']!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(task['subtitle']!, style: const TextStyle(fontSize: 16, color: Colors.black87)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        suggestedTasks.remove(task);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ Approved: ${task['title']}")));
                    },
                    icon: const Icon(Icons.check),
                    label: const Text("Approve"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        suggestedTasks.remove(task);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Rejected: ${task['title']}")));
                    },
                    icon: const Icon(Icons.close),
                    label: const Text("Reject"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryCard(String title, String status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          title: Text(title),
          subtitle: Text("Status: $status"),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topTaskKey = suggestedTasks.isNotEmpty ? suggestedTasks[0]['title'] : "";

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
          const Text("Suggested Tasks", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: Stack(
              clipBehavior: Clip.none,
              children: suggestedTasks.asMap().entries.toList().reversed.map((entry) {
                final index = entry.key;
                final task = entry.value;
                final int offset = suggestedTasks.length - 1 - index;
                final bool isTop = index == 0;
                final bool isAnimatingTop = isTop && isAnimating;

                return AnimatedPositioned(
                  key: ValueKey(task['title']),
                  duration: const Duration(milliseconds: 300),
                  top: isAnimatingTop ? -150 : offset * 15,
                  left: 0,
                  right: 0,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: isAnimatingTop ? 0.0 : 1.0,
                    child: TaskFlashCard(
                      title: task['title']!,
                      subtitle: task['subtitle']!,
                      elevation: 5 - offset.toDouble(),
                      isTopCard: isTop,
                      onSwipeUp: _onSwipeUp,
                      onTap: () => _onTaskTap(task),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 40),
          const Text("History", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildHistoryCard("Help with groceries", "Completed"),
          _buildHistoryCard("Doctor appointment", "Completed"),
        ],
      ),
    );
  }
}
