import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constants.dart';

class DosenService {
  // Get dosen name by ID
  static Future<String> getDosenName(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');
    
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final url = Uri.parse("${ApiConstants.baseUrl}${ApiConstants.dosenEndpoint}/$id");
    
    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          return data['data']['nama'] ?? 'Dosen $id';
        } else {
          return 'Dosen $id';
        }
      } else {
        return 'Dosen $id';
      }
    } catch (e) {
      print('Error in getDosenName: $e');
      return 'Dosen $id';
    }
  }

  // Get multiple dosen names by IDs
  static Future<Map<int, String>> getDosenNames(List<int> ids) async {
    Map<int, String> result = {};
    
    for (var id in ids) {
      try {
        String name = await getDosenName(id);
        result[id] = name;
      } catch (e) {
        result[id] = 'Dosen $id';
      }
    }
    
    return result;
  }
}
