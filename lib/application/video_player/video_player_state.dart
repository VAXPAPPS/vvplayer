import 'package:equatable/equatable.dart';
import 'package:media_kit/media_kit.dart' hide Playlist;
// ignore: unused_import
import '../../domain/entities/video_item.dart';
import '../../domain/entities/playlist.dart';

/// Player state
enum PlayerStatus {
  /// No video loaded
  idle,
  /// Loading
  loading,
  /// Playing
  playing,
  /// Paused
  paused,
  /// Stopped
  stopped,
  /// Error
  error,
}

/// Full video player state
class VideoPlayerState extends Equatable {
  /// Player state
  final PlayerStatus status;

  /// Current location
  final Duration position;

  /// Total video duration
  final Duration duration;

  /// Volume level (0.0 - 100.0)
  final double volume;

  /// Volume level before mute (to restore)
  final double volumeBeforeMute;

  /// Is audio muted
  final bool isMuted;

  /// Playback speed
  final double speed;

  /// Is it in fullscreen mode
  final bool isFullscreen;

  /// Is buffering
  final bool isBuffering;

  /// Playlist
  final Playlist playlist;

  /// Available audio tracks
  final List<AudioTrack> audioTracks;

  /// Available subtitle tracks
  final List<SubtitleTrack> subtitleTracks;

  /// Is playlist panel visible
  final bool isPlaylistPanelVisible;

  /// Is video info visible
  final bool isVideoInfoVisible;

  /// Error message
  final String? errorMessage;

  const VideoPlayerState({
    this.status = PlayerStatus.idle,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 100.0,
    this.volumeBeforeMute = 100.0,
    this.isMuted = false,
    this.speed = 1.0,
    this.isFullscreen = false,
    this.isBuffering = false,
    this.playlist = const Playlist(),
    this.audioTracks = const [],
    this.subtitleTracks = const [],
    this.isPlaylistPanelVisible = false,
    this.isVideoInfoVisible = false,
    this.errorMessage,
  });

  /// Is there a video loaded
  bool get hasMedia => status != PlayerStatus.idle;

  /// Is video playing
  bool get isPlaying => status == PlayerStatus.playing;

  /// Progress percentage (0.0 - 1.0)
  double get progress {
    if (duration.inMilliseconds == 0) return 0.0;
    return (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
  }

  /// Time remaining
  Duration get remaining => duration - position;

  /// Current title
  String get currentTitle {
    return playlist.currentItem?.title ?? 'VAXP Player';
  }

  VideoPlayerState copyWith({
    PlayerStatus? status,
    Duration? position,
    Duration? duration,
    double? volume,
    double? volumeBeforeMute,
    bool? isMuted,
    double? speed,
    bool? isFullscreen,
    bool? isBuffering,
    Playlist? playlist,
    List<AudioTrack>? audioTracks,
    List<SubtitleTrack>? subtitleTracks,
    bool? isPlaylistPanelVisible,
    bool? isVideoInfoVisible,
    String? errorMessage,
    bool clearError = false,
  }) {
    return VideoPlayerState(
      status: status ?? this.status,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      volumeBeforeMute: volumeBeforeMute ?? this.volumeBeforeMute,
      isMuted: isMuted ?? this.isMuted,
      speed: speed ?? this.speed,
      isFullscreen: isFullscreen ?? this.isFullscreen,
      isBuffering: isBuffering ?? this.isBuffering,
      playlist: playlist ?? this.playlist,
      audioTracks: audioTracks ?? this.audioTracks,
      subtitleTracks: subtitleTracks ?? this.subtitleTracks,
      isPlaylistPanelVisible:
          isPlaylistPanelVisible ?? this.isPlaylistPanelVisible,
      isVideoInfoVisible: isVideoInfoVisible ?? this.isVideoInfoVisible,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        position,
        duration,
        volume,
        volumeBeforeMute,
        isMuted,
        speed,
        isFullscreen,
        isBuffering,
        playlist,
        audioTracks,
        subtitleTracks,
        isPlaylistPanelVisible,
        isVideoInfoVisible,
        errorMessage,
      ];
}
