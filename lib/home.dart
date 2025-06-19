import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_farming/device_model.dart';
import 'package:smart_farming/device_service.dart';
import 'dashboard.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Device>> futureDevices;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    futureDevices = DeviceService.fetchDevicesByUserId();
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih Device'),
        backgroundColor: Colors.lightGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Cari device...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Device>>(
                future: futureDevices,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && _isLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasData) {
                    if (snapshot.data!.isEmpty) {
                      return Center(
                        child: Text("Tidak ada device aktif ditemukan"),
                      );
                    }
                    return ListView.separated(
                      itemCount: snapshot.data!.length,
                      separatorBuilder: (_, __) => Divider(),
                      itemBuilder: (context, index) {
                        Device device = snapshot.data![index];
                        return ListTile(
                          title: Text(device.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("ID: ${device.idDevice}"),
                              Text("Deskripsi: ${device.description}"),
                            ],
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, size: 12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DashboardScreen(deviceId: device.idDevice),
                              ),
                            );
                          },
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text("${snapshot.error}", style: TextStyle(color: Colors.red)),
                    );
                  }
                  return Center(child: Text("Terjadi kesalahan"));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}