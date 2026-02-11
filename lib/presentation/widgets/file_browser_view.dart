import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/file_browser/file_browser_bloc.dart';
import '../../application/file_browser/file_browser_event.dart';
import '../../application/file_browser/file_browser_state.dart';
import '../../domain/entities/file_item.dart';

/// متصفح الملفات المدمج مع تصميم زجاجي
class FileBrowserView extends StatelessWidget {
  const FileBrowserView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FileBrowserBloc, FileBrowserState>(
      builder: (context, state) {
        return Row(
          children: [
            // الشريط الجانبي السريع
            _QuickNavSidebar(
              quickPaths: state.quickNavPaths,
              currentPath: state.currentPath,
            ),

            // المحتوى الرئيسي
            Expanded(
              child: Column(
                children: [
                  // شريط التنقل العلوي
                  _NavigationBar(
                    currentPath: state.currentPath,
                    dirName: state.currentDirName,
                    canGoBack: state.canGoBack,
                    fileCount: state.fileCount,
                    dirCount: state.directoryCount,
                  ),

                  // المحتوى
                  Expanded(
                    child: state.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF7AB5FF),
                            ),
                          )
                        : state.items.isEmpty
                            ? _EmptyDirectory()
                            : _FileGrid(items: state.items),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ===== الشريط الجانبي السريع =====

class _QuickNavSidebar extends StatelessWidget {
  final List<FileItem> quickPaths;
  final String currentPath;

  const _QuickNavSidebar({
    required this.quickPaths,
    required this.currentPath,
  });

  IconData _getIcon(String name) {
    switch (name) {
      case 'الرئيسية':
        return Icons.home_rounded;
      case 'الفيديوهات':
        return Icons.video_library_rounded;
      case 'التنزيلات':
        return Icons.download_rounded;
      case 'المستندات':
        return Icons.description_rounded;
      case 'الموسيقى':
        return Icons.music_note_rounded;
      case 'سطح المكتب':
        return Icons.desktop_windows_rounded;
      case 'النظام /':
        return Icons.storage_rounded;
      default:
        return Icons.folder_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: 180,
          decoration: BoxDecoration(
            color: const Color.fromARGB(0, 0, 0, 0),
            border: Border(
              right: BorderSide(
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // عنوان
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.bookmark_rounded,
                      size: 16,
                      color: Colors.white.withOpacity(0.4),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'الأماكن',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.4),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),

              // القائمة
              ...quickPaths.map((item) {
                final isActive = currentPath == item.path;
                return _QuickNavItem(
                  name: item.name,
                  icon: _getIcon(item.name),
                  isActive: isActive,
                  onTap: () => context
                      .read<FileBrowserBloc>()
                      .add(NavigateToDirectory(item.path)),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickNavItem extends StatefulWidget {
  final String name;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _QuickNavItem({
    required this.name,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_QuickNavItem> createState() => _QuickNavItemState();
}

class _QuickNavItemState extends State<_QuickNavItem> {
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
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: widget.isActive
                ? const Color(0xFF7AB5FF).withOpacity(0.15)
                : _isHovered
                    ? Colors.white.withOpacity(0.05)
                    : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: widget.isActive
                    ? const Color(0xFF7AB5FF)
                    : Colors.white.withOpacity(0.5),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.name,
                  style: TextStyle(
                    fontSize: 13,
                    color: widget.isActive
                        ? const Color(0xFF7AB5FF)
                        : Colors.white.withOpacity(_isHovered ? 0.8 : 0.6),
                    fontWeight: widget.isActive
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== شريط التنقل العلوي =====

class _NavigationBar extends StatelessWidget {
  final String currentPath;
  final String dirName;
  final bool canGoBack;
  final int fileCount;
  final int dirCount;

  const _NavigationBar({
    required this.currentPath,
    required this.dirName,
    required this.canGoBack,
    required this.fileCount,
    required this.dirCount,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<FileBrowserBloc>();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.06),
          ),
        ),
      ),
      child: Row(
        children: [
          // أزرار التنقل
          _NavButton(
            icon: Icons.arrow_back_rounded,
            onTap: canGoBack ? () => bloc.add(GoBack()) : null,
          ),
          const SizedBox(width: 4),
          _NavButton(
            icon: Icons.home_rounded,
            onTap: () => bloc.add(GoHome()),
          ),
          const SizedBox(width: 4),
          // الذهاب للأعلى
          _NavButton(
            icon: Icons.arrow_upward_rounded,
            onTap: () {
              final parent = currentPath.substring(
                0,
                currentPath.lastIndexOf('/'),
              );
              if (parent.isNotEmpty) {
                bloc.add(NavigateToDirectory(parent));
              } else {
                bloc.add(NavigateToDirectory('/'));
              }
            },
          ),

          const SizedBox(width: 12),

          // المسار الحالي
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white.withOpacity(0.05),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.folder_open_rounded,
                    size: 14,
                    color: const Color(0xFF7AB5FF).withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      currentPath,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                        fontFamily: 'monospace',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // عداد الملفات
          Text(
            '$dirCount مجلد • $fileCount فيديو',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.35),
            ),
          ),

          // زر تشغيل الكل
          if (fileCount > 0) ...[
            const SizedBox(width: 8),
            _PlayAllButton(
              onTap: () => bloc.add(PlayAllInDirectory()),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _NavButton({required this.icon, this.onTap});

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: _isHovered && enabled
                ? Colors.white.withOpacity(0.1)
                : Colors.transparent,
          ),
          child: Icon(
            widget.icon,
            size: 18,
            color: Colors.white.withOpacity(enabled ? (_isHovered ? 0.9 : 0.5) : 0.2),
          ),
        ),
      ),
    );
  }
}

class _PlayAllButton extends StatefulWidget {
  final VoidCallback onTap;
  const _PlayAllButton({required this.onTap});

  @override
  State<_PlayAllButton> createState() => _PlayAllButtonState();
}

class _PlayAllButtonState extends State<_PlayAllButton> {
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF7AB5FF).withOpacity(_isHovered ? 0.4 : 0.2),
                const Color(0xFF5B9BF5).withOpacity(_isHovered ? 0.4 : 0.2),
              ],
            ),
            border: Border.all(
              color: const Color(0xFF7AB5FF).withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.play_arrow_rounded,
                size: 16,
                color: const Color(0xFF7AB5FF),
              ),
              const SizedBox(width: 4),
              Text(
                'تشغيل الكل',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF7AB5FF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== شبكة الملفات =====

class _FileGrid extends StatelessWidget {
  final List<FileItem> items;
  const _FileGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _FileGridItem(item: items[index]);
      },
    );
  }
}

class _FileGridItem extends StatefulWidget {
  final FileItem item;
  const _FileGridItem({required this.item});

  @override
  State<_FileGridItem> createState() => _FileGridItemState();
}

class _FileGridItemState extends State<_FileGridItem> {
  bool _isHovered = false;

  IconData _getFileIcon() {
    if (widget.item.isDirectory) return Icons.folder_rounded;

    switch (widget.item.extension) {
      case 'mp4':
      case 'mkv':
      case 'avi':
        return Icons.movie_rounded;
      case 'webm':
      case 'mov':
        return Icons.videocam_rounded;
      default:
        return Icons.video_file_rounded;
    }
  }

  Color _getIconColor() {
    if (widget.item.isDirectory) {
      return const Color(0xFFFFCA28); // أصفر للمجلدات
    }
    return const Color(0xFF7AB5FF); // أزرق للفيديوهات
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onDoubleTap: () {
          if (widget.item.isDirectory) {
            context.read<FileBrowserBloc>().add(
                  NavigateToDirectory(widget.item.path),
                );
          } else {
            context.read<FileBrowserBloc>().add(
                  FileSelected(widget.item.path),
                );
          }
        },
        onTap: () {
          if (widget.item.isDirectory) {
            context.read<FileBrowserBloc>().add(
                  NavigateToDirectory(widget.item.path),
                );
          } else {
            context.read<FileBrowserBloc>().add(
                  FileSelected(widget.item.path),
                );
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: _isHovered
                ? Colors.white.withOpacity(0.08)
                : Colors.white.withOpacity(0.03),
            border: Border.all(
              color: _isHovered
                  ? Colors.white.withOpacity(0.12)
                  : Colors.white.withOpacity(0.04),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // أيقونة
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: _getIconColor().withOpacity(_isHovered ? 0.15 : 0.08),
                ),
                child: Icon(
                  _getFileIcon(),
                  size: 32,
                  color: _getIconColor().withOpacity(_isHovered ? 0.9 : 0.7),
                ),
              ),

              const SizedBox(height: 10),

              // الاسم
              Text(
                widget.item.name,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(_isHovered ? 0.9 : 0.7),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),

              // الحجم (للفيديوهات فقط)
              if (!widget.item.isDirectory && widget.item.formattedSize.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  widget.item.formattedSize,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ===== مجلد فارغ =====

class _EmptyDirectory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.folder_off_rounded,
            size: 48,
            color: Colors.white.withOpacity(0.15),
          ),
          const SizedBox(height: 12),
          Text(
            'لا توجد ملفات فيديو أو مجلدات',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'يتم عرض ملفات الفيديو فقط',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}
