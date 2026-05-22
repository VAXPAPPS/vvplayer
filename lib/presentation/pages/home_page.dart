import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';

import '../../application/video_player/video_player_bloc.dart';
// ignore: unused_import
import '../../application/video_player/video_player_event.dart';
import '../../application/video_player/video_player_state.dart';
import '../../application/file_browser/file_browser_bloc.dart';
import '../../application/file_browser/file_browser_event.dart';
import '../../data/repositories/video_repository_impl.dart';
import '../../infrastructure/services/media_player_service.dart';
import '../../core/venom_layout.dart';
import '../screens/player_screen.dart';

/// الصفحة الرئيسية للتطبيق مع BlocProviders
class HomePage extends StatefulWidget {
  // 1. يجب تعريف المتغير هنا كحقل (Field) لكي تحتفظ به الصفحة
  final String? initialVideoPath;

  // 2. استخدام this.initialVideoPath لربط القيمة الممررة بالحقل
  const HomePage({super.key, this.initialVideoPath});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final MediaPlayerService _playerService;
  late final VideoRepositoryImpl _repository;
  late final VideoPlayerBloc _playerBloc;
  late final FileBrowserBloc _browserBloc;

  @override
  void initState() {
    super.initState();
    _playerService = MediaPlayerService();
    _repository = VideoRepositoryImpl();
    _playerBloc = VideoPlayerBloc(
      playerService: _playerService,
      repository: _repository,
    );
    _browserBloc = FileBrowserBloc(
      repository: _repository,
      playerBloc: _playerBloc,
    );

    // 3. الحقن المباشر للمسار
    // بمجرد تهيئة الـ Blocs، نتحقق مما إذا كان مدير الملفات قد أرسل مساراً
    if (widget.initialVideoPath != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _browserBloc.add(FileSelected(widget.initialVideoPath!));
      });
    }
  }

  @override
  void dispose() {
    _browserBloc.close();
    _playerBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<VideoPlayerBloc>.value(value: _playerBloc),
        BlocProvider<FileBrowserBloc>.value(value: _browserBloc),
      ],
      child: BlocListener<VideoPlayerBloc, VideoPlayerState>(
        listenWhen: (previous, current) =>
            previous.isFullscreen != current.isFullscreen,
        listener: (context, state) async {
          if (state.isFullscreen) {
            await windowManager.setFullScreen(true);
          } else {
            await windowManager.setFullScreen(false);
          }
        },
        child: BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
          buildWhen: (previous, current) =>
              previous.isFullscreen != current.isFullscreen ||
              previous.currentTitle != current.currentTitle,
          builder: (context, state) {
            if (state.isFullscreen) {
              return const Scaffold(
                backgroundColor: Color.fromARGB(0, 0, 0, 0),
                body: PlayerScreen(),
              );
            }

            return VenomScaffold(
              title: state.hasMedia ? state.currentTitle : 'VVPlayer',
              body: const PlayerScreen(),
            );
          },
        ),
      ),
    );
  }
}