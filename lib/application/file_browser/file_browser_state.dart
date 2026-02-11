import 'package:equatable/equatable.dart';
import '../../domain/entities/file_item.dart';

/// حالة متصفح الملفات
class FileBrowserState extends Equatable {
  /// المسار الحالي
  final String currentPath;

  /// اسم المجلد الحالي
  final String currentDirName;

  /// العناصر في المجلد الحالي
  final List<FileItem> items;

  /// جاري التحميل
  final bool isLoading;

  /// هل المتصفح مرئي
  final bool isVisible;

  /// تاريخ التنقل (للرجوع)
  final List<String> history;

  /// المجلدات السريعة
  final List<FileItem> quickNavPaths;

  /// رسالة خطأ
  final String? errorMessage;

  const FileBrowserState({
    this.currentPath = '',
    this.currentDirName = '',
    this.items = const [],
    this.isLoading = false,
    this.isVisible = true,
    this.history = const [],
    this.quickNavPaths = const [],
    this.errorMessage,
  });

  /// عدد المجلدات
  int get directoryCount => items.where((i) => i.isDirectory).length;

  /// عدد الملفات
  int get fileCount => items.where((i) => !i.isDirectory).length;

  /// هل يمكن الرجوع
  bool get canGoBack => history.isNotEmpty;

  /// قائمة ملفات الفيديو فقط
  List<FileItem> get videoFiles => items.where((i) => !i.isDirectory).toList();

  FileBrowserState copyWith({
    String? currentPath,
    String? currentDirName,
    List<FileItem>? items,
    bool? isLoading,
    bool? isVisible,
    List<String>? history,
    List<FileItem>? quickNavPaths,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FileBrowserState(
      currentPath: currentPath ?? this.currentPath,
      currentDirName: currentDirName ?? this.currentDirName,
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isVisible: isVisible ?? this.isVisible,
      history: history ?? this.history,
      quickNavPaths: quickNavPaths ?? this.quickNavPaths,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        currentPath,
        currentDirName,
        items,
        isLoading,
        isVisible,
        history,
        quickNavPaths,
        errorMessage,
      ];
}
