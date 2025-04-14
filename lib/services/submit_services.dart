import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/submit_model.dart';

class SubmitService {
  static const String baseUrl = "http://192.168.216.185:8080";

  static Future<List<Submit>> fetchSubmits() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    final response = await http.get(
      Uri.parse('$baseUrl/pengumpulan'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((e) => Submit.fromJson(e)).toList();
    } else {
      throw Exception("Gagal mengambil data");
    }
  }

  static Future<Submit> fetchSubmitById(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    final response = await http.get(
      Uri.parse('$baseUrl/pengumpulan/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Submit.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Gagal mengambil detail submitan");
    }
  }
}
