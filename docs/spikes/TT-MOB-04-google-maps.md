# TT-MOB-04 — Resultados del spike de Google Maps en Flutter

> **Jira:** KNOCK-39 · **Spec:** `specs/TT-MOB-04-spike-google-maps-pines-agrupacion/spec.md` · **Prepara:** HU-011 (KNOCK-55)
> **Estado del documento:** parcial (2026-10-22). Falta la parte que necesita la clave de Maps (no existe todavía: espera al plan Blaze, TT-FB-02) y un Android físico.

## 1. Entorno
- Flutter 3.47.7 stable · Dart 3.13.5 · Windows 11.
- Paquetes: `google_maps_flutter` 2.19.0 (agrupación nativa con `ClusterManager`) y `geolocator` 14.1.2. `flutter_driver` (SDK) solo en `dev_dependencies` para la medición.
- Dispositivo para TC-01: **pendiente** (modelo, versión de Android y año se anotan aquí al medir).

## 2. Qué se construyó
| Pieza | Dónde | ¿Se queda en HU-011? |
|---|---|---|
| `PuntoMapa`, `ResultadoUbicacion`, `UbicacionRepository` | `app/lib/features/inicio/domain/` | Sí |
| Ubicación con `geolocator` (permiso al tocar, una lectura, precisión baja, límite 15 s) | `app/lib/features/inicio/data/ubicacion_geolocator_repository.dart` | Sí |
| Marcadores con agrupación (`construirMarcadores`, `agrupacionDePines`) | `app/lib/features/inicio/presentation/mapa/marcadores.dart` | Sí |
| `MapaConPines` (`GoogleMap` sin capa ni botón nativo de ubicación) | `.../presentation/mapa/mapa_con_pines.dart` | Sí |
| Controlador y botón «Mi ubicación» | `.../presentation/mapa/{mi_ubicacion_controller,boton_mi_ubicacion}.dart` | Sí |
| Pantalla de prueba, 50 pines ficticios, punto de entrada | `.../presentation/spike/`, `app/lib/main_spike_mapa.dart` | No (se borra) |
| Clave por `local.properties` / variable `MAPS_API_KEY` → `manifestPlaceholders` | `app/android/app/build.gradle.kts`, `AndroidManifest.xml` | Sí |

## 3. Resultados por caso
| Caso | Resultado |
|---|---|
| TC-01 fluidez (50 pines, arrastre y zoom, *profile*) | **Sin medir.** Prueba escrita (`integration_test/mapa_rendimiento_test.dart` + `test_driver/perf_driver.dart`); requiere Android físico y la clave. Meta: p90 de construcción y de rasterizado ≤ 16 ms, *frames* fuera de presupuesto ≤ 5 %. |
| TC-02 clave inútil desde otra app | **Pendiente:** no hay clave. Se hace con `adb logcat -s Google_Maps_Android_API` cambiando el `applicationId` en local. |
| TC-03 agrupación | Automático en verde: los 50 marcadores llevan el mismo `clusterManagerId` que el `ClusterManager` del mapa. Comportamiento visual (agrupar al alejar, separar al acercar): pendiente de ver con la clave. |
| TC-04 «Mi ubicación» concedido | Automático en verde: el permiso no se pide al abrir; al tocar se lee una vez y la cámara se mueve a ese punto; la posición no se guarda. |
| TC-05 permiso negado / servicio apagado | Automático en verde: la cámara no se mueve y aparece el aviso; «Abrir ajustes» cuando se negó para siempre. |
| TC-06 pines ficticios | Automático en verde: 50 pines `prueba-01`…`prueba-50`, deterministas, dentro de lon −99.40..−99.28, lat 20.00..20.12. |
| TC-07 sin clave en el repo | `local.properties` ignorado; ninguna clave de Google en el repositorio. El build sin clave queda por confirmar (ver §6). |

## 4. Configuración de claves (sin valores)
- Una sola clave, de Android, en el proyecto de Google Cloud de Firebase; la crea y custodia el líder cuando el plan Blaze esté activo.
- Restricción de aplicación: paquete `app.knock.mobile` + SHA-1 de depuración de cada integrante. Restricción de API: solo Maps SDK for Android.
- Cuota diaria de 1 000 cargas y alerta de presupuesto de 1 USD.
- En la máquina: `MAPS_API_KEY=…` en `app/android/local.properties` o variable de entorno. Sin clave el valor es vacío: compila y el mapa queda en blanco.

## 5. Precio vigente
Consultado el **2026-10-22** en <https://developers.google.com/maps/billing-and-pricing/pricing> (la página dice «Last updated 2026-10-21 UTC»), sección *Maps – loads*, en USD por 1 000 eventos:

| SKU | Nivel | Uso gratuito al mes | Precio sobre el tope |
|---|---|---|---|
| Maps SDK (mapas nativos en móvil) | Essentials | **Ilimitado** | — (no aplica) |
| Dynamic Maps (web / JavaScript, fuera de alcance) | Essentials | 10 000 | 7.00 hasta 100 000; luego 5.60, 4.20, 2.10 y 0.53 por tramo |

La consulta se hizo con una herramienta que resume la página; falta la captura de pantalla. Aun con uso gratuito, Maps pide una cuenta de facturación activa: por eso la clave espera al plan Blaze.

## 6. Límites y lo que no se pudo verificar
- **Mapa pintado:** no hay clave, así que no se vio el mapa, la agrupación real ni el centrado en el emulador.
- **TC-01:** sin Android físico ni clave, sin medición. No se da la fluidez por confirmada.
- **TC-02:** pendiente de la clave.
- **Build sin clave:** se intentó `flutter build apk --debug` el 2026-10-22 y falló por **disco lleno** en la máquina (Gradle no pudo escribir en su caché); hay que repetirlo con espacio libre o tomarlo del job del CI.
- El lienzo del mapa no es accesible para lectores de pantalla (límite del SDK); HU-011 ofrece la lista del panel como alternativa.

## 7. Recomendación para HU-011
- Reutilizar `domain/`, `data/` y `presentation/mapa/` tal cual; borrar `presentation/spike/` y `lib/main_spike_mapa.dart`.
- Mantener la agrupación nativa (`ClusterManager`): no hace falta un paquete extra.
- Mantener el botón propio de «Mi ubicación» con permiso al tocar y precisión aproximada, o sustituirlo por el centro de la colonia (constitución §6).
- Iconos de grupo y de pin, y textos en ARB, en TT-MOB-02 / HU-011.
- Confirmar con TC-01 en dispositivo físico antes de prometer más de 50 pines; si no es fluido, abrir un ADR en `docs/decisiones/`.
