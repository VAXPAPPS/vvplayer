import 'dart:io';
import 'dart:typed_data';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// غلاف حول media_kit يوفر واجهة نظيفة للتطبيق
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

  /// الوصول إلى VideoController لعرض الفيديو
  VideoController get videoController => _videoController;

  /// الوصول إلى Player
  Player get player => _player;

  // ===== التشغيل الأساسي =====

  /// فتح ملف فيديو
  Future<void> open(String path) async {
    if (_isDisposed) return;
    await _player.open(Media(path));
  }

  /// فتح قائمة تشغيل
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

  /// تشغيل/إيقاف مؤقت
  Future<void> playOrPause() async {
    if (_isDisposed) return;
    await _player.playOrPause();
  }

  /// تشغيل
  Future<void> play() async {
    if (_isDisposed) return;
    await _player.play();
  }

  /// إيقاف مؤقت
  Future<void> pause() async {
    if (_isDisposed) return;
    await _player.pause();
  }

  /// إيقاف
  Future<void> stop() async {
    if (_isDisposed) return;
    await _player.stop();
  }

  // ===== التنقل =====

  /// الانتقال لموقع معين
  Future<void> seek(Duration position) async {
    if (_isDisposed) return;
    await _player.seek(position);
  }

  /// تقديم بمقدار ثوانٍ
  Future<void> seekForward(int seconds) async {
    if (_isDisposed) return;
    final current = _player.state.position;
    final target = current + Duration(seconds: seconds);
    final duration = _player.state.duration;
    await _player.seek(target > duration ? duration : target);
  }

  /// ترجيع بمقدار ثوانِ
  Future<void> seekBackward(int seconds) async {
    if (_isDisposed) return;
    final current = _player.state.position;
    final target = current - Duration(seconds: seconds);
    await _player.seek(target < Duration.zero ? Duration.zero : target);
  }

  // ===== قائمة التشغيل =====

  /// الانتقال للعنصر التالي
  Future<void> next() async {
    if (_isDisposed) return;
    await _player.next();
  }

  /// الانتقال للعنصر السابق
  Future<void> previous() async {
    if (_isDisposed) return;
    await _player.previous();
  }

  /// الانتقال لمؤشر محدد
  Future<void> jump(int index) async {
    if (_isDisposed) return;
    await _player.jump(index);
  }

  // ===== الصوت =====

  /// ضبط مستوى الصوت (0.0 - 100.0)
  Future<void> setVolume(double volume) async {
    if (_isDisposed) return;
    await _player.setVolume(volume.clamp(0.0, 100.0));
  }

  // ===== السرعة =====

  /// ضبط سرعة التشغيل
  Future<void> setRate(double rate) async {
    if (_isDisposed) return;
    await _player.setRate(rate.clamp(0.25, 4.0));
  }

  // ===== التكرار =====

  /// ضبط وضع التكرار
  Future<void> setPlaylistMode(PlaylistMode mode) async {
    if (_isDisposed) return;
    await _player.setPlaylistMode(mode);
  }

  // ===== المسارات =====

  /// الحصول على مسارات الصوت
  List<AudioTrack> get audioTracks => _player.state.tracks.audio;

  /// الحصول على مسارات الترجمة
  List<SubtitleTrack> get subtitleTracks => _player.state.tracks.subtitle;

  /// اختيار مسار صوت
  Future<void> setAudioTrack(AudioTrack track) async {
    if (_isDisposed) return;
    await _player.setAudioTrack(track);
  }

  /// اختيار مسار ترجمة
  Future<void> setSubtitleTrack(SubtitleTrack track) async {
    if (_isDisposed) return;
    await _player.setSubtitleTrack(track);
  }

  /// تحميل ملف ترجمة خارجي
  Future<void> loadExternalSubtitle(String path) async {
    if (_isDisposed) return;
    await _player.setSubtitleTrack(
      SubtitleTrack.uri(path),
    );
  }

  // ===== لقطة شاشة =====

  /// التقاط screenshot وحفظها
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

  /// Stream لحالة التشغيل
  Stream<bool> get playingStream => _player.stream.playing;

  /// Stream للموقع الحالي
  Stream<Duration> get positionStream => _player.stream.position;

  /// Stream لمدة الفيديو
  Stream<Duration> get durationStream => _player.stream.duration;

  /// Stream لمستوى الصوت
  Stream<double> get volumeStream => _player.stream.volume;

  /// Stream للسرعة
  Stream<double> get rateStream => _player.stream.rate;

  /// Stream لحالة التخزين المؤقت
  Stream<bool> get bufferingStream => _player.stream.buffering;

  /// Stream لاكتمال التشغيل
  Stream<bool> get completedStream => _player.stream.completed;

  /// Stream للمسارات المتاحة
  Stream<Tracks> get tracksStream => _player.stream.tracks;

  /// Stream للخطأ
  Stream<String> get errorStream => _player.stream.error;

  // ===== الحالة الحالية =====

  bool get isPlaying => _player.state.playing;
  Duration get position => _player.state.position;
  Duration get duration => _player.state.duration;
  double get volume => _player.state.volume;
  double get rate => _player.state.rate;
  bool get isBuffering => _player.state.buffering;
  bool get isCompleted => _player.state.completed;

  // ===== التنظيف =====

  /// تحرير الموارد
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await _player.dispose();
  }
}
