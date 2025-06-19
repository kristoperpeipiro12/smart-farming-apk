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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    futureDevices = DeviceService.fetchDevicesByUserId();
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
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Cari device...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[200],
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
                            children: [Text("ID: ${device.idDevice}")],
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, size: 12),
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
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "${snapshot.error}",
                        style: TextStyle(color: Colors.red),
                      ),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
