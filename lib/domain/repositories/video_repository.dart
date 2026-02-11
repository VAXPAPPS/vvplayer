import '../entities/video_item.dart';

/// واجهة تجريدية لعمليات ملفات الفيديو
abstract class VideoRepository {
  /// فتح مربع حوار لاختيار ملف/ملفات فيديو
  Future<List<VideoItem>> pickVideoFiles();

  /// الحصول على الصيغ المدعومة
  List<String> get supportedExtensions;
}
