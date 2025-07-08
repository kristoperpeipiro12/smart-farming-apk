import 'dart:convert';
import 'package:http/http.dart' as http;
import 'sensor_alert.dart';

class ApiService {
  static const String baseUrl = 'https://smart-farming.kejatikalbar.com/api ';

  static Future<List<SensorAlert>> fetchNotifications(String idDevice) async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications?id_device=$idDevice'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data.map((item) => SensorAlert.fromJson(item)).toList();
    } else {
      throw Exception('Gagal mengambil notifikasi');
    }
  }
}
