import 'package:flutter/material.dart';
import 'package:vvplayer/core/colors/vaxp_colors.dart';
import 'package:window_manager/window_manager.dart';
import 'package:media_kit/media_kit.dart';
import 'core/theme/vaxp_theme.dart';
import 'package:venom_config/venom_config.dart';
import 'presentation/pages/home_page.dart';

Future<void> main() async {
  // Initialize Flutter bindings first to ensure the binary messenger is ready
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize MediaKit (media_kit)
  MediaKit.ensureInitialized();

  // Initialize Venom Config System
  await VenomConfig().init();

  // Initialize VaxpColors listeners
  VaxpColors.init();

  // Initialize window manager for desktop controls
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1100, 750),
    minimumSize: Size(800, 500),
    center: true,
    titleBarStyle: TitleBarStyle.hidden,
    title: 'VAXP Video Player',
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const VaxpApp());
}

class VaxpApp extends StatelessWidget {
  const VaxpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VAXP Video Player',
      theme: VaxpTheme.dark,
      home: const HomePage(),
    );
  }
}
