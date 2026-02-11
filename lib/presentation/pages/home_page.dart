import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';

import '../../application/video_player/video_player_bloc.dart';
import '../../application/video_player/video_player_event.dart';
import '../../application/video_player/video_player_state.dart';
import '../../data/repositories/video_repository_impl.dart';
import '../../infrastructure/services/media_player_service.dart';
import '../../core/venom_layout.dart';
import '../screens/player_screen.dart';

/// الصفحة الرئيسية للتطبيق مع BlocProvider
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final MediaPlayerService _playerService;
  late final VideoPlayerBloc _bloc;

  @override
  void initState() {
    super.initState();
    _playerService = MediaPlayerService();
    _bloc = VideoPlayerBloc(
      playerService: _playerService,
      repository: VideoRepositoryImpl(),
    );
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VideoPlayerBloc>.value(
      value: _bloc,
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
              // وضع ملء الشاشة - بدون VenomScaffold
              return const Scaffold(
                backgroundColor: Color.fromARGB(0, 0, 0, 0),
                body: PlayerScreen(),
              );
            }

            // الوضع العادي - مع VenomScaffold
            return VenomScaffold(
              title: state.hasMedia ? state.currentTitle : 'VAXP Player',
              body: const PlayerScreen(),
            );
          },
        ),
      ),
    );
  }
}
