import 'package:flutter/material.dart';
import '../../core/colors/vaxp_colors.dart';
import '../../core/theme/vaxp_theme.dart';

/// شاشة الترحيب عندما لا يكون هناك فيديو محمّل
class WelcomeView extends StatelessWidget {
  final VoidCallback onOpenFile;
  final bool isDragHovering;

  const WelcomeView({
    super.key,
    required this.onOpenFile,
    this.isDragHovering = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDragHovering
                ? VaxpColors.secondary.withOpacity(0.8)
                : Colors.white.withOpacity(0.1),
            width: isDragHovering ? 2 : 1,
          ),
          color: isDragHovering
              ? VaxpColors.secondary.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // أيقونة التشغيل
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    VaxpColors.secondary.withOpacity(0.3),
                    VaxpColors.primary.withOpacity(0.5),
                  ],
                ),
                boxShadow: isDragHovering
                    ? [
                        BoxShadow(
                          color: VaxpColors.secondary.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                isDragHovering ? Icons.file_download : Icons.play_circle_outline,
                size: 64,
                color: Colors.white.withOpacity(0.8),
              ),
            ),

            const SizedBox(height: 24),

            // العنوان
            Text(
              'VAXP Video Player',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.9),
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 12),

            // الوصف
            Text(
              isDragHovering
                  ? 'أفلت الملفات هنا لتشغيلها'
                  : 'اسحب ملفات الفيديو هنا أو اضغط لفتح ملف',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.5),
              ),
            ),

            const SizedBox(height: 32),

            // زر فتح ملف
            if (!isDragHovering)
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: onOpenFile,
                  child: VaxpGlass(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.folder_open,
                            size: 20,
                            color: VaxpColors.secondary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'فتح ملف فيديو',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // الصيغ المدعومة
            if (!isDragHovering)
              Text(
                'MP4 • MKV • AVI • WebM • MOV • FLV • MPEG',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.3),
                  letterSpacing: 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
