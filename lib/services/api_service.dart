import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_artefak/models/student_model.dart';
import '../utils/api_constants.dart';

class ApiService {
<<<<<<< Updated upstream
=======
  static const String baseUrl = 'http://192.168.189.83:8080';
  static const String externalApiUrl = "https://cis-dev.del.ac.id/api";

>>>>>>> Stashed changes
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse("${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        "username": username,
        "password": password,
      },
    );

    final result = {
      'success': false,
      'message': 'Terjadi kesalahan',
    };

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final internalToken = data['internal_token'];
      final externalToken = data['external_token'];
      final user = data['user'];
      final role = user?['role'];
      final username = user?['username'];
      final userId = user?['user_id'];

      if ((role?.toLowerCase().trim() ?? "") != "mahasiswa") {
        result['message'] = 'Hanya Mahasiswa yang boleh login';
        return result;
      }

      if (internalToken != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt', internalToken);
        await prefs.setString('external_token', externalToken ?? '');
        await prefs.setString('username', username ?? '');
        await prefs.setInt('user_id', userId ?? 0);

        result['success'] = true;
        result['message'] = 'Login berhasil';
        return result;
      }
    } else {
      try {
        final error = jsonDecode(response.body);
        result['message'] = error['error'] ?? 'Login gagal';
      } catch (_) {
        result['message'] = 'Login gagal: ${response.statusCode}';
      }
    }

    return result;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt');
    await prefs.remove('external_token');
    await prefs.remove('username');
    await prefs.remove('user_id');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt');
  }

  static Future<String?> getExternalToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('external_token');
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  static Future<Student?> getStudentData() async {
    final username = await getUsername();
    final externalToken = await getExternalToken();
    
    if (username == null || externalToken == null) {
      return null;
    }

    // Option 1: Fetch directly from external API
    final url = Uri.parse("${ApiConstants.externalApiUrl}${ApiConstants.externalStudentEndpoint}?username=$username");
    
    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $externalToken",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] == 'Ok' && 
            data['data'] != null && 
            data['data']['mahasiswa'] != null && 
            data['data']['mahasiswa'].isNotEmpty) {
          return Student.fromJson(data['data']['mahasiswa'][0]);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching student data: $e');
      return null;
    }
  }
}
