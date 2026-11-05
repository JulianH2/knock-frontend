import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Indica si la persona ya pasó por las pantallas de entrada (HU-001).
///
/// **Diseño temporal:** empieza en falso, vive solo en memoria (al cerrar la
/// app se vuelve a pedir la entrada) y **no** es un control de seguridad: no
/// hay Firebase ni API todavía, así que cualquier código de 6 dígitos «entra».
/// Se reemplaza por la sesión real (Firebase + `POST /auth/firebase` + tokens
/// en almacenamiento seguro) cuando la HU-001 completa llegue con TT-MOB-03
/// (spec HU-001 §5 y §6).
class SesionNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// Marca la sesión como iniciada; el router lleva a Inicio.
  void iniciar() => state = true;
}

final sesionIniciadaProvider = NotifierProvider<SesionNotifier, bool>(
  SesionNotifier.new,
);
