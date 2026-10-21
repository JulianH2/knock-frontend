# TT-MOB-04 — tareas

## T1 — Claves y costo (fuera del repo) [Mobile]
- **Crear:** en Google Cloud, `maps-android-dev` (paquete `app.knock.mobile` + SHA-1 de depuración) y `maps-ios-dev` (bundle `app.knock.mobile`), ambas solo para Maps SDK for Android / iOS; cuota diaria y alerta de presupuesto (spec §8 decisiones 3 y 8, duda 3).
- **Verificar:** TC-TT-MOB-04-02 (después de T3)
- **No hacer:** claves sin restricción; pegar la clave en Jira, GitHub, chat ni en un prompt de IA; usar `mx.knock.app`.
- **Agente:** ninguno (persona)

## T2 — Dependencias y clave en la app [Mobile]
- **Crear:** —
- **Modificar:** `app/pubspec.yaml` (`google_maps_flutter`, `geolocator`; `flutter_driver` en dev), `app/android/app/build.gradle.kts`, `AndroidManifest.xml`, `ios/Flutter/{Debug,Release}.xcconfig`, `ios/Runner/Info.plist`, `ios/Runner/AppDelegate.swift`, `.gitignore`, `app/README.md`, `Memoria.md` (evaluación de dependencias).
- **Verificar:** TC-TT-MOB-04-07
- **No hacer:** clave en Dart o en archivos versionados; `--dart-define` para la clave; paquetes de agrupación extra; Secrets Gradle Plugin.
- **Agente:** flutter-builder

## T3 — Mapa, agrupación y «Mi ubicación» [Mobile]
- **Crear:** `features/inicio/domain/{punto_mapa,ubicacion_repository}.dart`, `features/inicio/data/ubicacion_geolocator_repository.dart`, `features/inicio/presentation/mapa/{marcadores,mapa_con_pines,mi_ubicacion_controller,boton_mi_ubicacion}.dart`; desechables `lib/main_spike_mapa.dart` y `features/inicio/presentation/spike/{mapa_spike_screen,pines_de_prueba}.dart`.
- **Verificar:** TC-TT-MOB-04-03 · TC-TT-MOB-04-04 · TC-TT-MOB-04-05 · TC-TT-MOB-04-06
- **No hacer:** tocar router, barra, `main.dart` o Inicio; pedir el permiso al abrir; guardar, enviar o registrar la posición; `getPositionStream`; datos reales en pines.
- **Agente:** flutter-builder

## T4 — Pruebas y medición [Pruebas]
- **Crear:** pruebas de `app/test/features/inicio/…` (TC-03 a TC-06, A11Y), `app/integration_test/mapa_rendimiento_test.dart`, `app/test_driver/perf_driver.dart`.
- **Verificar:** TC-TT-MOB-04-01 (dispositivo físico + video) · TC-TT-MOB-04-02 (logcat + captura tapada)
- **No hacer:** `skip:`, red real o clave en pruebas unitarias; montar `GoogleMap` en pruebas de widget.
- **Agente:** flutter-builder

## T5 — Resultados y cierre
- **Crear:** `docs/spikes/TT-MOB-04-google-maps.md` (fluidez medida, agrupación, permisos, precio con fecha y URL, recomendación para HU-011).
- **Modificar:** `Memoria.md`; (docs-keeper) enlace en el pendiente #2 de `docs/referencia/DECISIONES.md` y DECISION_TECNICA §11.
- **Verificar:** checklist de gates
- **Agente:** flutter-builder / docs-keeper
