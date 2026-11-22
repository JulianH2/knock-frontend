import 'package:app/core/errores/failure.dart';
import 'package:app/features/avisos/domain/aviso.dart';
import 'package:app/features/avisos/domain/avisos_repository.dart';
import 'package:app/features/avisos/domain/preferencias_avisos.dart';

/// Avisos ficticios en memoria, con el comportamiento del contrato (cursor,
/// filtros, tope 99). Se usa hasta que exista el cliente HTTP; `falla` simula
/// un error de la API en toda llamada.
class AvisosRepositoryDePrueba implements AvisosRepository {
  AvisosRepositoryDePrueba({List<Aviso>? avisos, this.falla})
    : _avisos = [...avisos ?? _ficticios];

  final List<Aviso> _avisos;
  final Failure? falla;

  void _revisar() {
    final error = falla;
    if (error != null) {
      throw error;
    }
  }

  @override
  Future<PaginaAvisos> listar({
    String? cursor,
    int limite = 20,
    FiltroAvisos filtro = const FiltroAvisos(),
  }) async {
    _revisar();
    final filtrados = [
      for (final a in _avisos)
        if ((filtro.leido == null || a.leido == filtro.leido) &&
            (filtro.comoRol == null || a.comoRol == filtro.comoRol))
          a,
    ];
    final inicio = (int.tryParse(cursor ?? '0') ?? 0).clamp(
      0,
      filtrados.length,
    );
    final fin = (inicio + limite).clamp(0, filtrados.length);
    return PaginaAvisos(
      items: filtrados.sublist(inicio, fin),
      siguienteCursor: fin < filtrados.length ? '$fin' : null,
    );
  }

  @override
  Future<ContadorAvisos> contador() async {
    _revisar();
    final noLeidos = _avisos.where((a) => !a.leido).length;
    return ContadorAvisos(
      cantidad: noLeidos > 99 ? 99 : noLeidos,
      masDe99: noLeidos > 99,
    );
  }

  @override
  Future<void> marcarLeido(String id) async {
    _revisar();
    final indice = _avisos.indexWhere((a) => a.id == id);
    if (indice >= 0) {
      _avisos[indice] = _avisos[indice].copiaLeido();
    }
  }

  @override
  Future<void> marcarTodosLeidos() async {
    _revisar();
    for (var i = 0; i < _avisos.length; i++) {
      _avisos[i] = _avisos[i].copiaLeido();
    }
  }
}

final _ficticios = [
  Aviso(
    id: 'a1',
    tipo: 'visita',
    comoRol: 'cliente',
    titulo: 'Tu visita fue confirmada',
    texto: 'Ana Prueba confirmó la visita de mañana.',
    leido: false,
    creadoEn: DateTime.utc(2026, 11, 20, 15),
  ),
  Aviso(
    id: 'a2',
    tipo: 'seguridad',
    comoRol: 'cliente',
    titulo: 'Recuerda tu código de visita',
    texto: 'Comparte el código solo cuando llegue el técnico.',
    leido: true,
    creadoEn: DateTime.utc(2026, 11, 19, 9),
  ),
];

/// Preferencias ficticias: todo activo salvo promociones; seguridad fija.
class PreferenciasAvisosRepositoryDePrueba
    implements PreferenciasAvisosRepository {
  const PreferenciasAvisosRepositoryDePrueba({this.falla});

  final Failure? falla;

  @override
  Future<List<PreferenciaAviso>> obtener() async {
    final error = falla;
    if (error != null) {
      throw error;
    }
    return const [
      PreferenciaAviso(tipo: 'seguridad', activo: true, apagable: false),
      PreferenciaAviso(tipo: 'visita', activo: true, apagable: true),
      PreferenciaAviso(tipo: 'mensaje', activo: true, apagable: true),
      PreferenciaAviso(tipo: 'promocion', activo: false, apagable: true),
    ];
  }
}
