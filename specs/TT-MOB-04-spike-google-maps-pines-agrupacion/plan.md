# plan.md — TT-MOB-04 Spike: Google Maps en Flutter con pines y agrupación

## 1. Mapeo de archivos
- **Reutilizar (buscar con `codemap.py --query "mapa"`, `"ubicacion"`, `"inicio"` antes de crear):** hoy no hay mapa, ubicación ni dominio en `app/lib` (solo router, sesión de prueba y `PantallaTitulada`). Se reutilizan la estructura `features/inicio/{presentation,domain,data}` de TT-MOB-01, `analysis_options.yaml`, el job de app del CI (`flutter build apk --debug`) y las reglas por defecto de gitleaks.
- **Crear (se queda para HU-011):**
  - `app/lib/features/inicio/domain/punto_mapa.dart` — entidad `PuntoMapa` (Dart puro).
  - `app/lib/features/inicio/domain/ubicacion_repository.dart` — `UbicacionRepository` y `ResultadoUbicacion` (`sealed`).
  - `app/lib/features/inicio/data/ubicacion_geolocator_repository.dart` — implementación con `geolocator` (pide permiso al llamarse; una lectura; sin stream).
  - `app/lib/features/inicio/presentation/mapa/marcadores.dart` — función pura `PuntoMapa` → `Set<Marker>` con `clusterManagerId`.
  - `app/lib/features/inicio/presentation/mapa/mapa_con_pines.dart` — `GoogleMap` con un `ClusterManager`, `myLocationButtonEnabled: false`.
  - `app/lib/features/inicio/presentation/mapa/mi_ubicacion_controller.dart` — `Notifier` que usa el repositorio y un puerto de cámara (mover a punto); guarda solo el aviso.
  - `app/lib/features/inicio/presentation/mapa/boton_mi_ubicacion.dart` — botón accesible + avisos.
- **Crear (desechable, se borra en HU-011):**
  - `app/lib/main_spike_mapa.dart` — punto de entrada propio (`ProviderScope` + `MapaSpikeScreen`).
  - `app/lib/features/inicio/presentation/spike/mapa_spike_screen.dart` — pantalla de prueba.
  - `app/lib/features/inicio/presentation/spike/pines_de_prueba.dart` — generador determinista de 50 pines (Dart puro).
- **Crear (pruebas y medición):**
  - `app/test/features/inicio/presentation/spike/pines_de_prueba_test.dart` (TC-06).
  - `app/test/features/inicio/presentation/mapa/marcadores_test.dart` (TC-03).
  - `app/test/features/inicio/presentation/mapa/mi_ubicacion_controller_test.dart` (TC-04, TC-05).
  - `app/test/features/inicio/presentation/mapa/boton_mi_ubicacion_test.dart` (TC-04, TC-05, A11Y).
  - `app/integration_test/mapa_rendimiento_test.dart` y `app/test_driver/perf_driver.dart` (TC-01).
  - `docs/spikes/TT-MOB-04-google-maps.md` — resultados (spec §8 decisión 7).
- **Modificar:**
  - `app/pubspec.yaml` / `pubspec.lock` — `google_maps_flutter`, `geolocator`; `flutter_driver` (SDK) en `dev_dependencies`.
  - `app/android/app/build.gradle.kts` — leer `MAPS_API_KEY` (local.properties → env → `""`) y `manifestPlaceholders`.
  - `app/android/app/src/main/AndroidManifest.xml` — `meta-data com.google.android.geo.API_KEY` = `${mapsApiKey}` y `ACCESS_COARSE_LOCATION`.
  - `.gitignore` — `app/android/local.properties` (defensa en la raíz; ya lo ignora `app/android/.gitignore`).
  - `app/README.md` — clave local y cómo correr el spike.
  - `Memoria.md` — evaluación de dependencias, decisiones y resultado.
- **No tocar:** `app/ios/` (iOS fuera de alcance por decisión del líder, spec §8 resuelto 5; los plugins no lo exigen para compilar el APK); `app/lib/core/router/*`, `app/lib/app.dart`, `app/lib/main.dart`, pantallas de las pestañas y sus pruebas (TT-MOB-01 Firmada); `contracts/`, `app/packages/knock_api/`, `panel/`, `.github/`, scripts de gobierno; `docs/referencia/*` (lo actualiza docs-keeper).

## 2. Riesgos y efectos secundarios
- **Secreto:** el error típico es pegar la clave en `AndroidManifest.xml` o en Dart; revisar `git diff` antes de cada commit y que gitleaks pase. La clave queda dentro del APK (inherente): la restricción es el control.
- **Build del CI:** los plugins nativos nuevos (Play services Maps y Location) aumentan el tiempo de `flutter build apk --debug` y pueden exigir `minSdk` mayor; si `flutter.minSdkVersion` no alcanza, fijar el mínimo que pidan los plugins y anotarlo.
- **Emulador:** Maps necesita imagen con Google Play services («Google APIs» o «Google Play»); con otra imagen el mapa no carga y parece un fallo de la clave.
- **Medición:** *profile* no corre en emulador; si el 2026-10-23 no hay dispositivo físico, TC-01 queda sin medición y se declara en el PR (spec §8 resuelto 1).
- **Clave bloqueada por facturación:** no se crea ninguna clave hasta que el plan Blaze esté activo (TT-FB-02, lo hace el líder). Mientras tanto se avanza con todo lo que no necesita el mapa pintado (dominio, marcadores, «Mi ubicación», build sin clave); TC-02 y la parte visual de TC-01/TC-03 esperan a la clave.
- **Dependencias:** `geolocator` arrastra paquetes federados de otras plataformas (se instalan aunque solo se compile Android); evaluar transitivas y OSV.
- **Arquitectura:** `domain/` sin `flutter`/`geolocator`; `presentation/spike/` no se importa desde `main.dart` ni desde el router. `codemap.py --check` debe quedar sin violaciones; regenerar el mapa (`PYTHONIOENCODING=utf-8`).
- **Cobertura:** el widget `GoogleMap`, la implementación con `geolocator` y `main_spike_mapa.dart` no los carga ninguna prueba unitaria; el umbral es global (50 %) y hoy está en 98.7 %, debería seguir sobrado.

