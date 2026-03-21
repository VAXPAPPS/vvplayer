import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/video_player/video_player_bloc.dart';
import '../../application/video_player/video_player_event.dart';
import '../../application/video_player/video_player_state.dart';

/// لوحة قائمة التشغيل الجانبية
class PlaylistPanel extends StatelessWidget {
  const PlaylistPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
      builder: (context, state) {
        if (!state.isPlaylistPanelVisible) return const SizedBox.shrink();

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          width: 280,
          child: ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(16),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  border: Border(
                    left: BorderSide(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    // العنوان
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.queue_music_rounded,
                            size: 20,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'قائمة التشغيل',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${state.playlist.items.length} ملف',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                            onPressed: () => context
                                .read<VideoPlayerBloc>()
                                .add(PlaylistPanelToggled()),
                          ),
                        ],
                      ),
                    ),

                    Divider(
                      color: Colors.white.withValues(alpha: 0.08),
                      height: 1,
                    ),

                    // قائمة الملفات
                    Expanded(
                      child: state.playlist.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.playlist_add,
                                    size: 40,
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'لا توجد ملفات',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.3),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              itemCount: state.playlist.items.length,
                              itemBuilder: (context, index) {
                                final item = state.playlist.items[index];
                                final isActive =
                                    index == state.playlist.currentIndex;

                                return _PlaylistItem(
                                  title: item.title,
                                  isActive: isActive,
                                  index: index,
                                  onTap: () => context
                                      .read<VideoPlayerBloc>()
                                      .add(JumpToTrackRequested(index)),
                                  onRemove: () => context
                                      .read<VideoPlayerBloc>()
                                      .add(RemoveFromPlaylist(index)),
                                );
                              },
                            ),
                    ),

                    // زر إضافة ملفات
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () => context
                              .read<VideoPlayerBloc>()
                              .add(OpenFilesRequested()),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('إضافة ملفات'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF7AB5FF),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: const Color(0xFF7AB5FF).withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                        ),
                      ),
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

class _PlaylistItem extends StatefulWidget {
  final String title;
  final bool isActive;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _PlaylistItem({
    required this.title,
    required this.isActive,
    required this.index,
    required this.onTap,
    required this.onRemove,
  });

  @override
  State<_PlaylistItem> createState() => _PlaylistItemState();
}

class _PlaylistItemState extends State<_PlaylistItem> {
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
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: widget.isActive
                ? const Color(0xFF7AB5FF).withValues(alpha: 0.15)
                : _isHovered
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.transparent,
            border: widget.isActive
                ? Border.all(
                    color: const Color(0xFF7AB5FF).withValues(alpha: 0.3),
                  )
                : null,
          ),
          child: Row(
            children: [
              // أيقونة التشغيل / الرقم
              SizedBox(
                width: 24,
                child: widget.isActive
                    ? const Icon(
                        Icons.play_arrow_rounded,
                        size: 16,
                        color: Color(0xFF7AB5FF),
                      )
                    : Text(
                        '${widget.index + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        textAlign: TextAlign.center,
                      ),
              ),

              const SizedBox(width: 8),

              // اسم الملف
              Expanded(
                child: Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: widget.isActive
                        ? const Color(0xFF7AB5FF)
                        : Colors.white.withValues(alpha: 0.7),
                    fontWeight: widget.isActive
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),

              // زر حذف
              if (_isHovered)
                GestureDetector(
                  onTap: widget.onRemove,
                  child: Icon(
                    Icons.close,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
