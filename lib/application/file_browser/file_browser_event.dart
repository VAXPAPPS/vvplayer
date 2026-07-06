import 'dart:typed_data';
import 'package:equatable/equatable.dart';

/// File browser events
abstract class FileBrowserEvent extends Equatable {
  const FileBrowserEvent();

  @override
  List<Object?> get props => [];
}

/// Load folder contents
class NavigateToDirectory extends FileBrowserEvent {
  final String path;
  const NavigateToDirectory(this.path);

  @override
  List<Object?> get props => [path];
}

/// Return to previous folder
class GoBack extends FileBrowserEvent {}

/// Return to main folder
class GoHome extends FileBrowserEvent {}

/// Select video file to play
class FileSelected extends FileBrowserEvent {
  final String path;
  const FileSelected(this.path);

  @override
  List<Object?> get props => [path];
}

/// Play all videos in current folder
class PlayAllInDirectory extends FileBrowserEvent {}

/// Toggle browser view
class ToggleBrowserVisibility extends FileBrowserEvent {}

/// Thumbnail update event for a file
class ThumbnailLoaded extends FileBrowserEvent {
  final String path;
  final Uint8List bytes;
  const ThumbnailLoaded(this.path, this.bytes);

  @override
  List<Object?> get props => [path, bytes];
}
