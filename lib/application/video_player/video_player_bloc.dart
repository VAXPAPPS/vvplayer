import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart';

import '../../domain/entities/video_item.dart';
import '../../domain/entities/playlist.dart' as app;
import '../../domain/repositories/video_repository.dart';
import '../../infrastructure/services/media_player_service.dart';
import 'video_player_event.dart';
import 'video_player_state.dart';

class VideoPlayerBloc extends Bloc<VideoPlayerEvent, VideoPlayerState> {
  final MediaPlayerService _playerService;
  final VideoRepository _repository;

  /// Access to Player service (for VideoController)
  MediaPlayerService get playerService => _playerService;

  final List<StreamSubscription> _subscriptions = [];

  VideoPlayerBloc({
    required MediaPlayerService playerService,
    required VideoRepository repository,
  })  : _playerService = playerService,
        _repository = repository,
        super(const VideoPlayerState()) {
    // Basic Playback
    on<FilesDropped>(_onFilesDropped);
    on<PlayPauseToggled>(_onPlayPauseToggled);
    on<StopRequested>(_onStopRequested);

    // Navigation
    on<SeekRequested>(_onSeekRequested);
    on<SeekForwardRequested>(_onSeekForwardRequested);
    on<SeekBackwardRequested>(_onSeekBackwardRequested);

    // Volume
    on<VolumeChanged>(_onVolumeChanged);
    on<MuteToggled>(_onMuteToggled);
    on<VolumeUpRequested>(_onVolumeUpRequested);
    on<VolumeDownRequested>(_onVolumeDownRequested);

    // Speed
    on<SpeedChanged>(_onSpeedChanged);

    // Screen
    on<FullscreenToggled>(_onFullscreenToggled);

    // Playlist
    on<NextTrackRequested>(_onNextTrackRequested);
    on<PreviousTrackRequested>(_onPreviousTrackRequested);
    on<JumpToTrackRequested>(_onJumpToTrackRequested);
    on<RemoveFromPlaylist>(_onRemoveFromPlaylist);
    on<LoopModeToggled>(_onLoopModeToggled);

    // Tracks
    on<AudioTrackChanged>(_onAudioTrackChanged);
    on<SubtitleTrackChanged>(_onSubtitleTrackChanged);
    on<ExternalSubtitleRequested>(_onExternalSubtitleRequested);

    // Others
    on<ScreenshotRequested>(_onScreenshotRequested);
    on<PlaylistPanelToggled>(_onPlaylistPanelToggled);
    on<VideoInfoToggled>(_onVideoInfoToggled);

    // Internal events
    on<PositionUpdated>(_onPositionUpdated);
    on<DurationUpdated>(_onDurationUpdated);
    on<BufferingStateChanged>(_onBufferingStateChanged);
    on<PlaybackCompleted>(_onPlaybackCompleted);
    on<TracksUpdated>(_onTracksUpdated);
    on<ErrorOccurred>(_onErrorOccurred);
    
    on<PlayInjectedFileRequested>((event, emit) async {
      await playerService.open(event.path);
    });

    // Listening to Streams
    _initStreams();
  }

  void _initStreams() {
    _subscriptions.add(
      _playerService.playingStream.listen((isPlaying) {
        if (!isClosed) {
          // ignore: invalid_use_of_visible_for_testing_member
          emit(state.copyWith(
            status: isPlaying ? PlayerStatus.playing : PlayerStatus.paused,
          ));
        }
      }),
    );

    _subscriptions.add(
      _playerService.positionStream.listen((position) {
        if (!isClosed) {
          add(PositionUpdated(position));
        }
      }),
    );

    _subscriptions.add(
      _playerService.durationStream.listen((duration) {
        if (!isClosed) {
          add(DurationUpdated(duration));
        }
      }),
    );

    _subscriptions.add(
      _playerService.bufferingStream.listen((isBuffering) {
        if (!isClosed) {
          add(BufferingStateChanged(isBuffering));
        }
      }),
    );

    _subscriptions.add(
      _playerService.completedStream.listen((completed) {
        if (!isClosed && completed) {
          add(PlaybackCompleted());
        }
      }),
    );

    _subscriptions.add(
      _playerService.tracksStream.listen((tracks) {
        if (!isClosed) {
          add(TracksUpdated(tracks.audio, tracks.subtitle));
        }
      }),
    );

    _subscriptions.add(
      _playerService.errorStream.listen((error) {
        if (!isClosed && error.isNotEmpty) {
          add(ErrorOccurred(error));
        }
      }),
    );
  }

  // ===== Event handlers =====

  Future<void> _onFilesDropped(
    FilesDropped event,
    Emitter<VideoPlayerState> emit,
  ) async {
    final supported = _repository.supportedExtensions;
    final items = event.paths
        .where((path) {
          final ext = path.split('.').last.toLowerCase();
          return supported.contains(ext);
        })
        .map((path) => VideoItem.fromPath(path))
        .toList();

    if (items.isEmpty) return;

    await _loadVideos(items, emit);
  }

