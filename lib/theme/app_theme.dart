import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom color palette for the app
extension AppColors on ColorScheme {
  // Primary colors
  Color get primaryLight => const Color(0xFFFFF9C4);
  Color get primaryDark => const Color(0xFFFFD54F);

  // Secondary colors
  Color get secondaryLight => const Color(0xFFE3F2FD);
  Color get secondaryDark => const Color(0xFF90CAF9);

  // Background colors
  Color get backgroundLight => const Color(0xFFFAFAFA);
  Color get backgroundDark => const Color(0xFF121212);

  // Surface colors
  Color get surfaceLight => Colors.white;
  Color get surfaceDark => const Color(0xFF1E1E1E);

  // Error and success colors
  Color get errorLight => const Color(0xFFE53935);
  Color get errorDark => const Color(0xFFEF9A9A);
  Color get successLight => const Color(0xFF4CAF50);
  Color get successDark => const Color(0xFF81C784);

  // Text colors
  Color get textPrimaryLight => const Color(0xFF212121);
  Color get textSecondaryLight => const Color(0xFF757575);
  Color get textPrimaryDark => Colors.white;
  Color get textSecondaryDark => const Color(0xFFB0BEC5);
}

/// Custom text styles for the app
class AppTextStyles {
  static TextStyle get displayLarge => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static TextStyle get displayMedium => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
  );

  static TextStyle get titleLarge => GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  static TextStyle get titleMedium => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  );

  static TextStyle get bodyLarge => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
  );

  static TextStyle get labelLarge => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  static TextStyle get labelSmall => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );
}

/// Custom theme extensions
class AppThemeExtensions extends ThemeExtension<AppThemeExtensions> {
  final double cardBorderRadius;
  final double buttonBorderRadius;
  final double inputBorderRadius;
  final double defaultPadding;
  final double defaultMargin;

  const AppThemeExtensions({
    required this.cardBorderRadius,
    required this.buttonBorderRadius,
    required this.inputBorderRadius,
    required this.defaultPadding,
    required this.defaultMargin,
  });

  @override
  ThemeExtension<AppThemeExtensions> copyWith({
    double? cardBorderRadius,
    double? buttonBorderRadius,
    double? inputBorderRadius,
    double? defaultPadding,
    double? defaultMargin,
  }) {
    return AppThemeExtensions(
      cardBorderRadius: cardBorderRadius ?? this.cardBorderRadius,
      buttonBorderRadius: buttonBorderRadius ?? this.buttonBorderRadius,
      inputBorderRadius: inputBorderRadius ?? this.inputBorderRadius,
      defaultPadding: defaultPadding ?? this.defaultPadding,
      defaultMargin: defaultMargin ?? this.defaultMargin,
    );
  }

  @override
  ThemeExtension<AppThemeExtensions> lerp(
      covariant ThemeExtension<AppThemeExtensions>? other,
      double t,
      ) {
    if (other is! AppThemeExtensions) {
      return this;
    }

    return AppThemeExtensions(
      cardBorderRadius: lerpDouble(cardBorderRadius, other.cardBorderRadius, t)!,
      buttonBorderRadius: lerpDouble(buttonBorderRadius, other.buttonBorderRadius, t)!,
      inputBorderRadius: lerpDouble(inputBorderRadius, other.inputBorderRadius, t)!,
      defaultPadding: lerpDouble(defaultPadding, other.defaultPadding, t)!,
      defaultMargin: lerpDouble(defaultMargin, other.defaultMargin, t)!,
    );
  }
}

/// Custom theme data for the app
class AppThemeData {
  static const double _cardBorderRadius = 12.0;
  static const double _buttonBorderRadius = 8.0;
  static const double _inputBorderRadius = 8.0;
  static const double _defaultPadding = 16.0;
  static const double _defaultMargin = 16.0;

