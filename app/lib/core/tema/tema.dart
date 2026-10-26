import 'package:app/core/tema/colores.dart';
import 'package:flutter/material.dart';

/// Familia tipográfica de la maqueta, empaquetada en `assets/fonts/nunito/`.
const String familiaTipografica = 'Nunito';

/// Tema claro de Knock (Material 3, paleta de la maqueta).
final ThemeData temaClaro = _construirTema(esquemaClaro);

/// Tema oscuro de Knock (Material 3, paleta de la maqueta).
final ThemeData temaOscuro = _construirTema(esquemaOscuro);

ThemeData _construirTema(ColorScheme esquema) {
  final claro = esquema.brightness == Brightness.light;
  // En claro el naranja (`primary`) no sirve como color de texto sobre crema
  // ni blanco (2.98 y 3.24:1): los botones sin relleno usan `amber-ink`.
  final textoDeAccion = claro ? ColoresClaro.amberInk : esquema.primary;
  final estiloSinRelleno = ButtonStyle(
    foregroundColor: WidgetStateProperty.resolveWith(
      (estados) => estados.contains(WidgetState.disabled)
          ? esquema.onSurface.withValues(alpha: 0.38)
          : textoDeAccion,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: esquema,
    brightness: esquema.brightness,
    scaffoldBackgroundColor: esquema.surface,
    fontFamily: familiaTipografica,
    textButtonTheme: TextButtonThemeData(style: estiloSinRelleno),
    outlinedButtonTheme: OutlinedButtonThemeData(style: estiloSinRelleno),
    elevatedButtonTheme: ElevatedButtonThemeData(style: estiloSinRelleno),
    // Botón relleno: naranja con texto tinta (5.27:1). En claro el naranja
    // contra crema da 2.98:1, por debajo del 3:1 que pide WCAG 1.4.11 para el
    // contorno de un componente: se delimita con un borde de tinta sin
    // cambiar el color del botón.
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        side: claro ? const BorderSide(color: ColoresClaro.ink) : null,
      ),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (estados) => estados.contains(WidgetState.selected)
            ? textoDeAccion
            : esquema.onSurfaceVariant,
      ),
    ),
  );
}
