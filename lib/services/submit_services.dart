import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/submit_model.dart';

class SubmitService {
  static const String baseUrl = "http://172.30.41.179:8080";

  static Future<List<Submit>> fetchSubmits() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    if (token == null) {
      throw Exception("Token tidak ditemukan, silakan login kembali");
    }

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
      throw Exception("Gagal mengambil data: ${response.statusCode}");
    }
  }

  static Future<Submit> fetchSubmitById(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    if (token == null) {
      throw Exception("Token tidak ditemukan, silakan login kembali");
    }

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
      throw Exception("Gagal mengambil detail submitan: ${response.statusCode}");
    }
  }

  static Future<String> uploadSubmit(int tugasId, String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    if (token == null) {
      throw Exception("Token tidak ditemukan, silakan login kembali");
    }

    final uri = Uri.parse('$baseUrl/pengumpulan/$tugasId/upload');
    final request = http.MultipartRequest('POST', uri);
    
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      filePath,
    ));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return 'File berhasil diunggah!';
    } else {
      return 'Gagal unggah: $responseBody';
    }
  }
}