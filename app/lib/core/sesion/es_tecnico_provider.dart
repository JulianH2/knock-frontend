import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Indica si la cuenta tiene el rol de técnico (gana la pestaña Trabajo).
///
/// Empieza en falso: por defecto la cuenta es de cliente
/// (FUNCIONES_Y_FLUJOS §2). Vive solo en memoria. Es un indicador de
/// interfaz, **no** un control de seguridad: la autorización real la hará la
/// API. Se reemplaza por el rol de la sesión real en la historia de sesión
/// (TT-MOB-01, spec §8 decisión 1).
class EsTecnicoNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// Cambia el indicador. Solo lo usa el interruptor de prueba de Mi cuenta.
  void cambiar({required bool esTecnico}) => state = esTecnico;
}

final esTecnicoProvider = NotifierProvider<EsTecnicoNotifier, bool>(
  EsTecnicoNotifier.new,
);

/// Si Mi cuenta muestra el interruptor «Modo técnico (prueba)».
///
/// Solo fuera de release: no llega a una compilación de tienda (spec §8
/// decisión 1). Es un provider para que las pruebas cubran el caso release.
final interruptorDePruebaProvider = Provider<bool>((ref) => !kReleaseMode);
