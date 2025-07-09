import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_farming/device_model.dart';
import 'package:smart_farming/device_service.dart';
import 'dashboard.dart';

class DeviceScreen extends StatefulWidget {
  @override
  _DeviceScreenState createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  late Future<List<Device>> futureDevices;
  late TextEditingController _searchController;
  bool _hasShownLoginSuccess = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    futureDevices = DeviceService.fetchDevicesByUserId();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkLoginSuccess());
  }

  void _checkLoginSuccess() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLogin = prefs.getBool('first_login') ?? true;

    if (isFirstLogin && !_hasShownLoginSuccess) {
      _hasShownLoginSuccess = true;
      await prefs.setBool('first_login', false);
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green),
                  SizedBox(width: 8),
                  Text("Login Berhasil"),
                ],
              ),
              content: Text("Selamat datang di Smart Farming!"),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text("Lanjut", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
      );
    }
  }

  void _onSearchChanged(String query) {
    if (query.isNotEmpty) {
      setState(() {
        futureDevices = DeviceService.searchDevicesByName(query);
      });
    } else {
      setState(() {
        futureDevices = DeviceService.fetchDevicesByUserId();
      });
    }
  }

  Future<void> _refreshDevices() async {
    setState(() {
      futureDevices = DeviceService.fetchDevicesByUserId();
    });
    await Future.delayed(Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monitoring'),
        backgroundColor: Colors.lightGreen,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.black),
                hintText: 'Cari device...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.black),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
              ),
              onChanged: _onSearchChanged,
            ),
            SizedBox(height: 16),

            Expanded(
              child: FutureBuilder<List<Device>>(
                future: futureDevices,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "${snapshot.error}",
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        "Tidak ada device aktif ditemukan",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    );
                  }
                  final devices = snapshot.data!;
                  return RefreshIndicator(
                    onRefresh: _refreshDevices,
                    child: ListView.separated(
                      itemCount: devices.length,
                      separatorBuilder: (_, __) => Divider(height: 8),
                      itemBuilder: (context, index) {
                        final device = devices[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              device.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text("ID: ${device.idDevice}"),
                            ),

                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: Colors.black,
                            ),

                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => DashboardScreen(
                                        deviceId: device.idDevice,
                                        deviceName: device.name,
                                      ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
