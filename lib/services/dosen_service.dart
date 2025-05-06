import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DosenService {
  static const String baseUrl = "https://cis-dev.del.ac.id/api";
  
  // Cache for dosen data to avoid repeated API calls
  static Map<int, String> _dosenCache = {};

  // Get dosen name by ID
  static Future<String> getDosenName(int dosenId) async {
    // Check cache first
    if (_dosenCache.containsKey(dosenId)) {
      return _dosenCache[dosenId]!;
    }
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');
    
    if (token == null) {
      throw Exception('Not authenticated');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dosen/$dosenId'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          final String name = data['data']['nama'] ?? 'Unknown';
          // Cache the result
          _dosenCache[dosenId] = name;
          return name;
        }
      }
      
      // If API call fails, return a placeholder
      return 'Dosen $dosenId';
    } catch (e) {
      print('Error fetching dosen name: $e');
      return 'Dosen $dosenId';
    }
  }

  // Get multiple dosen names at once
  static Future<Map<int, String>> getDosenNames(List<int> dosenIds) async {
    Map<int, String> results = {};
    List<int> idsToFetch = [];
    
    // Check which IDs we already have in cache
    for (int id in dosenIds) {
      if (_dosenCache.containsKey(id)) {
        results[id] = _dosenCache[id]!;
      } else {
        idsToFetch.add(id);
      }
    }
    
    if (idsToFetch.isEmpty) {
      return results;
    }
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');
    
    if (token == null) {
      // Return placeholder names if not authenticated
      for (int id in idsToFetch) {
        results[id] = 'Dosen $id';
      }
      return results;
    }

    try {
      // This assumes the API has a batch endpoint. If not, you'll need to make multiple calls.
      final response = await http.post(
        Uri.parse('$baseUrl/dosen/batch'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({'ids': idsToFetch}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          for (var dosen in data['data']) {
            int id = dosen['id'];
            String name = dosen['nama'] ?? 'Unknown';
            results[id] = name;
            _dosenCache[id] = name;
          }
        }
      }
      
      // Fill in any missing IDs with placeholders
      for (int id in idsToFetch) {
        if (!results.containsKey(id)) {
          results[id] = 'Dosen $id';
        }
      }
      
      return results;
    } catch (e) {
      print('Error fetching dosen names: $e');
      // Return placeholder names for all requested IDs
      for (int id in idsToFetch) {
        results[id] = 'Dosen $id';
      }
      return results;
    }
  }
}