import 'package:flutter/material.dart';
import 'package:smart_farming/device.dart'; // Halaman Device / Monitoring
import 'package:smart_farming/riwayat_device.dart'; // Halaman Riwayat
import 'package:smart_farming/informasi.dart'; // Halaman Profile / Informasi
import 'package:smart_farming/mqtt_sevice.dart'; // Layanan MQTT
import 'package:shared_preferences/shared_preferences.dart'; // Untuk membaca id_user

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late MqttService mqttService;

  final List<Widget> _pages = [
    DeviceScreen(), // index 0
    RiwayatDeviceScreen(), // index 1
    InformasiScreen(), // index 2
  ];

  @override
  void initState() {
    super.initState();
    _initMqtt();
  }

  Future<void> _initMqtt() async {
    // Ambil id_user dari SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final idUser = prefs.getString('id_user') ?? '';

    // Inisialisasi MQTT service dengan id_user
    mqttService = MqttService(idUser);
    await mqttService.connect();
    mqttService.subscribe(); // Subscribe ke topik IOT/NOTIF/{id_user}
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<BottomNavigationBarItem> getNavigationItems() {
    return const [
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
