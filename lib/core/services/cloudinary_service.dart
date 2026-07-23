import 'dart:convert';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  late final CloudinaryPublic? _cloudinary;
  final bool _isConfigured;

  CloudinaryService()
      : _isConfigured = (dotenv.env['CLOUDINARY_CLOUD_NAME'] != null &&
            dotenv.env['CLOUDINARY_CLOUD_NAME'] != 'demo_cloud_name' &&
            dotenv.env['CLOUDINARY_CLOUD_NAME']!.isNotEmpty),
        _cloudinary = (dotenv.env['CLOUDINARY_CLOUD_NAME'] != null &&
                dotenv.env['CLOUDINARY_CLOUD_NAME'] != 'demo_cloud_name')
            ? CloudinaryPublic(
                dotenv.env['CLOUDINARY_CLOUD_NAME']!,
                dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? 'preset',
                cache: false,
              )
            : null;

  /// Upload a single XFile to Cloudinary or convert to self-contained Base64 Data URI
  Future<String> uploadXFile(XFile xfile, {String folder = 'lost_and_found'}) async {
    final bytes = await xfile.readAsBytes();
    
    // If Cloudinary is configured, attempt upload to Cloudinary
    if (_isConfigured && _cloudinary != null) {
      try {
        final response = await _cloudinary.uploadFile(
          CloudinaryFile.fromBytesData(
            bytes,
            identifier: xfile.name.isNotEmpty ? xfile.name : 'upload.jpg',
            resourceType: CloudinaryResourceType.Image,
            folder: folder,
          ),
        );
        return response.secureUrl;
      } catch (_) {
        // Fallback to base64 Data URI so exact image is preserved
      }
    }

    // Convert raw image bytes to Data URI so the EXACT user-uploaded image is saved & shown
    final base64String = base64Encode(bytes);
    final mimeType = xfile.mimeType ?? 'image/jpeg';
    return 'data:$mimeType;base64,$base64String';
  }

  /// Upload multiple XFiles concurrently
  Future<List<String>> uploadMultipleXFiles(List<XFile> xfiles, {String folder = 'lost_and_found'}) async {
    if (xfiles.isEmpty) return [];
    final tasks = xfiles.map((file) => uploadXFile(file, folder: folder));
    return await Future.wait(tasks);
  }
}
