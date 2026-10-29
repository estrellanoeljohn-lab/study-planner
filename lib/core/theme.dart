import 'package:flutter/material.dart';

// ── Midnight Scholar palette ──
const kPrimary = Color(0xFFE8A838); // warm amber gold
const kPrimaryLight = Color(0xFFF5D590); // lighter amber
const kAccent = Color(0xFF6C9BCF); // cool blue for contrast
const kSurface = Color(0xFF1A1F2E); // deep navy card surface
const kSurfaceLight = Color(0xFF232A3D); // slightly lighter surface
const kBackground = Color(0xFF121620); // darkest background
const kInk = Color(0xFFF0E6D3); // warm cream text
const kMuted = Color(0xFF8A91A8); // muted lavender-gray
const kDivider = Color(0xFF2A3148); // subtle divider
const kSuccess = Color(0xFF4CAF7D); // muted green
const kError = Color(0xFFE85D5D); // soft red

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: kPrimary,
    scaffoldBackgroundColor: kBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: kBackground,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: kInk,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: kInk),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: kSurface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: kPrimary.withValues(alpha: 0.15),
      iconTheme: WidgetStatePropertyAll(
        IconThemeData(color: kMuted),
      ),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: kMuted,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kSurfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: kDivider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: kDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: kPrimary, width: 1.5),
      ),
      labelStyle: const TextStyle(color: kMuted),
      hintStyle: const TextStyle(color: kMuted),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kPrimary,
        foregroundColor: const Color(0xFF1A1200),
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kInk,
        side: BorderSide(color: kDivider),
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: kPrimary,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return kPrimary;
        return Colors.transparent;
      }),
      checkColor: const WidgetStatePropertyAll(Color(0xFF1A1200)),
      side: BorderSide(color: kMuted, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: kSurfaceLight,
      selectedColor: kPrimary.withValues(alpha: 0.2),
      labelStyle: const TextStyle(color: kInk, fontSize: 14),
      side: BorderSide(color: kDivider),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: kSurfaceLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return kPrimary.withValues(alpha: 0.2);
          }
          return kSurfaceLight;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return kPrimary;
          return kMuted;
        }),
        side: WidgetStatePropertyAll(BorderSide(color: kDivider)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: kPrimary,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: kPrimary,
      foregroundColor: const Color(0xFF1A1200),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: kSurfaceLight,
      surfaceTintColor: Colors.transparent,
      headerBackgroundColor: kSurface,
      headerForegroundColor: kInk,
      dayForegroundColor: WidgetStatePropertyAll(kInk),
      todayForegroundColor: WidgetStatePropertyAll(kPrimary),
      todayBackgroundColor: WidgetStatePropertyAll(Colors.transparent),
      todayBorder: BorderSide(color: kPrimary),
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: kSurfaceLight,
      dialBackgroundColor: kSurface,
      hourMinuteColor: kSurface,
      hourMinuteTextColor: kInk,
      dayPeriodColor: kSurface,
      dayPeriodTextColor: kInk,
      entryModeIconColor: kMuted,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: kSurfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
  );
}
