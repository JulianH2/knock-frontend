# plan.md — TT-MOB-03 Cliente de Dart generado desde OpenAPI e interceptor de sesión (dio)

## 1. Mapeo de archivos
- **Reutilizar (definidos por TT-MOB-08; volver a buscar con `python scripts/codemap.py --query "cliente api red sesion"` cuando esté fusionada):** `core/red/configuracion_api.dart` (`ConfiguracionApi`, `ErrorDeConfiguracionApi`), `core/red/cliente_api_provider.dart` (`configuracionApiProvider`, `clienteApiProvider`), `core/red/simulada/respuestas_simuladas.dart` (respuestas y escenarios), `core/errores/failure.dart` (`Failure` sellado con `SolicitudRechazadaFailure`), `features/oficios/data/oficios_repository_api.dart`, `features/oficios/data/oficio_mapper.dart`, `app/test/contrato/contrato_s4.json` y su prueba, `l10n/app_es.arb`/`app_en.arb`.
- **Crear:**
  - `contracts/openapi.v1.json` — copia del backend (persona, protegido; D1).
  - `app/packages/knock_api/` — paquete generado (protegido; nadie lo edita a mano).
  - `app/tool/` — script y configuración del generador con versión fija (D1, D2).
  - `app/lib/core/red/cliente_real.dart` — fábrica del `Dio` real (tiempos, sin redirecciones, tope de tamaño, `Accept`).
  - `app/lib/core/red/adaptador_simulado.dart` — `HttpClientAdapter` que sirve `respuestas_simuladas.dart` (D3).
  - `app/lib/core/red/interceptor_sesion.dart` y `app/lib/core/red/renovador_de_sesion.dart` (D6).
  - `app/lib/core/red/traductor_errores.dart` — respuesta o `DioException` → `Failure`.
  - `app/lib/core/red/version_api.dart` — `versionApi = '1'` (D4) (o dentro de `cliente_real.dart`).
  - `app/lib/core/sesion/almacen_de_sesion.dart` (+ implementación según D5).
  - `app/lib/core/errores/mensaje_de_failure.dart` — texto del catálogo por `Failure`.
  - Pruebas: `app/test/core/red/{cliente_generado,cliente_real,interceptor_sesion,traductor_errores,cliente_real_local,cliente_api_provider,arquitectura_cliente}_test.dart`, `app/test/core/sesion/almacen_de_sesion_test.dart`, `app/test/core/errores/mensaje_de_failure_test.dart`, `app/test/features/oficios/presentation/oficios_cambio_de_url_test.dart`.
- **Modificar:** `app/pubspec.yaml`/`pubspec.lock` (dependencias de D2/D5 y `knock_api` por `path`), `core/red/cliente_api_provider.dart` (cliente real en modo real), `core/errores/failure.dart` (D7), `features/oficios/data/oficios_repository_api.dart` (cliente generado), ARB es/en y salida de `gen-l10n`, pruebas de TT-MOB-08 que usan `ClienteApi` (conservando nombres, D3/D15), `app/android/app/src/main/AndroidManifest.xml` (solo si D5 trae el almacén seguro aquí: `allowBackup`), `docs/architecture/*` (regenerado) y `Memoria.md`.
- **Retirar (si D3 se aprueba):** `core/red/cliente_api.dart` y `core/red/simulada/cliente_api_simulado.dart` cuando nada los use.
- **No tocar (son del líder o de otra tarea; D1):** `scripts/`, `.github/`, `.agents/`, `AGENTS.md`, la constitución, `panel/`, el backend, la pantalla y el controlador de oficios, `OficiosRepositoryDePrueba` y las pruebas de TT-PRU-02 y TT-MOB-01.

## 2. Riesgos y efectos secundarios
- **Generador y OpenAPI 3.1.1** (D2): riesgo principal; el spike va primero y su resultado se informa al líder antes de seguir si cambia el alcance.
- **Job `contract` del CI:** se activa en cuanto exista `contracts/openapi.v1.json` y llama a `scripts/gen_clients.sh all`, que no existe: sin el PR del líder (D1) todos los PR de `app/` fallan. Coordinar el orden.
- **Pruebas de TT-MOB-08:** cambiar `clienteApiProvider` y la simulación toca sus pruebas; deben seguir en verde con sus nombres (`sdd_lint --trace TT-MOB-08`).
- **`Failure` sellado:** subtipos nuevos pueden romper `switch` exhaustivos; revisar con `flutter analyze`.
- **Dependencias transitivas** del paquete generado: entran a `app/pubspec.lock`; se evalúan todas en `Memoria.md`.
- **Tamaño del paquete generado:** solo se versiona lo que el generador produce; los `*.g.dart` ya generados para que el CI no corra `build_runner`.

