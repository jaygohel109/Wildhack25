import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../components/task_flashcard.dart';
import '../components/profile_menu.dart';
import '../components/custom_bottom_nav_bar.dart';
import '../theme/theme_colors.dart';

class VolunteerHomePage extends StatefulWidget {
  final String userId;
  const VolunteerHomePage({super.key, required this.userId});

  @override
  State<VolunteerHomePage> createState() => _VolunteerHomePageState();
}

class _VolunteerHomePageState extends State<VolunteerHomePage> with TickerProviderStateMixin {
  List<Map<String, String>> suggestedTasks = [];
  List<Map<String, String>> currentTasks = [];
  List<Map<String, String>> completedTasks = [];
  final String baseUrl = "http://localhost:8000";
  bool isAnimating = false;
  bool isLoading = true;
  String firstName = "Volunteer";  // Default value in case fetching fails


  @override
  void initState() {
    super.initState();
    fetchUserProfile();  // Fetch user profile for firstName
    _fetchSuggestedTasks();
    _fetchCurrentTask();
  }

  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning, $firstName 👋';
    } else if (hour < 17) {
      return 'Good Afternoon, $firstName 🌤️';
    } else if (hour < 20) {
      return 'Good Evening, $firstName 🌇';
    } else {
      return 'Good Night, $firstName 🌙';
    }
  }


Future<void> fetchUserProfile() async {
  try {
    final url = Uri.parse("http://localhost:8000/profile?user_id=${widget.userId}");
    final response = await http.get(url);
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['user_profile'] != null) {
      setState(() {
        firstName = data['user_profile']['first_name'] ?? "Volunteer";  // Update firstName
      });
    }
  } catch (e) {
    print('Error fetching profile: $e');
  }
}

  Future<void> _fetchSuggestedTasks() async {
    try {
      final uri = Uri.parse("$baseUrl/matching_tasks?volunteer_id=${widget.userId}");
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> tasks = data["matching_tasks"];

        setState(() {
          suggestedTasks = tasks.map<Map<String, String>>((task) {
            return {
              "title": task["issue"] ?? "Untitled Task",
              "subtitle": task["description"] ?? "No Description",
              "task_id": task["_id"],
            };
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load suggested tasks");
      }
    } catch (e) {
      print("Error fetching tasks: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchCurrentTask() async {
    try {
      final uri = Uri.parse("$baseUrl/current_volunteer_tasks?user_id=${widget.userId}");
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> tasks = data["current_tasks"];

        setState(() {
          currentTasks = tasks.map<Map<String, String>>((task) {
            return {
              "title": task["issue"] ?? "Untitled Task",
              "subtitle": task["description"] ?? "No Description",
              "task_id": task["_id"],
            };
          }).toList();
        });
      } else {
        throw Exception("Failed to fetch current task");
      }
    } catch (e) {
      print("Error fetching current task: $e");
    }
  }

  void _onSwipeUp() async {
    if (suggestedTasks.isNotEmpty && !isAnimating) {
      setState(() => isAnimating = true);
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        final task = suggestedTasks.removeAt(0);
        suggestedTasks.add(task);
        isAnimating = false;
      });
    }
  }

  void _showTaskModal(Map<String, String> task, {bool showActions = true}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return FractionallySizedBox(
          heightFactor: 0.6,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  height: 4,
                  width: 40,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Text(task['title']!, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(task['subtitle']!, style: const TextStyle(fontSize: 16)),
                const Spacer(),
                Visibility(
                  visible: showActions,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          setState(() {
                            suggestedTasks.remove(task);
                          });

                          final uri = Uri.parse('$baseUrl/assign_task');
                          final response = await http.post(
                            uri,
                            headers: {'Content-Type': 'application/json'},
                            body: jsonEncode({
                              'task_id': task['task_id'],
                              'volunteer_id': widget.userId,
                            }),
                          );

                          if (response.statusCode == 200) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("✅ Approved: ${task['title']}")),
                            );
                            _fetchCurrentTask(); // Refresh current tasks
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("❌ Failed to assign task")),
                            );
                          }
                        },
                        icon: const Icon(Icons.check),
                        label: const Text("Approve"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            suggestedTasks.remove(task);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("❌ Rejected: ${task['title']}")),
                          );
                        },
                        icon: const Icon(Icons.close),
                        label: const Text("Reject"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCurrentTaskModal(Map<String, String> task) {
    _showTaskModal(task, showActions: false);
  }

  Widget _buildHistoryCard(Map<String, String> task) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          title: Text(task['title']!, style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text("Customer: ${task['customer']}"),
        ),
      ),
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
drawer: ProfileDrawer(userId: widget.userId), // ✅ Correct
    extendBody: true,
    backgroundColor: peachCream,
    appBar: AppBar(
leading: ProfileMenu(userId: widget.userId),  // ✅ Correct
      title: Text(
        _getGreetingMessage(),
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          fontFamily: 'Nunito',
          color: skyAsh,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.forum_outlined, size: 35, color: skyAsh),
          onPressed: () {
            // Navigate to messages
          },
        ),
        const SizedBox(width: 8),
      ],
      backgroundColor: sandBlush,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text("Suggested Tasks", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: suggestedTasks.isEmpty
                      ? const Center(child: Text("No suggested tasks at the moment."))
                      : Stack(
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
                              top: isAnimatingTop ? -200 : offset * 20,
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
                                  onTap: () => _showTaskModal(task),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 40),
                const Text("Current Task", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                if (currentTasks.isNotEmpty)
                  SizedBox(
                    height: 160,
                    child: PageView.builder(
                      itemCount: currentTasks.length,
                      controller: PageController(viewportFraction: 0.9),
                      itemBuilder: (context, index) {
                        final task = currentTasks[index];
                        return GestureDetector(
                          onTap: () => _showCurrentTaskModal(task),
                          child: Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            color: Colors.orange[100],
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.assignment_turned_in, size: 30),
                                  const SizedBox(height: 8),
                                  Text(task['title']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  Text(task['subtitle']!, style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 30),
                const Text("History", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ...completedTasks.map(_buildHistoryCard),
              ],
            ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            color: Colors.transparent,
            child: const CustomBottomNavBar(),
          ),
        ),
      ),
    );
  }
}