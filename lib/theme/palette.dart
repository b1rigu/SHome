import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, VisualTheme>((ref) {
  return ThemeNotifier();
});

class Pallete {
  // Colors
  static const darkModeScaffoldBackgroundColor = Color.fromARGB(255, 10, 10, 10);
  static const darkModeCardBackgroundColor = Color.fromARGB(255, 0, 0, 0);
  static const darkModePrimaryTextColor = Color.fromARGB(255, 255, 255, 255);
  static const darkModeSecondaryTextColor = Color.fromARGB(255, 158, 158, 158);
  static const lightModeScaffoldBackgroundColor = Color.fromARGB(255, 240, 240, 240);
  static const lightModeCardBackgroundColor = Color.fromARGB(255, 255, 255, 255);
  static const lightModePrimaryTextColor = Color.fromARGB(255, 0, 0, 0);
  static const lightModeSecondaryTextColor = Color.fromARGB(255, 158, 158, 158);
  static const primaryMainColor = Color(0xFF7F85F9);
  static const secondColor = Color(0xfff589b4);
  static const thirdColor = Color(0xff16224a);
  static const fontFamily = 'Poppins';

  // Themes
  static var darkModeAppTheme = VisualTheme(
    scaffoldBackgroundColor: darkModeScaffoldBackgroundColor,
    cardBackgroundColor: darkModeCardBackgroundColor,
    primaryTextColor: darkModePrimaryTextColor,
    secondaryTextColor: darkModeSecondaryTextColor,
  );

  static var lightModeAppTheme = VisualTheme(
    scaffoldBackgroundColor: lightModeScaffoldBackgroundColor,
    cardBackgroundColor: lightModeCardBackgroundColor,
    primaryTextColor: lightModePrimaryTextColor,
    secondaryTextColor: lightModeSecondaryTextColor,
  );
}

class VisualTheme {
  Color scaffoldBackgroundColor;
  Color cardBackgroundColor;
  Color primaryTextColor;
  Color secondaryTextColor;

  VisualTheme({
    required this.scaffoldBackgroundColor,
    required this.cardBackgroundColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
  });
}

class ThemeNotifier extends StateNotifier<VisualTheme> {
  ThemeMode _mode;
  ThemeNotifier({ThemeMode mode = ThemeMode.light})
      : _mode = mode,
        super(
          Pallete.darkModeAppTheme,
        ) {
    getTheme();
  }

  ThemeMode get mode => _mode;

  void getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('theme');

    if (theme == null) {
      _mode = ThemeMode.light;
      state = Pallete.lightModeAppTheme;
    } else {
      if (theme == 'light') {
        _mode = ThemeMode.light;
        state = Pallete.lightModeAppTheme;
      } else {
        _mode = ThemeMode.dark;
        state = Pallete.darkModeAppTheme;
      }
    }
  }

  void toggleTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_mode == ThemeMode.dark) {
      _mode = ThemeMode.light;
      state = Pallete.lightModeAppTheme;
      prefs.setString('theme', 'light');
    } else {
      _mode = ThemeMode.dark;
      state = Pallete.darkModeAppTheme;
      prefs.setString('theme', 'dark');
    }
  }
}
