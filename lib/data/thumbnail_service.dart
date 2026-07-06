import 'dart:io';
import 'dart:typed_data';
import 'dart:ffi' as ffi;
import 'dart:isolate';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as p;

// C API bindings
typedef generate_thumbnail_ffi_c = ffi.Pointer<Utf8> Function(
    ffi.Pointer<Utf8> uri, ffi.Pointer<Utf8> mime_type);
typedef get_thumbnail_path_ffi_c = ffi.Pointer<Utf8> Function(
    ffi.Pointer<Utf8> uri);
typedef get_image_dimensions_ffi_c = ffi.Int32 Function(
    ffi.Pointer<Utf8> path, ffi.Pointer<ffi.Int32> width, ffi.Pointer<ffi.Int32> height);
typedef free_string_ffi_c = ffi.Void Function(ffi.Pointer<Utf8> ptr);

typedef GenerateThumbnailFfiDart = ffi.Pointer<Utf8> Function(
    ffi.Pointer<Utf8> uri, ffi.Pointer<Utf8> mimeType);
typedef GetThumbnailPathFfiDart = ffi.Pointer<Utf8> Function(
    ffi.Pointer<Utf8> uri);
typedef GetImageDimensionsFfiDart = int Function(
    ffi.Pointer<Utf8> path, ffi.Pointer<ffi.Int32> width, ffi.Pointer<ffi.Int32> height);
typedef FreeStringFfiDart = void Function(ffi.Pointer<Utf8> ptr);

class ThumbnailLib {
  static final ffi.DynamicLibrary _dylib =
      ffi.DynamicLibrary.open('libthumbnail.so');

  static final GenerateThumbnailFfiDart generateThumbnail = _dylib
      .lookup<ffi.NativeFunction<generate_thumbnail_ffi_c>>('generate_thumbnail_ffi')
      .asFunction<GenerateThumbnailFfiDart>();

  static final GetThumbnailPathFfiDart getThumbnailPath = _dylib
      .lookup<ffi.NativeFunction<get_thumbnail_path_ffi_c>>('get_thumbnail_path_ffi')
      .asFunction<GetThumbnailPathFfiDart>();

  static final GetImageDimensionsFfiDart getImageDimensions = _dylib
      .lookup<ffi.NativeFunction<get_image_dimensions_ffi_c>>('get_image_dimensions_ffi')
      .asFunction<GetImageDimensionsFfiDart>();

  static final FreeStringFfiDart freeString = _dylib
      .lookup<ffi.NativeFunction<free_string_ffi_c>>('free_string_ffi')
      .asFunction<FreeStringFfiDart>();
}

/// Service for generating and caching Thumbnails using FFI and file manager shared lib
class ThumbnailService {
  static const int thumbnailSize = 256; // Matching AetherFiles large thumbnail size

  /// Initialize cache folder (matching AetherFiles and Freedesktop Spec)
  Future<String> get cachePath async {
    final home = Platform.environment['HOME'] ?? '';
    final xdgCache = Platform.environment['XDG_CACHE_HOME'];
    final baseCache = xdgCache != null && xdgCache.isNotEmpty
        ? xdgCache
        : p.join(home, '.cache');
    return p.join(baseCache, 'thumbnails', 'large');
  }

  /// Get MIME type based on extension
  String _getMimeType(String filePath) {
    final ext = p.extension(filePath).toLowerCase();
    if (ext == '.mp4' || ext == '.mkv' || ext == '.avi' || ext == '.mov' || ext == '.webm') {
      return 'video/mp4';
    }
    if (ext == '.png') return 'image/png';
    if (ext == '.webp') return 'image/webp';
    if (ext == '.gif') return 'image/gif';
    if (ext == '.bmp') return 'image/bmp';
    return 'image/jpeg'; // Default fallback
  }

  /// Get local thumbnail cache path without freezing
  String _getCachedPath(String uri) {
    final uriPtr = uri.toNativeUtf8();
    final pathPtr = ThumbnailLib.getThumbnailPath(uriPtr);
    final path = pathPtr.toDartString();
    ThumbnailLib.freeString(pathPtr);
    malloc.free(uriPtr);
    return path;
  }

  /// Run FFI call to generate and cache Thumbnail in background Isolate
  static Future<String?> _generateThumbnailNative(String uri, String mimeType) async {
    return await Isolate.run(() {
      final uriPtr = uri.toNativeUtf8();
      final mimeTypePtr = mimeType.toNativeUtf8();
      try {
        final pathPtr = ThumbnailLib.generateThumbnail(uriPtr, mimeTypePtr);
        if (pathPtr == ffi.nullptr) return null;
        final path = pathPtr.toDartString();
        ThumbnailLib.freeString(pathPtr);
        return path;
      } catch (e) {
        return null;
      } finally {
        malloc.free(uriPtr);
        malloc.free(mimeTypePtr);
      }
    });
  }

  /// Generate or retrieve Thumbnail
  Future<Uint8List?> getThumbnail(String imagePath) async {
    try {
      final uri = Uri.file(imagePath).toString();

      // Check if image exists in cache on main thread 
      final thumbPath = _getCachedPath(uri);
      final file = File(thumbPath);
      if (file.existsSync()) {
        return await file.readAsBytes();
      }

      // If not present, we generate it in background Isolate
      final mimeType = _getMimeType(imagePath);
      final generatedPath = await _generateThumbnailNative(uri, mimeType);
      if (generatedPath != null) {
        final genFile = File(generatedPath);
        if (await genFile.exists()) {
          return await genFile.readAsBytes();
        }
      }
    } catch (e) {
      // Ignore errors and return empty
    }
    return null;
  }
}
