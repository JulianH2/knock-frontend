import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// Contraste mínimo WCAG 2.x (AA) para texto normal.
const double contrasteMinimoTexto = 4.5;

/// Contraste mínimo WCAG 2.x (AA) para bordes y componentes (1.4.11).
const double contrasteMinimoComponente = 3;

/// Relación de contraste WCAG 2.x entre dos colores opacos:
/// `(L1 + 0.05) / (L2 + 0.05)`, con L1 la luminancia relativa mayor.
///
/// Va de 1 (mismo color) a 21 (blanco y negro). La luminancia relativa es la
/// de [Color.computeLuminance] (fórmula sRGB de WCAG).
double relacionDeContraste(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}
