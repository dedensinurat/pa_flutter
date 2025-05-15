import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/submit_model.dart';
import '../utils/api_constants.dart';
import 'api_service.dart'; // Import your ApiService to access the token

class SubmitService {
<<<<<<< HEAD
  // Helper method to get auth headers
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await ApiService.getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }
=======
<<<<<<< Updated upstream
  static const Duration timeoutDuration = Duration(seconds: 60); // Increased timeout
=======
  static const String baseUrl = "http://192.168.189.83:8080";
>>>>>>> Stashed changes
>>>>>>> 0a57aa2e068c1ec95982e72d5ef76d66a209b51f

  // Fetch all submissions
  static Future<List<Submit>> fetchSubmits() async {
    try {
      final headers = await _getAuthHeaders();
      print('Fetching submissions with headers: $headers');
      
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.pengumpulanEndpoint}'),
        headers: headers,
      );

      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
<<<<<<< HEAD
        final responseData = json.decode(response.body);
        print('Response data: $responseData');
        
        if (responseData['data'] != null && responseData['data'] is List) {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => Submit.fromJson(json)).toList();
=======
        final Map<String, dynamic> responseData = jsonDecode(response.body);
<<<<<<< Updated upstream
        
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
=======

        // Check if the user doesn't have a group yet
        if (responseData['status'] == 'no_group') {
          throw NoGroupException(
              "Anda belum tergabung dalam kelompok. Silakan hubungi dosen untuk bergabung ke kelompok.");
        }

        if (responseData.containsKey('data') && responseData['data'] is List) {
          List<dynamic> body = responseData['data'];
          return body.map((e) => Submit.fromJson(e)).toList();
>>>>>>> Stashed changes
>>>>>>> 0a57aa2e068c1ec95982e72d5ef76d66a209b51f
        } else {
          throw Exception('Invalid response format: ${response.body}');
        }
      } else {
<<<<<<< HEAD
        print('Error response: ${response.body}');
        throw Exception('Failed to load submissions: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching submissions: $e');
      throw Exception('Error fetching submissions: $e');
=======
<<<<<<< Updated upstream
        print('Failed with status code: ${response.statusCode}');
        throw Exception('Failed to load assignments: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching assignments: $e');
      throw Exception('Gagal mengambil data tugas: $e');
=======
        throw Exception(
            "Gagal mengambil data: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      if (e is NoGroupException) {
        rethrow;
      }
      throw Exception("Error: $e");
>>>>>>> Stashed changes
>>>>>>> 0a57aa2e068c1ec95982e72d5ef76d66a209b51f
    }
  }

  // Fetch a specific submission by ID
  static Future<Submit> fetchSubmitById(int id) async {
    try {
      final headers = await _getAuthHeaders();
      
      final response = await http.get(
<<<<<<< HEAD
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.pengumpulanEndpoint}/$id'),
        headers: headers,
=======
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
<<<<<<< Updated upstream
        
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
=======

        // Check if the user doesn't have a group yet
        if (responseData['status'] == 'no_group') {
          throw NoGroupException(
              "Anda belum tergabung dalam kelompok. Silakan hubungi dosen untuk bergabung ke kelompok.");
        }

        if (responseData.containsKey('data')) {
          return Submit.fromJson(responseData['data']);
>>>>>>> Stashed changes
        } else {
          print('Error in response data: ${responseData['message']}');
          throw Exception(responseData['message'] ?? 'Gagal mengambil data tugas');
        }
      } else if (response.statusCode == 401) {
        print('Unauthorized, refreshing token');
        await _refreshToken();
        return fetchSubmitById(id); // Retry after refreshing token
      } else {
<<<<<<< Updated upstream
        print('Failed with status code: ${response.statusCode}');
        throw Exception('Failed to load assignment: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching assignment: $e');
      throw Exception('Gagal mengambil data tugas: $e');
=======
        throw Exception(
            "Gagal mengambil detail submitan: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      if (e is NoGroupException) {
        rethrow;
      }
      throw Exception("Error: $e");
>>>>>>> Stashed changes
    }
  }

  // Method to upload a submit file
  static Future<String> uploadSubmit(int tugasId, String filePath) async {
    try {
<<<<<<< Updated upstream
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
=======
      final uri = Uri.parse('$baseUrl/pengumpulan/$tugasId/upload');
      final request = http.MultipartRequest('POST', uri);

>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
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
=======
      final uri = Uri.parse('$baseUrl/pengumpulan/$tugasId/update');
      final request = http.MultipartRequest('PUT', uri);

>>>>>>> Stashed changes
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

<<<<<<< Updated upstream
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
>>>>>>> 0a57aa2e068c1ec95982e72d5ef76d66a209b51f
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          return Submit.fromJson(responseData['data']);
        } else {
          throw Exception('Invalid response format: ${response.body}');
        }
      } else {
        throw Exception('Failed to load submission: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching submission: $e');
      throw Exception('Error fetching submission: $e');
    }
  }

  // Upload a submission
  static Future<String> uploadSubmit(int submitId, String filePath) async {
    try {
      final token = await ApiService.getToken();
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.pengumpulanEndpoint}/$submitId/upload'),
      );

      // Add auth header
      request.headers['Authorization'] = 'Bearer $token';

      // Get file extension
      String extension = filePath.split('.').last.toLowerCase();
      
      // Add file to request
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          filePath,
          contentType: MediaType(
            _getMediaType(extension),
            extension,
          ),
        ),
      );

      print('Uploading file to: ${request.url}');
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      print('Upload response: ${response.statusCode} - $responseBody');

      if (response.statusCode == 200) {
        return 'File berhasil diunggah';
      } else {
        return 'Gagal mengunggah file: ${json.decode(responseBody)['message'] ?? 'Error ${response.statusCode}'}';
      }
    } catch (e) {
      print('Error uploading file: $e');
      return 'Error: $e';
    }
  }

  // Update a submission
  static Future<String> updateSubmit(int submitId, String filePath) async {
    try {
      final token = await ApiService.getToken();
      
      var request = http.MultipartRequest(
        'PUT', // Make sure this is PUT
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.pengumpulanEndpoint}/$submitId/upload'),
      );

      // Add auth header
      request.headers['Authorization'] = 'Bearer $token';

      // Get file extension
      String extension = filePath.split('.').last.toLowerCase();
      
      // Add file to request
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          filePath,
          contentType: MediaType(
            _getMediaType(extension),
            extension,
          ),
        ),
      );

      print('Updating file at: ${request.url}');
      print('Request method: ${request.method}');
      print('Request headers: ${request.headers}');
      
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      
      print('Update response: ${response.statusCode} - $responseBody');

      if (response.statusCode == 200) {
        return 'File berhasil diperbarui';
      } else {
        return 'Gagal memperbarui file: ${json.decode(responseBody)['message'] ?? 'Error ${response.statusCode}'}';
      }
    } catch (e) {
      print('Error updating file: $e');
      return 'Error: $e';
    }
  }

  // Helper method to get media type based on file extension
  static String _getMediaType(String extension) {
    switch (extension) {
      case 'pdf':
        return 'application';
      case 'doc':
      case 'docx':
        return 'application';
      case 'zip':
        return 'application';
      default:
        return 'application';
    }
  }

  // Get file URL for viewing
  static String getFileUrl(String filePath) {
    return ApiConstants.getFileUrl(filePath);
  }

  // Get file URL for downloading
  static String getDownloadUrl(String filePath) {
    return ApiConstants.getFileDownloadUrl(filePath);
  }
  
  // Test if a file can be accessed directly
  static Future<bool> testFileAccess(String filePath) async {
    try {
      final url = ApiConstants.getFileUrl(filePath);
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e) {
      print('Error testing file access: $e');
      return false;
    }
  }
  
  // List files in a directory
  static Future<List<Map<String, dynamic>>> listFiles(String path) async {
    try {
      final headers = await _getAuthHeaders();
      final url = ApiConstants.getFileListUrl(path);
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['files'] != null && responseData['files'] is List) {
          return List<Map<String, dynamic>>.from(responseData['files']);
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to list files: ${response.statusCode}');
      }
    } catch (e) {
      print('Error listing files: $e');
      return [];
    }
  }
}
=======
// Custom exception for no group case
class NoGroupException implements Exception {
  final String message;
  NoGroupException(this.message);

  @override
  String toString() => message;
}
>>>>>>> Stashed changes
