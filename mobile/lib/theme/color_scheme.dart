import 'package:flutter/material.dart';
import 'package:immich_mobile/constants/colors.dart';
import 'package:immich_mobile/theme/theme_data.dart';

final Map<ImmichColorPreset, ImmichTheme> _themePresets = {
  ImmichColorPreset.indigo: ImmichTheme(
    light: ColorScheme.fromSeed(
      seedColor: immichBrandColorLight,
    ).copyWith(primary: immichBrandColorLight, onSurface: const Color.fromARGB(255, 34, 31, 32)),
    dark: ColorScheme.fromSeed(
      seedColor: immichBrandColorDark,
      brightness: .dark,
    ).copyWith(primary: immichBrandColorDark),
  ),
  ImmichColorPreset.deepPurple: ImmichTheme(
    light: ColorScheme.fromSeed(seedColor: const Color(0xFF6F43C0)),
    dark: ColorScheme.fromSeed(seedColor: const Color(0xFFD3BBFF), brightness: .dark),
  ),
  ImmichColorPreset.pink: ImmichTheme(
    light: ColorScheme.fromSeed(seedColor: const Color(0xFFED79B5)),
    dark: ColorScheme.fromSeed(seedColor: const Color(0xFFED79B5), brightness: .dark),
  ),
  ImmichColorPreset.red: ImmichTheme(
    light: ColorScheme.fromSeed(seedColor: const Color(0xFFC51C16)),
    dark: ColorScheme.fromSeed(seedColor: const Color(0xFFD3302F), brightness: .dark),
  ),
  ImmichColorPreset.orange: ImmichTheme(
    light: ColorScheme.fromSeed(seedColor: const Color(0xffff5b01), dynamicSchemeVariant: .fidelity),
    dark: ColorScheme.fromSeed(seedColor: const Color(0xFFCC6D08), brightness: .dark, dynamicSchemeVariant: .fidelity),
  ),
  ImmichColorPreset.yellow: ImmichTheme(
    light: ColorScheme.fromSeed(seedColor: const Color(0xFFFFB400)),
    dark: ColorScheme.fromSeed(seedColor: const Color(0xFFFFB400), brightness: .dark),
  ),
  ImmichColorPreset.lime: ImmichTheme(
    light: ColorScheme.fromSeed(seedColor: const Color(0xFFCDDC39)),
    dark: ColorScheme.fromSeed(seedColor: const Color(0xFFCDDC39), brightness: .dark),
  ),
  ImmichColorPreset.green: ImmichTheme(
    light: ColorScheme.fromSeed(seedColor: const Color(0xFF18C249)),
    dark: ColorScheme.fromSeed(seedColor: const Color(0xFF18C249), brightness: .dark),
  ),
  ImmichColorPreset.cyan: ImmichTheme(
    light: ColorScheme.fromSeed(seedColor: const Color(0xFF00BCD4)),
    dark: ColorScheme.fromSeed(seedColor: const Color(0xFF00BCD4), brightness: .dark),
  ),
  ImmichColorPreset.slateGray: ImmichTheme(
    light: ColorScheme.fromSeed(seedColor: const Color(0xFF696969), dynamicSchemeVariant: .neutral),
    dark: ColorScheme.fromSeed(seedColor: const Color(0xff696969), brightness: .dark, dynamicSchemeVariant: .neutral),
  ),
};

extension ImmichColorModeExtension on ImmichColorPreset {
  ImmichTheme get themeOfPreset => _themePresets[this]!;
}
