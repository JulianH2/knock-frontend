# TT-MOB-01 — tareas

## T1 — Proyecto y estructura [Mobile]
- **Crear:** `app/` con `flutter create --org mx.knock --platforms android,ios app` e identificador `app.knock.mobile` en Android e iOS; `lib/core/router/`, `lib/core/sesion/`, `lib/core/widgets/pantalla_titulada.dart`; `lib/core/{tema,errores,red}/.gitkeep`; `lib/features/{inicio,explorar,actividad,trabajo,cuenta}/{presentation,domain,data}` (`domain/` y `data/` con `.gitkeep`).
- **Modificar:** `app/analysis_options.yaml` (copia de `docs/templates/app/analysis_options.yaml`).
- **Verificar:** TC-TT-MOB-01-03
- **No hacer:** tema, ARB, cliente de API, Firebase; versionar `google-services.json`, `GoogleService-Info.plist`, `key.properties` o `*.jks`.
- **Agente:** flutter-builder

## T2 — Dependencias y navegación [Mobile]
- **Crear:** router con `StatefulShellRoute`, barra inferior Inicio · Explorar · Actividad · Trabajo · Mi cuenta y `redirect` de `/trabajo` a `/inicio` si no es técnico; `esTecnicoProvider` (`Notifier<bool>`, inicia en falso) en `lib/core/sesion/`; interruptor «Modo técnico (prueba)» en Mi cuenta solo si `!kReleaseMode`; pantallas vacías con título.
- **Modificar:** `app/pubspec.yaml` (`flutter_riverpod`, `go_router`; `integration_test` en `dev_dependencies`); `Memoria.md` (evaluación de dependencias y versión de Flutter).
- **Verificar:** TC-TT-MOB-01-01 · TC-TT-MOB-01-02 · TC-TT-MOB-01-04
- **No hacer:** importar `data/` o `domain/` de una feature desde `core/` u otra feature; agregar `riverpod_annotation`, generadores u otros paquetes no evaluados.
- **Agente:** flutter-builder

## T3 — Pruebas [Pruebas]
- **Crear:** `app/test/core/router/app_shell_test.dart` (TC-02, TC-04, A11Y); `app/test/core/router/rutas_test.dart` (TC-02, unitarias de la regla de rol); `app/integration_test/tabs_navigation_test.dart` (TC-01).
- **Verificar:** TC-TT-MOB-01-01 · TC-TT-MOB-01-02 · TC-TT-MOB-01-04
- **No hacer:** `skip:`, red real, datos reales.
- **Agente:** flutter-builder

## T4 — Documentación y evidencia
- **Crear:** `app/README.md` (versión de Flutter, cómo correr la app, pruebas y análisis).
- **Modificar:** `Memoria.md`.
- **Verificar:** TC-TT-MOB-01-01 (video en emulador Android) · TC-TT-MOB-01-03 (salida de `flutter analyze --fatal-infos`; FALTA esperado en `--trace`, spec §8 decisión 8)
- **Agente:** flutter-builder / docs-keeper
