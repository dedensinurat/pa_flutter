import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/jadwal_model.dart';
import '../utils/api_constants.dart';

class JadwalService {
  // Get all jadwal for the current user
  static Future<List<Jadwal>> getJadwal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt');
      
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final url = Uri.parse("${ApiConstants.baseUrl}/jadwal/");
      
      print('Fetching jadwal from: $url');
      
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print('Jadwal API Response Status: ${response.statusCode}');
      print('Jadwal API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          
          // Check if the response has data field
          if (responseData.containsKey('data')) {
            if (responseData['data'] is List) {
              final List<dynamic> jadwalList = responseData['data'];
              print('Parsed ${jadwalList.length} jadwal items');
              
              // Process each item
              final jadwals = <Jadwal>[];
              for (var i = 0; i < jadwalList.length; i++) {
                try {
                  final item = jadwalList[i];
                  print('Parsing jadwal JSON: $item');
                  jadwals.add(Jadwal.fromJson(item));
                } catch (e) {
                  print('Error processing jadwal item $i: $e');
                  // Continue processing other items
                }
              }
              
              return jadwals;
            } else {
              print('Data field is not a list: ${responseData['data'].runtimeType}');
              return [];
            }
          } else {
            print('No data field in jadwal response');
            return [];
          }
        } catch (e) {
          print('Error parsing jadwal response: $e');
          return [];
        }
      } else {
        print('Error jadwal response: ${response.body}');
        throw Exception('Failed to load jadwal: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching jadwal: $e');
      return [];
    }
  }

  // Get jadwal details by ID
  static Future<Jadwal> getJadwalById(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt');
      
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final url = Uri.parse("${ApiConstants.baseUrl}/jadwal/$id");
      
      print('Fetching jadwal details from: $url');
      
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print('Jadwal Detail API Response Status: ${response.statusCode}');
      print('Jadwal Detail API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'success' && data['data'] != null) {
          // Create Jadwal object from the response
          return Jadwal.fromJson(data['data']);
        } else {
          throw Exception('Invalid response format: ${response.body}');
        }
      } else {
        throw Exception('Failed to load jadwal details: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in getJadwalById: $e');
      throw Exception('Error fetching jadwal details: $e');
    }
  }
}
