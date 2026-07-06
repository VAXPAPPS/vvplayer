import 'dart:io';
import 'dart:typed_data';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// Wrapper around media_kit providing clean interface for app
class MediaPlayerService {
  late final Player _player;
  late final VideoController _videoController;
  bool _isDisposed = false;

  MediaPlayerService() {
    _player = Player(
      configuration: const PlayerConfiguration(
        title: 'VAXP Video Player',
        bufferSize: 64 * 1024 * 1024, // 64MB buffer
      ),
    );
    _videoController = VideoController(_player);
  }

  /// Access to VideoController to display video
  VideoController get videoController => _videoController;

  /// Access to Player
  Player get player => _player;

  // ===== Basic Playback =====

  /// Open video file
  Future<void> open(String path) async {
    if (_isDisposed) return;
    await _player.open(Media(path));
  }

  /// Open playlist
  Future<void> openPlaylist(List<String> paths, {int index = 0}) async {
    if (_isDisposed) return;
    final playlist = Playlist(
      paths.map((p) => Media(p)).toList(),
    );
    await _player.open(playlist, play: true);
    if (index > 0) {
      await _player.jump(index);
    }
  }

  /// Play/Pause
  Future<void> playOrPause() async {
    if (_isDisposed) return;
    await _player.playOrPause();
  }

  /// Play
  Future<void> play() async {
    if (_isDisposed) return;
    await _player.play();
  }

  /// Pause
  Future<void> pause() async {
    if (_isDisposed) return;
    await _player.pause();
  }

  /// Stop
  Future<void> stop() async {
    if (_isDisposed) return;
    await _player.stop();
  }

  // ===== Navigation =====

  /// Go to specific location
  Future<void> seek(Duration position) async {
    if (_isDisposed) return;
    await _player.seek(position);
  }

  /// Forward by seconds
  Future<void> seekForward(int seconds) async {
    if (_isDisposed) return;
    final current = _player.state.position;
    final target = current + Duration(seconds: seconds);
    final duration = _player.state.duration;
    await _player.seek(target > duration ? duration : target);
  }

  /// Rewind by seconds
  Future<void> seekBackward(int seconds) async {
    if (_isDisposed) return;
    final current = _player.state.position;
    final target = current - Duration(seconds: seconds);
    await _player.seek(target < Duration.zero ? Duration.zero : target);
  }

  // ===== Playlist =====

  /// Move to next item
  Future<void> next() async {
    if (_isDisposed) return;
    await _player.next();
  }

  /// Move to previous item
  Future<void> previous() async {
    if (_isDisposed) return;
    await _player.previous();
  }

  /// Go to specific index
  Future<void> jump(int index) async {
    if (_isDisposed) return;
    await _player.jump(index);
  }

  // ===== Volume =====

  /// Set volume level (0.0 - 100.0)
  Future<void> setVolume(double volume) async {
    if (_isDisposed) return;
    await _player.setVolume(volume.clamp(0.0, 100.0));
  }

  // ===== Speed =====

  /// Set playback speed
  Future<void> setRate(double rate) async {
    if (_isDisposed) return;
    await _player.setRate(rate.clamp(0.25, 4.0));
  }

  // ===== Repeat =====

  /// Set repeat mode
  Future<void> setPlaylistMode(PlaylistMode mode) async {
    if (_isDisposed) return;
    await _player.setPlaylistMode(mode);
  }

  // ===== Tracks =====

  /// Get audio tracks
  List<AudioTrack> get audioTracks => _player.state.tracks.audio;

  /// Get subtitle tracks
  List<SubtitleTrack> get subtitleTracks => _player.state.tracks.subtitle;

  /// Select audio track
  Future<void> setAudioTrack(AudioTrack track) async {
    if (_isDisposed) return;
    await _player.setAudioTrack(track);
  }

  /// Select subtitle track
  Future<void> setSubtitleTrack(SubtitleTrack track) async {
    if (_isDisposed) return;
    await _player.setSubtitleTrack(track);
  }

  /// Load external subtitle file
  Future<void> loadExternalSubtitle(String path) async {
    if (_isDisposed) return;
    await _player.setSubtitleTrack(
      SubtitleTrack.uri(path),
    );
  }

  // ===== Screenshot =====

  /// Capture screenshot and save it
  Future<String?> takeScreenshot(String savePath) async {
    if (_isDisposed) return null;
    try {
      final Uint8List? screenshot = await _player.screenshot();
      if (screenshot != null) {
        final file = File(savePath);
        await file.writeAsBytes(screenshot);
        return savePath;
      }
    } catch (_) {
      // Ignore screenshot errors
    }
    return null;
  }

  // ===== Streams =====

  /// Playback state Stream
  Stream<bool> get playingStream => _player.stream.playing;

  /// Current location Stream
  Stream<Duration> get positionStream => _player.stream.position;

  /// Video duration Stream
  Stream<Duration> get durationStream => _player.stream.duration;

  /// Volume Stream
  Stream<double> get volumeStream => _player.stream.volume;

  /// Speed Stream
  Stream<double> get rateStream => _player.stream.rate;

  /// Buffering state Stream
  Stream<bool> get bufferingStream => _player.stream.buffering;

  /// Playback complete Stream
  Stream<bool> get completedStream => _player.stream.completed;

  /// Available tracks Stream
  Stream<Tracks> get tracksStream => _player.stream.tracks;

  /// Error Stream
  Stream<String> get errorStream => _player.stream.error;

  // ===== Current State =====

  bool get isPlaying => _player.state.playing;
  Duration get position => _player.state.position;
  Duration get duration => _player.state.duration;
  double get volume => _player.state.volume;
  double get rate => _player.state.rate;
  bool get isBuffering => _player.state.buffering;
  bool get isCompleted => _player.state.completed;

  // ===== Cleanup =====

  /// Free resources
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await _player.dispose();
  }
}
