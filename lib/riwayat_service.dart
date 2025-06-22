// riwayat_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'riwayat_model.dart';

class RiwayatService {
  static const String baseUrl =
      "https://smart-farming.kejatikalbar.com/api/mobile";

  static Future<List<Device>> fetchDevicesByUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final String? idUser = prefs.getString('id_user');
    if (idUser == null) throw Exception("ID User tidak ditemukan");

    final response = await http.post(
      Uri.parse("$baseUrl/devices/user"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'id_user': idUser}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data'] as List)
          .map((json) => Device.fromJson(json))
          .toList();
    } else {
      throw Exception("Gagal memuat devices");
    }
  }

  static Future<SensorHistoryResponse> fetchSensorHistory(
    String deviceId, {
    String? startDate,
    String? endDate,
    int limit = 10,
    int page = 1,
  }) async {
    final body = {
      'id_device': deviceId,
      if (startDate != null && startDate.isNotEmpty) 'start_date': startDate,
      if (endDate != null && endDate.isNotEmpty) 'end_date': endDate,
      'limit': limit.toString(),
      'page': page.toString(),
    };

    final response = await http.post(
      Uri.parse("$baseUrl/riwayat/sensor-value"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData =
          json.decode(response.body)['data'];
      return SensorHistoryResponse.fromJson(responseData);
    } else if (response.statusCode == 404) {
      return SensorHistoryResponse(
        items: [],
        currentPage: 1,
        perPage: 0,
        totalPages: 0,
        totalItems: 0,
      );
    } else {
      throw Exception(
        "Gagal memuat data sensor: ${response.statusCode} - ${response.body}",
      );
    }
  }
}
