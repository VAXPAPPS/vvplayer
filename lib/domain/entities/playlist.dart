import 'package:equatable/equatable.dart';
import 'video_item.dart';

/// Repeat mode
enum LoopMode {
  /// No repeat
  none,
  /// Repeat single file
  single,
  /// Repeat full playlist
  all,
}

/// Entity representing a playlist
class Playlist extends Equatable {
  final List<VideoItem> items;
  final int currentIndex;
  final LoopMode loopMode;

  const Playlist({
    this.items = const [],
    this.currentIndex = -1,
    this.loopMode = LoopMode.none,
  });

  /// Is the playlist empty
  bool get isEmpty => items.isEmpty;

  /// Is there a current item
  bool get hasCurrentItem => currentIndex >= 0 && currentIndex < items.length;

  /// Current item
  VideoItem? get currentItem =>
      hasCurrentItem ? items[currentIndex] : null;

  /// Can navigate to next
  bool get hasNext {
    if (isEmpty) return false;
    if (loopMode == LoopMode.all) return true;
    return currentIndex < items.length - 1;
  }

  /// Can navigate to previous
  bool get hasPrevious {
    if (isEmpty) return false;
    if (loopMode == LoopMode.all) return true;
    return currentIndex > 0;
  }

  /// Next item index
  int get nextIndex {
    if (!hasNext) return currentIndex;
    if (currentIndex >= items.length - 1) return 0; // loop
    return currentIndex + 1;
  }

  /// Previous item index
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