## 3. Pruebas por caso
| Caso | Prueba | Suite |
|---|---|---|
| TC-TT-MOB-03-01 | Contrato vendorizado idéntico (comando) | `diff` contra el backend / `sync_contract.py --check` |
| TC-TT-MOB-03-02 | Generación reproducible (comando) | script de `app/tool/` dos veces + `git diff --exit-code` |
| TC-TT-MOB-03-03 | CI falla sin regenerar (comando) | PR de prueba o secuencia local del job `contract` |
| TC-TT-MOB-03-04 | Modelos generados contra contrato y mocks | `app/test/core/red/cliente_generado_test.dart` |
| TC-TT-MOB-03-05 | Configuración de `dio` | `app/test/core/red/cliente_real_test.dart` |
| TC-TT-MOB-03-06 | Token solo al origen configurado | `app/test/core/red/interceptor_sesion_test.dart` |
| TC-TT-MOB-03-07 | 401, renovador y un reintento | `interceptor_sesion_test.dart` |
| TC-TT-MOB-03-08 | Traductor de errores | `app/test/core/red/traductor_errores_test.dart` |
| TC-TT-MOB-03-09 | Textos del catálogo | `app/test/core/errores/mensaje_de_failure_test.dart` |
| TC-TT-MOB-03-10 | Cambio de URL (trasladado de TT-MOB-08) | `app/test/features/oficios/presentation/oficios_cambio_de_url_test.dart` |
| TC-TT-MOB-03-11 | Servidor local: bearer, redirección, tamaño, tiempo | `app/test/core/red/cliente_real_local_test.dart` |
| TC-TT-MOB-03-12 | Release con `https` usa el cliente real | `app/test/core/red/cliente_api_provider_test.dart` |
| TC-TT-MOB-03-13 | Almacén de sesión | `app/test/core/sesion/almacen_de_sesion_test.dart` |
| TC-TT-MOB-03-14 | Capas y privacidad | `app/test/core/red/arquitectura_cliente_test.dart` |
| TC-TT-MOB-03-15 | Dependencias evaluadas (comando) | `git diff`, `osv-scanner`, `grep` |
| TC-TT-MOB-03-16 | Gates y builds (comando) | CI de la app + `flutter build appbundle --release` local |

## 4. Secuencia
1. Con la spec Aprobada por una persona distinta del autor y TT-MOB-08 fusionada en `sprint-02`: spike del generador (D2) sobre el contrato vigente; informar el resultado.
2. Evaluar dependencias en `Memoria.md`; vendorizar el contrato (persona) y generar el paquete (casos 01, 02, 04); acordar con el líder el PR de `scripts/` y del job `contract` (D1, caso 03).
3. Cliente real, adaptador simulado y cambio de `clienteApiProvider` (casos 05, 12); adaptar las pruebas de TT-MOB-08 conservando nombres.
4. Almacén de sesión, interceptor y renovador (casos 06, 07, 13).
5. Traductor de errores, `Failure` nuevos y textos ARB (casos 08, 09); repositorio de oficios con el cliente generado.
6. Pruebas con servidor local (casos 10, 11) y de capas y privacidad (caso 14); mutación manual de los casos 06 a 08.
7. Casos 15 y 16 (comandos), `docs/architecture`, `Memoria.md` e informe en el PR con «Uso de IA».

## 5. Verificación (comandos exactos)
```bash
git -C ../knock-backend show <commit>:docs/openapi.v1.json | diff - contracts/openapi.v1.json
bash app/tool/<script de generación> && bash app/tool/<script de generación> && git diff --exit-code -- app/packages/knock_api
cd app && flutter pub get --enforce-lockfile
cd app && dart format --set-exit-if-changed lib test
cd app && flutter analyze --fatal-infos --fatal-warnings
cd app && flutter test --coverage
cd app && flutter build apk --debug
cd app && flutter build appbundle --release --dart-define=KNOCK_API_URL=https://api.ejemplo.invalid
osv-scanner --lockfile=app/pubspec.lock
grep -rEn "https?://" app/lib
python scripts/sdd_lint.py
python scripts/sdd_lint.py --trace TT-MOB-03
python scripts/sdd_lint.py --trace TT-MOB-08
python scripts/codemap.py --check
python scripts/ci/check_exceptions.py
python scripts/sync_agents.py --check
```
