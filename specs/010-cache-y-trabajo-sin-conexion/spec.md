# Spec 010 — Caché y trabajo sin conexión

> **Estado:** Aprobada · **Repositorio:** knock-frontend · **Rector:** `constitution.md`

## 1. Objetivo
Definir cómo la app responde bien con señal irregular: caché local con revalidación, borradores y una base local con sincronización en alcance mínimo.

## 2. Alcance
**Dentro**
- Caché local de catálogos, perfiles, listados recientes e imágenes.
- Revalidación con `ETag`.
- Borradores de lo que la persona escribe.
- Base local (SQLite) con cola de envío en alcance mínimo.

**Fuera**
- Sincronización de todos los datos.
- Pantallas concretas.

## 3. Requisitos
- **R-01:** La app guarda por poco tiempo los catálogos, los perfiles ya vistos, los listados recientes y las imágenes.
- **R-02:** Antes de volver a descargar, la app pregunta al servidor con `ETag` y usa lo guardado si no cambió.
- **R-03:** Las pantallas muestran primero lo guardado y se actualizan cuando llegan los datos nuevos.
- **R-04:** No se guardan en caché las listas personales que cambian al crear algo.
- **R-05:** Al cerrar sesión se borra toda la caché y la base local.
- **R-06:** Lo que la persona escribe (texto y fotos elegidas) se conserva como borrador si se queda sin señal o cierra la app.
- **R-07:** La base local guarda solo catálogos, las últimas conversaciones y los mensajes por enviar.
- **R-08:** Los mensajes y cambios hechos sin conexión quedan en una cola y se envían en orden al volver la señal, con un identificador único para que no se dupliquen.

## 4. Criterios de aceptación
- **CA-01:** Dado un dato sin cambios, cuando la app lo pide de nuevo, entonces el servidor responde 304 y se usa lo guardado.
- **CA-02:** Dada una persona sin señal, cuando escribe un mensaje, entonces queda en la cola y se envía al volver la señal.
- **CA-03:** Dado un cierre de sesión, cuando se revisa el teléfono, entonces no queda caché ni base local.
- **CA-04:** Dado un mensaje repetido por reintento, cuando llega al servidor, entonces no se duplica.

## 5. Contrato
Consume `ETag`/`If-None-Match`. El encabezado `Idempotency-Key` no se usa en esta etapa (spec 010 del backend).

## 6. Amenazas y controles
| Amenaza | Control |
|---|---|
| Datos personales que quedan en el teléfono tras cerrar sesión | Borrado completo de caché y base local al cerrar sesión |
| Datos viejos mostrados como vigentes | Revalidación con `ETag` y vigencias cortas |
| Mensajes duplicados por reintentos | Identificador único por operación |

## 7. Plan de pruebas
| Tipo | ¿Aplica? | Motivo |
|---|---|---|
| Unitarias | Sí | Vigencias, revalidación y cola |
| Widget / componente | Sí | Pantalla mostrando lo guardado y luego lo nuevo |
| Integración | Sí | Base local real en el dispositivo de pruebas |
| Seguridad negativa | Sí | Cierre de sesión y borrado |
| Arquitectura | No | Se cubre en la spec 001 |
| Contrato | No | Se cubre en la spec 006 |

## 8. Decisiones
- **Caché con `ETag`:** gasta menos datos y responde rápido aunque la señal sea mala.
- **Base local en alcance mínimo:** refuerza la caché sin sincronizar lo que siempre debe consultarse en línea.
- **No cachear lo personal que cambia al crear algo:** evita mostrar datos viejos.

## 9. Decisiones de la revisión, riesgos y dudas
Decisiones tomadas en la revisión del 2026-11-04. Quien aprueba la spec las acepta; si alguna no convence, se cambia aquí antes de aprobar.

- **`Idempotency-Key` (decidido): la app no lo usa en esta etapa.** Se retoma cuando el backend lo defina para el primer endpoint que lo necesite.
- **Riesgo:** una base local con datos de conversaciones exige borrado fiable al cerrar sesión.

## Aprobación
- [x] Revisor 1 — nombre: José Julián Hernández Hernández fecha: 2026-11-04
- [x] Sin conflicto con la constitución
- **Estados:** Borrador → Aprobada (una persona; habilita el código) → Implementada (tras el merge)
