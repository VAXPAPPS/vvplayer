import 'package:equatable/equatable.dart';

/// Entity representing a single video file
class VideoItem extends Equatable {
  final String path;
  final String title;
  final Duration? duration;

  const VideoItem({
    required this.path,
    required this.title,
    this.duration,
  });

  /// Create entity from file path
  factory VideoItem.fromPath(String filePath) {
    final segments = filePath.split('/');
    final fileName = segments.last;
    // Remove extension from file name
    final title = fileName.contains('.')
        ? fileName.substring(0, fileName.lastIndexOf('.'))
        : fileName;
    return VideoItem(path: filePath, title: title);
  }

  VideoItem copyWith({
    String? path,
    String? title,
    Duration? duration,
  }) {
    return VideoItem(
      path: path ?? this.path,
      title: title ?? this.title,
      duration: duration ?? this.duration,
    );
  }

  @override
  List<Object?> get props => [path, title, duration];
}
