/// Aviso dentro de la app (spec 044, `NoticeResponse`). La app solo los lee.
class Aviso {
  const Aviso({
    required this.id,
    required this.tipo,
    required this.comoRol,
    required this.titulo,
    required this.texto,
    required this.leido,
    required this.creadoEn,
    this.destino,
  });

  final String id;
  final String tipo;
  final String comoRol;
  final String titulo;
  final String texto;

  /// Objeto de navegación que manda la API; su forma no está cerrada en el
  /// contrato, por eso se conserva tal cual.
  final Map<String, Object?>? destino;
  final bool leido;
  final DateTime creadoEn;

  Aviso copiaLeido() => Aviso(
    id: id,
    tipo: tipo,
    comoRol: comoRol,
    titulo: titulo,
    texto: texto,
    destino: destino,
    leido: true,
    creadoEn: creadoEn,
  );
}

/// Una página de la bandeja, más reciente primero.
class PaginaAvisos {
  const PaginaAvisos({required this.items, this.siguienteCursor});

  final List<Aviso> items;
  final String? siguienteCursor;
}

/// Contador de no leídos (tope 99): con `masDe99` se muestra «99+».
class ContadorAvisos {
  const ContadorAvisos({required this.cantidad, required this.masDe99});

  final int cantidad;
  final bool masDe99;

  String get etiqueta => masDe99 ? '99+' : '$cantidad';

  bool get hayNoLeidos => cantidad > 0 || masDe99;
}

/// Filtros de la bandeja: `leido` (null = todos) y `comoRol` (null = todos).
class FiltroAvisos {
  const FiltroAvisos({this.leido, this.comoRol});

  final bool? leido;
  final String? comoRol;

  @override
  bool operator ==(Object other) =>
      other is FiltroAvisos && other.leido == leido && other.comoRol == comoRol;

  @override
  int get hashCode => Object.hash(leido, comoRol);
}
