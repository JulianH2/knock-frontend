# Mapa de código

> Generado por `scripts/codemap.py` el 2026-11-02T19:44:45Z. No editar a mano.
> **Antes de crear una clase, método o archivo, busca aquí o corre `python scripts/codemap.py --query "<qué necesitas>"`.**

## Resumen

| Módulo | Capas | Archivos | Tipos | Métodos públicos |
|---|---|---|---|---|
| `actividad` | presentation | 1 | 1 | 1 |
| `app` | - | 3 | 2 | 4 |
| `cuenta` | presentation | 2 | 4 | 4 |
| `errores` | core | 1 | 3 | 1 |
| `explorar` | presentation | 1 | 1 | 1 |
| `home` | components, pages | 2 | 2 | 0 |
| `inicio` | data, domain, presentation | 10 | 18 | 17 |
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
- `app/lib/main_spike_mapa.dart` — class `SpikeMapaApp`
  - `main()`:11, `build()`:20

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

**data**

- `app/lib/features/inicio/data/ubicacion_geolocator_repository.dart` — class `UbicacionGeolocatorRepository`
  - `obtenerUnaVez()`:20, `abrirAjustes()`:65

**domain**

- `app/lib/features/inicio/domain/punto_mapa.dart` — class `PuntoMapa`
  - `toString()`:28
- `app/lib/features/inicio/domain/ubicacion_repository.dart` — class `ResultadoUbicacion`, class `Concedida`, class `Denegada`, class `DenegadaParaSiempre`, class `ServicioDesactivado`, class `UbicacionRepository`
  - `toString()`:16

**presentation**

- `app/lib/features/inicio/presentation/inicio_screen.dart` — class `InicioScreen`
  - `build()`:11
- `app/lib/features/inicio/presentation/mapa/boton_mi_ubicacion.dart` — class `BotonMiUbicacion`
  - `build()`:23, `FloatingActionButton()`:43
- `app/lib/features/inicio/presentation/mapa/mapa_con_pines.dart` — class `MapaConPines`, class `_MapaConPinesState`, class `_CamaraGoogleMap`
  - `didUpdateWidget()`:37, `build()`:45, `moverA()`:71
- `app/lib/features/inicio/presentation/mapa/marcadores.dart` — —
  - `construirMarcadores()`:16
- `app/lib/features/inicio/presentation/mapa/mi_ubicacion_controller.dart` — class `CamaraMapa`, enum `AvisoUbicacion`, class `MiUbicacionController`
  - `build()`:43, `centrar()`:46, `abrirAjustes()`:65
- `app/lib/features/inicio/presentation/spike/mapa_spike_screen.dart` — class `MapaSpikeScreen`, class `_MapaSpikeScreenState`
  - `build()`:30, `Scaffold()`:31
- `app/lib/features/inicio/presentation/spike/pines_de_prueba.dart` — —
  - `pinesDePrueba()`:28

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
