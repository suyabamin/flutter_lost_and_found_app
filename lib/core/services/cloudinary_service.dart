import 'dart:convert';
import 'dart:typed_data';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';

enum ImageUploadStatus { pending, uploading, success, failed }

class ImageUploadTask {
  final String id;
  final XFile xfile;
  final Uint8List bytes;
  ImageUploadStatus status;
  String? uploadedUrl;
  String? errorMessage;

  ImageUploadTask({
    required this.id,
    required this.xfile,
    required this.bytes,
    this.status = ImageUploadStatus.pending,
    this.uploadedUrl,
    this.errorMessage,
  });
}

class CloudinaryService {
  late final CloudinaryPublic? _cloudinary;
  final bool _isConfigured;

  CloudinaryService()
    : _isConfigured =
          (dotenv.env['CLOUDINARY_CLOUD_NAME'] != null &&
          dotenv.env['CLOUDINARY_CLOUD_NAME'] != 'demo_cloud_name' &&
          dotenv.env['CLOUDINARY_CLOUD_NAME']!.isNotEmpty),
      _cloudinary =
          (dotenv.env['CLOUDINARY_CLOUD_NAME'] != null &&
              dotenv.env['CLOUDINARY_CLOUD_NAME'] != 'demo_cloud_name')
          ? CloudinaryPublic(
              dotenv.env['CLOUDINARY_CLOUD_NAME']!,
              dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? 'preset',
              cache: false,
            )
          : null;

  /// Upload a single XFile.
  /// If Cloudinary is configured, uploads to Cloudinary.
  /// Otherwise, converts the actual user photo to self-contained Base64 Data URI.
  /// NEVER returns random stock images or placeholder pictures.
  Future<String> uploadXFile(
    XFile xfile, {
    String folder = 'lost_and_found',
  }) async {
    final bytes = await xfile.readAsBytes();

    // 1. Try Cloudinary if properly configured
    if (_isConfigured && _cloudinary != null) {
      try {
        final response = await _cloudinary
            .uploadFile(
              CloudinaryFile.fromBytesData(
                bytes,
                identifier: xfile.name.isNotEmpty ? xfile.name : 'upload.jpg',
                resourceType: CloudinaryResourceType.Image,
                folder: folder,
              ),
            )
            .timeout(const Duration(seconds: 15));
        return response.secureUrl;
      } catch (e) {
        print('Cloudinary upload notice: $e');
        // Fall through to actual photo Base64 Data URI
      }
    }

    // 2. Return the user's photo as Base64 Data URI with safety guard for Firestore limits
    final base64String = base64Encode(bytes);
    final mimeType = xfile.mimeType ?? 'image/jpeg';
    final dataUrl = 'data:$mimeType;base64,$base64String';

    // Firestore string property limit is 1,048,487 bytes (~1MB)
    if (dataUrl.length > 900000) {
      throw Exception(
        'Selected photo is too large (${(dataUrl.length / 1024).toStringAsFixed(0)} KB). Please choose a smaller image or crop it before uploading.',
      );
    }

    return dataUrl;
  }

  /// Upload multiple XFiles safely for Firestore document storage using controlled concurrency
  Future<List<String>> uploadMultipleXFiles(
    List<XFile> xfiles, {
    String folder = 'lost_and_found',
    int maxConcurrency = 3,
    void Function(int completed, int total, String statusMessage)? onProgress,
  }) async {
    if (xfiles.isEmpty) return [];

    return await uploadMultipleXFilesWithConcurrency(
      xfiles,
      folder: folder,
      maxConcurrency: maxConcurrency,
      onProgress: onProgress,
    );
  }

  /// Upload multiple XFiles using a pool worker to limit maximum parallel uploads (e.g., max 3 at a time)
  Future<List<String>> uploadMultipleXFilesWithConcurrency(
    List<XFile> xfiles, {
    String folder = 'lost_and_found',
    int maxConcurrency = 3,
    void Function(int completed, int total, String statusMessage)? onProgress,
  }) async {
    if (xfiles.isEmpty) return [];

    final results = List<String?>.filled(xfiles.length, null);
    int completedCount = 0;
    onProgress?.call(0, xfiles.length, 'Preparing images...');

    int nextIndex = 0;
    Future<void> worker() async {
      while (nextIndex < xfiles.length) {
        final currentIndex = nextIndex++;
        final file = xfiles[currentIndex];
        onProgress?.call(
          completedCount,
          xfiles.length,
          'Uploading image ${currentIndex + 1} of ${xfiles.length}...',
        );

        try {
          final url = await uploadXFile(file, folder: folder);
          results[currentIndex] = url;
        } catch (e) {
          results[currentIndex] = null;
        } finally {
          completedCount++;
          onProgress?.call(
            completedCount,
            xfiles.length,
            'Uploaded $completedCount of ${xfiles.length} images',
          );
        }
      }
    }

    final workerCount = xfiles.length < maxConcurrency
        ? xfiles.length
        : maxConcurrency;
    final workers = List.generate(workerCount, (_) => worker());
    await Future.wait(workers);

    return results.whereType<String>().toList();
  }
}
