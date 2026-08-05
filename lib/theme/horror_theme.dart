import 'package:flutter/material.dart';

class HorrorTheme {
  static const Color bloodRed = Color(0xFF8B0000);
  static const Color darkRed = Color(0xFF4A0000);
  static const Color deepBlack = Color(0xFF0A0A0A);
  static const Color darkGray = Color(0xFF1A1A1A);
  static const Color ghostWhite = Color(0xFFE8E8E8);
  static const Color paleSkin = Color(0xFFD4C4B0);
  static const Color paperYellow = Color(0xFFC4A35A);
  static const Color inkBlack = Color(0xFF0D0D0D);
  static const Color shadowColor = Color(0x66000000);
  static const Color eerieGreen = Color(0xFF2D4A3E);
  static const Color ghostBlue = Color(0xFF1A2A3A);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: bloodRed,
        secondary: paperYellow,
        surface: darkGray,
        error: bloodRed,
        onPrimary: ghostWhite,
        onSecondary: inkBlack,
        onSurface: ghostWhite,
        onError: ghostWhite,
      ),
      scaffoldBackgroundColor: deepBlack,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: bloodRed,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'MaShanZheng',
          letterSpacing: 4,
        ),
        iconTheme: IconThemeData(color: bloodRed),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: bloodRed,
          fontSize: 48,
          fontWeight: FontWeight.bold,
          fontFamily: 'MaShanZheng',
          letterSpacing: 8,
          shadows: [
            Shadow(
              color: shadowColor,
              offset: Offset(2, 2),
              blurRadius: 10,
            ),
          ],
        ),
        displayMedium: TextStyle(
          color: ghostWhite,
          fontSize: 36,
          fontWeight: FontWeight.bold,
          fontFamily: 'MaShanZheng',
          letterSpacing: 6,
        ),
        headlineLarge: TextStyle(
          color: bloodRed,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          fontFamily: 'MaShanZheng',
        ),
        headlineMedium: TextStyle(
          color: ghostWhite,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: ghostWhite,
          fontSize: 16,
          height: 1.8,
        ),
        bodyMedium: TextStyle(
          color: paleSkin,
          fontSize: 14,
          height: 1.6,
        ),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: darkRed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: bloodRed, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkRed,
          foregroundColor: ghostWhite,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(color: bloodRed, width: 1),
          ),
          textStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: darkGray,
        elevation: 8,
        shadowColor: bloodRed.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: bloodRed.withOpacity(0.5), width: 1),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: darkGray,
        elevation: 16,
        shadowColor: bloodRed.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: bloodRed, width: 2),
        ),
        titleTextStyle: TextStyle(
          color: bloodRed,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: bloodRed,
        inactiveTrackColor: darkGray,
        thumbColor: bloodRed,
        overlayColor: bloodRed.withOpacity(0.2),
      ),
      iconTheme: IconThemeData(
        color: bloodRed,
        size: 24,
      ),
    );
  }
}

class HorrorDecorations {
  static BoxDecoration bloodDripDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        HorrorTheme.deepBlack,
        HorrorTheme.darkGray,
        HorrorTheme.darkRed.withOpacity(0.3),
      ],
      stops: [0.0, 0.7, 1.0],
    ),
  );

  static BoxDecoration mistDecoration = BoxDecoration(
    gradient: RadialGradient(
      center: Alignment.center,
      radius: 1.5,
      colors: [
        HorrorTheme.ghostWhite.withOpacity(0.05),
        HorrorTheme.deepBlack,
      ],
    ),
  );

  static List<BoxShadow> horrorShadow = [
    BoxShadow(
      color: HorrorTheme.bloodRed.withOpacity(0.3),
      blurRadius: 20,
      spreadRadius: 2,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.8),
      blurRadius: 10,
      offset: Offset(0, 5),
    ),
  ];
}