  static AppThemeExtensions get _themeExtensions => const AppThemeExtensions(
    cardBorderRadius: _cardBorderRadius,
    buttonBorderRadius: _buttonBorderRadius,
    inputBorderRadius: _inputBorderRadius,
    defaultPadding: _defaultPadding,
    defaultMargin: _defaultMargin,
  );

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme.light(
      primary: Color(0xFFFFC107),
      primaryContainer: Color(0xFFFFECB3),
      onPrimary: Colors.black87,
      secondary: Color(0xFF2196F3),
      secondaryContainer: Color(0xFFBBDEFB),
      onSecondary: Colors.white,
      background: Color(0xFFFAFAFA),
      onBackground: Color(0xFF212121),
      surface: Colors.white,
      onSurface: Color(0xFF212121),
      error: Color(0xFFE53935),
      onError: Colors.white,
      brightness: Brightness.light,
      surfaceVariant: Color(0xFFEEEEEE),
      onSurfaceVariant: Color(0xFF757575),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      extensions: <ThemeExtension<dynamic>>[
        _themeExtensions,
      ],
      textTheme: GoogleFonts.poppinsTextTheme(TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: colorScheme.onBackground),
        displayMedium: AppTextStyles.displayMedium.copyWith(color: colorScheme.onBackground),
        titleLarge: AppTextStyles.titleLarge.copyWith(color: colorScheme.onBackground),
        titleMedium: AppTextStyles.titleMedium.copyWith(color: colorScheme.onBackground),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: colorScheme.onSurfaceVariant),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant),
        labelLarge: AppTextStyles.labelLarge.copyWith(color: colorScheme.onSurfaceVariant),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: colorScheme.onSurfaceVariant),
      )),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: colorScheme.onPrimary,
        ),
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardBorderRadius),
        ),
        color: colorScheme.surface,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonBorderRadius),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSecondary,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.secondary,
          side: BorderSide(color: colorScheme.secondary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonBorderRadius),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.secondary,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.secondary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.secondary,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputBorderRadius),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputBorderRadius),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputBorderRadius),
          borderSide: BorderSide(color: colorScheme.secondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputBorderRadius),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputBorderRadius),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: colorScheme.onSurfaceVariant,
        ),
        hintStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: colorScheme.onSurfaceVariant.withOpacity(0.6),
        ),
        errorStyle: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: colorScheme.error,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme.dark(
      primary: Color(0xFFFFD54F),
      primaryContainer: Color(0xFFFFA000),
      onPrimary: Colors.black87,
      secondary: Color(0xFF64B5F6),
      secondaryContainer: Color(0xFF1976D2),
      onSecondary: Colors.black87,
      surface: Color(0xFF1E1E1E),
      onSurface: Colors.white,
      error: Color(0xFFCF6679),
      onError: Colors.black87,
      brightness: Brightness.dark,
      surfaceContainerHighest: Color(0xFF2D2D2D),
      onSurfaceVariant: Color(0xFFB0B0B0),
    );

    final lightTheme = AppThemeData.lightTheme;

    return lightTheme.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: GoogleFonts.poppinsTextTheme(TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: colorScheme.onBackground),
        displayMedium: AppTextStyles.displayMedium.copyWith(color: colorScheme.onBackground),
        titleLarge: AppTextStyles.titleLarge.copyWith(color: colorScheme.onBackground),
        titleMedium: AppTextStyles.titleMedium.copyWith(color: colorScheme.onBackground),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: colorScheme.onSurfaceVariant),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant),
        labelLarge: AppTextStyles.labelLarge.copyWith(color: colorScheme.onSurfaceVariant),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: colorScheme.onSurfaceVariant),
      ),),
      appBarTheme: lightTheme.appBarTheme.copyWith(
        backgroundColor: colorScheme.onSecondary,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      cardTheme: lightTheme.cardTheme.copyWith(
        color: colorScheme.surface,
        shadowColor: Colors.black.withOpacity(0.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: lightTheme.elevatedButtonTheme.style?.copyWith(
          backgroundColor: WidgetStateProperty.all<Color>(colorScheme.secondary),
          foregroundColor: WidgetStateProperty.all<Color>(colorScheme.onSecondary),
          textStyle: WidgetStateProperty.all<TextStyle>(
            GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSecondary,
            ),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: lightTheme.outlinedButtonTheme.style?.copyWith(
          foregroundColor: WidgetStateProperty.all<Color>(colorScheme.secondary),
          side: WidgetStateProperty.all<BorderSide>(
            BorderSide(color: colorScheme.secondary),
          ),
          textStyle: WidgetStateProperty.all<TextStyle>(
            GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.secondary,
            ),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: lightTheme.textButtonTheme.style?.copyWith(
          foregroundColor: WidgetStateProperty.all<Color>(colorScheme.secondary),
          textStyle: WidgetStateProperty.all<TextStyle>(
            GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.secondary,
            ),
          ),
        ),
      ),
      inputDecorationTheme: lightTheme.inputDecorationTheme.copyWith(
        fillColor: colorScheme.surface,
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: colorScheme.onSurfaceVariant,
        ),
        hintStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: colorScheme.onSurfaceVariant.withOpacity(0.6),
        ),
      ),
    );
  }
}

class AppTheme {
  static ThemeData get lightTheme => AppThemeData.lightTheme;
  static ThemeData get darkTheme => AppThemeData.darkTheme;
}
