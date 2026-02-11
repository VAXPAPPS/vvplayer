import 'package:equatable/equatable.dart';
import 'package:media_kit/media_kit.dart' hide Playlist;
import '../../domain/entities/video_item.dart';
import '../../domain/entities/playlist.dart';

/// حالة المشغل
enum PlayerStatus {
  /// لم يتم تحميل أي فيديو
  idle,
  /// جاري التحميل
  loading,
  /// قيد التشغيل
  playing,
  /// مُوقف مؤقتاً
  paused,
  /// مُوقف
  stopped,
  /// خطأ
  error,
}

/// حالة مشغل الفيديو الكاملة
class VideoPlayerState extends Equatable {
  /// حالة المشغل
  final PlayerStatus status;

  /// الموقع الحالي
  final Duration position;

  /// مدة الفيديو الكلية
  final Duration duration;

  /// مستوى الصوت (0.0 - 100.0)
  final double volume;

  /// مستوى الصوت قبل الكتم (لاستعادته)
  final double volumeBeforeMute;

  /// هل الصوت مكتوم
  final bool isMuted;

  /// سرعة التشغيل
  final double speed;

  /// هل في وضع ملء الشاشة
  final bool isFullscreen;

  /// هل جاري التخزين المؤقت
  final bool isBuffering;

  /// قائمة التشغيل
  final Playlist playlist;

  /// مسارات الصوت المتاحة
  final List<AudioTrack> audioTracks;

  /// مسارات الترجمة المتاحة
  final List<SubtitleTrack> subtitleTracks;

  /// هل لوحة قائمة التشغيل مرئية
  final bool isPlaylistPanelVisible;

  /// هل معلومات الفيديو مرئية
  final bool isVideoInfoVisible;

  /// رسالة الخطأ
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

  /// هل يوجد فيديو محمّل
  bool get hasMedia => status != PlayerStatus.idle;

  /// هل الفيديو قيد التشغيل
  bool get isPlaying => status == PlayerStatus.playing;

  /// النسبة المئوية للتقدم (0.0 - 1.0)
  double get progress {
    if (duration.inMilliseconds == 0) return 0.0;
    return (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
  }

  /// الوقت المتبقي
  Duration get remaining => duration - position;

  /// العنوان الحالي
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
