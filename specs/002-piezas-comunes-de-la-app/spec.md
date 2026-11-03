# Spec 002 — Piezas comunes de la app

> **Estado:** Borrador · **Repositorio:** knock-frontend · **Rector:** `constitution.md`

## 1. Objetivo
Definir las piezas que comparte toda la app: cliente de la API, sesión, errores, idiomas, tema y caché local.

## 2. Alcance
**Dentro**
- Cliente de la API generado desde el contrato.
- Componente de sesión (token, renovación y cierre).
- Manejo común de errores en español.
- Archivos de traducción (español e inglés) y tema claro, oscuro o automático.
- Caché local con revalidación por ETag y borradores.

**Fuera**
- Pantallas concretas.
- Base local con sincronización de mensajes.

## 3. Requisitos
- **R-01:** El código que llama a la API se genera automáticamente; nadie lo escribe a mano.
- **R-02:** La sesión agrega el token a cada petición, lo renueva al vencer y cierra la sesión si ya no es válido.
- **R-03:** Los errores de la API se traducen a mensajes comprensibles en español.
- **R-04:** Todos los textos viven en archivos de traducción en español e inglés, y la app cambia de idioma según el sistema.
- **R-05:** El tema define colores, tipografía y espaciado como tokens; ningún widget usa colores fijos.
- **R-06:** La caché guarda catálogos y listados recientes por poco tiempo, pregunta al servidor con ETag antes de volver a descargar y se borra al cerrar sesión.

## 4. Criterios de aceptación
- **CA-01:** Dado un token vencido, cuando la app hace una petición, entonces lo renueva y repite la petición.
- **CA-02:** Dado un error de la API, cuando se muestra, entonces el mensaje está en español.
- **CA-03:** Dado el modo oscuro, cuando se abre la app, entonces usa los tokens del tema oscuro.
- **CA-04:** Dado un cierre de sesión, cuando se revisa la caché, entonces está vacía.

## 5. Contrato
Consume el cliente generado del contrato OpenAPI y el flujo de renovación de sesión. Fija los mensajes de error en español por código de error de la API.

## 6. Amenazas y controles
| Amenaza | Control |
|---|---|
| Robo del token de sesión | Almacenamiento seguro del sistema y borrado al cerrar sesión (spec 009) |
| Un error de la API muestra información técnica a la persona | Manejo común que traduce los errores a mensajes entendibles y registra el detalle sin datos personales |
| Datos de otra persona en la caché | La caché se organiza por sesión y se borra completa al cerrar sesión |

## 7. Plan de pruebas
| Tipo | ¿Aplica? | Motivo |
|---|---|---|
| Unitarias | Sí | Renovación del token, mapeo de errores y caché |
| Widget / componente | Sí | Cambio de idioma y de tema |
| Integración | Sí | Cliente generado contra un servidor simulado |
| Seguridad negativa | Sí | Token vencido, error inesperado y caché tras el cierre de sesión |
| Arquitectura | Sí | El cliente generado no se edita a mano |
| Accesibilidad | Sí | Contraste y tamaño de texto en claro y oscuro |

## 8. Decisiones
- **Cliente generado:** si el backend cambia, la app deja de compilar en lugar de fallar en producción.
- **Textos fuera de las pantallas:** facilita agregar idiomas y revisar el lenguaje.
- **Caché con ETag:** gasta menos datos y responde rápido con señal irregular.

## 9. Riesgos y dudas abiertas
- Ninguna duda abierta por ahora; se agregan aquí las que surjan al revisar la spec.

## Aprobación
- [ ] Revisor 1 — nombre: ________ fecha: ________
- [ ] Sin conflicto con la constitución
- **Estados:** Borrador → Aprobada (una persona; habilita el código) → Implementada (tras el merge)
