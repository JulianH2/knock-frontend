# plan.md — TT-MOB-08 API simulada desde el contrato para la app

## 1. Mapeo de archivos
- **Reutilizar (buscado con `codemap.py --query "red cliente api http"`, sin coincidencias; volver a buscar antes de implementar):** `core/errores/failure.dart` (`Failure` sellado), `features/oficios/data/oficio_mapper.dart` (`OficioMapper.listaDesdeContrato`), `features/oficios/oficios_providers.dart` (raíz de composición), el controlador y la pantalla de oficios sin cambios, `flutter_riverpod` ya declarado.
- **Crear (`app/lib/`):**
  - `core/red/cliente_api.dart` — interfaz `ClienteApi`, `PeticionApi`, `RespuestaApi`, `ErrorDeRedApi` y `ErrorDeConfiguracionApi`.
  - `core/red/configuracion_api.dart` — `ConfiguracionApi` (lee `KNOCK_API_URL` y `KNOCK_API_ESCENARIO`; recibe `esRelease` para poder probarlo).
  - `core/red/cliente_api_provider.dart` — `configuracionApiProvider` y `clienteApiProvider` (punto de inyección para TT-MOB-03; en modo real lanza `ErrorDeConfiguracionApi`).
  - `core/red/simulada/cliente_api_simulado.dart` y `core/red/simulada/respuestas_simuladas.dart` — simulación en memoria con escenarios.
  - `features/oficios/data/oficios_repository_api.dart` — `OficiosRepositoryApi`.
- **Crear (`app/test/`):** `contrato/contrato_s4.json`, `contrato/mocks_vs_contrato_test.dart`, `core/red/configuracion_api_test.dart`, `core/red/simulada/cliente_api_simulado_test.dart`, `core/red/arquitectura_red_test.dart`, `core/red/privacidad_red_test.dart`, `features/oficios/data/oficios_repository_api_test.dart` y `features/oficios/presentation/oficios_api_simulada_test.dart`.
- **Modificar:** `main.dart` (comprobar la configuración antes de `runApp`), `core/errores/failure.dart` (agregar `SolicitudRechazadaFailure`, D7), `features/oficios/oficios_providers.dart` (usar `OficiosRepositoryApi`), `docs/architecture/*` (regenerar con `python scripts/codemap.py`) y `Memoria.md`.
- **No tocar:** `app/pubspec.yaml` y `app/pubspec.lock`, `app/android/`, `contracts/`, `app/packages/`, `.github/`, `scripts/`, la constitución, `OficiosRepositoryDePrueba` y las pruebas existentes de TT-PRU-02 y TT-MOB-01.

## 2. Riesgos y efectos secundarios
- **Principio 4 (HTTP a mano):** no se escribe ninguna llamada HTTP (D2); el modo real falla de forma explícita hasta TT-MOB-03 y nunca cae a la simulación.
- **Cambiar el proveedor de oficios** hace que la app use la red simulada por defecto: las pruebas de TT-PRU-02 sobreescriben el repositorio y no deben cambiar; correrlas todas.
- **Contratos citados** (fusionados en `origin/sprint-02` con los PR #31 y #82 del backend): si su §4 cambia, actualizar la tabla y el commit de origen.
- **Relación con TT-MOB-03** (misma persona, mismo sprint): esta tarea deja `clienteApiProvider` y la simulación; TT-MOB-03 conecta ahí el cliente real, sin una segunda capa de red, y recibe la prueba de cambio de URL.
- **Subtipo nuevo de `Failure` sellado:** revisar que no haya `switch` exhaustivos que dejen de compilar (hoy la pantalla trata el error de forma genérica).

## 3. Pruebas por caso
| Caso | Prueba | Suite |
|---|---|---|
| TC-TT-MOB-08-01 | Modo y URL desde `dart-define`; URL no permitida → error | `app/test/core/red/configuracion_api_test.dart` |
| TC-TT-MOB-08-02 | Release nunca usa la simulación; modo real sin cliente falla de forma explícita | `configuracion_api_test.dart` |
| TC-TT-MOB-08-03 | GET oficios simulado igual al ejemplo de la §4; 404 en rutas no simuladas | `app/test/core/red/simulada/cliente_api_simulado_test.dart` |
| TC-TT-MOB-08-04 | Escenarios vacío, 5xx, sin conexión y lento | `cliente_api_simulado_test.dart` |
| TC-TT-MOB-08-05 | Canje de Firebase simulado: 200, 400, 401, 413 | `cliente_api_simulado_test.dart` |
| TC-TT-MOB-08-06 | Colonia por punto simulada: 200 (dos formas), 401, 422, 429, `no-store` | `cliente_api_simulado_test.dart` |
| TC-TT-MOB-08-07 | Mocks contra la tabla de la §4, en las dos direcciones, y mocks alterados rechazados | `app/test/contrato/mocks_vs_contrato_test.dart` |
| TC-TT-MOB-08-08 | Repositorio de oficios: entidades por el mapeador y `Failure` por estado | `app/test/features/oficios/data/oficios_repository_api_test.dart` |
| TC-TT-MOB-08-09 | `KnockApp` con proveedores por defecto: datos, error con Reintentar y vacío | `app/test/features/oficios/presentation/oficios_api_simulada_test.dart` |
| TC-TT-MOB-08-10 | Capas de `core/red` | `app/test/core/red/arquitectura_red_test.dart` |
| TC-TT-MOB-08-11 | Sin registros ni datos expuestos; mocks ficticios | `app/test/core/red/privacidad_red_test.dart` |
| TC-TT-MOB-08-12 | `pubspec` sin cambios y sin URL real (comando) | `git diff --stat` y `grep` (salida en el PR) |
| TC-TT-MOB-08-13 | Formato, análisis, pruebas y build (comando) | CI de la app |

## 4. Secuencia
1. Con la spec Aprobada por una persona distinta del autor, crear `ClienteApi`, `ConfiguracionApi` y el proveedor, comprobar la configuración en `main.dart`, con sus pruebas (casos 01, 02 y 10).
2. Crear la simulación y sus respuestas ficticias (casos 03 a 06), la tabla `contrato_s4.json` copiando la §4 de cada spec con su commit, y la prueba de contrato (caso 07); comprobar a mano que falla con un mock alterado.
3. Agregar `SolicitudRechazadaFailure`, crear `OficiosRepositoryApi` y cambiar `oficios_providers.dart` (caso 08).
4. Prueba de la app completa contra la simulación (caso 09) y pruebas de privacidad (caso 11); correr todas las pruebas de TT-PRU-02 y TT-MOB-01 sin cambios.
5. Casos 12 y 13 (comandos), regenerar `docs/architecture`, captura de la pantalla de oficios en el emulador con los escenarios `normal` y `error_servidor`, `Memoria.md` e informe en el PR con «Uso de IA».

## 5. Verificación (comandos exactos)
```bash
cd app && flutter pub get --enforce-lockfile
cd app && dart format --set-exit-if-changed lib test
cd app && flutter analyze --fatal-infos --fatal-warnings
cd app && flutter test --coverage
cd app && flutter build apk --debug
git diff --stat origin/sprint-02 -- app/pubspec.yaml app/pubspec.lock contracts app/packages
grep -rEn "https?://" app/lib
python scripts/sdd_lint.py
python scripts/sdd_lint.py --trace TT-MOB-08
python scripts/codemap.py --check
python scripts/ci/check_exceptions.py
python scripts/sync_agents.py --check
```
