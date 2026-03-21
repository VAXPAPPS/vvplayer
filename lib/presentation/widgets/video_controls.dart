import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/video_player/video_player_bloc.dart';
import '../../application/video_player/video_player_event.dart';
import '../../application/video_player/video_player_state.dart';
import '../../domain/entities/playlist.dart';
import 'seek_bar.dart';
import 'volume_control.dart';

/// شريط التحكم السفلي مع تأثير زجاجي
class VideoControls extends StatefulWidget {
  final bool visible;

  const VideoControls({super.key, this.visible = true});

  @override
  State<VideoControls> createState() => _VideoControlsState();
}

class _VideoControlsState extends State<VideoControls>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    if (widget.visible) _animController.forward();
  }

  @override
  void didUpdateWidget(VideoControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != oldWidget.visible) {
      widget.visible ? _animController.forward() : _animController.reverse();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(_fadeAnim),
        child: BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
          builder: (context, state) {
            final bloc = context.read<VideoPlayerBloc>();

            return ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // شريط التقدم
                      SeekBar(
                        position: state.position,
                        duration: state.duration,
                        onSeek: (pos) => bloc.add(SeekRequested(pos)),
                      ),

                      const SizedBox(height: 8),

                      // أزرار التحكم
                      Row(
                        children: [
                          // الجانب الأيسر: الصوت
                          VolumeControl(
                            volume: state.volume,
                            isMuted: state.isMuted,
                            onVolumeChanged: (v) =>
                                bloc.add(VolumeChanged(v)),
                            onMuteToggled: () => bloc.add(MuteToggled()),
                          ),

                          const Spacer(),

                          // الوسط: أزرار التشغيل
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // السابق
                              _ControlButton(
                                icon: Icons.skip_previous_rounded,
                                onTap: () =>
                                    bloc.add(PreviousTrackRequested()),
                                enabled: state.playlist.hasPrevious,
                              ),

                              const SizedBox(width: 8),

                              // ترجيع
                              _ControlButton(
                                icon: Icons.replay_10_rounded,
                                onTap: () =>
                                    bloc.add(SeekBackwardRequested()),
                              ),

                              const SizedBox(width: 12),

                              // تشغيل/إيقاف
                              _PlayPauseButton(
                                isPlaying: state.isPlaying,
                                isBuffering: state.isBuffering,
                                onTap: () => bloc.add(PlayPauseToggled()),
                              ),

                              const SizedBox(width: 12),

                              // تقديم
                              _ControlButton(
                                icon: Icons.forward_10_rounded,
                                onTap: () =>
                                    bloc.add(SeekForwardRequested()),
                              ),

                              const SizedBox(width: 8),

                              // التالي
                              _ControlButton(
                                icon: Icons.skip_next_rounded,
                                onTap: () =>
                                    bloc.add(NextTrackRequested()),
                                enabled: state.playlist.hasNext,
                              ),
                            ],
                          ),

                          const Spacer(),

                          // الجانب الأيمن: خيارات إضافية
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // التكرار
                              _ControlButton(
                                icon: _loopIcon(state.playlist.loopMode),
                                onTap: () =>
                                    bloc.add(LoopModeToggled()),
                                isActive: state.playlist.loopMode !=
                                    LoopMode.none,
                                size: 18,
                              ),

                              // السرعة
                              _SpeedButton(
                                speed: state.speed,
                                onSpeedChanged: (s) =>
                                    bloc.add(SpeedChanged(s)),
                              ),

                              // قائمة التشغيل
                              _ControlButton(
                                icon: Icons.queue_music_rounded,
                                onTap: () =>
                                    bloc.add(PlaylistPanelToggled()),
                                isActive: state.isPlaylistPanelVisible,
                                size: 20,
                              ),

                              // ملء الشاشة
                              _ControlButton(
                                icon: state.isFullscreen
                                    ? Icons.fullscreen_exit
                                    : Icons.fullscreen,
                                onTap: () =>
                                    bloc.add(FullscreenToggled()),
                                size: 22,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _loopIcon(LoopMode mode) {
    switch (mode) {
      case LoopMode.none:
        return Icons.repeat_rounded;
      case LoopMode.single:
        return Icons.repeat_one_rounded;
      case LoopMode.all:
        return Icons.repeat_rounded;
    }
  }
}

// ===== أزرار مساعدة =====

class _ControlButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  final bool isActive;
  final double size;

  const _ControlButton({
    required this.icon,
    required this.onTap,
    this.enabled = true,
    this.isActive = false,
    this.size = 22,
  });

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final opacity = widget.enabled ? 1.0 : 0.3;

    return MouseRegion(
      cursor: widget.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: _isHovered && widget.enabled
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.transparent,
          ),
          child: Icon(
            widget.icon,
            size: widget.size,
            color: widget.isActive
                ? const Color(0xFF7AB5FF)
                : Colors.white.withValues(alpha: 
                    opacity * (_isHovered ? 1.0 : 0.7)),
          ),
        ),
      ),
    );
  }
}

class _PlayPauseButton extends StatefulWidget {
  final bool isPlaying;
  final bool isBuffering;
  final VoidCallback onTap;

  const _PlayPauseButton({
    required this.isPlaying,
    required this.isBuffering,
    required this.onTap,
  });

  @override
  State<_PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<_PlayPauseButton> {
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
          duration: const Duration(milliseconds: 200),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF7AB5FF).withValues(alpha: _isHovered ? 0.9 : 0.7),
                const Color(0xFF5B9BF5).withValues(alpha: _isHovered ? 0.9 : 0.7),
              ],
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: const Color(0xFF7AB5FF).withValues(alpha: 0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: widget.isBuffering
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(
                  widget.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  size: 28,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }
}

class _SpeedButton extends StatefulWidget {
  final double speed;
  final ValueChanged<double> onSpeedChanged;

  const _SpeedButton({
    required this.speed,
    required this.onSpeedChanged,
  });

  @override
  State<_SpeedButton> createState() => _SpeedButtonState();
}

class _SpeedButtonState extends State<_SpeedButton> {
  static const _speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 3.0, 4.0];

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<double>(
      tooltip: 'سرعة التشغيل',
      offset: const Offset(0, -200),
      color: Colors.black.withValues(alpha: 0.85),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      itemBuilder: (context) => _speeds
          .map((s) => PopupMenuItem<double>(
                value: s,
                child: Row(
                  children: [
                    if (s == widget.speed)
                      const Icon(Icons.check, size: 16, color: Color(0xFF7AB5FF))
                    else
                      const SizedBox(width: 16),
                    const SizedBox(width: 8),
                    Text(
                      '${s}x',
                      style: TextStyle(
                        color: s == widget.speed
                            ? const Color(0xFF7AB5FF)
                            : Colors.white70,
                        fontWeight: s == widget.speed
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
      onSelected: widget.onSpeedChanged,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          '${widget.speed}x',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: widget.speed != 1.0
                ? const Color(0xFF7AB5FF)
                : Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
