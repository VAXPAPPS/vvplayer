# VVPlayer

A professional Linux video player built with Flutter, featuring a built-in file browser, glassmorphism UI, and powerful playback controls.

## Features

### Built-in File Browser
- Browse your filesystem directly within the app
- Quick navigation sidebar: Home, Videos, Downloads, Documents, Music, Desktop, System
- Grid view with folder/video icons and file sizes
- **Play All** button to queue all videos in a directory
- Back, Home, and Up navigation buttons with path display

### Video Playback
- High-performance playback powered by **libmpv** via `media_kit`
- Play/Pause, Stop, Seek forward/backward (±10s)
- Playback speed control: 0.25x – 4.0x
- 64MB buffer for smooth streaming

### Audio & Volume
- Volume slider with expand-on-hover
- Mute/unmute toggle
- Volume adjustment via keyboard (↑↓)

### Playlist
- Multi-file playlist with side panel
- Next/Previous/Jump to track
- Remove individual items
- Loop modes: None → Single → All

### Tracks & Subtitles
- Audio track switching
- Subtitle track switching
- External subtitle support (.srt, .ass, .ssa, .sub, .vtt) via drag & drop

### UI & Experience
- **Glassmorphism** design with transparent window
- Auto-hiding controls during playback
- Fullscreen mode (F key or double-click)
- Drag & drop files to play
- Video info overlay (title, duration, speed, tracks)
- Screenshots saved to `~/Pictures/`

### Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `Space` | Play / Pause |
| `←` | Seek backward 10s |
| `→` | Seek forward 10s |
| `↑` | Volume up |
| `↓` | Volume down |
| `F` | Toggle fullscreen |
| `M` | Mute / Unmute |
| `N` | Next track |
| `P` | Previous track |
| `L` | Cycle loop mode |
| `S` | Screenshot |
| `I` | Toggle video info |
| `B` | Toggle file browser |
| `Esc` | Exit fullscreen |

## Prerequisites

Install the following system dependencies before building:

```bash
sudo apt install libmpv-dev mpv
```

## Build & Run

```bash
# Get Flutter dependencies
flutter pub get

# Run in debug mode
flutter run -d linux

# Build release
flutter build linux
```

The release binary will be at `build/linux/x64/release/bundle/vvplayer`.

## Architecture

Built with **Clean Architecture** and **BLoC** state management:

```
lib/
├── domain/          # Entities (VideoItem, Playlist, FileItem), Repository interfaces
├── data/            # Repository implementation (filesystem browsing)
├── infrastructure/  # MediaPlayerService (media_kit wrapper)
├── application/     # BLoC: VideoPlayerBloc, FileBrowserBloc
├── presentation/    # Screens, Widgets (controls, seek bar, playlist, file browser)
└── core/            # Theme, Colors, Layout (VenomScaffold)
```

## Dependencies

| Package | Purpose |
|---------|---------|
| `media_kit` | Video playback engine |
| `media_kit_video` | Video rendering widget |
| `media_kit_libs_video` | Native libmpv bindings |
| `flutter_bloc` | State management |
| `equatable` | Value equality |
| `desktop_drop` | Drag & drop support |
| `window_manager` | Window control & fullscreen |
| `venom_config` | App configuration |

## License

This project is part of the VAXP organization.
