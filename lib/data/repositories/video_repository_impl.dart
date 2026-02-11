import 'dart:io';
import '../../domain/entities/video_item.dart';
import '../../domain/entities/file_item.dart';
import '../../domain/repositories/video_repository.dart';

/// تنفيذ مستودع الفيديو باستخدام dart:io لتصفح الملفات
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

    // المجلد الرئيسي
    quickPaths.add(FileItem(
      name: 'main',
      path: home,
      isDirectory: true,
    ));

    // مجلدات شائعة
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

    // الجذر
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

          // تخطي الملفات المخفية
          if (name.startsWith('.')) continue;

          if (entity is Directory) {
            items.add(FileItem(
              name: name,
              path: entity.path,
              isDirectory: true,
              modifiedDate: stat.modified,
            ));
          } else if (entity is File) {
            // فقط ملفات الفيديو
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
          // تخطي الملفات التي لا يمكن الوصول إليها
        }
      }
    } catch (_) {
      // permission denied أو أخطاء أخرى
    }

    items.sort();
    return items;
  }
}
