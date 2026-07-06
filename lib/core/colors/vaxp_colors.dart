import 'package:flutter/material.dart';
import 'package:venom_config/venom_config.dart';

class VaxpColors {
  static const Color primary = Color.fromARGB(141, 32, 32, 32);
  static const Color secondary = Color.fromARGB(111, 122, 177, 255);

  /// 🔲 System background (General background)
  /// Controlled now via VenomConfig (system.background_color)
  static const Color darkGlassBackground = Color.fromARGB(188, 0, 0, 0);

  /// 🧊 Glass color (semi-transparent surface)
  static const Color glassSurface = Color.fromARGB(188, 0, 0, 0);

  /// 📝 Default text color
  /// Controlled now via VenomConfig (system.text_color)
  static Color defaultText = Colors.white;
  static final ValueNotifier<Color> textNotifier = ValueNotifier<Color>(
    Colors.white,
  );

  static void init() {
    // Load initial value
    _updateFromConfig(VenomConfig().getAll());

    // Listen for changes
    VenomConfig().onConfigChanged.listen((config) {
      _updateFromConfig(config);
    });
  }

  static void _updateFromConfig(Map<String, dynamic> config) {
    final textHex = config['system.text_color'] as String?;
    if (textHex != null) {
      final newColor = _parseColor(textHex);
      defaultText = newColor;
      textNotifier.value = newColor;
    }
  }

  static Color _parseColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 3) {
      hex = hex.split('').map((c) => '$c$c').join();
    }
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    if (hex.length == 8) {
      return Color(int.parse(hex, radix: 16));
    }
    return Colors.white;
  }
}
