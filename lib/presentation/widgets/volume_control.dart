import 'package:flutter/material.dart';

/// عنصر التحكم بمستوى الصوت
class VolumeControl extends StatefulWidget {
  final double volume;
  final bool isMuted;
  final ValueChanged<double> onVolumeChanged;
  final VoidCallback onMuteToggled;

  const VolumeControl({
    super.key,
    required this.volume,
    required this.isMuted,
    required this.onVolumeChanged,
    required this.onMuteToggled,
  });

  @override
  State<VolumeControl> createState() => _VolumeControlState();
}

class _VolumeControlState extends State<VolumeControl> {
  bool _isExpanded = false;

  IconData _getVolumeIcon() {
    if (widget.isMuted || widget.volume == 0) {
      return Icons.volume_off;
    } else if (widget.volume < 30) {
      return Icons.volume_mute;
    } else if (widget.volume < 70) {
      return Icons.volume_down;
    } else {
      return Icons.volume_up;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isExpanded = true),
      onExit: (_) => setState(() => _isExpanded = false),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // زر كتم الصوت
          _ControlIcon(
            icon: _getVolumeIcon(),
            onTap: widget.onMuteToggled,
            size: 20,
          ),

          // شريط الصوت (يظهر عند hover)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: _isExpanded ? 100 : 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _isExpanded ? 1.0 : 0.0,
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 12,
                  ),
                  activeTrackColor: const Color(0xFF7AB5FF),
                  inactiveTrackColor: Colors.white.withOpacity(0.15),
                  thumbColor: Colors.white,
                  overlayColor: const Color(0xFF7AB5FF).withOpacity(0.2),
                ),
                child: Slider(
                  value: widget.isMuted ? 0 : widget.volume,
                  min: 0,
                  max: 100,
                  onChanged: (value) {
                    widget.onVolumeChanged(value);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// أيقونة تحكم قابلة للضغط
class _ControlIcon extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const _ControlIcon({
    required this.icon,
    required this.onTap,
    this.size = 22,
  });

  @override
  State<_ControlIcon> createState() => _ControlIconState();
}

class _ControlIconState extends State<_ControlIcon> {
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
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color:
                _isHovered ? Colors.white.withOpacity(0.1) : Colors.transparent,
          ),
          child: Icon(
            widget.icon,
            size: widget.size,
            color: Colors.white.withOpacity(_isHovered ? 1.0 : 0.7),
          ),
        ),
      ),
    );
  }
}
