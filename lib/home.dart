import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart'; // Untuk navigasi ke Device List

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _fullName = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fullName = prefs.getString('nama') ?? 'Pengguna';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Farming'),
        backgroundColor: Colors.lightGreen,
        elevation: 2,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selamat Datang
            Text(
              'Selamat Datang,',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            SizedBox(height: 4),
            Text(
              '$_fullName 👋',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),

            // Penjelasan Sistem Monitoring
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.agriculture, size: 30, color: Colors.green),
                        SizedBox(width: 12),
                        Text(
                          'Sistem Monitoring Pertanian',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Aplikasi Smart Farming memungkinkan Anda memantau kondisi tanah secara real-time seperti pH dan kelembapan untuk membantu meningkatkan produktivitas pertanian.",
                      style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
