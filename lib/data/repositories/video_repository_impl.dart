import 'package:file_picker/file_picker.dart';
import '../../domain/entities/video_item.dart';
import '../../domain/repositories/video_repository.dart';

/// تنفيذ مستودع الفيديو باستخدام file_picker
class VideoRepositoryImpl implements VideoRepository {
  @override
  List<String> get supportedExtensions => [
        'mp4', 'mkv', 'avi', 'webm', 'mov', 'wmv',
        'flv', 'mpg', 'mpeg', 'm4v', 'ts', '3gp',
        'ogv', 'vob', 'divx', 'f4v', 'rm', 'rmvb',
      ];

  @override
  Future<List<VideoItem>> pickVideoFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: supportedExtensions,
      allowMultiple: true,
      dialogTitle: 'اختر ملفات فيديو',
    );

    if (result == null || result.files.isEmpty) {
      return [];
    }

    return result.files
        .where((file) => file.path != null)
        .map((file) => VideoItem.fromPath(file.path!))
        .toList();
  }
}
