import 'package:flutter/material.dart';
import 'riwayat_model.dart';
import 'riwayat_service.dart';
import 'riwayat.dart';

class RiwayatDeviceScreen extends StatefulWidget {
  const RiwayatDeviceScreen({super.key});

  @override
  State<RiwayatDeviceScreen> createState() => _RiwayatDeviceScreenState();
}

class _RiwayatDeviceScreenState extends State<RiwayatDeviceScreen> {
  List<Device> _devices = [];
  List<Device> _filteredDevices = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadDevices();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDevices =
          _devices
              .where((device) => device.name.toLowerCase().contains(query))
              .toList();
    });
  }

  Future<void> loadDevices() async {
    try {
      final devices = await RiwayatService.fetchDevicesByUserId();
      setState(() {
        _devices = devices;
        _filteredDevices = devices;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Riwayat')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari device...',
                        prefixIcon: Icon(Icons.search, color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: loadDevices,
                        child:
                            _filteredDevices.isEmpty
                                ? ListView(
                                  children: const [
                                    SizedBox(height: 100),
                                    Center(
                                      child: Text('Tidak ada device ditemukan'),
                                    ),
                                  ],
                                )
                                : ListView.builder(
                                  itemCount: _filteredDevices.length,
                                  itemBuilder: (context, index) {
                                    final device = _filteredDevices[index];
                                    return Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 3,
                                      margin: EdgeInsets.symmetric(vertical: 8),
                                      child: ListTile(
                                        title: Text(
                                          device.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        subtitle: Text(
                                          "ID: ${device.idDevice}",
                                        ),
                                        trailing: Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                        ),
                                        onTap:
                                            () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (_) => RiwayatHistoriScreen(
                                                      deviceId: device.idDevice,
                                                      deviceName: device.name,
                                                    ),
                                              ),
                                            ),
                                      ),
                                    );
                                  },
                                ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
