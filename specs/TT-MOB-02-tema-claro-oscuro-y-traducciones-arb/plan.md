# plan.md — TT-MOB-02 Tema claro y oscuro con la paleta de la maqueta y archivos de traducción (ARB es/en)

## 1. Mapeo de archivos
- **Reutilizar (buscado con `codemap.py --query "tema idioma preferencias"` → sin coincidencias):** `KnockApp` (`app/lib/app.dart`), `AppShell` y su lista `_destinos` (`app/lib/core/router/app_shell.dart`), `PantallaTitulada` (`app/lib/core/widgets/`), `interruptorDePruebaProvider` (`app/lib/core/sesion/es_tecnico_provider.dart`) como condición del menú de prueba, y el arnés de pruebas de `app/test/core/router/app_shell_test.dart` (`UncontrolledProviderScope` + overrides) como molde.
- **Crear:**
  - `app/l10n.yaml` (spec §8 decisión 8).
  - `app/lib/l10n/app_es.arb` (plantilla, con `@clave.description`) y `app/lib/l10n/app_en.arb`.
  - `app/lib/l10n/generado/*.dart` — salida de `flutter gen-l10n` (generado, no se edita a mano).
  - `app/lib/core/tema/colores.dart` (paleta clara y oscura), `app/lib/core/tema/tema.dart` (`ThemeData` claro y oscuro, `TextTheme` con la fuente), `app/lib/core/tema/contraste.dart` (función pura WCAG). Se borra `app/lib/core/tema/.gitkeep`.
  - `app/lib/core/preferencias/preferencias_provider.dart` — `Preferencias` inmutable + `PreferenciasNotifier` (`Notifier`) con `cambiarTema` y `cambiarIdioma`; inicia en `ThemeMode.system` y `es`.
  - `app/assets/fonts/nunito/`: `Nunito-Regular.ttf` (400), `Nunito-Medium.ttf` (500), `Nunito-SemiBold.ttf` (600), `Nunito-Bold.ttf` (700), estáticos oficiales de Google Fonts, y su `OFL.txt` (spec §8 decisión 2).
  - `app/test/core/preferencias/preferencias_test.dart` (TC-01, unitaria).
  - `app/test/features/cuenta/menu_de_prueba_test.dart` (TC-01, widget, y caso release).
  - `app/test/l10n/textos_desde_arb_test.dart` (TC-02).
  - `app/test/core/tema/contraste_test.dart` (TC-03).
  - `app/test/core/router/app_shell_l10n_test.dart` (TC-04 + `textContrastGuideline`).
  - `app/test/soporte/montar_app.dart` (arnés compartido de las pruebas nuevas: montar la app, leer un ARB, buscar en la barra).
  - `app/lib/features/cuenta/presentation/widgets/menu_de_prueba.dart` (`MenuDePrueba`: modo técnico, tema e idioma).
- **Modificar:**
  - `app/pubspec.yaml` (`flutter_localizations` del SDK, `intl`, `flutter: generate: true`, `flutter: fonts:`).
  - `app/lib/app.dart` (tema, `themeMode`, `locale`, delegados, `onGenerateTitle`).
  - `app/lib/core/router/app_shell.dart` (etiquetas desde `AppLocalizations`).
  - `app/lib/features/{inicio,explorar,actividad,trabajo}/presentation/*_screen.dart` (títulos desde ARB).
  - `app/lib/features/cuenta/presentation/cuenta_screen.dart` (título y «Modo técnico (prueba)» desde ARB; menú de prueba de tema e idioma).
  - `app/android/app/src/main/AndroidManifest.xml` (`android:label="Knock"`) y `app/ios/Runner/Info.plist` (`CFBundleDisplayName`, `CFBundleName`, y `CFBundleLocalizations` es/en) — spec §8 decisión 3.
  - `app/README.md`, `Memoria.md`, `docs/architecture/*` (regenerado con `codemap.py`).
- **No tocar:** `contracts/`, `app/packages/knock_api/`, `panel/`, el router y la regla de rol (`app_router.dart`, `rutas.dart`), las aserciones de las pruebas de TT-MOB-01 (spec Firmada), `analysis_options.yaml` salvo que `pub get` lo reescriba, workflows y scripts de gobierno.

## 2. Riesgos y efectos secundarios
- **Pruebas de TT-MOB-01:** buscan textos en español («Inicio», «Trabajo», «Modo técnico (prueba)»). `flutter_test` usa `en_US` como idioma del dispositivo; si el idioma inicial siguiera al sistema, esas pruebas fallarían. Por eso el idioma inicial es **español fijo** (HU-052 §8) y no se cambian sus aserciones.
- **`intl` y `flutter_localizations`:** el SDK fija la versión de `intl`; una restricción incompatible rompe `pub get`. Se fija `intl: ^0.20.3`, la misma restricción que declara `flutter_localizations` en Flutter 3.47.7 (`flutter pub add intl` deja `any`, que es una versión abierta).
- **Archivos generados:** `gen-l10n` escribe en `lib/`; si no se versionan, el CI o `codemap.py` pueden ver estados distintos según el orden de comandos (spec §8 decisión 8). Excluirlos del análisis solo si `flutter analyze` reporta hallazgos en código generado (y con motivo en el PR, nunca con `// ignore`).
- **`analysis_options.yaml`:** Flutter repone los `exclude` en cada `pub get` (Memoria, 2026-10-17); no tocarlo a mano.
- **Contraste:** el naranja de la maqueta no sirve como texto sobre crema ni con texto blanco encima (spec §8 decisión 1): `onPrimary` = `ink` en claro y `bg` en oscuro, texto naranja con `amber-ink`, y ningún par `onX`/`X` es uno de los 7 prohibidos.
- **Fuente:** un `.ttf` mal declarado en `pubspec.yaml` no falla en `flutter test` (usa la fuente de prueba); revisarlo en el emulador con las capturas.
- **Mapa de código:** cambian `docs/architecture/*`; regenerar con `PYTHONIOENCODING=utf-8 python scripts/codemap.py` y revisar que los `.dart` generados no disparen clones.

