# plan.md — TT-PRU-02 Pantalla Flutter que lista los oficios

## 1. Mapeo de archivos
- **Reutilizar (buscado con `codemap.py --query "oficios"`, sin coincidencias; volver a buscar antes de implementar):** `core/widgets/pantalla_titulada.dart` (barra superior y cuerpo), `core/router/app_router.dart` y `core/router/rutas.dart` (se agrega una ruta hija), `flutter_riverpod` y `go_router` ya declarados en `app/pubspec.yaml`.
- **Crear (`app/lib/`):**
  - `core/errores/failure.dart` — `Failure` tipado mínimo (duda 3).
  - `features/oficios/domain/oficio.dart` y `modalidad.dart` — entidad y tipo de modalidad en Dart puro.
  - `features/oficios/domain/oficios_repository.dart` — interfaz `OficiosRepository`.
  - `features/oficios/data/oficio_mapper.dart` — mapeador del contrato (`Map` → `Oficio`, rechaza lo mal formado con `Failure`).
  - `features/oficios/data/oficios_repository_de_prueba.dart` — los 3 oficios del contrato, pasando por el mapeador.
  - `features/oficios/presentation/oficios_screen.dart` y `oficios_controller.dart` (Notifier asíncrono con estado inmutable) y el proveedor del repositorio.
  - Una ruta `Rutas.oficios` (`/explorar/oficios`) y su `GoRoute` hijo de la rama Explorar; un acceso mínimo en `explorar_screen.dart` (duda 2).
- **Crear (`app/test/`):** `features/oficios/presentation/oficios_screen_test.dart`, `features/oficios/domain/modalidad_test.dart`, `features/oficios/data/oficio_mapper_test.dart`, `features/oficios/arquitectura_test.dart` y `core/router/rutas_oficios_test.dart`.
- **Modificar:** `app/lib/core/router/app_router.dart`, `app/lib/core/router/rutas.dart`, `app/lib/features/explorar/presentation/explorar_screen.dart` (solo el acceso temporal) y `Memoria.md` al terminar.
- **No tocar:** `app/pubspec.yaml` y `app/pubspec.lock` (sin dependencias nuevas, caso 11), `contracts/`, `app/packages/knock_api/`, `.github/`, `scripts/`, la constitución y las pruebas existentes de TT-MOB-01 (deben seguir en verde sin cambios).

## 2. Riesgos y efectos secundarios
- **No se puede correr Flutter local:** el equipo de la persona tiene Flutter 3.29.0 y el proyecto pide 3.47.7; el resultado real viene del CI. Actualizar el SDK antes de implementar si es posible (duda 4).
- **TT-PRU-01 (PR #31) aún no está fusionado:** el contrato es el de su spec Aprobada; si cambia antes de fusionarse (p. ej. `cache`), el mapeador y el ejemplo se ajustan.
- **Tocar `explorar_screen.dart`** es el único cambio fuera de la feature; es un acceso temporal y no debe romper las pruebas de la barra (caso 10).
- **Cliente HTTP futuro (TT-MOB-03) o API simulada:** al llegar, solo cambia `OficiosRepositoryDePrueba`; no se debe filtrar HTTP a `presentation/` ni al dominio (caso 08).
- Textos literales en español: se migran a ARB en TT-MOB-02.

## 3. Pruebas por caso
| Caso | Prueba | Suite |
|---|---|---|
| TC-TT-PRU-02-01 | Los 3 oficios en el orden del contrato; sin carga, error ni vacío | `app/test/features/oficios/presentation/oficios_screen_test.dart` |
| TC-TT-PRU-02-02 | Ícono y texto por modalidad con etiqueta semántica | `oficios_screen_test.dart` |
| TC-TT-PRU-02-03 | Carga con `Completer` y luego lista | `oficios_screen_test.dart` |
| TC-TT-PRU-02-04 | Error genérico, Reintentar vuelve a pedir, área ≥ 48 dp | `oficios_screen_test.dart` |
| TC-TT-PRU-02-05 | Lista vacía distinta del error | `oficios_screen_test.dart` |
| TC-TT-PRU-02-06 | Modalidad desconocida con ícono genérico | `app/test/features/oficios/domain/modalidad_test.dart` y `oficios_screen_test.dart` |
| TC-TT-PRU-02-07 | Mapeador del contrato y rechazo de lo mal formado | `app/test/features/oficios/data/oficio_mapper_test.dart` |
| TC-TT-PRU-02-08 | Capas de la feature | `app/test/features/oficios/arquitectura_test.dart` |
| TC-TT-PRU-02-09 | Texto al 200 % sin desbordes | `oficios_screen_test.dart` |
| TC-TT-PRU-02-10 | La ruta cuelga de Explorar y la barra no cambia | `app/test/core/router/rutas_oficios_test.dart` |
| TC-TT-PRU-02-11 | Sin dependencias nuevas ni datos reales (comando) | `git diff --stat` y `grep` (salida en el PR) |
| TC-TT-PRU-02-12 | Formato, análisis y pruebas (comando) | CI de la app |

## 4. Secuencia
1. Con la spec Aprobada por una persona distinta del autor (el líder o Alexis), crear el `Failure`, el dominio y la interfaz del repositorio, con sus pruebas unitarias (casos 06, 07 y 08).
2. Crear el mapeador y el repositorio con datos de prueba (caso 07).
3. Crear el controlador y la pantalla con los cuatro estados y sus pruebas de widget (casos 01 a 06 y 09).
4. Agregar la ruta y el acceso desde Explorar y su prueba (caso 10).
5. Verificar que `pubspec` no cambió y que no hay datos reales (caso 11); correr formato, análisis y pruebas (caso 12) y registrar el resultado real del CI.
6. `Memoria.md`, informe en el PR con «Uso de IA», captura de la pantalla y la nota de cuánto tardó y qué fue difícil (ficha §5).

## 5. Verificación (comandos exactos)
```bash
cd app && flutter pub get
cd app && dart format --set-exit-if-changed lib test
cd app && flutter analyze --fatal-infos
cd app && flutter test --coverage
git diff --stat origin/sprint-01 -- app/pubspec.yaml app/pubspec.lock
grep -rEn "http|dio|Dio|Uri\.parse|api\." app/lib/features/oficios
python scripts/sdd_lint.py
python scripts/sdd_lint.py --trace TT-PRU-02
python scripts/codemap.py --check
python scripts/ci/check_exceptions.py
python scripts/sync_agents.py --check
```
