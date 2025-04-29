import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class ArtefakService {
  static const String baseUrl = 'http://172.27.81.96:8080';

  Future<String> uploadFileForArtefak({
    required String filePath,
    required String token,
    required int artefakId,
  }) async {
    final uri = Uri.parse('$baseUrl/artefak/upload/$artefakId');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      filePath,
      filename: basename(filePath),
    ));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return 'File artefak berhasil diunggah!';
    } else {
      return 'Gagal unggah: $responseBody';
    }
  }

  Future<List<Map<String, dynamic>>> getArtefakList(String token) async {
    final uri = Uri.parse('$baseUrl/artefak/');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      return [];
    }
  }
}
