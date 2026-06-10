import 'package:app/screens/app/documents/documents_screen.dart';
import 'package:app/screens/app/notes/notes_screen.dart';
import 'package:app/screens/app/credentials/credentials_screen.dart';
import 'package:app/screens/app/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    CredentialsScreen(),
    NotesScreen(),
    DocumentsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withAlpha(120),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedKey01,
                size: 26,
                color: _currentIndex == 0
                    ? colorScheme.primary
                    : colorScheme.onSurface,
              ),
            ),
            label: 'Credentials',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedNote01,
                size: 26,
                color: _currentIndex == 1
                    ? colorScheme.primary
                    : colorScheme.onSurface,
              ),
            ),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedFolderFileStorage,
                size: 26,
                color: _currentIndex == 2
                    ? colorScheme.primary
                    : colorScheme.onSurface,
              ),
            ),
            label: 'Files',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedUser,
                size: 26,
                color: _currentIndex == 3
                    ? colorScheme.primary
                    : colorScheme.onSurface,
              ),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
