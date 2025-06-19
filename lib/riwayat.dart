import 'package:flutter/material.dart';

class RiwayatScreen extends StatefulWidget {
  @override
  _RiwayatScreenState createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  // Data dummy untuk riwayat sensor
  List<Map<String, dynamic>> sensorData = [
    {
      'timestamp': DateTime.now().subtract(Duration(days: 1)),
      'ph': 7.2,
      'humidity': 60,
      'waterLevel1': 80,
      'waterLevel2': 75,
      'pumpStatus1': 'ON',
      'pumpStatus2': 'OFF',
    },
    {
      'timestamp': DateTime.now().subtract(Duration(days: 2)),
      'ph': 7.4,
      'humidity': 55,
      'waterLevel1': 70,
      'waterLevel2': 65,
      'pumpStatus1': 'OFF',
      'pumpStatus2': 'ON',
    },
    {
      'timestamp': DateTime.now().subtract(Duration(days: 3)),
      'ph': 7.1,
      'humidity': 65,
      'waterLevel1': 90,
      'waterLevel2': 85,
      'pumpStatus1': 'ON',
      'pumpStatus2': 'ON',
    },
  ];

  // Pilihan filter tanggal
  String selectedFilter = 'Hari Ini'; // Default filter

  // Fungsi untuk mengubah filter
  void _changeFilter(String filter) {
    setState(() {
      selectedFilter = filter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Riwayat')),
      body: Column(
        children: [
          // Filter tanggal
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => _changeFilter('Hari Ini'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      selectedFilter == 'Hari Ini'
                          ? Colors.blue
                          : Colors.grey[300],
                    ),
                  ),
                  child: Text('Hari Ini'),
                ),
                ElevatedButton(
                  onPressed: () => _changeFilter('Minggu Ini'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      selectedFilter == 'Minggu Ini'
                          ? Colors.blue
                          : Colors.grey[300],
                    ),
                  ),
                  child: Text('Minggu Ini'),
                ),
                ElevatedButton(
                  onPressed: () => _changeFilter('Bulan Ini'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      selectedFilter == 'Bulan Ini'
                          ? Colors.blue
                          : Colors.grey[300],
                    ),
                  ),
                  child: Text('Bulan Ini'),
                ),
              ],
            ),
          ),

          // Daftar card data sensor
          Expanded(
            child: ListView.builder(
              itemCount: sensorData.length,
              itemBuilder: (context, index) {
                final data = sensorData[index];
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Timestamp
                        Text(
                          'Waktu: ${data['timestamp'].toString()}',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        SizedBox(height: 8),

                        // Data sensor
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('pH: ${data['ph']}'),
                            Text('Kelembapan: ${data['humidity']}%'),
                          ],
                        ),
                        SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Level Air 1: ${data['waterLevel1']}%'),
                            Text('Level Air 2: ${data['waterLevel2']}%'),
                          ],
                        ),
                        SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pompa 1: ${data['pumpStatus1']}',
                              style: TextStyle(
                                color:
                                    data['pumpStatus1'] == 'ON'
                                        ? Colors.green
                                        : Colors.red,
                              ),
                            ),
                            Text(
                              'Pompa 2: ${data['pumpStatus2']}',
                              style: TextStyle(
                                color:
                                    data['pumpStatus2'] == 'ON'
                                        ? Colors.green
                                        : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
