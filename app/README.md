# Knock — app móvil (Flutter)

App de Knock para clientes y técnicos. Base creada en TT-MOB-01 (KNOCK-24): Clean Architecture por función, Riverpod, go_router y la barra inferior de la maqueta. Tema claro y oscuro con la paleta de la maqueta y textos en español e inglés desde TT-MOB-02 (KNOCK-25).

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
La cuenta empieza como cliente (4 pestañas), en español y con el tema del sistema. En **Mi cuenta** hay un menú de prueba: el interruptor «Modo técnico (prueba)» agrega la pestaña **Trabajo**, y los selectores «Tema (prueba)» (Sistema · Claro · Oscuro) e «Idioma (prueba)» (Español · English) cambian la app sin reiniciarla. El menú solo existe en compilaciones debug y profile (`!kReleaseMode`); el rol lo dará la sesión real y la pantalla de Configuración con la preferencia guardada es de HU-052. La elección vive solo en memoria.

## Tema
- `lib/core/tema/colores.dart`: tokens de la maqueta (`css/knock.css`) en claro y oscuro, y los `ColorScheme` completos.
- `lib/core/tema/tema.dart`: `temaClaro` y `temaOscuro` (Material 3, fuente Nunito).
- `lib/core/tema/contraste.dart`: relación de contraste WCAG 2.x; `test/core/tema/contraste_test.dart` exige ≥ 4.5:1 en cada par `onX`/`X`.
- **Regla de contraste:** estos pares no llegan a 4.5:1 y **no** se usan para texto ni para botones: en claro, `amber` (#E9682D) como texto sobre crema o blanco, y blanco sobre `amber`; en oscuro, `mut`, `navy` o `amber` sobre `navybg`, y `amber` sobre `navy-soft`. Para texto naranja usa `ColoresClaro.amberInk`; sobre `amber` va tinta (`onPrimary`). Usa siempre los colores de `Theme.of(context).colorScheme`, no colores sueltos.
- **Fuente:** Nunito 400, 500, 600 y 700 empaquetada en `assets/fonts/nunito/` con su licencia (`OFL.txt`, SIL Open Font License 1.1). No se usa `google_fonts` ni se descarga nada en tiempo de ejecución.

## Idiomas (ARB)
- Español es el idioma fuente (`lib/l10n/app_es.arb`, plantilla y respaldo) e inglés el segundo (`lib/l10n/app_en.arb`). Configuración en `l10n.yaml`.
- **Agregar un texto:** 1) agrega la clave en `app_es.arb` (camelCase con prefijo, p. ej. `tabInicio`, `pruebaTema`) con su `@clave.description`; 2) agrega la misma clave en `app_en.arb`; 3) corre `flutter gen-l10n`; 4) úsalo con `AppLocalizations.of(context).<clave>`. Nunca escribas un texto visible directo en un widget.
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
    errores/ red/      vacíos: TT-MOB-03
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
