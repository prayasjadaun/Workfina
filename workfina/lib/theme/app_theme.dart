import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primary = Color.fromARGB(255, 36, 39, 38);
  static const Color primaryDark = Color.fromARGB(255, 51, 132, 105);
  static const Color secondary = Color.fromARGB(255, 38, 45, 52);
  // static const Color secondary = Color(0xFF6BA3D6);
  static const Color accentPrimary = Color(0xFFF39C12);
  static const Color accentSecondary = Color(0xFF8E44AD);
  
  // Blue Colors
  static const Color blue = Color(0xFF2196F3);
  static const Color blueDark = Color(0xFF1976D2);
  static const Color blueLight = Color(0xFF64B5F6);

  // Green Card Colors
static const Color greenCardStart = Color(0xFFB7E08A);
static const Color greenCardEnd   = Color(0xFFA6D96A);
static const Color greenCardSolid = Color(0xFFCDEDAA);
static const Color greenCard = Color.fromARGB(255, 82, 134, 34);


  // Light Theme Colors
  static const Color lightBackground = Color.fromARGB(255, 250, 250, 250);
  static const Color lightSurface = Colors.white;
  static const Color lightCardBackground = Colors.white;
  static const Color lightGradientStart = Color(0xFFF7F1E3);
  static const Color lightGradientEnd = Color(0xFFFDF6EC);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCardBackground = Color(0xFF2D2D2D);
  static const Color darkGradientStart = Color(0xFF1A1A1A);
  static const Color darkGradientEnd = Color(0xFF2D2D2D);

  // Text Styles & Typography
  static final TextTheme _baseTextTheme = GoogleFonts.jostTextTheme();

  static TextTheme get lightTextTheme => _baseTextTheme.copyWith(
    displayLarge: GoogleFonts.jost(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      color: const Color(0xFF1C1B1F),
    ),
    displayMedium: GoogleFonts.jost(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: const Color(0xFF1C1B1F),
    ),
    displaySmall: GoogleFonts.jost(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: const Color(0xFF1C1B1F),
    ),
    headlineLarge: GoogleFonts.jost(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: const Color(0xFF1C1B1F),
    ),
    headlineMedium: GoogleFonts.jost(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: const Color(0xFF1C1B1F),
    ),
    headlineSmall: GoogleFonts.jost(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: const Color(0xFF1C1B1F),
    ),
    titleLarge: GoogleFonts.jost(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      color: const Color(0xFF1C1B1F),
    ),
    titleMedium: GoogleFonts.jost(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      color: const Color(0xFF1C1B1F),
    ),
    titleSmall: GoogleFonts.jost(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: const Color(0xFF1C1B1F),
    ),
    bodyLarge: GoogleFonts.jost(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      color: const Color(0xFF1C1B1F),
    ),
    bodyMedium: GoogleFonts.jost(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: const Color(0xFF1C1B1F),
    ),
    bodySmall: GoogleFonts.jost(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      color: const Color(0xFF1C1B1F),
    ),
    labelLarge: GoogleFonts.jost(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: const Color(0xFF1C1B1F),
    ),
    labelMedium: GoogleFonts.jost(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: const Color(0xFF1C1B1F),
    ),
    labelSmall: GoogleFonts.jost(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: const Color(0xFF1C1B1F),
    ),
  );

  static TextTheme get darkTextTheme => _baseTextTheme.copyWith(
    displayLarge: GoogleFonts.jost(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      color: Colors.white,
    ),
    displayMedium: GoogleFonts.jost(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: Colors.white,
    ),
    displaySmall: GoogleFonts.jost(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: Colors.white,
    ),
    headlineLarge: GoogleFonts.jost(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: Colors.white,
    ),
    headlineMedium: GoogleFonts.jost(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: Colors.white,
    ),
    headlineSmall: GoogleFonts.jost(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: Colors.white,
    ),
    titleLarge: GoogleFonts.jost(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      color: Colors.white,
    ),
    titleMedium: GoogleFonts.jost(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      color: Colors.white,
    ),
    titleSmall: GoogleFonts.jost(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: Colors.white,
    ),
    bodyLarge: GoogleFonts.jost(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      color: Colors.white,
    ),
    bodyMedium: GoogleFonts.jost(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: Colors.white,
    ),
    bodySmall: GoogleFonts.jost(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      color: Colors.white,
    ),
    labelLarge: GoogleFonts.jost(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: Colors.white,
    ),
    labelMedium: GoogleFonts.jost(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: Colors.white,
    ),
    labelSmall: GoogleFonts.jost(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: Colors.white,
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    textTheme: lightTextTheme,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: lightSurface,
      background: lightBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF1C1B1F),
      onBackground: Color(0xFF1C1B1F),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: primary,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      backgroundColor: lightSurface,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    textTheme: darkTextTheme,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: darkSurface,
      background: darkBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: primary,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      backgroundColor: darkSurface,
    ),
  );

  // Gradient decorations for different themes
  static BoxDecoration getGradientDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      gradient: LinearGradient(
        colors: isDark
            ? [darkGradientStart, darkGradientEnd]
            : [lightGradientStart, lightGradientEnd],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
  }

  static BoxDecoration getPrimaryGradientDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [primary, primaryDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  static Color getCardColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkCardBackground : lightCardBackground;
  }

  static BoxShadow getCardShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxShadow(
      color: isDark ? Colors.black54 : Colors.grey.withOpacity(0.2),
      blurRadius: 8,
      offset: const Offset(0, 2),
    );
  }

  // Dynamic Text Style Helpers
  static TextStyle getHeadlineStyle(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    final theme = Theme.of(context);
    return theme.textTheme.headlineMedium!.copyWith(
      color: color ?? theme.textTheme.headlineMedium!.color,
      fontWeight: fontWeight,
      fontSize: fontSize,
    );
  }

  static TextStyle getTitleStyle(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    final theme = Theme.of(context);
    return theme.textTheme.titleLarge!.copyWith(
      color: color ?? theme.textTheme.titleLarge!.color,
      fontWeight: fontWeight,
      fontSize: fontSize,
    );
  }

  static TextStyle getBodyStyle(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    final theme = Theme.of(context);
    return theme.textTheme.bodyMedium!.copyWith(
      color: color ?? theme.textTheme.bodyMedium!.color,
      fontWeight: fontWeight,
      fontSize: fontSize,
    );
  }

  static TextStyle getSubtitleStyle(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    final theme = Theme.of(context);
    return theme.textTheme.bodySmall!.copyWith(
      color: color ?? theme.textTheme.bodySmall!.color,
      fontWeight: fontWeight,
      fontSize: fontSize,
    );
  }

  static TextStyle getLabelStyle(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    final theme = Theme.of(context);
    return theme.textTheme.labelMedium!.copyWith(
      color: color ?? theme.textTheme.labelMedium!.color,
      fontWeight: fontWeight,
      fontSize: fontSize,
    );
  }

  // Custom Text Styles for Brand Specific Usage
  static TextStyle getPrimaryButtonTextStyle(BuildContext context) {
    return GoogleFonts.jost(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );
  }

  static TextStyle getCardTitleStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.jost(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: isDark ? Colors.white : const Color(0xFF1C1B1F),
    );
  }

  static TextStyle getCardSubtitleStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.jost(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
    );
  }

  static TextStyle getTabBarTextStyle(BuildContext context, bool isActive) {
    return GoogleFonts.jost(
      fontSize: 12,
      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
      color: isActive ? Colors.white : Colors.grey,
    );
  }

  static TextStyle getAppBarTextStyle() {
    return GoogleFonts.jost(fontSize: 20, fontWeight: FontWeight.w600);
  }

  static TextStyle getStatCardValueStyle(BuildContext context, Color color) {
    return GoogleFonts.jost(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: color,
    );
  }

  static TextStyle getStatCardLabelStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.jost(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
    );
  }
}