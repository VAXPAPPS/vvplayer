import 'package:equatable/equatable.dart';
import '../../domain/entities/file_item.dart';

/// File browser state
class FileBrowserState extends Equatable {
  /// Current path
  final String currentPath;

  /// Current folder name
  final String currentDirName;

  /// Items in current folder
  final List<FileItem> items;

  /// Loading
  final bool isLoading;

  /// Is browser visible
  final bool isVisible;

  /// Navigation history (for going back)
  final List<String> history;

  /// Quick folders
  final List<FileItem> quickNavPaths;

  /// Error message
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

  /// Number of folders
  int get directoryCount => items.where((i) => i.isDirectory).length;

  /// Number of files
  int get fileCount => items.where((i) => !i.isDirectory).length;

  /// Can navigate back
  bool get canGoBack => history.isNotEmpty;

  /// Video files list only
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
