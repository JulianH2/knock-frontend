# HU-001 (app) — tareas

> Ninguna tarea empieza antes de que la spec esté Aprobada por una persona distinta del autor.

## T1 — Evaluar y agregar paquetes [Mobile]
- **Verificar:** TC-HU-001-15.
- **No hacer:** agregar otros paquetes; fijar versiones a mano en el lock.

## T2 — Almacén seguro y deviceId [Mobile]
- **Crear:** `core/sesion/almacen_sesion.dart`, `core/sesion/dispositivo.dart` y sus pruebas.
- **Verificar:** TC-HU-001-04 y 06.

## T3 — Cliente generado e interceptor de sesión [Mobile] (con la spec de TT-MOB-03)
- **Verificar:** TC-HU-001-08 y 12.
- **No hacer:** llamadas HTTP escritas a mano.

## T4 — Entrar y código [Mobile]
- **Crear:** `features/identidad/…` (pantallas, controlador, pasarela de Firebase con interfaz y doble).
- **Verificar:** TC-HU-001-01, 02, 03, 05 y 13.

## T5 — Arranque con sesión viva y redirección [Mobile]
- **Modificar:** `main.dart`, `app_router.dart`, `rutas.dart`.
- **Verificar:** TC-HU-001-07.

## T6 — Completar perfil, Mi sesión y Cerrar sesión [Mobile] (el perfil espera la spec de backend)
- **Verificar:** TC-HU-001-09, 10 y 11.

## T7 — Manifiesto, textos y accesibilidad [Mobile]
- **Modificar:** `AndroidManifest.xml` (`INTERNET`), ARB es/en.
- **Verificar:** TC-HU-001-12 y 16.

## T8 — Recorrido real y evidencia [Pruebas]
- **Verificar:** TC-HU-001-14 y 17.
