// main_screen.dart
import 'package:flutter/material.dart';
import 'home.dart'; // Sesuaikan dengan file Anda
import 'dashboard.dart';
import 'riwayat.dart';
import 'informasi.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(), // index 0
    DashboardScreen(deviceId: 'IOT-20250518-202435'), // index 1
    RiwayatScreen(), // index 2
    InformasiScreen(), // index 3
  ];

  void _onItemTapped(int rawIndex) {
    int actualIndex;

    if (_selectedIndex == 0 || _selectedIndex == 3) {
      // Jika dari halaman Home atau Informasi
      if (rawIndex == 0) {
        actualIndex = 0;
      } else {
        actualIndex = 3;
      }
    } else {
      actualIndex = rawIndex;
    }

    setState(() {
      _selectedIndex = actualIndex;
    });
  }

  List<BottomNavigationBarItem> getNavigationItems() {
    if (_selectedIndex == 0 || _selectedIndex == 3) {
      // Hanya tampilkan Home dan Informasi
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Informasi'),
      ];
    } else {
      // Tampilkan semua item
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Informasi'),
      ];
    }
  }

  int getCurrentTabForIndex() {
    if (_selectedIndex == 0 || _selectedIndex == 3) {
      return _selectedIndex == 0 ? 0 : 1;
    }
    return _selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: getCurrentTabForIndex(),
        onTap: _onItemTapped,
        items: getNavigationItems(),
        selectedItemColor: Color.fromARGB(255, 10, 169, 71),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }
}
