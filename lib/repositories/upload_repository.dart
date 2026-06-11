import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:near_vibe/core/apikeys/api_key.dart';

class UploadRepository {
  Future<String> uploadImage(File imageFile) async {
    try {
      final timestamp =
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
      const folder = 'events';

      // Signature: sha1 of "folder=events&timestamp=<ts><apiSecret>"
      final stringToSign = 'folder=$folder&timestamp=$timestamp'
          '${CloudinaryConstants.apiSecret}';
      final signature =
          sha1.convert(utf8.encode(stringToSign)).toString();

      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/${CloudinaryConstants.cloudName}/image/upload',
      );

      final request = http.MultipartRequest('POST', uri);
      request.fields['api_key'] = CloudinaryConstants.apiKey;
      request.fields['timestamp'] = timestamp;
      request.fields['signature'] = signature;
      request.fields['folder'] = folder;
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode != 200) {
        throw Exception(
            'Upload failed [${response.statusCode}]: ${response.body}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final secureUrl = data['secure_url'] as String?;

      if (secureUrl == null) {
        throw Exception('No URL in response: ${response.body}');
      }

      return secureUrl;
    } catch (e) {
      throw Exception('Cloudinary Upload Failed: $e');
    }
  }
}