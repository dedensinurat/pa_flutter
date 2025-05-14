import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/submit_model.dart';
import '../utils/api_constants.dart';

class SubmitService {
  static const Duration timeoutDuration = Duration(seconds: 60); // Increased timeout

  // Method to fetch all assignments
  static Future<List<Submit>> fetchSubmits() async {
    try {
      print('Fetching all assignments');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt');

      if (token == null) {
        throw Exception("Token tidak ditemukan, silakan login kembali");
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/pengumpulan'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(timeoutDuration);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        if (responseData['status'] == 'success') {
          // Check if user has a kelompok
          final bool hasKelompok = responseData['has_kelompok'] ?? true;
          
          // Store the message for later use
          if (responseData['message'] != null) {
            prefs.setString('submission_message', responseData['message']);
          }
          
          // Store the kelompok status
          prefs.setBool('has_kelompok', hasKelompok);
          
          if (responseData['data'] != null) {
            final List<dynamic> tugasList = responseData['data'];
            print('Fetched ${tugasList.length} assignments');
            return tugasList.map((json) => Submit.fromJson(json)).toList();
          } else {
            print('No assignments data in response');
            return [];
          }
        } else {
          print('Error in response data: ${responseData['message']}');
          throw Exception(responseData['message'] ?? 'Gagal mengambil data tugas');
        }
      } else if (response.statusCode == 401) {
        print('Unauthorized, refreshing token');
        await _refreshToken();
        return fetchSubmits(); // Retry after refreshing token
      } else {
        print('Failed with status code: ${response.statusCode}');
        throw Exception('Failed to load assignments: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching assignments: $e');
      throw Exception('Gagal mengambil data tugas: $e');
    }
  }

