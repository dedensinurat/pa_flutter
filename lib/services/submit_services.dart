import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/submit_model.dart';
import '../utils/api_constants.dart';
import 'api_service.dart'; // Import your ApiService to access the token

class SubmitService {
  // Helper method to get auth headers
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await ApiService.getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

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
        final responseData = json.decode(response.body);
        print('Response data: $responseData');
        
        if (responseData['data'] != null && responseData['data'] is List) {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => Submit.fromJson(json)).toList();
        } else {
          throw Exception('Invalid response format: ${response.body}');
        }
      } else {
        print('Error response: ${response.body}');
        throw Exception('Failed to load submissions: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching submissions: $e');
      throw Exception('Error fetching submissions: $e');
    }
  }

  // Fetch a specific submission by ID
  static Future<Submit> fetchSubmitById(int id) async {
    try {
      final headers = await _getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.pengumpulanEndpoint}/$id'),
        headers: headers,
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