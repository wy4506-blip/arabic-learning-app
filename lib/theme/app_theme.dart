import 'package:flutter/material.dart';

class AppTheme {

  // Backward-compatible aliases for existing pages.
  static const Color background = bgBase;
  static const Color cardBackground = bgCard;
  static const Color primaryText = textPrimary;
  static const Color secondaryText = textSecondary;
  static const Color tertiaryText = textSecondary;
  static const Color deepAccent = accentMintDark;
  static const Color softAccent = accentMint;
  static const Color border = strokeLight;
  static const Color divider = strokeLight;
  static const Color bgBase = Color(0xFFF7F6F3);
  static const Color bgCard = Color(0xFFFCFBF8);
  static const Color bgCardSoft = Color(0xFFF2F1EE);
  static const Color accentMint = Color(0xFFBFEADF);
  static const Color accentMintDark = Color(0xFF6F9E92);
  static const Color textPrimary = Color(0xFF1E1E1C);
  static const Color textSecondary = Color(0xFF6D6A64);
  static const Color strokeLight = Color(0xFFE4E0DA);
  static const Color shadowColor = Color(0x14000000);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: bgBase,
    colorScheme: const ColorScheme.light(
      primary: accentMintDark,
      secondary: accentMint,
      surface: bgCard,
      onSurface: textPrimary,
    ),
    cardColor: bgCard,
    appBarTheme: const AppBarTheme(
      backgroundColor: bgBase,
      elevation: 0,
      centerTitle: false,
      foregroundColor: textPrimary,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 18,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 28, height: 1.2, fontWeight: FontWeight.w500, color: textPrimary),
      headlineMedium: TextStyle(fontSize: 22, height: 1.25, fontWeight: FontWeight.w600, color: textPrimary),
      titleLarge: TextStyle(fontSize: 22, height: 1.27, fontWeight: FontWeight.w600, color: textPrimary),
      titleMedium: TextStyle(fontSize: 18, height: 1.3, fontWeight: FontWeight.w500, color: textPrimary),
      titleSmall: TextStyle(fontSize: 16, height: 1.3, fontWeight: FontWeight.w500, color: textPrimary),
      bodyLarge: TextStyle(fontSize: 17, height: 1.41, color: textPrimary),
      bodyMedium: TextStyle(fontSize: 15, height: 1.46, color: textSecondary),
      bodySmall: TextStyle(fontSize: 12, height: 1.33, color: textSecondary),
      labelLarge: TextStyle(fontSize: 17, height: 1.2, fontWeight: FontWeight.w500, color: textPrimary),
      labelMedium: TextStyle(fontSize: 13, height: 1.23, fontWeight: FontWeight.w500, color: textSecondary),
      labelSmall: TextStyle(fontSize: 12, height: 1.2, fontWeight: FontWeight.w500, color: textSecondary),
    ),
    cardTheme: CardTheme(
      color: bgCard,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    dividerTheme: const DividerThemeData(color: strokeLight, thickness: 0.8),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: accentMint,
        foregroundColor: textPrimary,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textPrimary,
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: strokeLight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: bgCard,
      contentTextStyle: const TextStyle(color: textPrimary, fontSize: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: strokeLight),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF141414),
    colorScheme: const ColorScheme.dark(
      primary: accentMint,
      secondary: accentMintDark,
      surface: Color(0xFF1E1E1E),
    ),
    cardColor: const Color(0xFF1E1E1E),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF141414),
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardTheme(
      color: Color(0xFF1E1E1E),
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: accentMintDark,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );

  static List<BoxShadow> softShadow = const [
    BoxShadow(color: shadowColor, blurRadius: 24, offset: Offset(0, 8)),
  ];

  static EdgeInsets pagePadding = const EdgeInsets.fromLTRB(20, 12, 20, 108);
}
