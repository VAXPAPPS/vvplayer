import 'package:flutter/material.dart';

/// Custom progress bar with time display
class SeekBar extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;

  const SeekBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  bool _isDragging = false;
  double _dragValue = 0.0;
  bool _isHovering = false;
  double _hoverPosition = 0.0;

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
    final progress = widget.duration.inMilliseconds > 0
        ? widget.position.inMilliseconds / widget.duration.inMilliseconds
        : 0.0;
    final displayProgress = _isDragging ? _dragValue : progress.clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress bar
        MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          onHover: (event) {
            final box = context.findRenderObject() as RenderBox;
            final localPos = box.globalToLocal(event.position);
            setState(() {
              _hoverPosition = (localPos.dx / box.size.width).clamp(0.0, 1.0);
            });
          },
          child: GestureDetector(
            onHorizontalDragStart: (details) {
              setState(() {
                _isDragging = true;
                final box = context.findRenderObject() as RenderBox;
                _dragValue = (details.localPosition.dx / box.size.width)
                    .clamp(0.0, 1.0);
              });
            },
            onHorizontalDragUpdate: (details) {
              setState(() {
                final box = context.findRenderObject() as RenderBox;
                _dragValue = (details.localPosition.dx / box.size.width)
                    .clamp(0.0, 1.0);
              });
            },
            onHorizontalDragEnd: (details) {
              final seekPosition = Duration(
                milliseconds:
                    (_dragValue * widget.duration.inMilliseconds).round(),
              );
              widget.onSeek(seekPosition);
              setState(() => _isDragging = false);
            },
            onTapUp: (details) {
              final box = context.findRenderObject() as RenderBox;
              final pos = (details.localPosition.dx / box.size.width)
                  .clamp(0.0, 1.0);
              final seekPosition = Duration(
                milliseconds:
                    (pos * widget.duration.inMilliseconds).round(),
              );
              widget.onSeek(seekPosition);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: _isHovering || _isDragging ? 14 : 8,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Background
                  Container(
                    height: _isHovering || _isDragging ? 6 : 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),

                  // Hover mark
                  if (_isHovering && !_isDragging)
                    FractionallySizedBox(
                      widthFactor: _hoverPosition,
                      child: Container(
                        height: _isHovering ? 6 : 3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),

                  // Progress bar
                  FractionallySizedBox(
                    widthFactor: displayProgress,
                    child: Container(
                      height: _isHovering || _isDragging ? 6 : 3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF7AB5FF),
                            const Color(0xFF5B9BF5),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7AB5FF).withValues(alpha: 0.4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Cursor point
                  if (_isHovering || _isDragging)
                    Positioned(
                      left: (displayProgress *
                              (MediaQuery.of(context).size.width - 48)) -
                          6,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7AB5FF).withValues(alpha: 0.6),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 4),

        // Display time
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(
                  _isDragging
                      ? Duration(
                          milliseconds: (_dragValue *
                                  widget.duration.inMilliseconds)
                              .round())
                      : widget.position,
                ),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.6),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                _formatDuration(widget.duration),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.4),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
