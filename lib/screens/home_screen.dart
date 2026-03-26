import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'scan_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ScanScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  final List<String> _titles = [
    'NFC Reader',
    'Lịch sử quét',
    'Cài đặt',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          if (_currentIndex == 0)
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {
                setState(() => _currentIndex = 2);
              },
            ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.darkCardBorder.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: [
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.nfc_outlined, 0),
              activeIcon: _buildNavIcon(Icons.nfc, 0, isActive: true),
              label: 'Quét',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.history_outlined, 1),
              activeIcon: _buildNavIcon(Icons.history, 1, isActive: true),
              label: 'Lịch sử',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.settings_outlined, 2),
              activeIcon: _buildNavIcon(Icons.settings, 2, isActive: true),
              label: 'Cài đặt',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: isActive
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
            )
          : null,
      child: Icon(icon),
    );
  }
}
