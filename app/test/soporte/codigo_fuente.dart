import 'dart:io';

/// Un archivo de código de la app, con su ruta relativa a `app/` y con `/`.
typedef ArchivoFuente = ({String ruta, String texto});

/// Los archivos con esas extensiones bajo [carpeta] (relativa a `app/`;
/// `flutter test` corre desde ahí). Vacío si la carpeta no existe.
List<ArchivoFuente> archivosBajo(
  String carpeta, {
  Set<String> extensiones = const {'.dart'},
}) {
  final raiz = Directory(carpeta);
  if (!raiz.existsSync()) {
    return const [];
  }
  final archivos = <ArchivoFuente>[];
  for (final entidad in raiz.listSync(recursive: true)) {
    final ruta = entidad.path.replaceAll(r'\', '/');
    if (entidad is File && extensiones.any(ruta.endsWith)) {
      archivos.add((ruta: ruta, texto: entidad.readAsStringSync()));
    }
  }
  return archivos;
}

final _directivaImport = RegExp(
  r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

/// Lo que importa o exporta un archivo Dart.
List<String> importacionesDe(String texto) => _directivaImport
    .allMatches(texto)
    .map((coincidencia) => coincidencia.group(1)!)
    .toList();

/// El texto sin comentarios de línea (`//` y `///`), para buscar usos y no
/// menciones en la documentación.
String sinComentarios(String texto) => texto
    .split('\n')
    .map((linea) {
      final inicio = linea.indexOf('//');
      return inicio < 0 ? linea : linea.substring(0, inicio);
    })
    .join('\n');
