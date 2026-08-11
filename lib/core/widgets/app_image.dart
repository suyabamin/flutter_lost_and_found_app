import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Universal image widget that safely handles:
/// 1. Raw bytes (Uint8List) — highest priority, always shows user's actual photo
/// 2. HTTP(S) URLs
/// 3. Base64 Data URIs
/// 4. Local file paths (non-web)
/// 5. Fallback placeholder image
class AppImage extends StatelessWidget {
  final String url;

  /// Optional raw image bytes — when provided, these take priority over the URL.
  /// Use this to display the user's actual picked photo without any upload/encoding.
  final Uint8List? bytes;

  final double? width;
  final double? height;
  final BoxFit fit;
  final String placeholderSeed;
  final BorderRadius? borderRadius;

  const AppImage({
    super.key,
    required this.url,
    this.bytes,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholderSeed = 'item',
    this.borderRadius,
  });

  /// Build an ImageProvider for contexts requiring ImageProvider (e.g. DecorationImage / CircleAvatar)
  static ImageProvider getImageProvider(String imagePath, {String placeholderSeed = 'item', Uint8List? bytes}) {
    if (bytes != null) return MemoryImage(bytes);

    final clean = imagePath.trim();

    if (clean.startsWith('data:image')) {
      try {
        final commaIndex = clean.indexOf(',');
        if (commaIndex != -1) {
          final base64Data = clean.substring(commaIndex + 1);
          final decoded = base64Decode(base64Data);
          return MemoryImage(decoded);
        }
      } catch (_) {}
    } else if (clean.startsWith('http://') || clean.startsWith('https://')) {
      return NetworkImage(clean);
    } else if (clean.isNotEmpty && !kIsWeb) {
      try {
        final file = File(clean);
        if (file.existsSync()) {
          return FileImage(file);
        }
      } catch (_) {}
    }

    return NetworkImage('https://picsum.photos/seed/$placeholderSeed/600/400');
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = _buildRawImage();

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildRawImage() {
    final fallbackUrl = 'https://picsum.photos/seed/$placeholderSeed/600/400';

    // ── 1. Raw bytes (highest priority — user's actual photo, always works) ──
    if (bytes != null && bytes!.isNotEmpty) {
      return Image.memory(
        bytes!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) =>
            Image.network(fallbackUrl, width: width, height: height, fit: fit),
      );
    }

    final clean = url.trim();

    if (clean.isEmpty) {
      return Image.network(fallbackUrl, width: width, height: height, fit: fit);
    }

    // ── 2. Base64 Data URI ──
    if (clean.startsWith('data:image')) {
      try {
        final commaIndex = clean.indexOf(',');
        if (commaIndex != -1) {
          final base64Data = clean.substring(commaIndex + 1);
          final decoded = base64Decode(base64Data);
          return Image.memory(
            decoded,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, __, ___) =>
                Image.network(fallbackUrl, width: width, height: height, fit: fit),
          );
        }
      } catch (_) {}
    }

    // ── 3. HTTP / HTTPS ──
    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      return Image.network(
        clean,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) =>
            Image.network(fallbackUrl, width: width, height: height, fit: fit),
      );
    }

    // ── 4. Local File (non-web) ──
    if (!kIsWeb) {
      try {
        final file = File(clean);
        if (file.existsSync()) {
          return Image.file(
            file,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, __, ___) =>
                Image.network(fallbackUrl, width: width, height: height, fit: fit),
          );
        }
      } catch (_) {}
    }

    // ── 5. Fallback placeholder ──
    return Image.network(fallbackUrl, width: width, height: height, fit: fit);
  }
}
