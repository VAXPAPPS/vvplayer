import 'package:equatable/equatable.dart';
import 'video_item.dart';

/// وضع التكرار
enum LoopMode {
  /// بدون تكرار
  none,
  /// تكرار ملف واحد
  single,
  /// تكرار القائمة كاملة
  all,
}

/// كيان يمثل قائمة تشغيل
class Playlist extends Equatable {
  final List<VideoItem> items;
  final int currentIndex;
  final LoopMode loopMode;

  const Playlist({
    this.items = const [],
    this.currentIndex = -1,
    this.loopMode = LoopMode.none,
  });

  /// هل القائمة فارغة
  bool get isEmpty => items.isEmpty;

  /// هل يوجد عنصر حالي
  bool get hasCurrentItem => currentIndex >= 0 && currentIndex < items.length;

  /// العنصر الحالي
  VideoItem? get currentItem =>
      hasCurrentItem ? items[currentIndex] : null;

  /// هل يمكن الانتقال للتالي
  bool get hasNext {
    if (isEmpty) return false;
    if (loopMode == LoopMode.all) return true;
    return currentIndex < items.length - 1;
  }

  /// هل يمكن الانتقال للسابق
  bool get hasPrevious {
    if (isEmpty) return false;
    if (loopMode == LoopMode.all) return true;
    return currentIndex > 0;
  }

  /// مؤشر العنصر التالي
  int get nextIndex {
    if (!hasNext) return currentIndex;
    if (currentIndex >= items.length - 1) return 0; // loop
    return currentIndex + 1;
  }

  /// مؤشر العنصر السابق
  int get previousIndex {
    if (!hasPrevious) return currentIndex;
    if (currentIndex <= 0) return items.length - 1; // loop
    return currentIndex - 1;
  }

  Playlist copyWith({
    List<VideoItem>? items,
    int? currentIndex,
    LoopMode? loopMode,
  }) {
    return Playlist(
      items: items ?? this.items,
      currentIndex: currentIndex ?? this.currentIndex,
      loopMode: loopMode ?? this.loopMode,
    );
  }

  @override
  List<Object?> get props => [items, currentIndex, loopMode];
}
