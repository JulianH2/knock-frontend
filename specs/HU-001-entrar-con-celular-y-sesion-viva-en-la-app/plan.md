# plan.md — HU-001 (app) — Entrar con mi celular y mantener la sesión viva

> **Precondición:** spec Aprobada y, para los casos 08 a 10, las specs de backend de HU-003, HU-004 y HU-002 con contrato publicado. Antes de la aprobación no se escribe código.

## 1. Mapeo de archivos
- **Reutilizar (volver a buscar con `python scripts/codemap.py --query "sesion"`, `"red"` y `"oficios"` al empezar):**
  - `core/router/` (`Rutas`, `appRouterProvider`, `redireccionPorRol`): se amplía con la redirección por estado de sesión.
  - `core/preferencias/` (HU-052): no se toca; sirve de modelo del almacén con interfaz y doble de prueba.
  - `core/red/configuracion_api.dart` de la rama `chore/KNOCK-191-mock-api-from-contract` (TT-MOB-08): `ConfiguracionApi`, `ErrorDeConfiguracionApi` y la regla de release; se trae solo ese archivo y sus pruebas.
  - `features/oficios/` (TT-PRU-02): pantalla y mapeador; solo cambia el repositorio.
  - `core/widgets/pantalla_titulada.dart`, arnés `test/soporte/montar_app.dart`, `core/errores/failure.dart`.
- **Crear (`app/lib/`):** `core/sesion/almacen_sesion.dart`, `core/sesion/dispositivo.dart`, `core/sesion/estado_sesion.dart`, `core/red/interceptor_sesion.dart`, `features/identidad/{data,domain,presentation}/…` (entrar, código, completar perfil, cerrar sesión), `features/cuenta/presentation/mi_sesion_screen.dart`, `lib/l10n/*.arb` (claves `entrar…`, `perfil…`, `sesion…`).
- **Crear (pruebas):** las de los casos 01 a 13 y 16 en `test/`.
- **Modificar:** `pubspec.yaml` y `pubspec.lock` (con `flutter pub add`), `main.dart` (arranque asíncrono: configuración de red, Firebase y almacén), `app_router.dart` y `rutas.dart`, `cuenta_screen.dart` (Mi sesión y Cerrar sesión), `app/android/app/src/main/AndroidManifest.xml` (`INTERNET`), `Memoria.md`, `docs/architecture/*` (regenerado).
- **No tocar:** `.github/`, `scripts/`, la constitución, `app/android/app/google-services.json` (no se versiona), `core/tema/`, `core/preferencias/` (salvo pruebas que lo importen).

## 2. Riesgos y efectos secundarios
- Si el backend no tiene refresh, logout o perfil, no se programan esos casos (§4 de la spec).
- Firebase necesita `google-services.json` y la huella SHA-1 en la consola: sin ellos la verificación falla en el teléfono.
- Cambiar `main()` a asíncrono afecta las pruebas de arranque de TT-MOB-01 y HU-052 (ya lo hizo HU-052).
- El SCA puede rechazar licencias de pub (ver spec §8, decisión 6).

## 3. Pruebas por caso
| Caso | Prueba | Tipo |
|---|---|---|
| TC-HU-001-01 a 03, 05, 10, 11, 13, 16 | widget con dobles de Firebase y de la API | widget |
| TC-HU-001-04, 06, 07, 08, 09, 12 | unidad y widget con almacén y cliente falsos | unidad / widget |
| TC-HU-001-14 | recorrido en el teléfono contra la API real | manual |
| TC-HU-001-15, 17 | comandos | comando |

## 4. Secuencia
1. Spec Aprobada y spec de TT-MOB-03 aprobada; HU-001 del backend fusionada y desplegada.
2. Paquetes y su evaluación (T1). 3. Almacén seguro y `deviceId` (T2). 4. Cliente generado e interceptor (T3). 5. Entrar y código (T4). 6. Arranque con sesión viva y redirección (T5). 7. Perfil, Mi sesión y Cerrar sesión (T6, cuando exista su contrato). 8. Manifiesto, textos, accesibilidad (T7). 9. Recorrido real y evidencia (T8).

## 5. Verificación (comandos exactos)
```bash
python scripts/sdd_lint.py --trace HU-001 && python scripts/sync_agents.py --check
python scripts/codemap.py --check && python scripts/ci/check_exceptions.py
cd app && dart format --set-exit-if-changed lib test && flutter analyze && flutter test --coverage
```
