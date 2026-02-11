import 'package:equatable/equatable.dart';

/// كيان يمثل عنصر في متصفح الملفات (مجلد أو ملف فيديو)
class FileItem extends Equatable implements Comparable<FileItem> {
  /// اسم الملف أو المجلد
  final String name;

  /// المسار الكامل
  final String path;

  /// هل هو مجلد
  final bool isDirectory;

  /// حجم الملف بالبايت (فقط للملفات)
  final int size;

  /// تاريخ آخر تعديل
  final DateTime? modifiedDate;

  const FileItem({
    required this.name,
    required this.path,
    required this.isDirectory,
    this.size = 0,
    this.modifiedDate,
  });

  /// الحجم بصيغة مقروءة
  String get formattedSize {
    if (isDirectory) return '';
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// امتداد الملف
  String get extension {
    if (isDirectory) return '';
    final dot = name.lastIndexOf('.');
    return dot != -1 ? name.substring(dot + 1).toLowerCase() : '';
  }

  /// ترتيب: المجلدات أولاً ثم الملفات أبجدياً
  @override
  int compareTo(FileItem other) {
    if (isDirectory && !other.isDirectory) return -1;
    if (!isDirectory && other.isDirectory) return 1;
    return name.toLowerCase().compareTo(other.name.toLowerCase());
  }

  @override
  List<Object?> get props => [name, path, isDirectory, size, modifiedDate];
}
