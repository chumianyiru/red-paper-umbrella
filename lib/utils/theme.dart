import 'package:flutter/material.dart';

class HorrorTheme {
  static const Color bloodRed = Color(0xFF8B0000);
  static const Color darkRed = Color(0xFF4A0000);
  static const Color corpseBlack = Color(0xFF0A0A0A);
  static const Color ghostWhite = Color(0xFFE8E8E8);
  static const Color paperYellow = Color(0xFFD4C4A8);
  static const Color inkBlack = Color(0xFF1A1A1A);
  static const Color shadowGray = Color(0xFF2D2D2D);
  static const Color candleOrange = Color(0xFFFF6B00);
  static const Color eerieGreen = Color(0xFF004D40);
  static const Color moonlightBlue = Color(0xFF1A237E);

  static ThemeData get darkTheme => darkHorrorTheme;

  static ThemeData get darkHorrorTheme {
    final ColorScheme colorScheme = ColorScheme.dark(
      primary: bloodRed,
      secondary: candleOrange,
      surface: corpseBlack,
      error: bloodRed,
      onPrimary: ghostWhite,
      onSecondary: inkBlack,
      onSurface: ghostWhite,
      onError: ghostWhite,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: corpseBlack,
      fontFamily: 'ChineseBrush',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: bloodRed,
          shadows: [
            Shadow(
              color: Colors.black,
              offset: Offset(2, 2),
              blurRadius: 8,
            ),
            Shadow(
              color: bloodRed,
              offset: Offset(0, 0),
              blurRadius: 15,
            ),
          ],
        ),
        displayMedium: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: ghostWhite,
          shadows: [
            Shadow(
              color: bloodRed,
              offset: Offset(0, 0),
              blurRadius: 10,
            ),
          ],
        ),
        headlineLarge: TextStyle(
          fontSize: 28,
          color: ghostWhite,
          letterSpacing: 2,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          color: paperYellow,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          color: ghostWhite,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: ghostWhite,
          height: 1.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: inkBlack,
        foregroundColor: ghostWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 24,
          color: bloodRed,
          fontFamily: 'ChineseBrush',
          letterSpacing: 4,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkRed,
          foregroundColor: ghostWhite,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
            side: const BorderSide(color: bloodRed, width: 2),
          ),
          textStyle: const TextStyle(
            fontSize: 20,
            letterSpacing: 4,
            fontFamily: 'ChineseBrush',
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: paperYellow,
          side: const BorderSide(color: paperYellow, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: shadowGray,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: bloodRed.withOpacity(0.5), width: 1),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: inkBlack,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: bloodRed, width: 2),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 24,
          color: bloodRed,
          fontFamily: 'ChineseBrush',
        ),
        contentTextStyle: const TextStyle(
          fontSize: 16,
          color: ghostWhite,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: bloodRed,
        inactiveTrackColor: shadowGray,
        thumbColor: candleOrange,
        overlayColor: bloodRed.withOpacity(0.3),
      ),
      iconTheme: const IconThemeData(
        color: bloodRed,
        size: 24,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: inkBlack,
        selectedItemColor: bloodRed,
        unselectedItemColor: shadowGray,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