  Future<void> _loadVideos(
    List<VideoItem> items,
    Emitter<VideoPlayerState> emit,
  ) async {
    emit(state.copyWith(status: PlayerStatus.loading, clearError: true));

    try {
      // Add to current playlist or create new one
      final currentItems = List<VideoItem>.from(state.playlist.items);
      final startIndex = currentItems.isEmpty ? 0 : currentItems.length;
      currentItems.addAll(items);

      final newPlaylist = state.playlist.copyWith(
        items: currentItems,
        currentIndex: state.playlist.isEmpty ? 0 : state.playlist.currentIndex,
      );

      emit(state.copyWith(playlist: newPlaylist));

      // Load playlist in player
      final paths = currentItems.map((item) => item.path).toList();
      await _playerService.openPlaylist(
        paths,
        index: state.playlist.isEmpty ? 0 : startIndex,
      );
    } catch (e) {
      emit(state.copyWith(
        status: PlayerStatus.error,
        errorMessage: 'Failed to load video: $e',
      ));
    }
  }

  Future<void> _onPlayPauseToggled(
    PlayPauseToggled event,
    Emitter<VideoPlayerState> emit,
  ) async {
    if (!state.hasMedia) return;
    await _playerService.playOrPause();
  }

  Future<void> _onStopRequested(
    StopRequested event,
    Emitter<VideoPlayerState> emit,
  ) async {
    await _playerService.stop();
    emit(state.copyWith(
      status: PlayerStatus.stopped,
      position: Duration.zero,
    ));
  }

  Future<void> _onSeekRequested(
    SeekRequested event,
    Emitter<VideoPlayerState> emit,
  ) async {
    await _playerService.seek(event.position);
  }

  Future<void> _onSeekForwardRequested(
    SeekForwardRequested event,
    Emitter<VideoPlayerState> emit,
  ) async {
    await _playerService.seekForward(10);
  }

  Future<void> _onSeekBackwardRequested(
    SeekBackwardRequested event,
    Emitter<VideoPlayerState> emit,
  ) async {
    await _playerService.seekBackward(10);
  }

  Future<void> _onVolumeChanged(
    VolumeChanged event,
    Emitter<VideoPlayerState> emit,
  ) async {
    await _playerService.setVolume(event.volume);
    emit(state.copyWith(
      volume: event.volume,
      isMuted: event.volume == 0,
    ));
  }

  Future<void> _onMuteToggled(
    MuteToggled event,
    Emitter<VideoPlayerState> emit,
  ) async {
    if (state.isMuted) {
      // Unmute - restore previous volume
      final restoreVolume =
          state.volumeBeforeMute > 0 ? state.volumeBeforeMute : 50.0;
      await _playerService.setVolume(restoreVolume);
      emit(state.copyWith(volume: restoreVolume, isMuted: false));
    } else {
      // Mute
      emit(state.copyWith(
        volumeBeforeMute: state.volume,
        isMuted: true,
      ));
      await _playerService.setVolume(0);
      emit(state.copyWith(volume: 0));
    }
  }

  Future<void> _onVolumeUpRequested(
    VolumeUpRequested event,
    Emitter<VideoPlayerState> emit,
  ) async {
    final newVolume = (state.volume + 5).clamp(0.0, 100.0);
    await _playerService.setVolume(newVolume);
    emit(state.copyWith(volume: newVolume, isMuted: newVolume == 0));
  }

  Future<void> _onVolumeDownRequested(
    VolumeDownRequested event,
    Emitter<VideoPlayerState> emit,
  ) async {
    final newVolume = (state.volume - 5).clamp(0.0, 100.0);
    await _playerService.setVolume(newVolume);
    emit(state.copyWith(volume: newVolume, isMuted: newVolume == 0));
  }

  Future<void> _onSpeedChanged(
    SpeedChanged event,
    Emitter<VideoPlayerState> emit,
  ) async {
    await _playerService.setRate(event.speed);
    emit(state.copyWith(speed: event.speed));
  }

  void _onFullscreenToggled(
    FullscreenToggled event,
    Emitter<VideoPlayerState> emit,
  ) {
    emit(state.copyWith(isFullscreen: !state.isFullscreen));
  }

  Future<void> _onNextTrackRequested(
    NextTrackRequested event,
    Emitter<VideoPlayerState> emit,
  ) async {
    if (!state.playlist.hasNext) return;
    final nextIndex = state.playlist.nextIndex;
    emit(state.copyWith(
      playlist: state.playlist.copyWith(currentIndex: nextIndex),
    ));
    await _playerService.jump(nextIndex);
  }

  Future<void> _onPreviousTrackRequested(
    PreviousTrackRequested event,
    Emitter<VideoPlayerState> emit,
  ) async {
    if (!state.playlist.hasPrevious) return;
    final prevIndex = state.playlist.previousIndex;
    emit(state.copyWith(
      playlist: state.playlist.copyWith(currentIndex: prevIndex),
    ));
    await _playerService.jump(prevIndex);
  }

  Future<void> _onJumpToTrackRequested(
    JumpToTrackRequested event,
    Emitter<VideoPlayerState> emit,
  ) async {
    if (event.index < 0 || event.index >= state.playlist.items.length) return;
    emit(state.copyWith(
      playlist: state.playlist.copyWith(currentIndex: event.index),
    ));
    await _playerService.jump(event.index);
  }

