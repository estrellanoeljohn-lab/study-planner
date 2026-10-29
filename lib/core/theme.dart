import 'package:flutter/material.dart';

const kPrimary = Color(0xFF3B5BDB);
const kInk = Color(0xFF14213D);
const kMuted = Color(0xFF4A5268);
const kBackground = Color(0xFFF4F6FB);

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: kPrimary,
    scaffoldBackgroundColor: kBackground,
        appBarTheme: const AppBarTheme(
      backgroundColor: kBackground,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCBD2E1)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}