import 'dart:io';
import '../../domain/entities/file_item.dart';
import '../../domain/repositories/video_repository.dart';

/// Implement video repository using dart:io for file browsing
class VideoRepositoryImpl implements VideoRepository {
  @override
  List<String> get supportedExtensions => [
        'mp4', 'mkv', 'avi', 'webm', 'mov', 'wmv',
        'flv', 'mpg', 'mpeg', 'm4v', 'ts', '3gp',
        'ogv', 'vob', 'divx', 'f4v', 'rm', 'rmvb',
      ];

  @override
  String getHomeDirectory() {
    return Platform.environment['HOME'] ?? '/home';
  }

  @override
  List<FileItem> getQuickNavDirectories() {
    final home = getHomeDirectory();
    final quickPaths = <FileItem>[];

    // Main folder
    quickPaths.add(FileItem(
      name: 'main',
      path: home,
      isDirectory: true,
    ));

    // Common folders
    final commonDirs = {
      'Videos': '$home/Videos',
      'Downloads': '$home/Downloads',
      'Documents': '$home/Documents',
      'Music': '$home/Music',
      'Desktop': '$home/Desktop',
    };

    for (final entry in commonDirs.entries) {
      final dir = Directory(entry.value);
      if (dir.existsSync()) {
        quickPaths.add(FileItem(
          name: entry.key,
          path: entry.value,
          isDirectory: true,
        ));
      }
    }

    // Root
    quickPaths.add(const FileItem(
      name: 'System /',
      path: '/',
      isDirectory: true,
    ));

    return quickPaths;
  }

  @override
  Future<List<FileItem>> listDirectory(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) return [];

    final items = <FileItem>[];

    try {
      await for (final entity in dir.list(followLinks: true)) {
        try {
          final stat = await entity.stat();
          final name = entity.path.split('/').last;

          // Skip hidden files
          if (name.startsWith('.')) continue;

          if (entity is Directory) {
            items.add(FileItem(
              name: name,
              path: entity.path,
              isDirectory: true,
              modifiedDate: stat.modified,
            ));
          } else if (entity is File) {
            // Only video files
            final ext = name.split('.').last.toLowerCase();
            if (supportedExtensions.contains(ext)) {
              items.add(FileItem(
                name: name,
                path: entity.path,
                isDirectory: false,
                size: stat.size,
                modifiedDate: stat.modified,
              ));
            }
          }
        } catch (_) {
          // Skip inaccessible files
        }
      }
    } catch (_) {
      // permission denied or other errors
    }

    items.sort();
    return items;
  }
}
