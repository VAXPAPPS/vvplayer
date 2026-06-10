import 'dart:typed_data';
import 'package:equatable/equatable.dart';

/// أحداث متصفح الملفات
abstract class FileBrowserEvent extends Equatable {
  const FileBrowserEvent();

  @override
  List<Object?> get props => [];
}

/// تحميل محتويات مجلد
class NavigateToDirectory extends FileBrowserEvent {
  final String path;
  const NavigateToDirectory(this.path);

  @override
  List<Object?> get props => [path];
}

/// رجوع للمجلد السابق
class GoBack extends FileBrowserEvent {}

/// رجوع للمجلد الرئيسي
class GoHome extends FileBrowserEvent {}

/// اختيار ملف فيديو للتشغيل
class FileSelected extends FileBrowserEvent {
  final String path;
  const FileSelected(this.path);

  @override
  List<Object?> get props => [path];
}

/// تشغيل جميع الفيديوهات في المجلد الحالي
class PlayAllInDirectory extends FileBrowserEvent {}

/// تبديل عرض المتصفح
class ToggleBrowserVisibility extends FileBrowserEvent {}

/// حدث تحديث الصورة المصغرة لملف
class ThumbnailLoaded extends FileBrowserEvent {
  final String path;
  final Uint8List bytes;
  const ThumbnailLoaded(this.path, this.bytes);

  @override
  List<Object?> get props => [path, bytes];
}
