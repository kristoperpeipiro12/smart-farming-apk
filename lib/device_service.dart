import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'device_model.dart';

class DeviceService {
  static const String apiUrl =
      "https://smart-farming.kejatikalbar.com/api/mobile/devices/user";

  // Untuk ambil semua device berdasarkan id_user
  static Future<List<Device>> fetchDevicesByUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final String? idUser = prefs.getString('id_user');

    if (idUser == null) {
      throw Exception("ID User tidak ditemukan");
    }

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'id_user': idUser}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['success'] == true && responseData['data'] != null) {
        List<dynamic> devicesJson = responseData['data'];
        return devicesJson.map((json) => Device.fromJson(json)).toList();
      } else {
        throw ("Tidak ada data device ditemukan");
      }
    } else {
      throw ("Device Belum Tersedia!");
    }
  }

  // Untuk pencarian device berdasarkan name
  static Future<List<Device>> searchDevicesByName(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final String? idUser = prefs.getString('id_user');

    if (idUser == null) {
      throw ("ID User tidak ditemukan");
    }

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'id_user': idUser,
        'name': query, // Kirim parameter name
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['success'] == true && responseData['data'] != null) {
        List<dynamic> devicesJson = responseData['data'];
        return devicesJson.map((json) => Device.fromJson(json)).toList();
      } else {
        return []; // Kembalikan list kosong jika tidak ada hasil
      }
    } else {
      throw ("Device Tidak Tersedia!");
    }
  }
}
