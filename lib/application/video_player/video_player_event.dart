import 'package:equatable/equatable.dart';
import 'package:media_kit/media_kit.dart';

/// أحداث مشغل الفيديو
abstract class VideoPlayerEvent extends Equatable {
  const VideoPlayerEvent();

  @override
  List<Object?> get props => [];
}

// ===== التشغيل الأساسي =====

/// فتح ملف/ملفات فيديو عبر مربع حوار
class OpenFilesRequested extends VideoPlayerEvent {}

/// فتح ملفات فيديو من مسارات (Drag & Drop)
class FilesDropped extends VideoPlayerEvent {
  final List<String> paths;
  const FilesDropped(this.paths);

  @override
  List<Object?> get props => [paths];
}

/// تشغيل/إيقاف مؤقت
class PlayPauseToggled extends VideoPlayerEvent {}

/// إيقاف التشغيل
class StopRequested extends VideoPlayerEvent {}

// ===== التنقل =====

/// الانتقال لموقع معين في الفيديو
class SeekRequested extends VideoPlayerEvent {
  final Duration position;
  const SeekRequested(this.position);

  @override
  List<Object?> get props => [position];
}

/// تقديم 10 ثوانٍ
class SeekForwardRequested extends VideoPlayerEvent {}

/// ترجيع 10 ثوانِ
class SeekBackwardRequested extends VideoPlayerEvent {}

// ===== الصوت =====

/// تغيير مستوى الصوت
class VolumeChanged extends VideoPlayerEvent {
  final double volume;
  const VolumeChanged(this.volume);

  @override
  List<Object?> get props => [volume];
}

/// كتم/إلغاء كتم الصوت
class MuteToggled extends VideoPlayerEvent {}

/// رفع الصوت 5%
class VolumeUpRequested extends VideoPlayerEvent {}

/// خفض الصوت 5%
class VolumeDownRequested extends VideoPlayerEvent {}

// ===== السرعة =====

/// تغيير سرعة التشغيل
class SpeedChanged extends VideoPlayerEvent {
  final double speed;
  const SpeedChanged(this.speed);

  @override
  List<Object?> get props => [speed];
}

// ===== الشاشة =====

/// تبديل ملء الشاشة
class FullscreenToggled extends VideoPlayerEvent {}

// ===== قائمة التشغيل =====

/// الانتقال للفيديو التالي
class NextTrackRequested extends VideoPlayerEvent {}

/// الانتقال للفيديو السابق
class PreviousTrackRequested extends VideoPlayerEvent {}

/// الانتقال لعنصر محدد في القائمة
class JumpToTrackRequested extends VideoPlayerEvent {
  final int index;
  const JumpToTrackRequested(this.index);

  @override
  List<Object?> get props => [index];
}

/// إزالة عنصر من قائمة التشغيل
class RemoveFromPlaylist extends VideoPlayerEvent {
  final int index;
  const RemoveFromPlaylist(this.index);

  @override
  List<Object?> get props => [index];
}

/// تبديل وضع التكرار
class LoopModeToggled extends VideoPlayerEvent {}

// ===== المسارات =====

/// تغيير مسار الصوت
class AudioTrackChanged extends VideoPlayerEvent {
  final AudioTrack track;
  const AudioTrackChanged(this.track);

  @override
  List<Object?> get props => [track];
}

/// تغيير مسار الترجمة
class SubtitleTrackChanged extends VideoPlayerEvent {
  final SubtitleTrack track;
  const SubtitleTrackChanged(this.track);

  @override
  List<Object?> get props => [track];
}

/// تحميل ملف ترجمة خارجي
class ExternalSubtitleRequested extends VideoPlayerEvent {}

// ===== أخرى =====

/// التقاط لقطة شاشة
class ScreenshotRequested extends VideoPlayerEvent {}

/// تبديل إظهار/إخفاء قائمة التشغيل
class PlaylistPanelToggled extends VideoPlayerEvent {}

/// تبديل إظهار/إخفاء معلومات الفيديو
class VideoInfoToggled extends VideoPlayerEvent {}

// ===== أحداث داخلية (من الـ Streams) =====

/// تحديث حالة التشغيل
// ignore: unused_element
class _PlayingStateChanged extends VideoPlayerEvent {
  final bool isPlaying;
  const _PlayingStateChanged(this.isPlaying);
}

/// تحديث الموقع
class PositionUpdated extends VideoPlayerEvent {
  final Duration position;
  const PositionUpdated(this.position);

  @override
  List<Object?> get props => [position];
}

/// تحديث المدة
class DurationUpdated extends VideoPlayerEvent {
  final Duration duration;
  const DurationUpdated(this.duration);

  @override
  List<Object?> get props => [duration];
}

/// تحديث حالة التخزين المؤقت
class BufferingStateChanged extends VideoPlayerEvent {
  final bool isBuffering;
  const BufferingStateChanged(this.isBuffering);

  @override
  List<Object?> get props => [isBuffering];
}

/// اكتمال التشغيل
class PlaybackCompleted extends VideoPlayerEvent {}

/// تحديث المسارات المتاحة
class TracksUpdated extends VideoPlayerEvent {
  final List<AudioTrack> audioTracks;
  final List<SubtitleTrack> subtitleTracks;
  const TracksUpdated(this.audioTracks, this.subtitleTracks);

  @override
  List<Object?> get props => [audioTracks, subtitleTracks];
}

/// حدث خطأ
class ErrorOccurred extends VideoPlayerEvent {
  final String message;
  const ErrorOccurred(this.message);

  @override
  List<Object?> get props => [message];
}
