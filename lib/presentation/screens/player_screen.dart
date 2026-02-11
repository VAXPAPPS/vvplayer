import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:desktop_drop/desktop_drop.dart';

import '../../application/video_player/video_player_bloc.dart';
import '../../application/video_player/video_player_event.dart';
import '../../application/video_player/video_player_state.dart';
import '../widgets/video_controls.dart';
import '../widgets/playlist_panel.dart';
import '../widgets/video_info_overlay.dart';
import '../widgets/welcome_view.dart';

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
    _showControls();

    switch (event.logicalKey) {
      case LogicalKeyboardKey.space:
        bloc.add(PlayPauseToggled());
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
      case LogicalKeyboardKey.keyO:
        bloc.add(OpenFilesRequested());
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
      builder: (context, state) {
        final bloc = context.read<VideoPlayerBloc>();

        return KeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: _handleKeyEvent,
          child: DropTarget(
            onDragEntered: (_) => setState(() => _isDragHovering = true),
            onDragExited: (_) => setState(() => _isDragHovering = false),
            onDragDone: (details) {
              setState(() => _isDragHovering = false);
              final paths = details.files
                  .map((f) => f.path)
                  .toList();
              if (paths.isNotEmpty) {
                bloc.add(FilesDropped(paths));
              }
            },
            child: MouseRegion(
              onHover: (_) => _showControls(),
              child: GestureDetector(
                onTap: () {
                  if (state.hasMedia) {
                    setState(() => _controlsVisible = !_controlsVisible);
                    if (_controlsVisible) _resetHideTimer();
                  }
                },
                onDoubleTap: () {
                  if (state.hasMedia) {
                    bloc.add(FullscreenToggled());
                  }
                },
                child: Stack(
                  children: [
                    // خلفية سوداء
                    Container(color: Colors.black),

                    // عرض الفيديو أو شاشة الترحيب
                    if (state.hasMedia)
                      Center(
                        child: Video(
                          controller:
                              bloc.playerService.videoController,
                          controls: NoVideoControls,
                          fill: Colors.black,
                        ),
                      )
                    else
                      WelcomeView(
                        onOpenFile: () => bloc.add(OpenFilesRequested()),
                        isDragHovering: _isDragHovering,
                      ),

                    // تراكب Drag & Drop
                    if (_isDragHovering && state.hasMedia)
                      Container(
                        color: Colors.black.withOpacity(0.5),
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
                                'أفلت الملفات لإضافتها',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // عنوان الفيديو (أعلى)
                    if (state.hasMedia && _controlsVisible)
                      Positioned(
                        top: 44,
                        left: 16,
                        right: 16,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: _controlsVisible ? 1.0 : 0.0,
                          child: Text(
                            state.currentTitle,
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
                    const VideoInfoOverlay(),

                    // عناصر التحكم (أسفل)
                    if (state.hasMedia)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: state.isPlaylistPanelVisible ? 280 : 0,
                        child: VideoControls(
                          visible: _controlsVisible,
                        ),
                      ),

                    // مؤشر التخزين المؤقت
                    if (state.isBuffering && state.hasMedia)
                      const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF7AB5FF),
                        ),
                      ),

                    // لوحة قائمة التشغيل (يمين)
                    if (state.hasMedia)
                      const Positioned(
                        top: 40,
                        right: 0,
                        bottom: 0,
                        child: PlaylistPanel(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
