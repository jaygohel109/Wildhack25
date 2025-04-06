import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend_app/components/custom_bottom_nav_bar.dart';
import 'package:frontend_app/components/profile_menu.dart';
import 'package:frontend_app/senior/new_request_dialog.dart';
import '../theme/theme_colors.dart';

class SeniorHomePage extends StatefulWidget {
  final String userId;

  const SeniorHomePage({super.key, required this.userId});

  @override
  State<SeniorHomePage> createState() => _SeniorHomePageState();
}

class _SeniorHomePageState extends State<SeniorHomePage> {
  List<Map<String, dynamic>> activeTasks = [];
  List<Map<String, dynamic>> completedTasks = [];
  bool isLoadingActive = true;
  bool isLoadingCompleted = true;

  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    fetchActiveTasks();
    fetchCompletedTasks();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchActiveTasks() async {
    final url = Uri.parse('http://localhost:8000/active_tasks?user_id=${widget.userId}');
    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['active_tasks'] != null) {
        setState(() {
          activeTasks = List<Map<String, dynamic>>.from(data['active_tasks']);
          isLoadingActive = false;
        });
        _startAutoSwipe();
      }
    } catch (e) {
      print('Error fetching active tasks: $e');
      setState(() => isLoadingActive = false);
    }
  }

  Future<void> fetchCompletedTasks() async {
    final url = Uri.parse('http://localhost:8000/completed_tasks?user_id=${widget.userId}');
    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['completed_tasks'] != null) {
        setState(() {
          completedTasks = List<Map<String, dynamic>>.from(data['completed_tasks']);
          isLoadingCompleted = false;
        });
      }
    } catch (e) {
      print('Error fetching completed tasks: $e');
      setState(() => isLoadingCompleted = false);
    }
  }

  void _startAutoSwipe() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_pageController.hasClients && activeTasks.length > 1) {
        _currentIndex = (_currentIndex + 1) % activeTasks.length;
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onNewRequestSubmitted(Map<String, dynamic> newTask) {
    setState(() {
      activeTasks.insert(0, newTask);
    });
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
            onPressed: () {
              print("Chat button pressed");
            },
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: sandBlush,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: Column(
          children: [
            const Text(
              "My Current Requests",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                fontFamily: 'Nunito',
                color: skyAsh,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 260,
              child: isLoadingActive
                  ? const Center(child: CircularProgressIndicator())
                  : activeTasks.isNotEmpty
                      ? PageView.builder(
                          controller: _pageController,
                          itemCount: activeTasks.length,
                          itemBuilder: (_, index) => _buildTaskCard(activeTasks[index]),
                        )
                      : const Center(child: Text("No active requests found.")),
            ),
            const SizedBox(height: 24),
            const Text(
              "📖 Request History",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                fontFamily: 'Nunito',
                color: skyAsh,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: isLoadingCompleted
                  ? const Center(child: CircularProgressIndicator())
                  : completedTasks.isEmpty
                      ? const Center(child: Text("No completed requests."))
                      : ListView.builder(
                          itemCount: completedTasks.length,
                          itemBuilder: (context, index) {
                            final task = completedTasks[index];
                            final volunteer = task['volunteer'];
                            final avatarUrl = 'https://i.pravatar.cc/300?img=${20 + index}';
                            final volunteerName = volunteer != null && volunteer['name'] != null
                                ? volunteer['name']
                                : 'Not assigned';
                            final createdAt = task['created_at'] != null
                                ? DateTime.parse(task['created_at']).toLocal()
                                : null;
                            final formattedDate = createdAt != null
                                ? "${_formatMonth(createdAt.month)} ${createdAt.day}, ${createdAt.year}"
                                : "N/A";

                            return _buildHistoryCard(
                              task['issue'] ?? '-',
                              task['status'],
                              volunteerName,
                              avatarUrl,
                              formattedDate,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTask = await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (_) => NewRequestDialog(userId: widget.userId),
          );
          if (newTask != null) {
            _onNewRequestSubmitted(newTask);
          }
        },
        child: const Icon(Icons.add),
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

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final volunteer = task['volunteer'];
    final volunteerName = volunteer != null && volunteer['name'] != null
        ? volunteer['name']
        : 'Not assigned';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: pastelPeach,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Title", style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Nunito', fontSize: 14)),
            const SizedBox(height: 4),
            Text(task['issue'] ?? '-', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Nunito')),
            const SizedBox(height: 16),
            const Text("Status", style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Nunito', fontSize: 14)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                task['status'] ?? '-',
                style: const TextStyle(color: Color(0xFFCE5E50), fontWeight: FontWeight.w600, fontFamily: 'Nunito'),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Volunteer", style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Nunito', fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              children: [
                const CircleAvatar(radius: 20, child: Text("NA")),
                const SizedBox(width: 12),
                Text(volunteerName, style: const TextStyle(fontSize: 16, fontFamily: 'Nunito', fontWeight: FontWeight.w500))
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(String title, String status, String volunteerName, String avatarUrl, String dateCompleted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 1,
        color: lavenderMist,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              CircleAvatar(radius: 18, backgroundImage: NetworkImage(avatarUrl)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Nunito', color: slateText)),
                    const SizedBox(height: 6),
                    Text("Completed by $volunteerName on $dateCompleted", style: const TextStyle(fontSize: 13, color: bodyText, fontFamily: 'Nunito')),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text("Done", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Nunito', color: mutedNavy)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatMonth(int month) {
    const months = [ '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec' ];
    return months[month];
  }
}

String _getGreetingMessage() {
  final hour = DateTime.now().hour;
  const name = 'Jay';
  if (hour < 12) return 'Good Morning, $name 👋';
  if (hour < 17) return 'Good Afternoon, $name 🌤️';
  if (hour < 20) return 'Good Evening, $name 🌇';
  return 'Good Night, $name 🌙';
}
