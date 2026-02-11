import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/video_item.dart';
import '../../domain/repositories/video_repository.dart';
import '../video_player/video_player_bloc.dart';
import '../video_player/video_player_event.dart';
import 'file_browser_event.dart';
import 'file_browser_state.dart';

class FileBrowserBloc extends Bloc<FileBrowserEvent, FileBrowserState> {
  final VideoRepository _repository;
  final VideoPlayerBloc _playerBloc;

  FileBrowserBloc({
    required VideoRepository repository,
    required VideoPlayerBloc playerBloc,
  })  : _repository = repository,
        _playerBloc = playerBloc,
        super(const FileBrowserState()) {
    on<NavigateToDirectory>(_onNavigateToDirectory);
    on<GoBack>(_onGoBack);
    on<GoHome>(_onGoHome);
    on<FileSelected>(_onFileSelected);
    on<PlayAllInDirectory>(_onPlayAllInDirectory);
    on<ToggleBrowserVisibility>(_onToggleBrowserVisibility);

    // تحميل المجلد الرئيسي والمجلدات السريعة عند البداية
    _init();
  }

  void _init() {
    final home = _repository.getHomeDirectory();
    final quickNav = _repository.getQuickNavDirectories();

    // ignore: invalid_use_of_visible_for_testing_member
    emit(state.copyWith(quickNavPaths: quickNav));
    add(NavigateToDirectory(home));
  }

  Future<void> _onNavigateToDirectory(
    NavigateToDirectory event,
    Emitter<FileBrowserState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final items = await _repository.listDirectory(event.path);
      final dirName = event.path == '/'
          ? '/'
          : event.path.split('/').where((s) => s.isNotEmpty).last;

      // إضافة المسار الحالي للتاريخ (إذا لم يكن فارغاً)
      final newHistory = List<String>.from(state.history);
      if (state.currentPath.isNotEmpty && state.currentPath != event.path) {
        newHistory.add(state.currentPath);
      }

      emit(state.copyWith(
        currentPath: event.path,
        currentDirName: dirName,
        items: items,
        isLoading: false,
        history: newHistory,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'لا يمكن الوصول لهذا المجلد',
      ));
    }
  }

  Future<void> _onGoBack(
    GoBack event,
    Emitter<FileBrowserState> emit,
  ) async {
    if (!state.canGoBack) return;

    final newHistory = List<String>.from(state.history);
    final previousPath = newHistory.removeLast();

    emit(state.copyWith(history: newHistory));

    // التنقل للمجلد السابق بدون إضافة للتاريخ
    final items = await _repository.listDirectory(previousPath);
    final dirName = previousPath == '/'
        ? '/'
        : previousPath.split('/').where((s) => s.isNotEmpty).last;

    emit(state.copyWith(
      currentPath: previousPath,
      currentDirName: dirName,
      items: items,
      isLoading: false,
    ));
  }

  Future<void> _onGoHome(
    GoHome event,
    Emitter<FileBrowserState> emit,
  ) async {
    final home = _repository.getHomeDirectory();
    // مسح التاريخ والذهاب للرئيسية
    emit(state.copyWith(history: const []));
    add(NavigateToDirectory(home));
  }

  void _onFileSelected(
    FileSelected event,
    Emitter<FileBrowserState> emit,
  ) {
    // إنشاء VideoItem وإرسال للـ PlayerBloc
    // ignore: unused_local_variable
    final videoItem = VideoItem.fromPath(event.path);
    _playerBloc.add(FilesDropped([event.path]));

    // إخفاء المتصفح عند تشغيل فيديو
    emit(state.copyWith(isVisible: false));
  }

  void _onPlayAllInDirectory(
    PlayAllInDirectory event,
    Emitter<FileBrowserState> emit,
  ) {
    final videoPaths = state.videoFiles.map((f) => f.path).toList();
    if (videoPaths.isEmpty) return;

    _playerBloc.add(FilesDropped(videoPaths));
    emit(state.copyWith(isVisible: false));
  }

  void _onToggleBrowserVisibility(
    ToggleBrowserVisibility event,
    Emitter<FileBrowserState> emit,
  ) {
    emit(state.copyWith(isVisible: !state.isVisible));
  }
}
