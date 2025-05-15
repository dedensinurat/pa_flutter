import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/jadwal_model.dart';
import '../utils/api_constants.dart';
import 'dosen_service.dart';

<<<<<<< Updated upstream
class JadwalService {
  // Get all jadwal for the current user
  static Future<List<Jadwal>> getJadwal() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');
    
    if (token == null) {
      throw Exception('Not authenticated');
=======
  class JadwalService {
    static const String baseUrl = "http://192.168.189.83:8080";

    // Get all jadwal for the current user
    static Future<List<Jadwal>> getJadwal() async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt');
      
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final url = Uri.parse("$baseUrl/jadwal");
      
      try {
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
          final data = jsonDecode(response.body);
          if (data['status'] == 'success' && data['data'] != null) {
            final List<dynamic> jadwalList = data['data'];
            print('Parsed ${jadwalList.length} jadwal items');
            
            // Create Jadwal objects from the response
            List<Jadwal> jadwals = jadwalList.map((item) => Jadwal.fromJson(item)).toList();
            
            // Collect all penguji IDs
            Set<int> pengujiIds = {};
            for (var jadwal in jadwals) {
              pengujiIds.add(jadwal.penguji1);
              pengujiIds.add(jadwal.penguji2);
            }
            
            // Fetch dosen names from external API
            if (pengujiIds.isNotEmpty) {
              try {
                Map<int, String> dosenNames = await DosenService.getDosenNames(pengujiIds.toList());
                
                // Update jadwal objects with dosen names
                for (var jadwal in jadwals) {
                  jadwal.penguji1Nama = dosenNames[jadwal.penguji1] ?? 'Penguji 1';
                  jadwal.penguji2Nama = dosenNames[jadwal.penguji2] ?? 'Penguji 2';
                }
              } catch (e) {
                print('Error fetching dosen names: $e');
                // Continue without dosen names
              }
            }
            
            return jadwals;
          } else {
            // If data is empty but status is success, return empty list
            if (data['status'] == 'success' && (data['data'] == null || (data['data'] is List && data['data'].isEmpty))) {
              return [];
            }
            throw Exception('Invalid response format: ${response.body}');
          }
        } else {
          throw Exception('Failed to load jadwal: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        print('Error in getJadwal: $e');
        throw Exception('Error fetching jadwal: $e');
      }
>>>>>>> Stashed changes
    }

    final url = Uri.parse("${ApiConstants.baseUrl}${ApiConstants.jadwalEndpoint}");
    
    try {
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
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          final List<dynamic> jadwalList = data['data'];
          print('Parsed ${jadwalList.length} jadwal items');
          
          // Create Jadwal objects from the response
          List<Jadwal> jadwals = jadwalList.map((item) => Jadwal.fromJson(item)).toList();
          
          // Collect all penguji IDs
          Set<int> pengujiIds = {};
          for (var jadwal in jadwals) {
            if (jadwal.penguji1 > 0) pengujiIds.add(jadwal.penguji1);
            if (jadwal.penguji2 > 0) pengujiIds.add(jadwal.penguji2);
          }
          
          // Fetch dosen names from external API
          if (pengujiIds.isNotEmpty) {
            try {
              Map<int, String> dosenNames = await DosenService.getDosenNames(pengujiIds.toList());
              
              // Update jadwal objects with dosen names
              for (var jadwal in jadwals) {
                if (jadwal.penguji1 > 0) {
                  jadwal.penguji1Nama = dosenNames[jadwal.penguji1] ?? 'Penguji 1';
                }
                if (jadwal.penguji2 > 0) {
                  jadwal.penguji2Nama = dosenNames[jadwal.penguji2] ?? 'Penguji 2';
                }
              }
            } catch (e) {
              print('Error fetching dosen names: $e');
              // Continue without dosen names
            }
          }
          
          return jadwals;
        } else {
          // If data is empty but status is success, return empty list
          if (data['status'] == 'success' && (data['data'] == null || (data['data'] is List && data['data'].isEmpty))) {
            return [];
          }
          throw Exception('Invalid response format: ${response.body}');
        }
      } else {
        throw Exception('Failed to load jadwal: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in getJadwal: $e');
      throw Exception('Error fetching jadwal: $e');
    }
  }

  // Get jadwal details by ID
  static Future<Jadwal> getJadwalById(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');
    
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final url = Uri.parse("${ApiConstants.baseUrl}${ApiConstants.jadwalEndpoint}/$id");
    
    try {
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
          Jadwal jadwal = Jadwal.fromJson(data['data']);
          
          // Fetch dosen names from external API
          try {
            if (jadwal.penguji1 > 0) {
              String penguji1Name = await DosenService.getDosenName(jadwal.penguji1);
              jadwal.penguji1Nama = penguji1Name;
            }
            
            if (jadwal.penguji2 > 0) {
              String penguji2Name = await DosenService.getDosenName(jadwal.penguji2);
              jadwal.penguji2Nama = penguji2Name;
            }
          } catch (e) {
            print('Error fetching dosen names: $e');
            // Continue without dosen names
            jadwal.penguji1Nama = 'Penguji 1';
            jadwal.penguji2Nama = 'Penguji 2';
          }
          
          return jadwal;
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

  // Get all available ruangan (rooms)
  static Future<List<Ruangan>> getRuangan() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');
    
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final url = Uri.parse("${ApiConstants.baseUrl}${ApiConstants.jadwalEndpoint}/ruangan");
    
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
          final List<dynamic> ruanganList = data['data'];
          
          // Create Ruangan objects from the response
          return ruanganList.map((item) => Ruangan.fromJson(item)).toList();
        } else {
          throw Exception('Invalid response format: ${response.body}');
        }
      } else {
        throw Exception('Failed to load ruangan: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in getRuangan: $e');
      throw Exception('Error fetching ruangan: $e');
    }
  }
}
