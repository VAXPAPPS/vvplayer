import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:desktop_drop/desktop_drop.dart';

import '../../application/video_player/video_player_bloc.dart';
import '../../application/video_player/video_player_event.dart';
import '../../application/video_player/video_player_state.dart';
import '../../application/file_browser/file_browser_bloc.dart';
import '../../application/file_browser/file_browser_event.dart';
import '../../application/file_browser/file_browser_state.dart';
import '../widgets/video_controls.dart';
import '../widgets/playlist_panel.dart';
import '../widgets/video_info_overlay.dart';
import '../widgets/file_browser_view.dart';

/// شاشة المشغل الرئيسية
class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _controlsVisible = true;
  bool _isDragHovering = false;
  Timer? _hideTimer;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _showControls() {
    setState(() => _controlsVisible = true);
    _resetHideTimer();
  }

  void _resetHideTimer() {
    _hideTimer?.cancel();
    final state = context.read<VideoPlayerBloc>().state;
    if (state.isPlaying) {
      _hideTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _controlsVisible = false);
        }
      });
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final bloc = context.read<VideoPlayerBloc>();
    final browserBloc = context.read<FileBrowserBloc>();
    _showControls();

    switch (event.logicalKey) {
      case LogicalKeyboardKey.space:
        if (bloc.state.hasMedia) {
          bloc.add(PlayPauseToggled());
        }
        break;
      case LogicalKeyboardKey.arrowRight:
        bloc.add(SeekForwardRequested());
        break;
      case LogicalKeyboardKey.arrowLeft:
        bloc.add(SeekBackwardRequested());
        break;
      case LogicalKeyboardKey.arrowUp:
        bloc.add(VolumeUpRequested());
        break;
      case LogicalKeyboardKey.arrowDown:
        bloc.add(VolumeDownRequested());
        break;
      case LogicalKeyboardKey.keyF:
        bloc.add(FullscreenToggled());
        break;
      case LogicalKeyboardKey.keyM:
        bloc.add(MuteToggled());
        break;
      case LogicalKeyboardKey.escape:
        if (bloc.state.isFullscreen) {
          bloc.add(FullscreenToggled());
        }
        break;
      case LogicalKeyboardKey.keyN:
        bloc.add(NextTrackRequested());
        break;
      case LogicalKeyboardKey.keyP:
        bloc.add(PreviousTrackRequested());
        break;
      case LogicalKeyboardKey.keyL:
        bloc.add(LoopModeToggled());
        break;
      case LogicalKeyboardKey.keyS:
        bloc.add(ScreenshotRequested());
        break;
      case LogicalKeyboardKey.keyI:
        bloc.add(VideoInfoToggled());
        break;
      case LogicalKeyboardKey.keyB:
        // تبديل المتصفح
        browserBloc.add(ToggleBrowserVisibility());
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
      builder: (context, playerState) {
        return BlocBuilder<FileBrowserBloc, FileBrowserState>(
          builder: (context, browserState) {
            final bloc = context.read<VideoPlayerBloc>();
            final showBrowser = !playerState.hasMedia || browserState.isVisible;

            return KeyboardListener(
              focusNode: _focusNode,
              autofocus: true,
              onKeyEvent: _handleKeyEvent,
              child: DropTarget(
                onDragEntered: (_) => setState(() => _isDragHovering = true),
                onDragExited: (_) => setState(() => _isDragHovering = false),
                onDragDone: (details) {
                  setState(() => _isDragHovering = false);
                  final paths = details.files.map((f) => f.path).toList();
                  if (paths.isNotEmpty) {
                    bloc.add(FilesDropped(paths));
                  }
                },
                child: Stack(
                  children: [
                    // خلفية شفافة (تظهر خلفية سطح المكتب)
                    Container(
                      color: const Color.fromARGB(0, 0, 0, 0),
                    ),

                    // المحتوى الرئيسي
                    if (playerState.hasMedia && !showBrowser)
                      // عرض الفيديو
                      MouseRegion(
                        onHover: (_) => _showControls(),
                        child: GestureDetector(
                          onTap: () {
                            setState(
                                () => _controlsVisible = !_controlsVisible);
                            if (_controlsVisible) _resetHideTimer();
                          },
                          onDoubleTap: () =>
                              bloc.add(FullscreenToggled()),
                          child: Center(
                            child: Video(
                              controller:
                                  bloc.playerService.videoController,
                              controls: NoVideoControls,
                              fill: Colors.black,
                            ),
                          ),
                        ),
                      )
                    else
                      // متصفح الملفات
                      const FileBrowserView(),

                    // تراكب Drag & Drop
                    if (_isDragHovering)
                      Container(
                        color: Colors.black.withOpacity(0.6),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.file_download,
                                size: 48,
                                color: const Color(0xFF7AB5FF)
                                    .withOpacity(0.8),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'أفلت الملفات لتشغيلها',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // عنوان الفيديو (أعلى) - فقط في وضع التشغيل
                    if (playerState.hasMedia &&
                        !showBrowser &&
                        _controlsVisible)
                      Positioned(
                        top: 44,
                        left: 16,
                        right: 16,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: 1.0,
                          child: Text(
                            playerState.currentTitle,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.8),
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),

                    // معلومات الفيديو
                    if (playerState.hasMedia && !showBrowser)
                      const VideoInfoOverlay(),

                    // عناصر التحكم (أسفل)
                    if (playerState.hasMedia && !showBrowser)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: playerState.isPlaylistPanelVisible ? 280 : 0,
                        child: VideoControls(visible: _controlsVisible),
                      ),

                    // مؤشر التخزين المؤقت
                    if (playerState.isBuffering &&
                        playerState.hasMedia &&
                        !showBrowser)
                      const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF7AB5FF),
                        ),
                      ),

                    // لوحة قائمة التشغيل (يمين)
                    if (playerState.hasMedia && !showBrowser)
                      const Positioned(
                        top: 40,
                        right: 0,
                        bottom: 0,
                        child: PlaylistPanel(),
                      ),

                    // زر العودة للمتصفح (في وضع التشغيل)
                    if (playerState.hasMedia &&
                        !showBrowser &&
                        _controlsVisible)
                      Positioned(
                        top: 44,
                        right: 16,
                        child: _BrowserToggleButton(
                          onTap: () => context
                              .read<FileBrowserBloc>()
                              .add(ToggleBrowserVisibility()),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// زر العودة لمتصفح الملفات
class _BrowserToggleButton extends StatefulWidget {
  final VoidCallback onTap;
  const _BrowserToggleButton({required this.onTap});

  @override
  State<_BrowserToggleButton> createState() => _BrowserToggleButtonState();
}

class _BrowserToggleButtonState extends State<_BrowserToggleButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: _isHovered
                ? Colors.white.withOpacity(0.15)
                : Colors.black.withOpacity(0.3),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.folder_rounded,
                size: 16,
                color: Colors.white.withOpacity(0.7),
              ),
              const SizedBox(width: 6),
              Text(
                'الملفات',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
