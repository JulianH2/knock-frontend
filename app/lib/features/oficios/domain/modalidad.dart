/// Cómo se presta un oficio. El contrato de la API la declara como cadena con
/// valores conocidos (`domicilio` y `taller`), no como enum cerrado: una
/// modalidad nueva no debe romper la app, por eso se conserva el texto recibido.
final class Modalidad {
  const Modalidad._(this.valor);

  /// Cualquier texto del contrato; los conocidos usan [domicilio] y [taller].
  factory Modalidad.desdeTexto(String valor) => switch (valor) {
    'domicilio' => domicilio,
    'taller' => taller,
    _ => Modalidad._(valor),
  };

  static const domicilio = Modalidad._('domicilio');
  static const taller = Modalidad._('taller');

  /// Texto tal como llegó en el contrato.
  final String valor;

  bool get esDomicilio => this == domicilio;

  bool get esTaller => this == taller;

  /// Si es una de las modalidades que el contrato lista hoy.
  bool get esConocida => esDomicilio || esTaller;

  @override
  bool operator ==(Object other) => other is Modalidad && other.valor == valor;

  @override
  int get hashCode => valor.hashCode;
}
