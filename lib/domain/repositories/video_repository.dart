import '../entities/video_item.dart';
import '../entities/file_item.dart';

/// واجهة تجريدية لعمليات ملفات الفيديو وتصفح الملفات
abstract class VideoRepository {
  /// تصفح محتويات مجلد (مجلدات + ملفات فيديو فقط)
  Future<List<FileItem>> listDirectory(String path);

  /// الحصول على مسار المجلد الرئيسي
  String getHomeDirectory();

  /// الحصول على المجلدات السريعة (Videos, Downloads, Home)
  List<FileItem> getQuickNavDirectories();

  /// الحصول على الصيغ المدعومة
  List<String> get supportedExtensions;
}
