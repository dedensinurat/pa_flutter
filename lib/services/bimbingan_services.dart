import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bimbingan_model.dart';
import '../models/ruangan_model.dart';
import '../utils/api_constants.dart';

class BimbinganService {
  // Kirim request bimbingan baru
  static Future<bool> create({
    required String keperluan,
    required DateTime rencanaMulai,
    required DateTime rencanaSelesai,
    required int ruanganId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    if (token == null) {
      throw Exception("Token tidak ditemukan, silakan login kembali");
    }

    // Ensure we're sending UTC time to the server
    final utcRencanaMulai = rencanaMulai.toUtc();
    final utcRencanaSelesai = rencanaSelesai.toUtc();
    
    final body = {
      "keperluan": keperluan,
      "rencana_mulai": utcRencanaMulai.toIso8601String(),
      "rencana_selesai": utcRencanaSelesai.toIso8601String(),
      "ruangan_id": ruanganId,
    };

    print("Sending bimbingan request with times:");
    print("Original rencanaMulai: ${rencanaMulai.toString()}");
    print("UTC rencanaMulai: ${utcRencanaMulai.toIso8601String()}");
    print("Original rencanaSelesai: ${rencanaSelesai.toString()}");
    print("UTC rencanaSelesai: ${utcRencanaSelesai.toIso8601String()}");

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.bimbinganEndpoint}/'),
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
        rethrow;
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
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.bimbinganEndpoint}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == 'no_group') {
          throw NoGroupException("Anda belum tergabung dalam kelompok. Silakan hubungi dosen untuk bergabung ke kelompok.");
        }

        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> jsonList = responseData['data'];
          final bimbingans = jsonList.map((json) => Bimbingan.fromJson(json)).toList();
          
          // Print received times for debugging
          for (var bimbingan in bimbingans) {
            print("Received bimbingan: ${bimbingan.id}");
            print("  rencanaMulai (original): ${bimbingan.rencanaMulai}");
            print("  rencanaMulai (local): ${bimbingan.rencanaMulai.toLocal()}");
            print("  rencanaSelesai (original): ${bimbingan.rencanaSelesai}");
            print("  rencanaSelesai (local): ${bimbingan.rencanaSelesai.toLocal()}");
          }
          
          return bimbingans;
        } else {
          throw Exception("Format respons tidak sesuai");
        }
      } else {
        print("Gagal memuat bimbingan: ${response.statusCode} ${response.body}");
        throw Exception('Gagal memuat data bimbingan');
      }
    } catch (e) {
      if (e is NoGroupException) {
        rethrow;
      }
      throw Exception("Error: $e");
    }
  }

  // Ambil semua ruangan
  static Future<List<Ruangan>> getRuangans() async {
    try {
      final response = await http.get(Uri.parse('${ApiConstants.baseUrl}${ApiConstants.ruangansEndpoint}'));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> jsonList = responseData['data'];
        return jsonList.map((json) => Ruangan.fromJson(json)).toList();
      } else {
        throw Exception("Gagal memuat ruangan");
      }
    } catch (e) {
      print("Error fetching ruangan: $e");
      throw Exception("Gagal memuat ruangan: $e");
    }
  }
}

// Custom exception untuk user tanpa kelompok
class NoGroupException implements Exception {
  final String message;
  NoGroupException(this.message);

  @override
  String toString() => message;
}