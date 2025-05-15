import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/submit_model.dart';
import '../utils/api_constants.dart';

class SubmitService {
  // Fetch all submissions
  static Future<List<Submit>> fetchSubmits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt');
      
      if (token == null) {
        throw Exception("Token tidak ditemukan, silakan login kembali");
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/pengumpulan/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          
          // Check if the response has data field
          if (responseData.containsKey('data')) {
            final List<dynamic> tugasList = responseData['data'];
            print('Fetched ${tugasList.length} assignments');
            
            // Process each item
            final submissions = <Submit>[];
            for (var i = 0; i < tugasList.length; i++) {
              try {
                final item = tugasList[i];
                print('Processing item $i: ${item['judul_tugas'] ?? 'Unknown'}');
                submissions.add(Submit.fromJson(item));
              } catch (e) {
                print('Error processing item $i: $e');
                // Continue processing other items
              }
            }
            
            print('Successfully processed ${submissions.length} submissions');
            return submissions;
          } else {
            print('No data field in response. Keys: ${responseData.keys.toList()}');
            throw Exception('Invalid response format: no data field');
          }
        } catch (e) {
          print('Error parsing response: $e');
          throw Exception('Error parsing response: $e');
        }
      } else {
        print('Error response: ${response.body}');
        throw Exception('Failed to load submissions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching submissions: $e');
      throw Exception('Error fetching submissions: $e');
    }
  }

  // Fetch a single submission by ID
  static Future<Submit> fetchSubmitById(int submitId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt');
      
      if (token == null) {
        throw Exception("Token tidak ditemukan, silakan login kembali");
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/pengumpulan/$submitId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);
          if (responseData['data'] != null) {
            return Submit.fromJson(responseData['data']);
          } else {
            throw Exception('Invalid response format: no data field');
          }
        } catch (e) {
          print('Error parsing response for submission $submitId: $e');
          throw Exception('Error parsing response: $e');
        }
      } else {
        print('Error response for submission $submitId: ${response.body}');
        throw Exception('Failed to load submission: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching submission $submitId: $e');
      throw Exception('Error fetching submission: $e');
    }
  }

  // Method to upload a submit file
  static Future<String> uploadSubmit(int tugasId, String filePath) async {
    try {
      print('Uploading file for task ID: $tugasId');
      print('File path: $filePath');
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt');
      
      if (token == null) {
        throw Exception("Token tidak ditemukan, silakan login kembali");
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
      
      // Get file extension
      String extension = filePath.split('.').last.toLowerCase();
      
      // Add the file to the request
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType: MediaType(
          _getMediaType(extension),
          extension,
        ),
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
        print('File uploaded successfully');
        return 'File berhasil diunggah!';
      } else {
        print('Error response: ${response.statusCode} - ${response.body}');
        return 'Gagal unggah: ${responseBody['message'] ?? responseBody['error'] ?? 'Error ${response.statusCode}'}';
      }
    } catch (e) {
      print('Error uploading file: $e');
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
      
      if (token == null) {
        throw Exception("Token tidak ditemukan, silakan login kembali");
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
      
      // Get file extension
      String extension = filePath.split('.').last.toLowerCase();
      
      // Add the file to the request
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType: MediaType(
          _getMediaType(extension),
          extension,
        ),
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
        print('File updated successfully');
        return 'File berhasil diperbarui!';
      } else {
        print('Error response: ${response.statusCode} - ${response.body}');
        return 'Gagal memperbarui: ${responseBody['message'] ?? responseBody['error'] ?? 'Error ${response.statusCode}'}';
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
}
