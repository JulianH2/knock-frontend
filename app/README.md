# Knock — app móvil (Flutter)

App de Knock para clientes y técnicos. Base creada en TT-MOB-01 (KNOCK-24): Clean Architecture por función, Riverpod, go_router y la barra inferior de la maqueta. Tema claro y oscuro con la paleta de la maqueta y textos en español e inglés desde TT-MOB-02 (KNOCK-25).

## Requisitos
- **Flutter 3.47.7 (canal stable) · Dart 3.13.5.** Es la versión con la que se creó el proyecto; el CI (TT-CI-01) usa la misma.
- Android SDK con un emulador (la verificación de TT-MOB-01 es en Android). iOS se genera, pero compilarlo requiere macOS.
- Para llamar a la API: `--dart-define=KNOCK_API_URL=...` (ver «API y cliente generado»). Java 11+ solo si regeneras el cliente.

## Correr la app
```bash
cd app
flutter pub get
flutter emulators --launch <id_del_emulador>   # o abre uno desde Android Studio
flutter run
```
La cuenta empieza como cliente (4 pestañas), en español y con el tema del sistema (Automático). En **Mi cuenta → Configuración** (`/cuenta/configuracion`, HU-052) se eligen el idioma (Español · English) y el tema (Automático · Claro · Oscuro); el cambio se ve al momento y se conserva al cerrar y abrir la app. Fuera de release (`!kReleaseMode`), Mi cuenta muestra además el interruptor «Modo técnico (prueba)», que agrega la pestaña **Trabajo** hasta que el rol llegue con la sesión real.

## Tema
- `lib/core/tema/colores.dart`: tokens de la maqueta (`css/knock.css`) en claro y oscuro, y los `ColorScheme` completos.
- `lib/core/tema/tema.dart`: `temaClaro` y `temaOscuro` (Material 3, fuente Nunito).
- `lib/core/tema/contraste.dart`: relación de contraste WCAG 2.x; `test/core/tema/contraste_test.dart` exige ≥ 4.5:1 en cada par `onX`/`X`.
- **Regla de contraste:** estos pares no llegan a 4.5:1 y **no** se usan para texto ni para botones: en claro, `amber` (#E9682D) como texto sobre crema o blanco, y blanco sobre `amber`; en oscuro, `mut`, `navy` o `amber` sobre `navybg`, y `amber` sobre `navy-soft`. Para texto naranja usa `ColoresClaro.amberInk`; sobre `amber` va tinta (`onPrimary`). Usa siempre los colores de `Theme.of(context).colorScheme`, no colores sueltos.
- **Fuente:** Nunito 400, 500, 600 y 700 empaquetada en `assets/fonts/nunito/` con su licencia (`OFL.txt`, SIL Open Font License 1.1). No se usa `google_fonts` ni se descarga nada en tiempo de ejecución.

## Preferencias guardadas (HU-052)
- `lib/core/preferencias/`: `preferenciasProvider` (estado) y `AlmacenPreferencias` (dónde se guarda). En el dispositivo se guardan **solo** `knock.preferencias.tema` (`automatico`, `claro`, `oscuro`) y `knock.preferencias.idioma` (`es`, `en`) con `shared_preferences`, que **no está cifrado**: nunca guardes ahí tokens ni datos de la cuenta (van en almacenamiento seguro). `test/core/preferencias/arquitectura_preferencias_test.dart` falla si otra carpeta de `lib/` importa `shared_preferences`.
- `main()` espera `crearAlmacenDeArranque()` antes de `runApp` para que el primer cuadro ya tenga lo guardado. Un valor guardado inválido usa el valor por defecto (español, Automático) y un fallo del almacenamiento no rompe la app ni se registra.
- En pruebas: `SharedPreferences.setMockInitialValues({...})` en cada prueba. Sin override, `almacenPreferenciasProvider` es un almacén en memoria.

## Idiomas (ARB)
- Español es el idioma fuente (`lib/l10n/app_es.arb`, plantilla y respaldo) e inglés el segundo (`lib/l10n/app_en.arb`). Configuración en `l10n.yaml`.
- **Agregar un texto:** 1) agrega la clave en `app_es.arb` (camelCase con prefijo, p. ej. `tabInicio`, `configuracionTema`) con su `@clave.description`; 2) agrega la misma clave en `app_en.arb`; 3) corre `flutter gen-l10n`; 4) úsalo con `AppLocalizations.of(context).<clave>`. Nunca escribas un texto visible directo en un widget.
- `lib/l10n/generado/` es la salida de `flutter gen-l10n`: se versiona y **no se edita a mano**. Tras cambiar un ARB, `flutter gen-l10n` y `git status lib/l10n` deben quedar al día.
- `test/l10n/textos_desde_arb_test.dart` comprueba que ambos ARB tengan las mismas claves y que todo texto visible salga del ARB del idioma activo; al agregar una pantalla, agrégala a su recorrido.

