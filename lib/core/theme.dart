import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Travel-themed palette ──────────────────────────────────────────────
  // Light: Sky Blue primary, Amber/Golden secondary, Coral tertiary
  static const Color _primaryLight   = Color(0xFF0284C7); // Sky blue
  static const Color _secondaryLight = Color(0xFFF59E0B); // Amber gold
  static const Color _tertiaryLight  = Color(0xFFF97316); // Sunset orange
  static const Color _errorLight     = Color(0xFFDC2626);

  // Dark: Bright Sky Blue, Golden Yellow, Vibrant Coral
  static const Color _primaryDark    = Color(0xFF38BDF8); // Bright sky
  static const Color _secondaryDark  = Color(0xFFFBBF24); // Bright amber
  static const Color _tertiaryDark   = Color(0xFFFB923C); // Warm coral
  static const Color _errorDark      = Color(0xFFF87171);

  // ── Named gradient presets ─────────────────────────────────────────────
  /// Sky → Teal  (primary card)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0284C7), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Sky → Indigo  (dark card variant)
  static const LinearGradient darkPrimaryGradient = LinearGradient(
    colors: [Color(0xFF38BDF8), Color(0xFF818CF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Amber → Coral  (sunset card)
  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Deep Blue → Cyan  (ocean card)
  static const LinearGradient oceanGradient = LinearGradient(
    colors: [Color(0xFF0369A1), Color(0xFF0891B2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Green → Teal  (success / settled)
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF0D9488)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Text theme factory ─────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Color baseColor) {
    return GoogleFonts.plusJakartaSansTextTheme().copyWith(
      displayLarge:  GoogleFonts.plusJakartaSans(fontSize: 57, fontWeight: FontWeight.w700, color: baseColor),
      displayMedium: GoogleFonts.plusJakartaSans(fontSize: 45, fontWeight: FontWeight.w700, color: baseColor),
      headlineLarge: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.w700, color: baseColor),
      headlineMedium:GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w600, color: baseColor),
      headlineSmall: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w600, color: baseColor),
      titleLarge:    GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w700, color: baseColor),
      titleMedium:   GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: baseColor),
      titleSmall:    GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: baseColor),
      bodyLarge:     GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w400, color: baseColor),
      bodyMedium:    GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w400, color: baseColor),
      bodySmall:     GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w400, color: baseColor),
      labelLarge:    GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w500, color: baseColor),
    );
  }

  // ── LIGHT THEME ────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    const Color bg      = Color(0xFFF0F9FF);  // Very light sky blue tint
    const Color surface = Color(0xFFFFFFFF);
    const Color onSurf  = Color(0xFF0C1A2E);  // Deep navy text

    final scheme = ColorScheme.fromSeed(
      seedColor: _primaryLight,
      secondary: _secondaryLight,
      tertiary: _tertiaryLight,
      error: _errorLight,
      brightness: Brightness.light,
      surface: surface,
      onSurface: onSurf,
      surfaceContainerHighest: const Color(0xFFE0F2FE),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: _buildTextTheme(onSurf),
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.plusJakartaSans(
            fontSize: 20, fontWeight: FontWeight.w700, color: onSurf),
        iconTheme: const IconThemeData(color: onSurf),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: _primaryLight.withOpacity(0.15)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: _primaryLight.withOpacity(0.12),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _primaryLight,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      chipTheme: ChipThemeData(
        selectedColor: _primaryLight.withOpacity(0.12),
        side: BorderSide(color: _primaryLight.withOpacity(0.35)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: onSurf),
        backgroundColor: surface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _primaryLight.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _primaryLight.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primaryLight, width: 2),
        ),
        labelStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF5B7EA6)),
        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFFABC3D8)),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 16,
        backgroundColor: surface,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primaryLight,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryLight,
          side: const BorderSide(color: _primaryLight),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFE0EEF9), thickness: 1),
    );
  }

  // ── DARK THEME ─────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    const Color bg      = Color(0xFF071526);  // Deep ocean night
    const Color surface = Color(0xFF0C1E38);  // Dark navy
    const Color card    = Color(0xFF0F2044);  // Slightly lighter navy card
    const Color onSurf  = Color(0xFFE0F2FE);  // Sky-white text

    final scheme = ColorScheme.fromSeed(
      seedColor: _primaryDark,
      secondary: _secondaryDark,
      tertiary: _tertiaryDark,
      error: _errorDark,
      brightness: Brightness.dark,
      surface: surface,
      onSurface: onSurf,
      surfaceContainerHighest: card,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: _buildTextTheme(onSurf),
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.plusJakartaSans(
            fontSize: 20, fontWeight: FontWeight.w700, color: onSurf),
        iconTheme: const IconThemeData(color: onSurf),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: _primaryDark.withOpacity(0.18)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: _primaryDark.withOpacity(0.18),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _primaryDark,
        foregroundColor: const Color(0xFF071526),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      chipTheme: ChipThemeData(
        selectedColor: _primaryDark.withOpacity(0.18),
        side: BorderSide(color: _primaryDark.withOpacity(0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: onSurf),
        backgroundColor: card,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _primaryDark.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _primaryDark.withOpacity(0.22)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primaryDark, width: 2),
        ),
        labelStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF7CB9D8)),
        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF3A6080)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 24,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primaryDark,
          foregroundColor: const Color(0xFF071526),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryDark,
          side: const BorderSide(color: _primaryDark),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFF142952), thickness: 1),
    );
  }
}
