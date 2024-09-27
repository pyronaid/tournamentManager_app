// ignore_for_file: overridden_fields, annotate_overrides

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shared_preferences/shared_preferences.dart';

const kThemeModeKey = '__theme_mode__';
SharedPreferences? _prefs;

abstract class CustomFlowTheme {
  static Future initialize() async =>
      _prefs = await SharedPreferences.getInstance();
  static ThemeMode get themeMode {
    final darkMode = _prefs?.getBool(kThemeModeKey);
    return darkMode == null
        ? ThemeMode.system
        : darkMode
            ? ThemeMode.dark
            : ThemeMode.light;
  }

  static void saveThemeMode(ThemeMode mode) => mode == ThemeMode.system
      ? _prefs?.remove(kThemeModeKey)
      : _prefs?.setBool(kThemeModeKey, mode == ThemeMode.dark);

  static CustomFlowTheme of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? DarkModeTheme()
        : LightModeTheme();
  }

  static Brightness bright(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Brightness.light
        : Brightness.dark;
  }

  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  late Color pawColor;
  late Color primary;
  late Color secondary;
  late Color tertiary;
  late Color alternate;
  late Color primaryText;
  late Color secondaryText;
  late Color gradientBackgroundBegin;
  late Color gradientBackgroundEnd;
  late Color primaryBackground;
  late Color secondaryBackground;
  late Color accent1;
  late Color accent2;
  late Color accent3;
  late Color accent4;
  late Color success;
  late Color warning;
  late Color error;
  late Color info;
  late Color cardDetail;
  late Color cardMain;
  late Color cardSecond;

  @Deprecated('Use displaySmallFamily instead')
  String get title1Family => displaySmallFamily;
  @Deprecated('Use displaySmall instead')
  TextStyle get title1 => typography.displaySmall;
  @Deprecated('Use headlineMediumFamily instead')
  String get title2Family => typography.headlineMediumFamily;
  @Deprecated('Use headlineMedium instead')
  TextStyle get title2 => typography.headlineMedium;
  @Deprecated('Use headlineSmallFamily instead')
  String get title3Family => typography.headlineSmallFamily;
  @Deprecated('Use headlineSmall instead')
  TextStyle get title3 => typography.headlineSmall;
  @Deprecated('Use titleMediumFamily instead')
  String get subtitle1Family => typography.titleMediumFamily;
  @Deprecated('Use titleMedium instead')
  TextStyle get subtitle1 => typography.titleMedium;
  @Deprecated('Use titleSmallFamily instead')
  String get subtitle2Family => typography.titleSmallFamily;
  @Deprecated('Use titleSmall instead')
  TextStyle get subtitle2 => typography.titleSmall;
  @Deprecated('Use bodyMediumFamily instead')
  String get bodyText1Family => typography.bodyMediumFamily;
  @Deprecated('Use bodyMedium instead')
  TextStyle get bodyText1 => typography.bodyMedium;
  @Deprecated('Use bodySmallFamily instead')
  String get bodyText2Family => typography.bodySmallFamily;
  @Deprecated('Use bodySmall instead')
  TextStyle get bodyText2 => typography.bodySmall;
  @Deprecated('Use bodyMicroFamily instead')
  String get bodyText3Family => typography.bodyMicroFamily;
  @Deprecated('Use bodyMicro instead')
  TextStyle get bodyText3 => typography.bodyMicro;

  String get displayLargeFamily => typography.displayLargeFamily;
  TextStyle get displayLarge => typography.displayLarge;
  String get displayMediumFamily => typography.displayMediumFamily;
  TextStyle get displayMedium => typography.displayMedium;
  String get displaySmallFamily => typography.displaySmallFamily;
  TextStyle get displaySmall => typography.displaySmall;
  String get headlineLargeFamily => typography.headlineLargeFamily;
  TextStyle get headlineLarge => typography.headlineLarge;
  String get headlineMediumFamily => typography.headlineMediumFamily;
  TextStyle get headlineMedium => typography.headlineMedium;
  String get headlineSmallFamily => typography.headlineSmallFamily;
  TextStyle get headlineSmall => typography.headlineSmall;
  String get titleLargeFamily => typography.titleLargeFamily;
  TextStyle get titleLarge => typography.titleLarge;
  String get titleMediumFamily => typography.titleMediumFamily;
  TextStyle get titleMedium => typography.titleMedium;
  String get titleSmallFamily => typography.titleSmallFamily;
  TextStyle get titleSmall => typography.titleSmall;
  String get labelLargeFamily => typography.labelLargeFamily;
  TextStyle get labelLarge => typography.labelLarge;
  String get labelMediumFamily => typography.labelMediumFamily;
  TextStyle get labelMedium => typography.labelMedium;
  String get labelSmallFamily => typography.labelSmallFamily;
  TextStyle get labelSmall => typography.labelSmall;
  String get bodyLargeFamily => typography.bodyLargeFamily;
  TextStyle get bodyLarge => typography.bodyLarge;
  String get bodyMediumFamily => typography.bodyMediumFamily;
  TextStyle get bodyMedium => typography.bodyMedium;
  String get bodySmallFamily => typography.bodySmallFamily;
  TextStyle get bodySmall => typography.bodySmall;
  String get bodyMicroFamily => typography.bodyMicroFamily;
  TextStyle get bodyMicro => typography.bodyMicro;

  Typography get typography => ThemeTypography(this);
}

