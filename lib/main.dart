import 'package:flutter/material.dart';
import 'package:vvplayer/core/colors/vaxp_colors.dart';
import 'package:window_manager/window_manager.dart';
import 'package:media_kit/media_kit.dart';
import 'core/theme/vaxp_theme.dart';
import 'package:venom_config/venom_config.dart';
import 'presentation/pages/home_page.dart';
import 'dart:io'; // Added: to check for video path existence in file system

Future<void> main(List<String> args) async { // Added: receive inputs from system
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

  // Added: process inputs (extract video path if passed from file manager)
  String? injectedVideoPath;
  if (args.isNotEmpty) {
    injectedVideoPath = args.first;
    
    // Check that path is valid and exists in system to avoid errors
    if (!File(injectedVideoPath).existsSync()) {
      injectedVideoPath = null;
    }
  }

  // Pass extracted path to application
  runApp(VaxpApp(initialVideoPath: injectedVideoPath));
}

class VaxpApp extends StatelessWidget {
  final String? initialVideoPath; // Added: variable to receive path

  const VaxpApp({super.key, this.initialVideoPath});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VAXP Video Player',
      theme: VaxpTheme.dark,
      // Pass path to home page (or put a condition here to open player page directly)
      home: HomePage(initialVideoPath: initialVideoPath), 
    );
  }
}