# Mapa de código

> Generado por `scripts/codemap.py` el 2026-10-27T21:14:22Z. No editar a mano.
> **Antes de crear una clase, método o archivo, busca aquí o corre `python scripts/codemap.py --query "<qué necesitas>"`.**

## Resumen

| Módulo | Capas | Archivos | Tipos | Métodos públicos |
|---|---|---|---|---|
| `actividad` | presentation | 1 | 1 | 1 |
| `app` | - | 2 | 1 | 2 |
| `cuenta` | presentation | 2 | 4 | 4 |
| `errores` | core | 1 | 3 | 1 |
| `explorar` | presentation | 1 | 1 | 1 |
| `home` | components, pages | 2 | 2 | 0 |
| `inicio` | presentation | 1 | 1 | 1 |
| `l10n` | - | 3 | 4 | 5 |
| `layout` | core | 1 | 1 | 0 |
| `oficios` | -, data, domain, presentation | 8 | 12 | 11 |
| `panel` | - | 3 | 1 | 0 |
| `preferencias` | core | 1 | 2 | 4 |
| `router` | core | 3 | 3 | 4 |
| `sesion` | core | 1 | 1 | 2 |
| `tema` | core | 3 | 3 | 1 |
| `trabajo` | presentation | 1 | 1 | 1 |
| `widgets` | core | 1 | 1 | 1 |

## Índice por módulo

### actividad

**presentation**

- `app/lib/features/actividad/presentation/actividad_screen.dart` — class `ActividadScreen`
  - `build()`:11

### app

**-**

- `app/lib/app.dart` — class `KnockApp`
  - `build()`:16
- `app/lib/main.dart` — —
  - `main()`:5

### cuenta

**presentation**

- `app/lib/features/cuenta/presentation/cuenta_screen.dart` — class `CuentaScreen`
  - `build()`:13
- `app/lib/features/cuenta/presentation/widgets/menu_de_prueba.dart` — class `MenuDePrueba`, class `_Encabezado`, class `_Opcion`
  - `build()`:16, `build()`:67, `build()`:83

### errores

**core**

- `app/lib/core/errores/failure.dart` — class `Failure`, class `DatosInvalidosFailure`, class `ServicioNoDisponibleFailure`
  - `toString()`:10

### explorar

**presentation**

- `app/lib/features/explorar/presentation/explorar_screen.dart` — class `ExplorarScreen`
  - `build()`:15

### home

**components**

- `panel/src/app/features/home/components/static-menu.component.ts` — class `StaticMenuComponent`

**pages**

- `panel/src/app/features/home/pages/home-page.component.ts` — class `HomePageComponent`

### inicio

**presentation**

- `app/lib/features/inicio/presentation/inicio_screen.dart` — class `InicioScreen`
  - `build()`:11

### l10n

**-**

- `app/lib/l10n/generado/app_localizations.dart` — class `AppLocalizations`, class `_AppLocalizationsDelegate`
  - `of()`:70, `load()`:197, `isSupported()`:202, `shouldReload()`:206, `lookupAppLocalizations()`:209
- `app/lib/l10n/generado/app_localizations_en.dart` — class `AppLocalizationsEn`
- `app/lib/l10n/generado/app_localizations_es.dart` — class `AppLocalizationsEs`

### layout

**core**

- `panel/src/app/core/layout/app-shell.component.ts` — class `AppShellComponent`

### oficios

**-**

- `app/lib/features/oficios/oficios_providers.dart` — —

**data**

- `app/lib/features/oficios/data/oficio_mapper.dart` — class `OficioMapper`
  - `listaDesdeContrato()`:13, `desdeContrato()`:21
- `app/lib/features/oficios/data/oficios_repository_de_prueba.dart` — class `OficiosRepositoryDePrueba`
  - `listar()`:24

**domain**

- `app/lib/features/oficios/domain/modalidad.dart` — class `Modalidad`
- `app/lib/features/oficios/domain/oficio.dart` — class `Oficio`
- `app/lib/features/oficios/domain/oficios_repository.dart` — class `OficiosRepository`

**presentation**

- `app/lib/features/oficios/presentation/oficios_controller.dart` — class `OficiosController`
  - `build()`:9, `reintentar()`:13
- `app/lib/features/oficios/presentation/oficios_screen.dart` — class `OficiosScreen`, class `_Cargando`, class `_Vacio`, class `_ConError`, class `_Lista`, class `_FilaOficio`
  - `build()`:15, `build()`:39, `build()`:48, `build()`:65, `build()`:93, `build()`:105

### panel

**-**

- `panel/src/app/app.routes.ts` — —
- `panel/src/app/app.ts` — class `App`
- `panel/src/main.ts` — —

### preferencias

**core**

- `app/lib/core/preferencias/preferencias_provider.dart` — class `Preferencias`, class `PreferenciasNotifier`
  - `copyWith()`:22, `build()`:43, `cambiarTema()`:45, `cambiarIdioma()`:49

### router

**core**

- `app/lib/core/router/app_router.dart` — —
- `app/lib/core/router/app_shell.dart` — class `_Destino`, class `AppShell`
  - `ramasVisibles()`:35, `build()`:48, `Scaffold()`:53
- `app/lib/core/router/rutas.dart` — class `Rutas`
  - `redireccionPorRol()`:17

### sesion

**core**

- `app/lib/core/sesion/es_tecnico_provider.dart` — class `EsTecnicoNotifier`
  - `build()`:13, `cambiar()`:16

### tema

**core**

- `app/lib/core/tema/colores.dart` — class `ColoresClaro`, class `ColoresOscuro`, class `ColoresError`
- `app/lib/core/tema/contraste.dart` — —
  - `relacionDeContraste()`:16
- `app/lib/core/tema/tema.dart` — —

### trabajo

**presentation**

- `app/lib/features/trabajo/presentation/trabajo_screen.dart` — class `TrabajoScreen`
  - `build()`:11

### widgets

**core**

- `app/lib/core/widgets/pantalla_titulada.dart` — class `PantallaTitulada`
  - `build()`:14
