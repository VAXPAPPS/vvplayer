import 'package:flutter/material.dart';
import 'package:vvplayer/core/colors/vaxp_colors.dart';
import 'package:window_manager/window_manager.dart';
import 'package:media_kit/media_kit.dart';
import 'core/theme/vaxp_theme.dart';
import 'package:venom_config/venom_config.dart';
import 'presentation/pages/home_page.dart';
import 'dart:io'; // تمت الإضافة: للتحقق من وجود مسار الفيديو في نظام الملفات

Future<void> main(List<String> args) async { // تمت الإضافة: استقبال المدخلات من النظام
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

  // تمت الإضافة: معالجة المدخلات (استخراج مسار الفيديو إذا تم تمريره من مدير الملفات)
  String? injectedVideoPath;
  if (args.isNotEmpty) {
    injectedVideoPath = args.first;
    
    // التحقق من أن المسار صالح وموجود بالفعل في النظام لتجنب الأخطاء
    if (!File(injectedVideoPath).existsSync()) {
      injectedVideoPath = null;
    }
  }

  // تمرير المسار المستخرج إلى التطبيق
  runApp(VaxpApp(initialVideoPath: injectedVideoPath));
}

class VaxpApp extends StatelessWidget {
  final String? initialVideoPath; // تمت الإضافة: متغير لاستقبال المسار

  const VaxpApp({super.key, this.initialVideoPath});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VAXP Video Player',
      theme: VaxpTheme.dark,
      // تمرير المسار إلى الصفحة الرئيسية (أو يمكنك وضع شرط هنا لفتح صفحة المشغل مباشرة)
      home: HomePage(initialVideoPath: initialVideoPath), 
    );
  }
}