## 3. Pruebas por caso
| Caso | Prueba | Suite |
|---|---|---|
| TC-TT-MOB-02-01 | `test('TC-TT-MOB-02-01 estado inicial sistema y español; cambiar tema e idioma actualiza el estado', …)` en `preferencias_test.dart`; `testWidgets('TC-TT-MOB-02-01 cambia tema e idioma sin reiniciar la app', …)` en `menu_de_prueba_test.dart` — navega a Mi cuenta, cambia a Oscuro y comprueba `Theme.of(…).brightness == dark` y el fondo; cambia a English y comprueba el título «My account»; la pestaña seleccionada y la ruta `/cuenta` se conservan y `KnockApp` no se volvió a montar (mismo `State`/elemento); `testWidgets('TC-TT-MOB-02-01 sin modo de prueba (release) Mi cuenta no muestra el menú de tema e idioma', …)`; capturas en emulador | unitaria + widget (`flutter test`) + manual |
| TC-TT-MOB-02-02 | `testWidgets('TC-TT-MOB-02-02 todo texto visible sale del ARB del idioma activo', …)` — lee `lib/l10n/app_<idioma>.arb` con `dart:io` (archivo local, sin red), monta la app como técnico en es y en, visita las 5 pestañas y comprueba que cada `Text.data` y cada etiqueta de `NavigationDestination` está entre los valores del ARB; `test('TC-TT-MOB-02-02 app_es.arb y app_en.arb tienen las mismas claves', …)` | widget + unitaria (`flutter test`) |
| TC-TT-MOB-02-03 | En `contraste_test.dart`: `test('TC-TT-MOB-02-03 la fórmula de contraste da 21:1 con blanco y negro y 1:1 con el mismo color', …)`; `test('TC-TT-MOB-02-03 el texto sobre crema cumple al menos 4.5:1', …)` (ink, ink2, mut, amber-ink y navy sobre crema y blanco); `test('TC-TT-MOB-02-03 el texto del tema oscuro cumple al menos 4.5:1 sobre sus fondos', …)`; `test('TC-TT-MOB-02-03 todos los pares onX/X del ColorScheme claro cumplen al menos 4.5:1', …)` y el mismo para `oscuro` (primary, containers, fixed, error, inverse y onSurface/onSurfaceVariant sobre cada superficie); `test('TC-TT-MOB-02-03 ningún par onX/X usa uno de los 7 pares prohibidos y onPrimary en claro no es blanco', …)` (protege la regla del líder); `test('TC-TT-MOB-02-03 en claro los botones sin relleno no usan el naranja como texto', …)`; `test('TC-TT-MOB-02-03 en claro el botón relleno naranja lleva un borde visible sobre crema', …)`; `test('TC-TT-MOB-02-03 los temas usan la paleta y la fuente de la maqueta', …)` | unitaria (`flutter test`) |

| TC-TT-MOB-02-04 | `testWidgets('TC-TT-MOB-02-04 al cambiar el idioma a inglés las pestañas cambian de texto', …)` — etiquetas en español, cambio de idioma por el Notifier, etiquetas iguales a los valores de `app_en.arb` y ninguna en español; más `meetsGuideline(textContrastGuideline)` en claro y oscuro | widget (`flutter test`) |

## 4. Secuencia
1. Spec Aprobada con las decisiones de §8; evaluar `intl`, `flutter_localizations` y la fuente; registrar en `Memoria.md`.
2. `pubspec.yaml`, `l10n.yaml`, ARB es/en y `flutter gen-l10n`.
3. `core/tema` (paleta, `ThemeData`, contraste) + `contraste_test.dart` (TC-03).
4. `core/preferencias` + `preferencias_test.dart` (TC-01 unitaria).
5. `KnockApp`, barra y pantallas con textos del ARB; menú de prueba en Mi cuenta; nombre «Knock» en Android e iOS.
6. Pruebas de widget TC-01, TC-02, TC-04 (+ A11Y); pruebas de TT-MOB-01 en verde sin cambios.
7. Emulador: capturas en claro, oscuro, español e inglés (y el lanzador con «Knock»).
8. Gates + `codemap.py` + `app/README.md` + `Memoria.md` + informe final en el PR.

## 5. Verificación (comandos exactos)
```bash
cd app && flutter pub get
flutter gen-l10n && git status --porcelain lib/l10n   # sin cambios si los generados están al día
flutter pub deps --style=compact | grep -E "intl|flutter_localizations"
dart format --set-exit-if-changed lib test integration_test
flutter analyze --fatal-infos
flutter test --coverage
flutter test integration_test            # emulador Android encendido; TC-TT-MOB-01-01 sigue en verde
cd .. && PYTHONIOENCODING=utf-8 python scripts/codemap.py && PYTHONIOENCODING=utf-8 python scripts/codemap.py --check
PYTHONIOENCODING=utf-8 python scripts/sdd_lint.py && PYTHONIOENCODING=utf-8 python scripts/sdd_lint.py --trace TT-MOB-02
python scripts/ci/check_exceptions.py && python scripts/sync_agents.py --check
```
