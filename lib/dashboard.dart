import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  final String deviceId;
  final String deviceName;
  const DashboardScreen({
    super.key,
    required this.deviceId,
    required this.deviceName,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late ValueNotifier<Map<String, dynamic>> _sensorDataNotifier;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _sensorDataNotifier = ValueNotifier<Map<String, dynamic>>({});
    _fetchSensorData(); // Ambil data awal
    _startAutoRefresh(); // Mulai auto-refresh
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sensorDataNotifier.dispose();
    super.dispose();
  }

  /// Fungsi untuk mengambil data sensor dari API
  Future<void> _fetchSensorData() async {
    final url = Uri.parse(
      'https://smart-farming.kejatikalbar.com/api/mobile/dashboard/last-sensor-values',
    );
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_device': widget.deviceId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _sensorDataNotifier.value = data['data'] ?? {};
    } else {
      debugPrint('Gagal mengambil data sensor: ${response.statusCode}');
    }
  }

  /// Fungsi untuk memulai auto-refresh setiap 5 detik
  void _startAutoRefresh() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchSensorData();
    });
  }

  String getPumpStatus(int value) => value == 1 ? 'ON' : 'OFF';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Realtime Monitoring'),
        backgroundColor: Colors.lightGreen,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
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
                        '${widget.deviceName} (${widget.deviceId})',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$formattedDate | $formattedTime',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),
              ValueListenableBuilder<Map<String, dynamic>>(
                valueListenable: _sensorDataNotifier,
                builder: (context, sensorData, _) {
                  if (sensorData.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final phValue =
                      (sensorData['S-PH']?['latest_value'] ?? 0.0).toDouble();
                  final humidityValue =
                      (sensorData['S-MOIS']?['latest_value'] ?? 0.0).toDouble();
                  final pump1Status =
                      sensorData['S-POMPA1']?['status'] == 'ON' ? 1 : 0;
                  final pump2Status =
                      sensorData['S-POMPA2']?['status'] == 'ON' ? 1 : 0;
                  final sisaPupuk =
                      (sensorData['S-AIR1']?['latest_value'] ?? 0.0).toDouble();
                  final sisaAir =
                      (sensorData['S-AIR2']?['latest_value'] ?? 0.0).toDouble();

                  String statusPh;
                  Color colorPh;
                  if (phValue < 6) {
                    statusPh = "Asam";
                    colorPh = Colors.redAccent;
                  } else if (phValue >= 6 && phValue <= 7) {
                    statusPh = "Netral";
                    colorPh = Colors.green;
                  } else {
                    statusPh = "Basa";
                    colorPh = Colors.blue;
                  }

                  String statusKelembapan =
                      humidityValue < 40 ? "Kering" : "Lembab";
                  Color colorKelembapan =
                      humidityValue < 40 ? Colors.orange : Colors.green;

                  String statusLevelPupuk = sisaPupuk < 20 ? "Kurang" : "Cukup";
                  Color colorLevelPupuk =
                      sisaPupuk < 20 ? Colors.red : Colors.green;

                  String statusLevelAir = sisaAir < 20 ? "Kurang" : "Cukup";
                  Color colorLevelAir =
                      sisaAir < 20 ? Colors.red : Colors.green;

                  return GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      InfoCardGauge(
                        title: "pH Tanah",
                        value: phValue,
                        max: 14,
                        icon: Icons.science,
                        color: const Color.fromARGB(255, 105, 52, 1),
                        additionalInfo: statusPh,
                        infoColor: colorPh,
                      ),
                      InfoCardGauge(
                        title: "Kelembapan",
                        value: humidityValue,
                        max: 100,
                        icon: Icons.water_drop,
                        color: Colors.blue,
                        additionalInfo: statusKelembapan,
                        infoColor: colorKelembapan,
                        showPercentage: true,
                        suffix: '%',
                      ),
                      InfoCardGauge(
                        title: "Level Air (Wadah Pupuk)",
                        value: sisaPupuk,
                        max: 100,
                        icon: Icons.inventory_2,
                        color: Colors.orange,
                        additionalInfo: statusLevelPupuk,
                        infoColor: colorLevelPupuk,
                        showPercentage: true,
                        suffix: '%',
                      ),
                      InfoCardGauge(
                        title: "Level Air (Wadah Air)",
                        value: sisaAir,
                        max: 100,
                        icon: Icons.water_drop_rounded,
                        color: Colors.cyan,
                        additionalInfo: statusLevelAir,
                        infoColor: colorLevelAir,
                        showPercentage: true,
                        suffix: '%',
                      ),
                      InfoCard(
                        title1: "Pompa 1 - Nutrisi",
                        value1: getPumpStatus(pump1Status),
                        ikon: Icons.vaccines,
                        color: pump1Status == 1 ? Colors.green : Colors.red,
                      ),
                      InfoCard(
                        title1: "Pompa 2 - Penyiraman",
                        value1: getPumpStatus(pump2Status),
                        ikon: Icons.shower,
                        color: pump2Status == 1 ? Colors.green : Colors.red,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget untuk kartu teks
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(ikon, size: 24, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title1,
                  style: TextStyle(
                    fontSize: 16,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Center(
              child: Text(
                value1,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
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

// Widget untuk kartu gauge
class InfoCardGauge extends StatelessWidget {
  final String title;
  final double value;
  final double max;
  final IconData icon;
  final Color color;
  final String? additionalInfo;
  final Color? infoColor;
  final bool showPercentage;
  final String suffix;

  const InfoCardGauge({
    super.key,
    required this.title,
    required this.value,
    required this.max,
    required this.icon,
    required this.color,
    this.additionalInfo,
    this.infoColor,
    this.showPercentage = false,
    this.suffix = '',
  });

  double get percentage => max > 0 ? (value / max).clamp(0.0, 1.0) : 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 90,
                  width: 90,
                  child: CircularProgressIndicator(
                    value: percentage,
                    strokeWidth: 8,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    backgroundColor: color.withOpacity(0.2),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${value.toStringAsFixed(1)}$suffix',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (additionalInfo != null)
                      Text(
                        additionalInfo!,
                        style: TextStyle(
                          fontSize: 12,
                          color: infoColor ?? Colors.grey,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
