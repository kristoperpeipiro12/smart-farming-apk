// informasi.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

class InformasiScreen extends StatefulWidget {
  @override
  _InformasiScreenState createState() => _InformasiScreenState();
}

class _InformasiScreenState extends State<InformasiScreen> {
  String _nama = '-';
  String _username = '-';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nama = prefs.getString('nama') ?? '-';
      _username = prefs.getString('username') ?? '-';
    });
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profil Pengguna")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: Colors.green.shade200,
              child: Icon(Icons.person, size: 48, color: Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              _nama,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text('@$_username', style: TextStyle(color: Colors.grey)),
            Divider(height: 40),
            ListTile(
              leading: Icon(Icons.people, color: Colors.blue),
              title: Text("Level Pengguna"),
              subtitle: Text("User"),
            ),
            ListTile(
              leading: Icon(Icons.verified_user, color: Colors.green),
              title: Text("Status"),
              subtitle: Text("Aktif"),
            ),
            Spacer(),
            ElevatedButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: Text("Konfirmasi Logout"),
                        content: Text("Apakah Anda yakin ingin keluar?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text("Batal"),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text("Ya, Keluar"),
                          ),
                        ],
                      ),
                );
                if (confirm == true) {
                  _logout(context);
                }
              },
              icon: Icon(Icons.logout),
              label: Text("Keluar"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