  Future<void> _onRemoveFromPlaylist(
    RemoveFromPlaylist event,
    Emitter<VideoPlayerState> emit,
  ) async {
    final items = List<VideoItem>.from(state.playlist.items);
    if (event.index < 0 || event.index >= items.length) return;

    items.removeAt(event.index);
    var currentIndex = state.playlist.currentIndex;

    if (items.isEmpty) {
      await _playerService.stop();
      emit(state.copyWith(
        status: PlayerStatus.idle,
        playlist: const app.Playlist(),
        position: Duration.zero,
        duration: Duration.zero,
      ));
      return;
    }

    if (event.index < currentIndex) {
      currentIndex--;
    } else if (event.index == currentIndex) {
      currentIndex = currentIndex.clamp(0, items.length - 1);
    }

    emit(state.copyWith(
      playlist: state.playlist.copyWith(
        items: items,
        currentIndex: currentIndex,
      ),
    ));
  }

  void _onLoopModeToggled(
    LoopModeToggled event,
    Emitter<VideoPlayerState> emit,
  ) {
    final currentMode = state.playlist.loopMode;
    late app.LoopMode nextMode;
    late PlaylistMode playerMode;

    switch (currentMode) {
      case app.LoopMode.none:
        nextMode = app.LoopMode.single;
        playerMode = PlaylistMode.single;
        break;
      case app.LoopMode.single:
        nextMode = app.LoopMode.all;
        playerMode = PlaylistMode.loop;
        break;
      case app.LoopMode.all:
        nextMode = app.LoopMode.none;
        playerMode = PlaylistMode.none;
        break;
    }

    _playerService.setPlaylistMode(playerMode);
    emit(state.copyWith(
      playlist: state.playlist.copyWith(loopMode: nextMode),
    ));
  }

  Future<void> _onAudioTrackChanged(
    AudioTrackChanged event,
    Emitter<VideoPlayerState> emit,
  ) async {
    await _playerService.setAudioTrack(event.track);
  }

  Future<void> _onSubtitleTrackChanged(
    SubtitleTrackChanged event,
    Emitter<VideoPlayerState> emit,
  ) async {
    await _playerService.setSubtitleTrack(event.track);
  }

  Future<void> _onExternalSubtitleRequested(
    ExternalSubtitleRequested event,
    Emitter<VideoPlayerState> emit,
  ) async {
    // Subtitles can be loaded by dragging subtitle file to the window
  }

  Future<void> _onScreenshotRequested(
    ScreenshotRequested event,
    Emitter<VideoPlayerState> emit,
  ) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final home = Platform.environment['HOME'] ?? '/tmp';
    final savePath = '$home/Pictures/vaxp_screenshot_$timestamp.png';

    await _playerService.takeScreenshot(savePath);
  }

  void _onPlaylistPanelToggled(
    PlaylistPanelToggled event,
    Emitter<VideoPlayerState> emit,
  ) {
    emit(state.copyWith(
      isPlaylistPanelVisible: !state.isPlaylistPanelVisible,
    ));
  }

  void _onVideoInfoToggled(
    VideoInfoToggled event,
    Emitter<VideoPlayerState> emit,
  ) {
    emit(state.copyWith(
      isVideoInfoVisible: !state.isVideoInfoVisible,
    ));
  }

  // ===== Internal event handlers =====

  void _onPositionUpdated(
    PositionUpdated event,
    Emitter<VideoPlayerState> emit,
  ) {
    emit(state.copyWith(position: event.position));
  }

  void _onDurationUpdated(
    DurationUpdated event,
    Emitter<VideoPlayerState> emit,
  ) {
    emit(state.copyWith(duration: event.duration));
  }

  void _onBufferingStateChanged(
    BufferingStateChanged event,
    Emitter<VideoPlayerState> emit,
  ) {
    emit(state.copyWith(isBuffering: event.isBuffering));
  }

  Future<void> _onPlaybackCompleted(
    PlaybackCompleted event,
    Emitter<VideoPlayerState> emit,
  ) async {
    final loopMode = state.playlist.loopMode;
    if (loopMode == app.LoopMode.single) {
      // Restart current file
      await _playerService.seek(Duration.zero);
      await _playerService.play();
    } else if (loopMode == app.LoopMode.all && state.playlist.hasNext) {
      // Move to next
      add(NextTrackRequested());
    } else if (state.playlist.hasNext) {
      add(NextTrackRequested());
    }
  }

  void _onTracksUpdated(
    TracksUpdated event,
    Emitter<VideoPlayerState> emit,
  ) {
    emit(state.copyWith(
      audioTracks: event.audioTracks,
      subtitleTracks: event.subtitleTracks,
    ));
  }

  void _onErrorOccurred(
    ErrorOccurred event,
    Emitter<VideoPlayerState> emit,
  ) {
    emit(state.copyWith(
      status: PlayerStatus.error,
      errorMessage: event.message,
    ));
  }

  @override
  Future<void> close() async {
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();
    await _playerService.dispose();
    return super.close();
  }
}
