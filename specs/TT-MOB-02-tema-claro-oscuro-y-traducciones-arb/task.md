# TT-MOB-02 — tareas

## T1 — Dependencias y traducciones [Mobile]
- **Crear:** `app/l10n.yaml`; `app/lib/l10n/app_es.arb` (plantilla, con descripciones) y `app/lib/l10n/app_en.arb`; salida de `flutter gen-l10n` en `app/lib/l10n/generado/` (spec §8 duda 8).
- **Modificar:** `app/pubspec.yaml` (`flutter_localizations` del SDK, `intl` compatible con el SDK, `flutter: generate: true`); `Memoria.md` (evaluación de dependencias).
- **Verificar:** TC-TT-MOB-02-02 (mismas claves en es y en)
- **No hacer:** claves con puntos (`gen-l10n` no las admite, duda 6); editar a mano los archivos generados; agregar `google_fonts`, `shared_preferences` u otros paquetes no evaluados.
- **Agente:** flutter-builder

## T2 — Tema de la maqueta [Mobile]
- **Crear:** `app/lib/core/tema/colores.dart`, `tema.dart` y `contraste.dart` (paleta clara y oscura de §8 duda 1, `ThemeData` Material 3 con `ColorScheme` explícito, `onPrimary` tinta); fuente en `app/assets/fonts/<familia>/` con su licencia (duda 2).
- **Modificar:** `app/pubspec.yaml` (`flutter: fonts:`); borrar `app/lib/core/tema/.gitkeep`.
- **Verificar:** TC-TT-MOB-02-03
- **No hacer:** usar el naranja `#E9682D` como texto sobre crema; descargar fuentes en tiempo de ejecución.
- **Agente:** flutter-builder

## T3 — Preferencias, textos y menú de prueba [Mobile]
- **Crear:** `app/lib/core/preferencias/preferencias_provider.dart` (`Preferencias` inmutable, `PreferenciasNotifier`; inicia en sistema y español; solo en memoria).
- **Modificar:** `app/lib/app.dart` (tema, `themeMode`, `locale`, delegados, `onGenerateTitle`); `app/lib/core/router/app_shell.dart` y las 5 pantallas (textos desde ARB); `cuenta_screen.dart` (menú de prueba de tema e idioma con `interruptorDePruebaProvider`); `AndroidManifest.xml` e `Info.plist` (nombre «Knock», duda 3).
- **Verificar:** TC-TT-MOB-02-01 · TC-TT-MOB-02-02 · TC-TT-MOB-02-04
- **No hacer:** cambiar el router ni la regla de rol (TT-MOB-01, Firmada); guardar la preferencia en disco (HU-052); seguir el idioma del sistema.
- **Agente:** flutter-builder

## T4 — Pruebas [Pruebas]
- **Crear:** `app/test/core/preferencias/preferencias_test.dart` (TC-01); `app/test/features/cuenta/menu_de_prueba_test.dart` (TC-01 y caso release); `app/test/l10n/textos_desde_arb_test.dart` (TC-02); `app/test/core/tema/contraste_test.dart` (TC-03); `app/test/core/router/app_shell_l10n_test.dart` (TC-04 + `textContrastGuideline`).
- **Verificar:** TC-TT-MOB-02-01 · TC-TT-MOB-02-02 · TC-TT-MOB-02-03 · TC-TT-MOB-02-04; las pruebas de TT-MOB-01 siguen en verde sin cambiar sus aserciones.
- **No hacer:** `skip:`, red real, datos reales; cambiar pruebas de TT-MOB-01 para que pasen.
- **Agente:** flutter-builder

## T5 — Documentación y evidencia
- **Modificar:** `app/README.md` (tema, idiomas, cómo agregar un texto y correr `flutter gen-l10n`); `Memoria.md`; `docs/architecture/*` (`codemap.py`).
- **Verificar:** TC-TT-MOB-02-01 (capturas en emulador: claro, oscuro, español, inglés, y el lanzador con «Knock»)
- **Agente:** flutter-builder / docs-keeper
