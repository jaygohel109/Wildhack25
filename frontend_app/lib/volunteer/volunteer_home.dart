import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
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

class _VolunteerHomePageState extends State<VolunteerHomePage>
    with TickerProviderStateMixin {
  List<Map<String, String>> suggestedTasks = [];
  List<Map<String, String>> currentTasks = [];
  List<Map<String, String>> completedTasks = [];
  Timer? _refreshTimer;
  final String baseUrl = "http://localhost:8000";
  bool isAnimating = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSuggestedTasks();
    _fetchCurrentTask();
    _fetchCompletedTasks();

    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _fetchSuggestedTasks();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchSuggestedTasks() async {
    try {
      final uri =
          Uri.parse("$baseUrl/matching_tasks?volunteer_id=${widget.userId}");
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> tasks = data["matching_tasks"];
        final newTasks = tasks.map<Map<String, String>>((task) {
          return {
            "title": task["issue"] ?? "Untitled Task",
            "subtitle": task["description"] ?? "No Description",
            "task_id": task["_id"],
          };
        }).toList();

        if (!listEquals(newTasks, suggestedTasks)) {
          setState(() {
            suggestedTasks = newTasks;
          });
        }
        setState(() => isLoading = false);
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
      final uri = Uri.parse(
          "$baseUrl/current_volunteer_tasks?user_id=${widget.userId}");
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

  Future<void> _fetchCompletedTasks() async {
    try {
      final uri =
          Uri.parse("$baseUrl/history_of_volunteers?user_id=${widget.userId}");
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> tasks = data["completed_tasks"];

        setState(() {
          completedTasks = tasks.map<Map<String, String>>((task) {
            return {
              "title": task["issue"] ?? "Untitled Task",
              "status": task["status"] ?? "Completed",
              "volunteer": task["volunteer"]?["name"] ?? "Unknown",
              "avatarUrl": "https://i.pravatar.cc/300?img=20",
              "date":
                  "Apr 4, 2025" // Replace with real date from API if available
            };
          }).toList();
        });
      }
    } catch (e) {
      print("Error fetching completed tasks: $e");
    }
  }

  void _onSwipeDown() async {
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
      backgroundColor: peachCream,
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
                Text(task['title']!,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Nunito',
                      color: skyAsh,
                    )),
                const SizedBox(height: 12),
                Text(task['subtitle']!,
                    style: const TextStyle(
                        fontSize: 16, fontFamily: 'Nunito', color: slateText)),
                const Spacer(),
                
                Visibility(
                  visible: true,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (showActions) ...[
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
                              _fetchCurrentTask();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("❌ Failed to assign task")),
                              );
                            }
                          },
                          icon: const Icon(Icons.check),
                          label: const Text("Approve"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: sunsetCoral,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          ),
                        ),
                      ] else ...[
                        ElevatedButton.icon(
                          onPressed: () async {
                            Navigator.pop(context);
                            final uri = Uri.parse('$baseUrl/complete_task?task_id=${task['task_id']}');
                            final response = await http.post(uri);

                            if (response.statusCode == 200) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("✅ Task marked as completed")),
                              );
                              _fetchCurrentTask();
                              _fetchCompletedTasks();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("❌ Failed to complete task")),
                              );
                            }
                          },
                          icon: const Icon(Icons.check_circle),
                          label: const Text("Completed"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: sunsetCoral,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            Navigator.pop(context);
                            final uri = Uri.parse('$baseUrl/deny_task?task_id=${task['task_id']}');
                            final response = await http.post(uri);

                            if (response.statusCode == 200) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("⚠️ Task was terminated")),
                              );
                              _fetchCurrentTask();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("❌ Failed to terminate task")),
                              );
                            }
                          },
                          icon: const Icon(Icons.cancel),
                          label: const Text("Terminate"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          ),
                        ),
                      ],
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

  Widget _buildHistoryCard(String title, String status, String volunteerName,
      String avatarUrl, String dateCompleted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 1,
        color: lavenderMist,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                  radius: 18, backgroundImage: NetworkImage(avatarUrl)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Nunito',
                          color: slateText,
                        )),
                    const SizedBox(height: 6),
                    Text("Completed by $volunteerName on $dateCompleted",
                        style: const TextStyle(
                          fontSize: 13,
                          color: bodyText,
                          fontFamily: 'Nunito',
                        )),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Done",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nunito',
                    color: mutedNavy,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const ProfileDrawer(),
      extendBody: true,
      backgroundColor: peachCream,
      appBar: AppBar(
        leading: const ProfileMenu(),
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
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: sandBlush,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text("Suggested Tasks",
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Nunito',
                        color: skyAsh)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: suggestedTasks.isEmpty
                      ? const Center(
                          child: Text("No suggested tasks at the moment."))
                      : Stack(
                          clipBehavior: Clip.none,
                          children: suggestedTasks
                              .asMap()
                              .entries
                              .toList()
                              .reversed
                              .map((entry) {
                            final index = entry.key;
                            final task = entry.value;
                            final int offset =
                                suggestedTasks.length - 1 - index;
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
                                child: GestureDetector(
                                  onPanUpdate: (details) {
                                    if (details.delta.dy > 10 && isTop) {
                                      _onSwipeDown();
                                    }
                                  },
                                  onTap: () => _showTaskModal(task),
                                  child: Card(
                                    color: pastelPeach,
                                    elevation: 5 - offset.toDouble(),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    child: Padding(
                                      padding: const EdgeInsets.all(18),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Task Title",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Nunito',
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            task['title'] ?? "-",
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Nunito',
                                              color: slateText,
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                          const Text(
                                            "Description",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Nunito',
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            task['subtitle'] ?? "-",
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontFamily: 'Nunito',
                                              color: bodyText,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 14),
                                          const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Icon(Icons.swipe_down,
                                                  color: mutedNavy),
                                              SizedBox(width: 6),
                                              Text(
                                                "Swipe down to skip",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontFamily: 'Nunito',
                                                  fontWeight: FontWeight.w500,
                                                  color: mutedNavy,
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 10),
                const Text("Current Task",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Nunito',
                        color: skyAsh)),
                const SizedBox(height: 10),
                if (currentTasks.isNotEmpty)
                  SizedBox(
                    height: 150,
                    width: 160,
                    child: PageView.builder(
                      itemCount: currentTasks.length,
                      controller: PageController(viewportFraction: 1),
                      itemBuilder: (context, index) {
                        final task = currentTasks[index];
                        return GestureDetector(
                          onTap: () => _showCurrentTaskModal(task),
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            color: lavenderMist,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.assignment_turned_in,
                                      size: 30, color: sunsetCoral),
                                  const SizedBox(height: 8),
                                  Text(task['title']!,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Nunito')),
                                  const SizedBox(height: 6),
                                  Text(task['subtitle']!,
                                      style: const TextStyle(
                                          fontSize: 14, fontFamily: 'Nunito')),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 30),
                const Text("History",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Nunito',
                        color: skyAsh)),
                const SizedBox(height: 10),
                ...completedTasks.map((task) => _buildHistoryCard(
                      task['title']!,
                      task['status']!,
                      task['volunteer']!,
                      task['avatarUrl']!,
                      task['date']!,
                    )),
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

String _getGreetingMessage() {
  final hour = DateTime.now().hour;
  const name = 'Heyt'; // Replace dynamically if needed

  if (hour < 12) {
    return 'Good Morning, $name 👋';
  } else if (hour < 17) {
    return 'Good Afternoon, $name 🌤️';
  } else if (hour < 20) {
    return 'Good Evening, $name 🌇';
  } else {
    return 'Good Night, $name 🌙';
  }
}
