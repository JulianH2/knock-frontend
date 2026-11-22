import 'package:app/core/errores/failure.dart';
import 'package:app/core/widgets/estados.dart';

/// Códigos de dominio de las acciones de visita (contrato de `/llegada` y
/// reglas de VIS-xx) con su texto para la persona.
const _porCodigo = {
  'wrong_code': 'El código no es correcto. Revísalo e inténtalo de nuevo.',
  'visit_locked': 'La visita quedó bloqueada por demasiados intentos.',
  'outside_window':
      'Todavía no es la hora de la visita o ya pasó el tiempo para esta '
      'acción.',
  'code_used': 'Ese código ya se usó.',
  'code_expired': 'El código venció.',
  'visit_cancelled': 'La visita está cancelada.',
  'visit_not_active': 'La visita no está en curso.',
  'visit_without_code': 'Esta visita no usa código.',
};

/// Texto para el error de una acción de visita. Una regla de negocio (409/422)
/// dice por qué la visita no permite la acción cuando el código es conocido;
/// una ruta que aún no existe en el gateway no es un fallo de la app.
String mensajeDeErrorVisita(Object error) => switch (error) {
  ReglaDeNegocioFailure(:final codigo) when _porCodigo[codigo] != null =>
    _porCodigo[codigo]!,
  ReglaDeNegocioFailure() => 'La visita ya no permite esta acción.',
  DatosInvalidosFailure() => 'Revisa los datos e intenta de nuevo.',
  _ => mensajeDeError(error, porDefecto: 'No pudimos completar la acción.'),
};
