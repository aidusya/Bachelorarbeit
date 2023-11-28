import 'dart:io';
import 'package:flutter/material.dart';

const MaterialColor listipalette =
    MaterialColor(_listipalettePrimaryValue, <int, Color>{
  50: Color(0xFFE0E7ED),
  100: Color(0xFFB3C2D1),
  200: Color(0xFF8099B3),
  300: Color(0xFF4D7094),
  400: Color(0xFF26527D),
  500: Color(_listipalettePrimaryValue),
  600: Color(0xFF002E5E),
  700: Color(0xFF002753),
  800: Color(0xFF002049),
  900: Color(0xFF001438),
});
const int _listipalettePrimaryValue = 0xFF003366;

const MaterialColor listipaletteAccent =
    MaterialColor(_listipaletteAccentValue, <int, Color>{
  100: Color(0xFF6E93FF),
  200: Color(_listipaletteAccentValue),
  400: Color(0xFF0846FF),
  700: Color(0xFF003BEE),
});
const int _listipaletteAccentValue = 0xFF3B6CFF;

Color get shoppingModeColor {
  return listipalette;
}

ThemeData get listiTheme {
  if (Platform.isIOS) {
    return ThemeData(
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: listipalette,
      ),
    );
  } else {
    return ThemeData(
      colorScheme: ColorScheme.fromSwatch(primarySwatch: listipalette),
    );
  }
}