## 3. Pruebas por caso
| Caso | Prueba | Suite |
|---|---|---|
| TC-TT-MOB-04-01 | `testWidgets('TC-TT-MOB-04-01 el mapa con 50 pines se mueve fluido', …)` con `binding.traceAction` sobre arrastre y zoom; `flutter drive --profile` en Android físico; resumen de frames + video | rendimiento / E2E (comando) |
| TC-TT-MOB-04-02 | Ejecutar con otro `applicationId` (cambio local sin commit) y con el correcto; `adb logcat` muestra el error de autorización solo en el primero; captura tapada de restricciones | manual por comando |
| TC-TT-MOB-04-03 | `test('TC-TT-MOB-04-03 cada pin se asigna al administrador de agrupación', …)`: 50 puntos → 50 marcadores, ids iguales a los puntos, todos con el mismo `clusterManagerId`; tramo de zoom en el video | unitaria (`flutter test`) + manual |
| TC-TT-MOB-04-04 | `test('TC-TT-MOB-04-04 con permiso concedido centra la cámara en la posición', …)` (repositorio falso `Concedida`, cámara falsa recibe el punto una vez, sin aviso) · `testWidgets('TC-TT-MOB-04-04 el permiso se pide solo al tocar Mi ubicación', …)` (0 llamadas al montar, 1 al tocar) | unitaria + widget |
| TC-TT-MOB-04-05 | `test('TC-TT-MOB-04-05 con permiso denegado no mueve la cámara y avisa', …)` para `Denegada`, `DenegadaParaSiempre` y `ServicioDesactivado` (cámara sin llamadas, aviso correcto) · `testWidgets('TC-TT-MOB-04-05 muestra el aviso cuando se niega el permiso', …)` + `meetsGuideline` | unitaria + widget |
| TC-TT-MOB-04-06 | `test('TC-TT-MOB-04-06 genera 50 pines ficticios, deterministas y dentro de la ciudad piloto', …)`: longitud 50, ids únicos `prueba-NN`, dentro del área, dos llamadas iguales | unitaria |
| TC-TT-MOB-04-07 | `git check-ignore -v …`, `git ls-files app \| grep -i -E "local.properties\|secrets"` vacío, gitleaks, `flutter build apk --debug` sin `MAPS_API_KEY` | comando |

## 4. Secuencia
1. Spec aprobada (dudas de §8 ya resueltas por el líder el 2026-10-21); cuando el plan Blaze esté activo, José Julián crea la clave de Android restringida (paquete + SHA-1 de Erick, solo Maps SDK for Android) en el proyecto de Firebase, con cuota diaria de 1 000 cargas y alerta de 1 USD, y la pasa por canal privado (fuera del repo).
2. Evaluar `google_maps_flutter`, `geolocator` (y transitivas) y registrar en `Memoria.md`; agregarlas.
3. Configuración nativa de la clave (solo Android) y `.gitignore`; comprobar build sin clave (TC-07).
4. Dominio (`PuntoMapa`, `ResultadoUbicacion`, `UbicacionRepository`) y generador de pines + unitarias (TC-06).
5. Marcadores con agrupación + unitaria (TC-03); controlador y botón «Mi ubicación» + unitarias y widget (TC-04, TC-05, A11Y).
6. Implementación con `geolocator`, widget de mapa, pantalla y punto de entrada del spike; prueba en emulador (agrupación y permisos).
7. `integration_test` de rendimiento + driver; medición en dispositivo físico y video (TC-01); prueba de otra app (TC-02).
8. Precio vigente (página oficial, fecha y captura) y documento de resultados.
9. Gates + `codemap.py` + `Memoria.md` + informe final en el PR.

## 5. Verificación (comandos exactos)
```bash
cd app && flutter pub get
dart format --set-exit-if-changed lib test integration_test test_driver
flutter analyze --fatal-infos --fatal-warnings
flutter test --coverage
flutter build apk --debug                         # sin MAPS_API_KEY (como el CI)
flutter run -t lib/main_spike_mapa.dart           # emulador con Google Play services, clave en local.properties
flutter drive --profile --driver=test_driver/perf_driver.dart --target=integration_test/mapa_rendimiento_test.dart   # Android físico
adb logcat -s Google_Maps_Android_API             # TC-02
cd .. && git check-ignore -v app/android/local.properties
PYTHONIOENCODING=utf-8 python scripts/codemap.py && PYTHONIOENCODING=utf-8 python scripts/codemap.py --check
python scripts/sdd_lint.py && python scripts/sdd_lint.py --trace TT-MOB-04
python scripts/ci/check_exceptions.py && python scripts/sync_agents.py --check
```
