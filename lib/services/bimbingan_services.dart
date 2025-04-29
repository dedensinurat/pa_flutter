import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bimbingan_model.dart';

class BimbinganService {
  static const String baseUrl = "http://172.27.81.96:8080";

  // Kirim request bimbingan baru
  static Future<bool> create({
    required String keperluan,
    required DateTime rencanaMulai,
    required DateTime rencanaSelesai,
    required String lokasi,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    final body = {
      "keperluan": keperluan,
      "rencana_mulai": rencanaMulai.toIso8601String(),
      "rencana_selesai": rencanaSelesai.toIso8601String(),
      "lokasi": lokasi,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/bimbingan/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print("Gagal kirim bimbingan: ${response.statusCode} ${response.body}");
      return false;
    }
  }

  // Ambil semua bimbingan milik user
  static Future<List<Bimbingan>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    final response = await http.get(
      Uri.parse('$baseUrl/bimbingan'), 
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Bimbingan.fromJson(json)).toList();
    } else {
      print("Gagal memuat bimbingan: ${response.statusCode} ${response.body}");
      throw Exception('Gagal memuat data bimbingan');
    }
  }
}
