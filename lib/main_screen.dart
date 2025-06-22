import 'package:flutter/material.dart';
// import 'package:smart_farming/home.dart'; // Halaman Home
import 'package:smart_farming/device.dart'; // Halaman Device / Monitoring
import 'package:smart_farming/riwayat_device.dart'; // Halaman Riwayat
import 'package:smart_farming/informasi.dart'; // Halaman Profile / Informasi

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    // HomeScreen(), // index 0
    DeviceScreen(), // index 1
    RiwayatDeviceScreen(), // index 2
    InformasiScreen(), // index 3
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<BottomNavigationBarItem> getNavigationItems() {
    return const [
      // BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(
        icon: Icon(Icons.dashboard), // Ganti ikon sesuai preferensi
        label: 'Monitoring',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.bar_chart_sharp),
        label: 'Riwayat',
      ),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: getNavigationItems(),
        selectedItemColor: Color.fromARGB(255, 10, 169, 71),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        backgroundColor: Colors.white,
      ),
    );
  }
}