## Pruebas y análisis
```bash
cd app
dart format --set-exit-if-changed lib test integration_test   # formato
flutter analyze --fatal-infos                   # análisis estático (debe decir «No issues found!»)
flutter test --coverage                         # unitarias y widget; cobertura en coverage/lcov.info (mínimo 50 %)
flutter test integration_test                   # E2E de humo; requiere un emulador o dispositivo Android encendido
```

## API y cliente generado (spec 006)
- El contrato vive en `../contracts/openapi.v1.json` (copiado de knock-backend, hoy el de Identity) y el cliente Dart en `packages/knock_api/`. **Ninguno se edita a mano.**
- Regenerar tras actualizar el contrato (desde la raíz del repositorio; Python 3.11+ y Java 11+):
  ```bash
  python app/tool/generar_cliente_api.py          # escribe app/packages/knock_api/
  python app/tool/generar_cliente_api.py --check  # exit 1 si el cliente no corresponde al contrato
  python -m unittest app/tool/test_generar_cliente_api.py
  ```
  El script descarga openapi-generator-cli 7.27.0 (verificado por SHA-256) y normaliza el contrato de OpenAPI 3.2 a 3.1 en memoria, porque el generador no acepta 3.2.
- `test/api/cliente_generado_test.dart` falla en `flutter test` si el cliente se editó a mano o el contrato cambió sin regenerar.
- La URL base se pasa al compilar; sin ella las llamadas fallan con un error claro:
  ```bash
  flutter run --dart-define=KNOCK_API_URL=https://knock-gateway.happyground-f62473c9.westus.azurecontainerapps.io
  ```
  Solo se acepta `https` (o `http` hacia `localhost`, `127.0.0.1` o `10.0.2.2` para el backend local). HTTP solo por `lib/core/red/` (`clienteApiProvider`, `authApiProvider`).

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
  app.dart             MaterialApp.router con tema, idioma y delegados
  core/
    router/            GoRouter con StatefulShellRoute, barra inferior y redirect por rol
    preferencias/      preferenciasProvider (tema e idioma, en memoria)
    sesion/            esTecnicoProvider (indicador «es técnico», en memoria)
    tema/              paleta, ThemeData claro y oscuro, contraste WCAG
    widgets/           widgets compartidos entre features
    errores/           Failure tipados (incluye los errores de la API)
    red/               cliente generado, URL base y mapeo de errores (spec 006)
  l10n/                ARB es/en y generado/ (salida de gen-l10n)
  features/<función>/  inicio · explorar · actividad · trabajo · cuenta
    presentation/      pantallas (hoy vacías, con su título)
    domain/            Dart puro (entidades, casos de uso, interfaces)
    data/              repositorios con el cliente generado
assets/fonts/nunito/   Nunito 400-700 y OFL.txt
test/                  pruebas unitarias y de widget (soporte/: arnés compartido)
integration_test/      recorrido E2E en emulador
```
Reglas de capas y convenciones: `AGENTS.md` y la skill `flutter-clean-architecture`. Una feature no importa `data/` ni `domain/` de otra; lo compartido va a `core/`.
