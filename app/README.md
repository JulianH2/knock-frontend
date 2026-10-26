# Knock — app móvil (Flutter)

App de Knock para clientes y técnicos. Base creada en TT-MOB-01 (KNOCK-24): Clean Architecture por función, Riverpod, go_router y la barra inferior de la maqueta.

## Requisitos
- **Flutter 3.47.7 (canal stable) · Dart 3.13.5.** Es la versión con la que se creó el proyecto; el CI (TT-CI-01) usa la misma.
- Android SDK con un emulador (la verificación de TT-MOB-01 es en Android). iOS se genera, pero compilarlo requiere macOS.
- Sin Firebase ni API todavía: no hace falta ningún archivo de configuración ni secreto.

## Correr la app
```bash
cd app
flutter pub get
flutter emulators --launch <id_del_emulador>   # o abre uno desde Android Studio
flutter run
```
La cuenta empieza como cliente (4 pestañas). En **Mi cuenta**, el interruptor «Modo técnico (prueba)» agrega la pestaña **Trabajo**. Ese interruptor solo existe en compilaciones debug y profile (`!kReleaseMode`) y se retira cuando la sesión real dé el rol.

## Pruebas y análisis
```bash
cd app
dart format --set-exit-if-changed lib test     # formato
flutter analyze --fatal-infos                   # análisis estático (debe decir «No issues found!»)
flutter test --coverage                         # unitarias y widget; cobertura en coverage/lcov.info (mínimo 50 %)
flutter test integration_test                   # E2E de humo; requiere un emulador o dispositivo Android encendido
```

## Spike de Google Maps (TT-MOB-04, desechable)
Pantalla de prueba con 50 pines ficticios alrededor de Tula de Allende, agrupación nativa y botón «Mi ubicación». No está en el router ni en `main.dart`: tiene su propio punto de entrada.

1. **Clave (solo Android).** La crea y custodia el líder en el proyecto de Firebase (restringida a `app.knock.mobile` + tu SHA-1 de depuración y solo a Maps SDK for Android) y te la pasa por un canal privado. Agrégala a `app/android/local.properties` (ignorado por git) en una línea `MAPS_API_KEY=<tu clave>`, o expórtala como variable de entorno `MAPS_API_KEY`. **Nunca** la escribas en el manifiesto, en Dart, en un PR ni en un chat con IA. Tu SHA-1: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android`.
2. **Correr.** Emulador con imagen «Google APIs» o «Google Play» (sin Play services el mapa no carga):
   ```bash
   cd app
   flutter run -t lib/main_spike_mapa.dart
   ```
3. **Medir la fluidez (TC-TT-MOB-04-01).** Solo en un Android físico (el modo *profile* no corre en emulador):
   ```bash
   flutter drive --profile --driver=test_driver/perf_driver.dart --target=integration_test/mapa_rendimiento_test.dart
   ```
   El resumen queda en `build/mapa_rendimiento.timeline_summary.json`.

Sin clave la app compila igual (`flutter build apk --debug`, como en el CI); solo el mapa queda en blanco. Resultados: `docs/spikes/TT-MOB-04-google-maps.md`.

## Estructura
```
lib/
  main.dart            arranque con ProviderScope
  app.dart             MaterialApp.router
  core/
    router/            GoRouter con StatefulShellRoute, barra inferior y redirect por rol
    sesion/            esTecnicoProvider (indicador «es técnico», en memoria)
    widgets/           widgets compartidos entre features
    tema/ errores/ red/   vacíos: TT-MOB-02 y TT-MOB-03
  features/<función>/  inicio · explorar · actividad · trabajo · cuenta
    presentation/      pantallas (hoy vacías, con su título)
    domain/            Dart puro (entidades, casos de uso, interfaces)
    data/              repositorios con el cliente generado
test/                  pruebas unitarias y de widget
integration_test/      recorrido E2E en emulador
```
Reglas de capas y convenciones: `AGENTS.md` y la skill `flutter-clean-architecture`. Una feature no importa `data/` ni `domain/` de otra; lo compartido va a `core/`.
