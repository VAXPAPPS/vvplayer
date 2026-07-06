import 'dart:typed_data';
import 'package:equatable/equatable.dart';

/// Entity representing an item in file browser (folder or video file)
class FileItem extends Equatable implements Comparable<FileItem> {
  /// File or folder name
  final String name;

  /// Full path
  final String path;

  /// Is it a folder
  final bool isDirectory;

  /// File size in bytes (only for files)
  final int size;

  /// Last modified date
  final DateTime? modifiedDate;

  /// Thumbnail pixels (only for video files)
  final Uint8List? thumbnailBytes;

  const FileItem({
    required this.name,
    required this.path,
    required this.isDirectory,
    this.size = 0,
    this.modifiedDate,
    this.thumbnailBytes,
  });

  /// Size in readable format
  String get formattedSize {
    if (isDirectory) return '';
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// File extension
  String get extension {
    if (isDirectory) return '';
    final dot = name.lastIndexOf('.');
    return dot != -1 ? name.substring(dot + 1).toLowerCase() : '';
  }

  FileItem copyWith({
    String? name,
    String? path,
    bool? isDirectory,
    int? size,
    DateTime? modifiedDate,
    Uint8List? thumbnailBytes,
  }) {
    return FileItem(
      name: name ?? this.name,
      path: path ?? this.path,
      isDirectory: isDirectory ?? this.isDirectory,
      size: size ?? this.size,
      modifiedDate: modifiedDate ?? this.modifiedDate,
      thumbnailBytes: thumbnailBytes ?? this.thumbnailBytes,
    );
  }

  /// Order: folders first then files alphabetically
  @override
  int compareTo(FileItem other) {
    if (isDirectory && !other.isDirectory) return -1;
    if (!isDirectory && other.isDirectory) return 1;
    return name.toLowerCase().compareTo(other.name.toLowerCase());
  }

  @override
  List<Object?> get props => [name, path, isDirectory, size, modifiedDate, thumbnailBytes];
}

