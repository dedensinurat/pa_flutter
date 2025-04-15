import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://192.168.216.227:8080";

static Future<Map<String, dynamic>> login(String username, String password) async {
  final url = Uri.parse("$baseUrl/login");

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
    final token = data['internal_token']; 
    final user = data['user'];
    final role = user?['role'];
    final username = user?['username'];

    if ((role?.toLowerCase().trim() ?? "") != "mahasiswa") {
      result['message'] = 'Hanya Mahasiswa yang boleh login';
      return result;
    }

    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt', token);
      await prefs.setString('username', username ?? '');

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
    await prefs.remove('username');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt');
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }
}

