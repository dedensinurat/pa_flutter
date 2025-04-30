import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bimbingan_model.dart';

class BimbinganService {
  static const String baseUrl = "http://192.168.157.227:8080";

  // Kirim request bimbingan baru
  static Future<bool> create({
    required String keperluan,
    required DateTime rencanaMulai,
    required DateTime rencanaSelesai,
    required String lokasi,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    if (token == null) {
      throw Exception("Token tidak ditemukan, silakan login kembali");
    }

    final body = {
      "keperluan": keperluan,
      "rencana_mulai": rencanaMulai.toIso8601String(),
      "rencana_selesai": rencanaSelesai.toIso8601String(),
      "lokasi": lokasi,
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bimbingan/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        return true;
      } else if (responseData['status'] == 'no_group') {
        throw NoGroupException("Anda belum tergabung dalam kelompok. Silakan hubungi dosen untuk bergabung ke kelompok.");
      } else {
        print("Gagal kirim bimbingan: ${response.statusCode} ${response.body}");
        return false;
      }
    } catch (e) {
      if (e is NoGroupException) {
        throw e;
      }
      print("Error: $e");
      return false;
    }
  }

  // Ambil semua bimbingan milik user
  static Future<List<Bimbingan>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    if (token == null) {
      throw Exception("Token tidak ditemukan, silakan login kembali");
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bimbingan'), 
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Check if the user doesn't have a group yet
        if (responseData['status'] == 'no_group') {
          throw NoGroupException("Anda belum tergabung dalam kelompok. Silakan hubungi dosen untuk bergabung ke kelompok.");
        }
        
        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> jsonList = responseData['data'];
          return jsonList.map((json) => Bimbingan.fromJson(json)).toList();
        } else {
          throw Exception("Format respons tidak sesuai");
        }
      } else {
        print("Gagal memuat bimbingan: ${response.statusCode} ${response.body}");
        throw Exception('Gagal memuat data bimbingan');
      }
    } catch (e) {
      if (e is NoGroupException) {
        throw e;
      }
      throw Exception("Error: $e");
    }
  }
}

// Custom exception for no group case
class NoGroupException implements Exception {
  final String message;
  NoGroupException(this.message);
  
  @override
  String toString() => message;
}