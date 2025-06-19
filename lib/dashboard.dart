import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  final String deviceId;

  const DashboardScreen({super.key, required this.deviceId});

  Future<Map<String, dynamic>> fetchSensorData(String deviceId) async {
    final url = Uri.parse(
      'https://smart-farming.kejatikalbar.com/api/mobile/dashboard/last-sensor-values',
    );
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_device': deviceId}),
      );
      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        if (decodedResponse['success'] == true) {
          return decodedResponse['data'];
        } else {
          throw Exception('API error: ${decodedResponse['message']}');
        }
      } else {
        throw Exception('Gagal mengambil data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Monitoring'),
        backgroundColor: Colors.lightGreen,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            StreamBuilder<DateTime>(
              stream: Stream.periodic(
                const Duration(seconds: 1),
                (_) => DateTime.now(),
              ),
              builder: (context, snapshot) {
                final now = snapshot.data ?? DateTime.now();
                final formattedDate = DateFormat('dd MMM yyyy').format(now);
                final formattedTime = DateFormat('HH:mm:ss').format(now);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Device = $deviceId',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$formattedDate | $formattedTime',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Expanded(
              child: StreamBuilder<Map<String, dynamic>>(
                stream: Stream.periodic(
                  const Duration(seconds: 1),
                ).asyncMap((_) => fetchSensorData(deviceId)),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData) {
                    return const Center(child: Text('Tidak ada data'));
                  }

                  final data = snapshot.data!;

                  final phValue =
                      (data['S-PH']?['latest_value'] ?? 0).toString();
                  final humidityValue =
                      (data['S-MOIS']?['latest_value'] ?? 0).toString();
                  final pump1Status =
                      data['S-POMPA1']?['status'] == 'ON' ? 1 : 0;
                  final pump2Status =
                      data['S-POMPA2']?['status'] == 'ON' ? 1 : 0;
                  final sisaPupuk =
                      (data['S-AIR1']?['latest_value'] ?? 0).toString();
                  final sisaAir =
                      (data['S-AIR2']?['latest_value'] ?? 0).toString();

                  return GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      InfoCard(
                        title1: "pH Tanah",
                        value1: phValue,
                        ikon: Icons.science,
                        color: const Color.fromARGB(255, 105, 52, 1),
                      ),
                      InfoCard(
                        title1: "Kelembapan",
                        value1: '$humidityValue%',
                        ikon: Icons.water_drop,
                        color: Colors.blue,
                      ),
                      InfoCard(
                        title1: "Level Air (Wadah Pupuk)",
                        value1: '$sisaPupuk%',
                        ikon: Icons.inventory_2,
                        color: Colors.orange,
                      ),
                      InfoCard(
                        title1: "Level Air (Wadah Air)",
                        value1: '$sisaAir%',
                        ikon: Icons.water_drop_rounded,
                        color: Colors.cyan,
                      ),
                      InfoCard(
                        title1: "Pompa 1 - Nutrisi",
                        value1: getPumpStatus(pump1Status),
                        ikon: Icons.vaccines,
                        color: Colors.deepOrange,
                      ),
                      InfoCard(
                        title1: "Pompa 2 - Penyiraman",
                        value1: getPumpStatus(pump2Status),
                        ikon: Icons.shower,
                        color: const Color.fromARGB(255, 0, 68, 214),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getPumpStatus(int value) {
    return value == 1 ? 'ON' : 'OFF';
  }
}

class InfoCard extends StatelessWidget {
  final String title1;
  final String value1;
  final IconData ikon;
  final Color color;

  const InfoCard({
    super.key,
    required this.title1,
    required this.value1,
    required this.ikon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(ikon, size: 28, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title1,
                  style: TextStyle(
                    fontSize: 18,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: Text(
                value1,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