class LightModeTheme extends CustomFlowTheme {
  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  late Color pawColor = const Color(0xFF00BF63);
  late Color primary = const Color(0xFF448AFF);
  late Color secondary = const Color(0xFF386EC8);
  late Color tertiary = const Color(0xFF7CA3E4);
  late Color alternate = const Color(0xFFE0E3E7);
  late Color primaryText = const Color(0xFF272727);
  late Color secondaryText = const Color(0xFF797979);
  late Color gradientBackgroundBegin = Colors.blueAccent;
  late Color gradientBackgroundEnd = Colors.white;
  late Color primaryBackground = const Color(0xFFFFFFFF);
  late Color secondaryBackground = const Color(0xFFF2F2F2);
  late Color accent1 = const Color(0x4D44A4C1);
  late Color accent2 = const Color(0x4C20596A);
  late Color accent3 = const Color(0x7FD5EEBA);
  late Color accent4 = const Color(0xB2E0E3E7);
  late Color success = const Color(0xFF04A24C);
  late Color warning = const Color(0x4CFF5963);
  late Color error = const Color(0xFFFF5963);
  late Color info = const Color(0xFFFFFFFF);
  late Color cardDetail = const Color(0xFF211F1F);
  late Color cardMain = const Color(0xFF001294);
  late Color cardSecond = const Color(0xFFFFFFFF);
}

abstract class Typography {
  String get displayLargeFamily;
  TextStyle get displayLarge;
  String get displayMediumFamily;
  TextStyle get displayMedium;
  String get displaySmallFamily;
  TextStyle get displaySmall;
  String get headlineLargeFamily;
  TextStyle get headlineLarge;
  String get headlineMediumFamily;
  TextStyle get headlineMedium;
  String get headlineSmallFamily;
  TextStyle get headlineSmall;
  String get titleLargeFamily;
  TextStyle get titleLarge;
  String get titleMediumFamily;
  TextStyle get titleMedium;
  String get titleSmallFamily;
  TextStyle get titleSmall;
  String get labelLargeFamily;
  TextStyle get labelLarge;
  String get labelMediumFamily;
  TextStyle get labelMedium;
  String get labelSmallFamily;
  TextStyle get labelSmall;
  String get bodyLargeFamily;
  TextStyle get bodyLarge;
  String get bodyMediumFamily;
  TextStyle get bodyMedium;
  String get bodySmallFamily;
  TextStyle get bodySmall;
  String get bodyMicroFamily;
  TextStyle get bodyMicro;
}

class ThemeTypography extends Typography {
  ThemeTypography(this.theme);

  final CustomFlowTheme theme;

