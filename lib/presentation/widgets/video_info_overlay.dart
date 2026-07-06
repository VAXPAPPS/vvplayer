import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/video_player/video_player_bloc.dart';
import '../../application/video_player/video_player_event.dart';
import '../../application/video_player/video_player_state.dart';

/// Video info overlay
class VideoInfoOverlay extends StatelessWidget {
  const VideoInfoOverlay({super.key});

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
      builder: (context, state) {
        if (!state.isVideoInfoVisible || !state.hasMedia) {
          return const SizedBox.shrink();
        }

        final currentItem = state.playlist.currentItem;
        if (currentItem == null) return const SizedBox.shrink();

        return Positioned(
          top: 50,
          left: 16,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 320),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Row(
                      children: [
                        Icon(
                          Icons.movie_outlined,
                          size: 16,
                          color: const Color(0xFF7AB5FF),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            currentItem.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context
                              .read<VideoPlayerBloc>()
                              .add(VideoInfoToggled()),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    Divider(
                      color: Colors.white.withValues(alpha: 0.08),
                      height: 1,
                    ),
                    const SizedBox(height: 12),

                    // Information
                    _InfoRow(
                      label: 'Duration',
                      value: _formatDuration(state.duration),
                    ),
                    const SizedBox(height: 6),
                    _InfoRow(
                      label: 'Location',
                      value: _formatDuration(state.position),
                    ),
                    const SizedBox(height: 6),
                    _InfoRow(
                      label: 'Speed',
                      value: '${state.speed}x',
                    ),
                    const SizedBox(height: 6),
                    _InfoRow(
                      label: 'Volume',
                      value: state.isMuted
                          ? 'Muted'
                          : '${state.volume.round()}%',
                    ),
                    if (state.playlist.items.length > 1) ...[
                      const SizedBox(height: 6),
                      _InfoRow(
                        label: 'Menu',
                        value:
                            '${state.playlist.currentIndex + 1}/${state.playlist.items.length}',
                      ),
                    ],
                    const SizedBox(height: 6),
                    _InfoRow(
                      label: 'Path',
                      value: currentItem.path.split('/').last,
                      isSmall: true,
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isSmall;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: TextStyle(
              fontSize: isSmall ? 10 : 12,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isSmall ? 10 : 12,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
