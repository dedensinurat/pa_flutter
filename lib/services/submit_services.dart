import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/submit_model.dart';

class SubmitService {
  static const String baseUrl = "http://192.168.157.227:8080";

  static Future<List<Submit>> fetchSubmits() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    if (token == null) {
      throw Exception("Token tidak ditemukan, silakan login kembali");
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pengumpulan'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        // Check if the user doesn't have a group yet
        if (responseData['status'] == 'no_group') {
          throw NoGroupException("Anda belum tergabung dalam kelompok. Silakan hubungi dosen untuk bergabung ke kelompok.");
        }
        
        if (responseData.containsKey('data') && responseData['data'] is List) {
          List<dynamic> body = responseData['data'];
          return body.map((e) => Submit.fromJson(e)).toList();
        } else {
          throw Exception("Format respons tidak sesuai");
        }
      } else {
        throw Exception("Gagal mengambil data: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      if (e is NoGroupException) {
        throw e;
      }
      throw Exception("Error: $e");
    }
  }

  static Future<Submit> fetchSubmitById(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    if (token == null) {
      throw Exception("Token tidak ditemukan, silakan login kembali");
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pengumpulan/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        // Check if the user doesn't have a group yet
        if (responseData['status'] == 'no_group') {
          throw NoGroupException("Anda belum tergabung dalam kelompok. Silakan hubungi dosen untuk bergabung ke kelompok.");
        }
        
        if (responseData.containsKey('data')) {
          return Submit.fromJson(responseData['data']);
        } else {
          throw Exception("Format respons tidak sesuai");
        }
      } else {
        throw Exception("Gagal mengambil detail submitan: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      if (e is NoGroupException) {
        throw e;
      }
      throw Exception("Error: $e");
    }
  }

  static Future<String> uploadSubmit(int tugasId, String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    if (token == null) {
      throw Exception("Token tidak ditemukan, silakan login kembali");
    }

    try {
      final uri = Uri.parse('$baseUrl/pengumpulan/$tugasId/upload');
      final request = http.MultipartRequest('POST', uri);
      
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return 'File berhasil diunggah!';
      } else if (responseBody['status'] == 'no_group') {
        return 'Anda belum tergabung dalam kelompok. Silakan hubungi dosen untuk bergabung ke kelompok.';
      } else {
        return 'Gagal unggah: ${responseBody['message'] ?? responseBody['error']}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  static Future<String> updateSubmit(int tugasId, String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    if (token == null) {
      throw Exception("Token tidak ditemukan, silakan login kembali");
    }

    try {
      final uri = Uri.parse('$baseUrl/pengumpulan/$tugasId/update');
      final request = http.MultipartRequest('PUT', uri);
      
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return 'File berhasil diperbarui!';
      } else if (responseBody['status'] == 'no_group') {
        return 'Anda belum tergabung dalam kelompok. Silakan hubungi dosen untuk bergabung ke kelompok.';
      } else {
        return 'Gagal memperbarui: ${responseBody['message'] ?? responseBody['error']}';
      }
    } catch (e) {
      return 'Error: $e';
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