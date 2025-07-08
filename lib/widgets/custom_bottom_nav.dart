import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';
import '../screens/home_screen.dart';
import '../screens/tour_planner_screen.dart';
import '../screens/ai_assistant_screen.dart';
import '../screens/user_profile_screen.dart';
import '../screens/crowd_monitor_screen.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                label: 'Home',
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
              ),
              _buildNavItem(
                index: 1,
                label: 'Tours',
                icon: Icons.map_outlined,
                activeIcon: Icons.map,
              ),
              _buildNavItem(
                index: 2,
                label: 'Crowds',
                icon: Icons.people_outline,
                activeIcon: Icons.people,
              ),
              _buildNavItem(
                index: 3,
                label: 'Assistant',
                icon: Icons.chat_bubble_outline,
                activeIcon: Icons.chat_bubble,
              ),
              _buildNavItem(
                index: 4,
                label: 'Profile',
                icon: Icons.person_outline,
                activeIcon: Icons.person,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final isSelected = index == currentIndex;

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppTheme.primaryColor.withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppTheme.primaryColor : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppTheme.primaryColor : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    const TourPlannerScreen(),
    const CrowdMonitorScreen(),
    const AiAssistantScreen(),
    const UserProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _syncCompletedTours();
        },
      ),
    );
  }

  /// Syncs completed tours from 'tours' collection to each user's 'completedTours' field.
  Future<void> _syncCompletedTours() async {
    try {
      final now = DateTime.now();
      final firestore = FirebaseFirestore.instance;
      // Query tours that are not cancelled and have tourDate in the past
      final tourSnapshot =
          await firestore
              .collection('tours')
              .where('isCancelled', isEqualTo: false)
              .where('tourDate', isLessThan: Timestamp.fromDate(now))
              .get();

      // Map of userId to list of tourIds that should be marked completed
      final Map<String, List<String>> userCompletedMap = {};
      for (var doc in tourSnapshot.docs) {
        final data = doc.data();
        final tourId = doc.id;
        final userId = data['userId'] as String?;
        if (userId == null) continue;
        userCompletedMap.putIfAbsent(userId, () => []).add(tourId);
      }

      // Update each user's completedTours
      for (final entry in userCompletedMap.entries) {
        final userId = entry.key;
        final tourIds = entry.value;
        final userRef = firestore.collection('users').doc(userId);
        final userDoc = await userRef.get();
        if (!userDoc.exists) continue;

        final existing =
            (userDoc.data()?['completedTours'] ?? <dynamic>[]) as List<dynamic>;
        // Determine which tourIds are new
        final newTours = tourIds.where((id) => !existing.contains(id)).toList();
        if (newTours.isNotEmpty) {
          await userRef.update({
            'completedTours': FieldValue.arrayUnion(newTours),
          });
        }
      }
    } catch (e, st) {
      debugPrint('Error syncing completed tours: $e\n$st');
    }
  }
}
