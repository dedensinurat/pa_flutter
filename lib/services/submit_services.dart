import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/submit_model.dart';

class SubmitService {
  static const String baseUrl = "http://172.27.81.96:8080";

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
        if (responseData.containsKey('data')) {
          return Submit.fromJson(responseData['data']);
        } else {
          throw Exception("Format respons tidak sesuai");
        }
      } else {
        throw Exception("Gagal mengambil detail submitan: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
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
      final responseBody = response.body;

      if (response.statusCode == 200) {
        return 'File berhasil diunggah!';
      } else {
        return 'Gagal unggah: $responseBody';
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
      final responseBody = response.body;

      if (response.statusCode == 200) {
        return 'File berhasil diperbarui!';
      } else {
        return 'Gagal memperbarui: $responseBody';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}