import '../entities/file_item.dart';

/// Abstract interface for video file operations and file browsing
abstract class VideoRepository {
  /// Browse folder contents (folders + video files only)
  Future<List<FileItem>> listDirectory(String path);

  /// Get main folder path
  String getHomeDirectory();

  /// Get quick folders (Videos, Downloads, Home)
  List<FileItem> getQuickNavDirectories();

  /// Get supported formats
  List<String> get supportedExtensions;
}