  // Method to fetch a specific assignment by ID
  static Future<Submit> fetchSubmitById(int id) async {
    try {
      print('Fetching assignment with ID: $id');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt');

      if (token == null) {
        throw Exception("Token tidak ditemukan, silakan login kembali");
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/pengumpulan/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(timeoutDuration);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        if (responseData['status'] == 'success') {
          // Check if user has a kelompok
          final bool hasKelompok = responseData['has_kelompok'] ?? true;
          
          // Store the message for later use
          if (responseData['message'] != null) {
            prefs.setString('submission_message', responseData['message']);
          }
          
          // Store the kelompok status
          prefs.setBool('has_kelompok', hasKelompok);
          
          if (responseData['data'] != null) {
            print('Successfully fetched assignment details');
            return Submit.fromJson(responseData['data']);
          } else {
            print('No assignment data in response');
            throw Exception('Data tugas tidak ditemukan');
          }
        } else {
          print('Error in response data: ${responseData['message']}');
          throw Exception(responseData['message'] ?? 'Gagal mengambil data tugas');
        }
      } else if (response.statusCode == 401) {
        print('Unauthorized, refreshing token');
        await _refreshToken();
        return fetchSubmitById(id); // Retry after refreshing token
      } else {
        print('Failed with status code: ${response.statusCode}');
        throw Exception('Failed to load assignment: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching assignment: $e');
      throw Exception('Gagal mengambil data tugas: $e');
    }
  }

  // Method to upload a submit file
  static Future<String> uploadSubmit(int tugasId, String filePath) async {
    try {
      print('Uploading file for task ID: $tugasId');
      print('File path: $filePath');
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt');
      final hasKelompok = prefs.getBool('has_kelompok') ?? false;

      if (token == null) {
        throw Exception("Token tidak ditemukan, silakan login kembali");
      }
      
      // Check if user has a kelompok
      if (!hasKelompok) {
        return 'Error: Anda belum tergabung dalam kelompok. Silakan hubungi dosen untuk bergabung dengan kelompok.';
      }

      // Check if file exists
      final file = File(filePath);
      if (!await file.exists()) {
        print('File not found at path: $filePath');
        return 'Error: File tidak ditemukan di lokasi: $filePath';
      }

      final uri = Uri.parse('${ApiConstants.baseUrl}/pengumpulan/$tugasId/upload');
      final request = http.MultipartRequest('POST', uri);

      // Add the authorization header
      request.headers['Authorization'] = 'Bearer $token';
      
      // Add the file to the request
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
      ));

      print('Sending request to: $uri');
      print('Headers: ${request.headers}');
      print('Files: ${request.files.length}');

      // Send the request
      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Invalidate cache after successful upload
        _clearAllCaches();
        print('File uploaded successfully');
        return 'File berhasil diunggah!';
      } else if (response.statusCode == 401) {
        print('Unauthorized, refreshing token');
        await _refreshToken();
        return uploadSubmit(tugasId, filePath); // Retry after refreshing the token
      } else {
        print('Error response: ${response.statusCode} - ${response.body}');
        return 'Gagal unggah: ${responseBody['message'] ?? responseBody['error']}';
      }
    } on http.ClientException catch (e) {
      print('Client exception: ${e.message}');
      return 'Koneksi gagal: ${e.message}. Periksa koneksi internet Anda.';
    } catch (e) {
      print('General error: $e');
      return 'Error: $e';
    }
  }

  // Method to update an existing submission
  static Future<String> updateSubmit(int tugasId, String filePath) async {
    try {
      print('Updating submission for task ID: $tugasId');
      print('File path: $filePath');
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt');
      final hasKelompok = prefs.getBool('has_kelompok') ?? false;

      if (token == null) {
        throw Exception("Token tidak ditemukan, silakan login kembali");
      }
      
      // Check if user has a kelompok
      if (!hasKelompok) {
        return 'Error: Anda belum tergabung dalam kelompok. Silakan hubungi dosen untuk bergabung dengan kelompok.';
      }

      // Check if file exists
      final file = File(filePath);
      if (!await file.exists()) {
        print('File not found at path: $filePath');
        return 'Error: File tidak ditemukan di lokasi: $filePath';
      }

      final uri = Uri.parse('${ApiConstants.baseUrl}/pengumpulan/$tugasId/upload');
      final request = http.MultipartRequest('PUT', uri);

      // Add the authorization header
      request.headers['Authorization'] = 'Bearer $token';
      
      // Add the file to the request
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
      ));

      print('Sending request to: $uri');
      print('Headers: ${request.headers}');
      print('Files: ${request.files.length}');

      // Send the request
      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Invalidate cache after successful update
        _clearAllCaches();
        print('File updated successfully');
        return 'File berhasil diperbarui!';
      } else if (response.statusCode == 401) {
        print('Unauthorized, refreshing token');
        await _refreshToken();
        return updateSubmit(tugasId, filePath); // Retry after refreshing the token
      } else {
        print('Error response: ${response.statusCode} - ${response.body}');
        return 'Gagal memperbarui: ${responseBody['message'] ?? responseBody['error']}';
      }
    } on http.ClientException catch (e) {
      print('Client exception: ${e.message}');
      return 'Koneksi gagal: ${e.message}. Periksa koneksi internet Anda.';
    } catch (e) {
      print('General error: $e');
      return 'Error: $e';
    }
  }

  static Future<void> _refreshToken() async {
    try {
      print('Refreshing token');
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refreshToken');
      if (refreshToken == null) {
        throw Exception("Refresh token tidak ditemukan.");
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/refresh_token'),
        body: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final newToken = responseData['accessToken'];
        prefs.setString('jwt', newToken);  // Save the new token
        print('Token refreshed successfully');
      } else {
        print('Failed to refresh token: ${response.statusCode}');
        throw Exception("Gagal memperbarui token");
      }
    } catch (e) {
      print('Error refreshing token: $e');
      throw Exception("Gagal memperbarui token: $e");
    }
  }

  // Method to clear all caches
  static void _clearAllCaches() {
    print('All caches cleared');
  }
}