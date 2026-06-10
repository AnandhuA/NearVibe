import 'package:flutter/material.dart';
import 'package:near_vibe/core/themes/theme_extensions.dart';
import 'package:near_vibe/providers/event_provider.dart';
import 'package:near_vibe/providers/user_provider.dart';
import 'package:near_vibe/screens/event/add_event_screen.dart';
import 'package:near_vibe/screens/home/home_screen.dart';
import 'package:near_vibe/screens/map/map_screen.dart';
import 'package:near_vibe/screens/profile/profile_screen.dart';
import 'package:near_vibe/screens/saved/saved_events_screen.dart';
import 'package:provider/provider.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int currentIndex = 0;

  final List<Widget> screens = const [
    HomeScreen(),
    MapScreen(),
    AddEventScreen(),
    SavedEventsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // ← Fetch on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchCurrentUser();
      context.read<EventProvider>().fetchSavedEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],

      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: context.primary.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            navItem(icon: Icons.home_rounded, index: 0),

            navItem(icon: Icons.map, index: 1),

            navItem(icon: Icons.add_circle_rounded, index: 2),

            navItem(icon: Icons.bookmark_rounded, index: 3),

            navItem(icon: Icons.person_rounded, index: 4),
          ],
        ),
      ),
    );
  }

  Widget navItem({required IconData icon, required int index}) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          currentIndex = index;
        });
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? context.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey),

            const SizedBox(height: 4),

            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 4,
              width: 4,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
