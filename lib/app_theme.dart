import 'package:flutter/material.dart';

class AppTheme {
  // ── Core palette ──────────────────────────────────────────────
  static const Color primary      = Color(0xFF1B3A5C); // Deep navy
  static const Color primaryDark  = Color(0xFF0F2438); // Darkest navy
  static const Color primaryLight = Color(0xFF254F7A); // Lighter navy
  static const Color accent       = Color(0xFF1F7A8C); // Professional teal
  static const Color accentLight  = Color(0xFF2A9BB0); // Light teal
  static const Color gold         = Color(0xFFC49A2A); // Legal gold
  static const Color surface      = Color(0xFFEEF2F8); // Cool light bg
  static const Color card         = Colors.white;
  static const Color divider      = Color(0xFFDFE8F2);
  static const Color darkSurface  = Color(0xFF0E1620);
  static const Color darkCard     = Color(0xFF172433);
  static const Color darkDivider  = Color(0xFF2A3D52);
  static const Color darkInput    = Color(0xFF1E2F42);

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color surfaceOf(BuildContext context) => isDark(context) ? darkSurface : surface;
  static Color cardOf(BuildContext context) => isDark(context) ? darkCard : card;
  static Color dividerOf(BuildContext context) => isDark(context) ? darkDivider : divider;
  static Color primaryTextOf(BuildContext context) =>
      isDark(context) ? const Color(0xFFE8EFF7) : primaryDark;
  static Color mutedTextOf(BuildContext context) =>
      isDark(context) ? const Color(0xFF8FA3B8) : Colors.grey.shade600;

  // ── Gradients ─────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primaryDark, primary],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, accent],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary, Color(0xFF1A5068)],
    stops: [0.0, 0.55, 1.0],
  );

  // ── Shadows ───────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.07),
      blurRadius: 20,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: primaryDark.withValues(alpha: 0.18),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: -2,
    ),
    BoxShadow(
      color: accent.withValues(alpha: 0.1),
      blurRadius: 32,
      offset: const Offset(0, 2),
      spreadRadius: -4,
    ),
  ];

  // ── ThemeData ─────────────────────────────────────────────────
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: accent,
      tertiary: gold,
      surface: surface,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surface,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
        toolbarHeight: 62,
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: card,
        selectedIconTheme: const IconThemeData(color: primary, size: 24),
        unselectedIconTheme: IconThemeData(color: Colors.grey.shade400, size: 22),
        selectedLabelTextStyle: const TextStyle(
          color: primary,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0.2,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 12,
        ),
        indicatorColor: primary.withValues(alpha: 0.12),
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        useIndicator: true,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: card,
        elevation: 8,
        shadowColor: primaryDark.withValues(alpha: 0.12),
        surfaceTintColor: Colors.transparent,
        height: 70,
        indicatorColor: primary.withValues(alpha: 0.12),
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontWeight: FontWeight.w700,
              color: primary,
              fontSize: 11,
              letterSpacing: 0.3,
            );
          }
          return TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
            letterSpacing: 0.2,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary, size: 24);
          }
          return IconThemeData(color: Colors.grey.shade400, size: 22);
        }),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: divider, width: 1),
        ),
        margin: EdgeInsets.zero,
        shadowColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) return accent;
          return Colors.grey.shade500;
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primary.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          shadowColor: primary.withValues(alpha: 0.35),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primaryDark,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        elevation: 8,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
        headlineMedium: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.3),
        headlineSmall: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.2),
        titleLarge: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0),
        titleMedium: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0),
        titleSmall: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.1),
        bodyLarge: TextStyle(letterSpacing: 0.1),
        bodyMedium: TextStyle(letterSpacing: 0.1),
        labelLarge: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: const BorderSide(color: divider),
      ),
      datePickerTheme: DatePickerThemeData(
        headerBackgroundColor: primary,
        headerForegroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        dayShape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  static ThemeData get dark {
    const darkScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: primaryLight,
      onPrimary: Colors.white,
      secondary: accentLight,
      onSecondary: Colors.white,
      tertiary: gold,
      surface: darkSurface,
      onSurface: Color(0xFFE8EFF7),
      error: Colors.redAccent,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: darkScheme,
      scaffoldBackgroundColor: darkSurface,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
        toolbarHeight: 62,
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: darkCard,
        selectedIconTheme: const IconThemeData(color: accentLight, size: 24),
        unselectedIconTheme: const IconThemeData(color: Color(0xFF6B8499), size: 22),
        selectedLabelTextStyle: const TextStyle(
          color: accentLight,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0.2,
        ),
        unselectedLabelTextStyle: const TextStyle(
          color: Color(0xFF6B8499),
          fontSize: 12,
        ),
        indicatorColor: accent.withValues(alpha: 0.2),
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        useIndicator: true,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkCard,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        surfaceTintColor: Colors.transparent,
        height: 70,
        indicatorColor: accent.withValues(alpha: 0.2),
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontWeight: FontWeight.w700,
              color: accentLight,
              fontSize: 11,
              letterSpacing: 0.3,
            );
          }
          return const TextStyle(
            fontSize: 11,
            color: Color(0xFF6B8499),
            letterSpacing: 0.2,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: accentLight, size: 24);
          }
          return const IconThemeData(color: Color(0xFF6B8499), size: 22);
        }),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkDivider, width: 1),
        ),
        margin: EdgeInsets.zero,
        shadowColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkDivider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        labelStyle: const TextStyle(color: Color(0xFF8FA3B8), fontSize: 14),
        hintStyle: const TextStyle(color: Color(0xFF5C7288), fontSize: 14),
        prefixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) return accentLight;
          return const Color(0xFF6B8499);
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primaryLight.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentLight,
          side: const BorderSide(color: accentLight, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: darkDivider,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkCard,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        elevation: 8,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5, color: Color(0xFFE8EFF7)),
        headlineMedium: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.3, color: Color(0xFFE8EFF7)),
        headlineSmall: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.2, color: Color(0xFFE8EFF7)),
        titleLarge: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFE8EFF7)),
        titleMedium: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFE8EFF7)),
        titleSmall: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFE8EFF7)),
        bodyLarge: TextStyle(letterSpacing: 0.1, color: Color(0xFFD0DCE8)),
        bodyMedium: TextStyle(letterSpacing: 0.1, color: Color(0xFFD0DCE8)),
        labelLarge: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5, color: Color(0xFFE8EFF7)),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textColor: const Color(0xFFE8EFF7),
        iconColor: const Color(0xFF8FA3B8),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkInput,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFD0DCE8)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: const BorderSide(color: darkDivider),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          side: WidgetStateProperty.all(const BorderSide(color: darkDivider)),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return accent.withValues(alpha: 0.25);
            }
            return darkInput;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return accentLight;
            return const Color(0xFF8FA3B8);
          }),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        headerBackgroundColor: primary,
        headerForegroundColor: Colors.white,
        backgroundColor: darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        dayShape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
