import 'package:equatable/equatable.dart';
import 'package:media_kit/media_kit.dart';

/// Video player events
abstract class VideoPlayerEvent extends Equatable {
  const VideoPlayerEvent();

  @override
  List<Object?> get props => [];
}

// ===== Basic Playback =====
/// Play specific video file (injected by system via file manager)
class PlayInjectedFileRequested extends VideoPlayerEvent {
  final String path;
  const PlayInjectedFileRequested(this.path);

  @override
  List<Object?> get props => [path];
}
/// Open video file/files via dialog
class OpenFilesRequested extends VideoPlayerEvent {}

/// Open video files from paths (Drag & Drop)
class FilesDropped extends VideoPlayerEvent {
  final List<String> paths;
  const FilesDropped(this.paths);

  @override
  List<Object?> get props => [paths];
}

/// Play/Pause
class PlayPauseToggled extends VideoPlayerEvent {}

/// Stop playback
class StopRequested extends VideoPlayerEvent {}

// ===== Navigation =====

/// Go to specific location in video
class SeekRequested extends VideoPlayerEvent {
  final Duration position;
  const SeekRequested(this.position);

  @override
  List<Object?> get props => [position];
}

/// Forward 10 seconds
class SeekForwardRequested extends VideoPlayerEvent {}

/// Rewind 10 seconds
class SeekBackwardRequested extends VideoPlayerEvent {}

// ===== Volume =====

/// Change volume
class VolumeChanged extends VideoPlayerEvent {
  final double volume;
  const VolumeChanged(this.volume);

  @override
  List<Object?> get props => [volume];
}

/// Mute/Unmute audio
class MuteToggled extends VideoPlayerEvent {}

/// Volume up 5%
class VolumeUpRequested extends VideoPlayerEvent {}

/// Volume down 5%
class VolumeDownRequested extends VideoPlayerEvent {}

// ===== Speed =====

/// Change playback speed
class SpeedChanged extends VideoPlayerEvent {
  final double speed;
  const SpeedChanged(this.speed);

  @override
  List<Object?> get props => [speed];
}

// ===== Screen =====

/// Toggle fullscreen
class FullscreenToggled extends VideoPlayerEvent {}

// ===== Playlist =====

/// Move to next video
class NextTrackRequested extends VideoPlayerEvent {}

/// Move to previous video
class PreviousTrackRequested extends VideoPlayerEvent {}

/// Move to specific item in playlist
class JumpToTrackRequested extends VideoPlayerEvent {
  final int index;
  const JumpToTrackRequested(this.index);

  @override
  List<Object?> get props => [index];
}

/// Remove item from playlist
class RemoveFromPlaylist extends VideoPlayerEvent {
  final int index;
  const RemoveFromPlaylist(this.index);

  @override
  List<Object?> get props => [index];
}

/// Toggle repeat mode
class LoopModeToggled extends VideoPlayerEvent {}

// ===== Tracks =====

/// Change audio track
class AudioTrackChanged extends VideoPlayerEvent {
  final AudioTrack track;
  const AudioTrackChanged(this.track);

  @override
  List<Object?> get props => [track];
}

/// Change subtitle track
class SubtitleTrackChanged extends VideoPlayerEvent {
  final SubtitleTrack track;
  const SubtitleTrackChanged(this.track);

  @override
  List<Object?> get props => [track];
}

/// Load external subtitle file
class ExternalSubtitleRequested extends VideoPlayerEvent {}

// ===== Others =====

/// Take screenshot
class ScreenshotRequested extends VideoPlayerEvent {}

/// Toggle showing/hiding playlist
class PlaylistPanelToggled extends VideoPlayerEvent {}

/// Toggle showing/hiding video info
class VideoInfoToggled extends VideoPlayerEvent {}

// ===== Internal events (from Streams) =====

/// Update playback state
// ignore: unused_element
class _PlayingStateChanged extends VideoPlayerEvent {
  final bool isPlaying;
  const _PlayingStateChanged(this.isPlaying);
}

/// Update location
class PositionUpdated extends VideoPlayerEvent {
  final Duration position;
  const PositionUpdated(this.position);

  @override
  List<Object?> get props => [position];
}

/// Update duration
class DurationUpdated extends VideoPlayerEvent {
  final Duration duration;
  const DurationUpdated(this.duration);

  @override
  List<Object?> get props => [duration];
}

/// Update buffering state
class BufferingStateChanged extends VideoPlayerEvent {
  final bool isBuffering;
  const BufferingStateChanged(this.isBuffering);

  @override
  List<Object?> get props => [isBuffering];
}

/// Playback complete
class PlaybackCompleted extends VideoPlayerEvent {}

/// Update available tracks
class TracksUpdated extends VideoPlayerEvent {
  final List<AudioTrack> audioTracks;
  final List<SubtitleTrack> subtitleTracks;
  const TracksUpdated(this.audioTracks, this.subtitleTracks);

  @override
  List<Object?> get props => [audioTracks, subtitleTracks];
}

/// Error event
class ErrorOccurred extends VideoPlayerEvent {
  final String message;
  const ErrorOccurred(this.message);

  @override
  List<Object?> get props => [message];
}
