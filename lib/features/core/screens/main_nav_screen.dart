import 'package:flutter/material.dart';
import 'package:smart_face_attendance/features/attendance/screens/attendance_screen.dart';

class MainNavBarScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavBarScreen({super.key, this.initialIndex = 0});

  static const String name = "/dashboard";

  @override
  State<MainNavBarScreen> createState() => _MainNavBarScreenState();
}

class _MainNavBarScreenState extends State<MainNavBarScreen> {
  int _selectedIndex = 0;

  final Color primaryColor = Color(0xFF2196F3);

  final List<Widget> _screens = [AttendanceScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,

        /// ⭐ SELECTED COLOR FIX
        indicatorColor: primaryColor,

        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },

        destinations: [
          NavigationDestination(
            icon: Icon(Icons.people_alt_outlined),
            selectedIcon: Icon(Icons.people_alt, color: primaryColor),
            label: "Attendance",
          ),

          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble, color: primaryColor),
            label: "Chats",
          ),

          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: primaryColor),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
