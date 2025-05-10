import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/submit_model.dart';

class SubmitService {
  // Base URL of the backend
  static const String baseUrl = "http://192.168.41.227:8080";
  static const Duration timeoutDuration = Duration(seconds: 15);

  // Cache mechanism to reduce API calls
  static List<Submit>? _cachedSubmits;
  static DateTime? _lastFetchTime;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  // Method to fetch all submits with cache mechanism
  static Future<List<Submit>> fetchSubmits({bool forceRefresh = false}) async {
    // Return cached data if available and not expired
    if (!forceRefresh && _cachedSubmits != null && _lastFetchTime != null) {
      final difference = DateTime.now().difference(_lastFetchTime!);
      if (difference < _cacheValidDuration) {
        return _cachedSubmits!;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    if (token == null) {
      throw Exception("Token tidak ditemukan, silakan login kembali");
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pengumpulan'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        // Check if the user doesn't have a group yet
        if (responseData['status'] == 'no_group') {
          throw NoGroupException("Anda belum tergabung dalam kelompok. Silakan hubungi dosen untuk bergabung ke kelompok.");
        }
        
        if (responseData.containsKey('data') && responseData['data'] is List) {
          List<dynamic> body = responseData['data'];
          _cachedSubmits = body.map((e) => Submit.fromJson(e)).toList();
          _lastFetchTime = DateTime.now();
          return _cachedSubmits!;
        } else {
          throw Exception("Format respons tidak sesuai");
        }
      } else if (response.statusCode == 401) {
        // Handle token expiration
        await _refreshToken();
        // Retry the request once after refreshing token
        return fetchSubmits();
      } else {
        throw Exception("Gagal mengambil data: ${response.statusCode} - ${response.body}");
      }
    } on http.ClientException catch (e) {
      throw Exception("Koneksi gagal: ${e.message}. Periksa koneksi internet Anda.");
    } catch (e) {
      if (e is NoGroupException) {
        throw e;
      }
      throw Exception("Error: $e");
    }
  }

  // Method to fetch a single submit by ID
  static Future<Submit> fetchSubmitById(int id) async {
    // Check if we have this submit in cache first
    if (_cachedSubmits != null) {
      final cachedSubmit = _cachedSubmits!.firstWhere(
        (submit) => submit.id == id,
        orElse: () => Submit(
          id: 0,
          userId: 0,
          judulTugas: '',
          deskripsiTugas: '',
          kpaId: 0,
          prodiId: 0,
          tmId: 0,
          tanggalPengumpulan: '',
          file: '',
        ),
      );
      
      // If found in cache and not the default empty submit, return it
      if (cachedSubmit.id != 0) {
        return cachedSubmit;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    if (token == null) {
      throw Exception("Token tidak ditemukan, silakan login kembali");
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pengumpulan/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        // Check if the user doesn't have a group yet
        if (responseData['status'] == 'no_group') {
          throw NoGroupException("Anda belum tergabung dalam kelompok. Silakan hubungi dosen untuk bergabung ke kelompok.");
        }
        
        if (responseData.containsKey('data')) {
          final submit = Submit.fromJson(responseData['data']);
          
          // Update the item in cache if it exists
          if (_cachedSubmits != null) {
            final index = _cachedSubmits!.indexWhere((s) => s.id == id);
            if (index >= 0) {
              _cachedSubmits![index] = submit;
            }
          }
          
          return submit;
        } else {
          throw Exception("Format respons tidak sesuai");
        }
      } else if (response.statusCode == 401) {
        // Handle token expiration
        await _refreshToken();
        // Retry the request once after refreshing token
        return fetchSubmitById(id);
      } else {
        throw Exception("Gagal mengambil detail submitan: ${response.statusCode} - ${response.body}");
      }
    } on http.ClientException catch (e) {
      throw Exception("Koneksi gagal: ${e.message}. Periksa koneksi internet Anda.");
    } catch (e) {
      if (e is NoGroupException) {
        throw e;
      }
      throw Exception("Error: $e");
    }
  }

  // Method to upload a submit file
  static Future<String> uploadSubmit(int tugasId, String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    if (token == null) {
      throw Exception("Token tidak ditemukan, silakan login kembali");
    }

    try {
      final uri = Uri.parse('$baseUrl/pengumpulan/$tugasId/upload');
      final request = http.MultipartRequest('POST', uri);
      
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
      ));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Invalidate cache after successful upload
        _cachedSubmits = null;
        _lastFetchTime = null;
        return 'File berhasil diunggah!';
      } else if (response.statusCode == 401) {
        await _refreshToken();
        return uploadSubmit(tugasId, filePath);
      } else if (responseBody['status'] == 'no_group') {
        return 'Anda belum tergabung dalam kelompok. Silakan hubungi dosen untuk bergabung ke kelompok.';
      } else {
        return 'Gagal unggah: ${responseBody['message'] ?? responseBody['error']}';
      }
    } on http.ClientException catch (e) {
      return 'Koneksi gagal: ${e.message}. Periksa koneksi internet Anda.';
    } catch (e) {
      return 'Error: $e';
    }
  }

  // Method to update a submit file
  static Future<String> updateSubmit(int tugasId, String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    if (token == null) {
      throw Exception("Token tidak ditemukan, silakan login kembali");
    }

    try {
      final uri = Uri.parse('$baseUrl/pengumpulan/$tugasId/update');
      final request = http.MultipartRequest('PUT', uri);
      
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
      ));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Invalidate cache after successful update
        _cachedSubmits = null;
        _lastFetchTime = null;
        return 'File berhasil diperbarui!';
      } else if (response.statusCode == 401) {
        await _refreshToken();
        return updateSubmit(tugasId, filePath);
      } else if (responseBody['status'] == 'no_group') {
        return 'Anda belum tergabung dalam kelompok. Silakan hubungi dosen untuk bergabung ke kelompok.';
      } else {
        return 'Gagal memperbarui: ${responseBody['message'] ?? responseBody['error']}';
      }
    } on http.ClientException catch (e) {
      return 'Koneksi gagal: ${e.message}. Periksa koneksi internet Anda.';
    } catch (e) {
      return 'Error: $e';
    }
  }

  // Helper method to refresh token if needed
  static Future<void> _refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');

    if (refreshToken == null) {
      throw Exception("Sesi telah berakhir, silakan login kembali");
    }

    final response = await http.post(
      Uri.parse('$baseUrl/refresh_token'),
      body: {'refreshToken': refreshToken},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final newToken = responseData['accessToken'];
      prefs.setString('jwt', newToken);  // Save new token to SharedPreferences
    } else {
      throw Exception("Gagal memperbarui token");
    }
  }

  // Method to clear cache manually
  static void clearCache() {
    _cachedSubmits = null;
    _lastFetchTime = null;
  }
}
  
// Custom exception for no group case
class NoGroupException implements Exception {
  final String message;
  NoGroupException(this.message);

  @override
  String toString() => message;
}
 