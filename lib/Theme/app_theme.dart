import 'package:flutter/material.dart';
import 'package:ruitoque/constans.dart';

/// Tema de la app: los colores de la marca (verde y morado) aplicados a todos los
/// componentes de Material. Lo que una pantalla fije explícitamente sigue mandando;
/// esto define cómo se ve todo lo demás.
class AppTheme {
  AppTheme._();

  static const _fuente = 'RobotoCondensed';
  static const _radio = 14.0;
  static const _radioDialogo = 20.0;

  /// Fondo oscuro de SnackBars y avisos: verde casi negro de la marca.
  static const _fondoOscuro = Color(0xFF1B2623);

  static ThemeData claro() {
    final esquema = ColorScheme.fromSeed(
      seedColor: kPprimaryColor,
      primary: kPprimaryColor,
      onPrimary: Colors.white,
      secondary: kPcontrastMoradoColor,
      onSecondary: Colors.white,
      tertiary: kPOcre,
      onTertiary: Colors.white,
    );

    const forma = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(_radio)));
    const textoBoton = TextStyle(fontFamily: _fuente, fontSize: 16, fontWeight: FontWeight.w700);
    const tamanoMinimo = Size(64, 48);

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      fontFamily: _fuente,

      appBarTheme: const AppBarTheme(
        backgroundColor: kPprimaryColor,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 2,
        titleTextStyle: TextStyle(
          fontFamily: _fuente,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled) ? esquema.onSurface.withValues(alpha: 0.12) : kPprimaryColor,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled) ? esquema.onSurface.withValues(alpha: 0.38) : Colors.white,
          ),
          overlayColor: WidgetStatePropertyAll(Colors.white.withValues(alpha: 0.12)),
          elevation: const WidgetStatePropertyAll(0),
          minimumSize: const WidgetStatePropertyAll(tamanoMinimo),
          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20)),
          shape: const WidgetStatePropertyAll(forma),
          textStyle: const WidgetStatePropertyAll(textoBoton),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: tamanoMinimo,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: forma,
          textStyle: textoBoton,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: kPprimaryColor,
          side: const BorderSide(color: kPprimaryColor, width: 1.5),
          minimumSize: tamanoMinimo,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: forma,
          textStyle: textoBoton,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: kPprimaryColor,
          minimumSize: const Size(48, 44),
          shape: forma,
          textStyle: textoBoton.copyWith(fontSize: 15),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: kPprimaryColor,
        foregroundColor: Colors.white,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(_radioDialogo))),
        titleTextStyle: TextStyle(
          fontFamily: _fuente,
          fontSize: 21,
          fontWeight: FontWeight.w700,
          color: esquema.onSurface,
        ),
        contentTextStyle: TextStyle(
          fontFamily: _fuente,
          fontSize: 16,
          height: 1.35,
          color: esquema.onSurfaceVariant,
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(_radioDialogo))),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _fondoOscuro,
        actionTextColor: kPverdeMasClaro,
        contentTextStyle: const TextStyle(fontFamily: _fuente, fontSize: 15, color: Colors.white),
        shape: forma,
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radio),
          borderSide: BorderSide(color: esquema.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radio),
          borderSide: BorderSide(color: esquema.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radio),
          borderSide: const BorderSide(color: kPprimaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radio),
          borderSide: BorderSide(color: esquema.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radio),
          borderSide: BorderSide(color: esquema.error, width: 2),
        ),
      ),

      cardTheme: const CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(color: kPprimaryColor),

      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        labelStyle: const TextStyle(fontFamily: _fuente, fontWeight: FontWeight.w600),
        side: BorderSide(color: esquema.outlineVariant),
      ),
    );
  }
}