  String get displayLargeFamily => 'Inter';
  TextStyle get displayLarge => GoogleFonts.getFont(
        'Inter',
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 44.0,
        letterSpacing: 0,
      );
  String get displayMediumFamily => 'Inter';
  TextStyle get displayMedium => GoogleFonts.getFont(
        'Inter',
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 36.0,
        letterSpacing: 0,
      );
  String get displaySmallFamily => 'Inter';
  TextStyle get displaySmall => GoogleFonts.getFont(
        'Inter',
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 32.0,
        letterSpacing: 0,
      );
  String get headlineLargeFamily => 'Inter';
  TextStyle get headlineLarge => GoogleFonts.getFont(
        'Inter',
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 24.0,
        letterSpacing: 0,
      );
  String get headlineMediumFamily => 'Inter';
  TextStyle get headlineMedium => GoogleFonts.getFont(
        'Inter',
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 24.0,
        letterSpacing: 0,
      );
  String get headlineSmallFamily => 'Inter';
  TextStyle get headlineSmall => GoogleFonts.getFont(
        'Inter',
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 22.0,
        letterSpacing: 0,
      );
  String get titleLargeFamily => 'Inter';
  TextStyle get titleLarge => GoogleFonts.getFont(
        'Inter',
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 22.0,
        letterSpacing: 0,
      );
  String get titleMediumFamily => 'Inter';
  TextStyle get titleMedium => GoogleFonts.getFont(
        'Inter',
        color: theme.info,
        fontWeight: FontWeight.w600,
        fontSize: 18.0,
        letterSpacing: 0,
      );
  String get titleSmallFamily => 'Inter';
  TextStyle get titleSmall => GoogleFonts.getFont(
        'Inter',
        color: theme.info,
        fontWeight: FontWeight.w600,
        fontSize: 16.0,
        letterSpacing: 0,
      );
  String get labelLargeFamily => 'Inter';
  TextStyle get labelLarge => GoogleFonts.getFont(
        'Inter',
        color: theme.secondaryText,
        fontWeight: FontWeight.w500,
        fontSize: 14.0,
        letterSpacing: 0,
      );
  String get labelMediumFamily => 'Inter';
  TextStyle get labelMedium => GoogleFonts.getFont(
        'Inter',
        color: theme.secondaryText,
        fontWeight: FontWeight.w500,
        fontSize: 12.0,
        letterSpacing: 0,
      );
  String get labelSmallFamily => 'Inter';
  TextStyle get labelSmall => GoogleFonts.getFont(
        'Inter',
        color: theme.secondaryText,
        fontWeight: FontWeight.w500,
        fontSize: 11.0,
        letterSpacing: 0,
      );
  String get bodyLargeFamily => 'Inter';
  TextStyle get bodyLarge => GoogleFonts.getFont(
        'Inter',
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 16.0,
        letterSpacing: 0,
      );
  String get bodyMediumFamily => 'Inter';
  TextStyle get bodyMedium => GoogleFonts.getFont(
        'Inter',
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 14.0,
        letterSpacing: 0,
      );
  String get bodySmallFamily => 'Inter';
  TextStyle get bodySmall => GoogleFonts.getFont(
        'Inter',
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 14.0,
        letterSpacing: 0,
      );
  String get bodyMicroFamily => 'Inter';
  TextStyle get bodyMicro => GoogleFonts.getFont(
      'Inter',
      color: theme.primaryText,
      fontWeight: FontWeight.w500,
      fontSize: 8.0,
      letterSpacing: 0,
    );
}

class DarkModeTheme extends CustomFlowTheme {
  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  late Color pawColor = const Color(0xFF00BF63);
  late Color primary = const Color(0xFF448AFF);
  late Color secondary = const Color(0xFF386EC8);
  late Color tertiary = const Color(0xFF7CA3E4);
  late Color alternate = const Color(0xFF22282F);
  late Color primaryText = const Color(0xFFFFFFFF);
  late Color secondaryText = const Color(0xFF999999);
  late Color gradientBackgroundBegin = Colors.blueAccent;
  late Color gradientBackgroundEnd = Colors.black;
  late Color primaryBackground = const Color(0xFF171717);
  late Color secondaryBackground = const Color(0xFF1F1F1F);
  late Color accent1 = const Color(0x4D4495C1);
  late Color accent2 = const Color(0x4C206A6A);
  late Color accent3 = const Color(0x7FBAEEE8);
  late Color accent4 = const Color(0xB322282F);
  late Color success = const Color(0xFF04A24C);
  late Color warning = const Color(0x4DFF5963);
  late Color error = const Color(0xFFFF5963);
  late Color info = const Color(0xFFFFFFFF);
  late Color cardDetail = const Color(0xFF211F1F);
  late Color cardMain = const Color(0xFF001294);
  late Color cardSecond = const Color(0xFFFFFFFF);
}

extension TextStyleHelper on TextStyle {

  TextStyle override({
    String? fontFamily,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    FontStyle? fontStyle,
    bool useGoogleFonts = true,
    TextDecoration? decoration,
    double? lineHeight,
  }) {
    final RegExp pattern = RegExp(r'_\d+$');

    return useGoogleFonts ? GoogleFonts.getFont(
      fontFamily ?? this.fontFamily!.replaceAll(pattern, ''),
      color: color ?? this.color,
      fontSize: fontSize ?? this.fontSize,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      fontWeight: fontWeight ?? this.fontWeight,
      fontStyle: fontStyle ?? this.fontStyle,
      decoration: decoration,
      height: lineHeight,
    ) : copyWith(
      fontFamily: fontFamily,
      color: color,
      fontSize: fontSize,
      letterSpacing: letterSpacing,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      decoration: decoration,
      height: lineHeight,
    );
  }
}
