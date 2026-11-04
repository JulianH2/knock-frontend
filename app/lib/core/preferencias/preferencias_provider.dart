import 'dart:async';

import 'package:app/core/preferencias/almacen_preferencias.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Idiomas de la app. El primero (español) es el idioma fuente de los ARB y
/// el respaldo si el sistema pide uno que no está (HU-052 §8).
const List<Locale> idiomasSoportados = [Locale('es'), Locale('en')];

/// Preferencias de apariencia e idioma (inmutable).
@immutable
class Preferencias {
  const Preferencias({required this.modoTema, required this.idioma});

  /// Valor inicial: tema del sistema y español.
  static const inicial = Preferencias(
    modoTema: ThemeMode.system,
    idioma: Locale('es'),
  );

  final ThemeMode modoTema;
  final Locale idioma;

  Preferencias copyWith({ThemeMode? modoTema, Locale? idioma}) => Preferencias(
    modoTema: modoTema ?? this.modoTema,
    idioma: idioma ?? this.idioma,
  );

  @override
  bool operator ==(Object other) =>
      other is Preferencias &&
      other.modoTema == modoTema &&
      other.idioma == idioma;

  @override
  int get hashCode => Object.hash(modoTema, idioma);
}

/// Estado de tema e idioma que lee `KnockApp`.
///
/// Arranca con lo guardado en [almacenPreferenciasProvider] (lectura síncrona,
/// HU-052 spec §8 decisión 4). Al cambiar, primero se actualiza el estado y
/// luego se guarda sin esperar: lo que se ve no depende del guardado.
class PreferenciasNotifier extends Notifier<Preferencias> {
  @override
  Preferencias build() {
    final almacen = ref.read(almacenPreferenciasProvider);
    return Preferencias.inicial.copyWith(
      modoTema: almacen.leerTema(),
      idioma: almacen.leerIdioma(),
    );
  }

  void cambiarTema(ThemeMode modoTema) {
    state = state.copyWith(modoTema: modoTema);
    _guardar(() => ref.read(almacenPreferenciasProvider).guardarTema(modoTema));
  }

  /// Cambia el idioma. Solo acepta los de [idiomasSoportados].
  void cambiarIdioma(Locale idioma) {
    if (!idiomasSoportados.contains(idioma)) {
      throw ArgumentError.value(idioma, 'idioma', 'Idioma no soportado');
    }
    state = state.copyWith(idioma: idioma);
    _guardar(() => ref.read(almacenPreferenciasProvider).guardarIdioma(idioma));
  }

  /// Un fallo al guardar se ignora sin registrarlo (spec §8 decisión 5).
  void _guardar(Future<void> Function() guardado) {
    unawaited(() async {
      try {
        await guardado();
      } on Object {
        return;
      }
    }());
  }
}

final preferenciasProvider =
    NotifierProvider<PreferenciasNotifier, Preferencias>(
      PreferenciasNotifier.new,
    );
