import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/video_item.dart';
import '../../domain/entities/file_item.dart';
import '../../domain/repositories/video_repository.dart';
import '../../data/thumbnail_service.dart';
import '../video_player/video_player_bloc.dart';
import '../video_player/video_player_event.dart';
import 'file_browser_event.dart';
import 'file_browser_state.dart';

class FileBrowserBloc extends Bloc<FileBrowserEvent, FileBrowserState> {
  final VideoRepository _repository;
  final VideoPlayerBloc _playerBloc;
  final ThumbnailService _thumbnailService = ThumbnailService();

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
    on<ThumbnailLoaded>(_onThumbnailLoaded);

    // Load main folder and quick folders on start
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

      // Add current path to history (if not empty)
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

      _loadThumbnailsForItems(event.path, items);
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Cannot access this folder',
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

    // Navigate to previous folder without adding to history
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

    _loadThumbnailsForItems(previousPath, items);
  }

  Future<void> _onGoHome(
    GoHome event,
    Emitter<FileBrowserState> emit,
  ) async {
    final home = _repository.getHomeDirectory();
    // Clear history and go to main
    emit(state.copyWith(history: const []));
    add(NavigateToDirectory(home));
  }

  void _onFileSelected(
    FileSelected event,
    Emitter<FileBrowserState> emit,
  ) {
    // Create VideoItem and send to PlayerBloc
    // ignore: unused_local_variable
    final videoItem = VideoItem.fromPath(event.path);
    _playerBloc.add(FilesDropped([event.path]));

    // Hide browser when playing video
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

  void _onThumbnailLoaded(
    ThumbnailLoaded event,
    Emitter<FileBrowserState> emit,
  ) {
    final updatedItems = state.items.map((item) {
      if (item.path == event.path) {
        return item.copyWith(thumbnailBytes: event.bytes);
      }
      return item;
    }).toList();
    emit(state.copyWith(items: updatedItems));
  }

  void _loadThumbnailsForItems(String dirPath, List<FileItem> items) {
    final videoItems = items.where((i) => !i.isDirectory).toList();
    for (final item in videoItems) {
      _thumbnailService.getThumbnail(item.path).then((bytes) {
        if (bytes != null && state.currentPath == dirPath) {
          add(ThumbnailLoaded(item.path, bytes));
        }
      });
    }
  }
}
