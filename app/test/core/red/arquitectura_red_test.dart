import 'package:flutter_test/flutter_test.dart';

import '../../soporte/codigo_fuente.dart';

const _red = 'lib/core/red/';
const _simulada = 'lib/core/red/simulada/';
const _proveedor = 'lib/core/red/cliente_api_provider.dart';

final _capaDeFeature = RegExp(r'^lib/features/[^/]+/(presentation|domain)/');
final _dataDeFeature = RegExp(r'^lib/features/[^/]+/data/');
final _http = RegExp(r'\b(HttpClient|HttpServer|Socket|WebSocket)\b');
final _tipoClienteApi = RegExp(r'\bClienteApi\b');

/// Violaciones de las reglas de capas de la red (spec TC-TT-MOB-08-10).
List<String> violacionesDeRed(List<ArchivoFuente> archivos) {
  final violaciones = <String>[];
  for (final (:ruta, :texto) in archivos) {
    final codigo = sinComentarios(texto);
    final enRed = ruta.startsWith(_red);
    final enData = _dataDeFeature.hasMatch(ruta);
    for (final importacion in importacionesDe(texto)) {
      if (enRed && importacion.contains('features/')) {
        violaciones.add('$ruta: core/red importa $importacion');
      }
      if (_capaDeFeature.hasMatch(ruta) &&
          (importacion.contains('core/red/') || importacion == 'dart:io')) {
        violaciones.add('$ruta: presentation/domain importa $importacion');
      }
      if ((enRed || enData) &&
          (importacion == 'dart:io' ||
              importacion.startsWith('package:http/') ||
              importacion.startsWith('package:dio/'))) {
        violaciones.add('$ruta: HTTP a mano con $importacion');
      }
      if (importacion.contains('core/red/simulada/') &&
          ruta != _proveedor &&
          !ruta.startsWith(_simulada)) {
        violaciones.add('$ruta: usa la simulación fuera del proveedor');
      }
    }
    if ((enRed || enData) && _http.hasMatch(codigo)) {
      violaciones.add('$ruta: HTTP a mano');
    }
    if (!enRed && !enData && _tipoClienteApi.hasMatch(codigo)) {
      violaciones.add('$ruta: usa ClienteApi fuera de data/');
    }
  }
  return violaciones;
}

void main() {
  test('TC-TT-MOB-08-10 la red respeta las capas', () {
    final archivos = archivosBajo('lib');
    final rutas = archivos.map((a) => a.ruta).toList();
    expect(rutas, contains(_proveedor));
    expect(rutas, contains('${_simulada}cliente_api_simulado.dart'));
    expect(
      rutas,
      contains('lib/features/oficios/data/oficios_repository_api.dart'),
    );

    expect(violacionesDeRed(archivos), isEmpty);

    // Las reglas detectan cada violación (no aceptan todo).
    const casos = <ArchivoFuente>[
      (
        ruta: 'lib/core/red/x.dart',
        texto: "import 'package:app/features/oficios/domain/oficio.dart';",
      ),
      (
        ruta: 'lib/features/oficios/presentation/x.dart',
        texto: "import 'package:app/core/red/cliente_api.dart';",
      ),
      (ruta: 'lib/features/oficios/domain/x.dart', texto: "import 'dart:io';"),
      (ruta: 'lib/core/red/x.dart', texto: "import 'dart:io';"),
      (ruta: 'lib/features/oficios/data/x.dart', texto: "import 'dart:io';"),
      (
        ruta: 'lib/features/oficios/data/x.dart',
        texto: "import 'package:http/http.dart';",
      ),
      (ruta: 'lib/core/red/x.dart', texto: 'final c = HttpClient();'),
      (
        ruta: 'lib/features/oficios/oficios_providers.dart',
        texto: 'ClienteApi? c;',
      ),
      (
        ruta: 'lib/main.dart',
        texto:
            "import 'package:app/core/red/simulada/cliente_api_simulado.dart';",
      ),
    ];
    for (final caso in casos) {
      expect(violacionesDeRed([caso]), hasLength(1), reason: caso.texto);
    }
    // Un comentario que menciona el tipo no es un uso.
    expect(
      violacionesDeRed(const [
        (ruta: 'lib/main.dart', texto: '// sin ClienteApi aquí'),
      ]),
      isEmpty,
    );
  });
}
