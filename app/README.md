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
