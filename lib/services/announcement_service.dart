import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/announcement_model.dart';

class AnnouncementService {
  static const String baseUrl = "http://192.168.157.227:8080";

  // Get all announcements
  static Future<List<Announcement>> getAnnouncements() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');
    
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final url = Uri.parse("$baseUrl/pengumuman");
    
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
          return (data['data'] as List)
              .map((item) => Announcement.fromJson(item))
              .toList();
        }
      }
      throw Exception('Failed to load announcements: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching announcements: $e');
    }
  }

  // Get announcement details by ID
  static Future<Announcement> getAnnouncementById(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');
    
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final url = Uri.parse("$baseUrl/pengumuman/$id");
    
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
          return Announcement.fromJson(data['data']);
        }
      }
      throw Exception('Failed to load announcement details: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching announcement details: $e');
    }
  }
}