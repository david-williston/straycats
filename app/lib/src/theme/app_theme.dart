import 'package:flutter/material.dart';

/// The website's palette (assets/css/extended/theme-cat.css), as one place
/// the whole app takes its colours from.
class CatColors {
  const CatColors._();

  // Light: cream and dark coffee.
  static const lightBackground = Color(0xFFFBF6EF);
  static const lightCard = Color(0xFFFFFDF9);
  static const lightPrimary = Color(0xFF2B211B);
  static const lightContent = Color(0xFF3A2E26);
  static const lightSecondary = Color(0xFF6E5D50);
  static const lightTertiary = Color(0xFFE8DCCD);
  static const lightBorder = Color(0xFFEFE5D8);
  static const lightAccent = Color(0xFF9A4F0E);

  // Dark: night and amber.
  static const darkBackground = Color(0xFF1B1714);
  static const darkCard = Color(0xFF25201C);
  static const darkPrimary = Color(0xFFF3E9DD);
  static const darkContent = Color(0xFFE6DBCF);
  static const darkSecondary = Color(0xFFB6A594);
  static const darkTertiary = Color(0xFF3A322B);
  static const darkBorder = Color(0xFF332C26);
  static const darkAccent = Color(0xFFF2A45A);
}

const _fontFamily = 'Nunito';

/// Corner radius for cards, photos, sheets and fields (the site's 12px).
const catRadius = 12.0;

ColorScheme _scheme({
  required Brightness brightness,
  required Color background,
  required Color card,
  required Color primaryText,
  required Color secondary,
  required Color tertiary,
  required Color border,
  required Color accent,
}) {
  final dark = brightness == Brightness.dark;
  return ColorScheme(
    brightness: brightness,
    primary: accent,
    onPrimary: dark ? background : card,
    primaryContainer: tertiary,
    onPrimaryContainer: primaryText,
    secondary: secondary,
    onSecondary: dark ? background : card,
    secondaryContainer: tertiary,
    onSecondaryContainer: primaryText,
    tertiary: accent,
    onTertiary: dark ? background : card,
    tertiaryContainer: tertiary,
    onTertiaryContainer: primaryText,
    error: dark ? const Color(0xFFFF8A80) : const Color(0xFFB3261E),
    onError: dark ? const Color(0xFF1B1714) : Colors.white,
    surface: background,
    onSurface: primaryText,
    onSurfaceVariant: secondary,
    outline: secondary,
    outlineVariant: border,
    surfaceContainerLowest: card,
    surfaceContainerLow: card,
    surfaceContainer: card,
    surfaceContainerHigh: card,
    surfaceContainerHighest: tertiary,
    inverseSurface: primaryText,
    onInverseSurface: background,
    inversePrimary: accent,
    surfaceTint: Colors.transparent,
    shadow: Colors.black,
    scrim: Colors.black,
  );
}

ThemeData _build(ColorScheme scheme, Color content) {
  final text = ThemeData(
    brightness: scheme.brightness,
    fontFamily: _fontFamily,
  ).textTheme.apply(bodyColor: content, displayColor: scheme.onSurface);
  final textTheme = text.copyWith(
    titleLarge: text.titleLarge?.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w800,
    ),
    titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    titleSmall: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
    labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
  );
  final shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(catRadius),
  );
  final fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(catRadius),
    borderSide: BorderSide(color: scheme.surfaceContainerHighest, width: 1.5),
  );
  const minSize = Size(64, 48);
  return ThemeData(
    useMaterial3: true,
    brightness: scheme.brightness,
    colorScheme: scheme,
    fontFamily: _fontFamily,
    textTheme: textTheme,
    scaffoldBackgroundColor: scheme.surface,
    canvasColor: scheme.surface,
    dividerColor: scheme.outlineVariant,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w800,
      ),
    ),
    cardTheme: CardThemeData(
      color: scheme.surfaceContainerLow,
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(catRadius),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        minimumSize: minSize,
        shape: shape,
        textStyle: textTheme.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: scheme.primary,
        minimumSize: minSize,
        shape: shape,
        textStyle: textTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,
        minimumSize: minSize,
        shape: shape,
        side: BorderSide(color: scheme.surfaceContainerHighest, width: 1.5),
        textStyle: textTheme.labelLarge,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: scheme.onSurface,
        minimumSize: const Size(48, 48),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      elevation: 2,
      highlightElevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      selectedColor: scheme.primaryContainer,
      checkmarkColor: scheme.primary,
      side: BorderSide(color: scheme.surfaceContainerHighest),
      shape: const StadiumBorder(),
      labelStyle: textTheme.labelLarge?.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      border: fieldBorder,
      enabledBorder: fieldBorder,
      focusedBorder: fieldBorder.copyWith(
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      labelStyle: TextStyle(color: scheme.onSurfaceVariant),
      hintStyle: TextStyle(color: scheme.onSurfaceVariant),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: scheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: scheme.onInverseSurface,
      ),
      shape: shape,
    ),
    bannerTheme: MaterialBannerThemeData(
      backgroundColor: scheme.surfaceContainerHighest,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
      surfaceTintColor: Colors.transparent,
      dividerColor: Colors.transparent,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: scheme.primary,
      minVerticalPadding: 8,
      shape: shape,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
    radioTheme: RadioThemeData(
      fillColor: WidgetStatePropertyAll(scheme.primary),
    ),
  );
}

/// Light theme from the website's cream palette.
ThemeData lightTheme() => _build(
  _scheme(
    brightness: Brightness.light,
    background: CatColors.lightBackground,
    card: CatColors.lightCard,
    primaryText: CatColors.lightPrimary,
    secondary: CatColors.lightSecondary,
    tertiary: CatColors.lightTertiary,
    border: CatColors.lightBorder,
    accent: CatColors.lightAccent,
  ),
  CatColors.lightContent,
);

/// Dark theme from the website's night palette.
ThemeData darkTheme() => _build(
  _scheme(
    brightness: Brightness.dark,
    background: CatColors.darkBackground,
    card: CatColors.darkCard,
    primaryText: CatColors.darkPrimary,
    secondary: CatColors.darkSecondary,
    tertiary: CatColors.darkTertiary,
    border: CatColors.darkBorder,
    accent: CatColors.darkAccent,
  ),
  CatColors.darkContent,
);
