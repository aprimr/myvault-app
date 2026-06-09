import 'package:app/screens/app/document.dart';
import 'package:app/screens/app/notes.dart';
import 'package:app/screens/app/password.dart';
import 'package:app/screens/app/profile.dart';
import 'package:flutter/material.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const Notes(),
    const Password(),
    const Document(),
    const Profile(),
  ];

  final List<String> _titles = ["Dashboard", "Notes", "Documents", "Profile"];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TOP BAR
      appBar: AppBar(title: Text(_titles[_currentIndex]), centerTitle: true),

      // BODY (pages switch here)
      body: _pages[_currentIndex],

      // BOTTOM NAV BAR
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.note), label: "Notes"),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: "Files"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
