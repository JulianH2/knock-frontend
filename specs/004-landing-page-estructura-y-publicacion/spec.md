# Spec 004 — Landing page: estructura y publicación

> **Estado:** Aprobada · **Repositorio:** knock-frontend · **Rector:** `constitution.md`

## 1. Objetivo
Definir cómo está hecha y dónde se publica la landing page, sin escribir su contenido.

## 2. Alcance
**Dentro**
- Sitio estático con HTML y CSS.
- Hosting con HTTPS y publicación automática desde la rama principal.
- Cabeceras de seguridad y política de contenido.
- Rutas reservadas para el aviso de privacidad y la eliminación de cuenta.

**Fuera**
- Texto del aviso de privacidad.
- Analítica.

## 3. Requisitos
- **R-01:** La landing es un sitio estático sin servidor propio ni JavaScript innecesario.
- **R-02:** Se publica con HTTPS obligatorio y cada cambio aprobado en la rama principal se publica solo.
- **R-03:** El servidor envía una política de seguridad de contenido y las cabeceras de seguridad habituales.
- **R-04:** El proceso de publicación revisa enlaces rotos y busca claves olvidadas.
- **R-05:** La landing lleva su propia versión.

## 4. Criterios de aceptación
- **CA-01:** Dado un cambio fusionado en la rama principal, cuando termina el proceso, entonces la landing se publica.
- **CA-02:** Dada la landing publicada, cuando se pide por HTTP, entonces redirige a HTTPS.
- **CA-03:** Dado un enlace roto, cuando corre el proceso, entonces falla.

## 5. Contrato
No consume la API. Interfaces que fija: las rutas reservadas `/privacidad/` y `/eliminar-cuenta/`, y la URL de redirección a Google Play.

## 6. Amenazas y controles
| Amenaza | Control |
|---|---|
| Un clon de la página engaña a las personas | HTTPS con HSTS y un único enlace oficial desde la ficha de Google Play y la app |
| Inyección de contenido o terceros | Sitio estático, sin JavaScript innecesario y política de seguridad de contenido restrictiva |
| Un enlace de la página apunta a otra aplicación | El enlace a Google Play es una constante revisada en el PR |

## 7. Plan de pruebas
| Tipo | ¿Aplica? | Motivo |
|---|---|---|
| Unitarias | Sí | Revisión de enlaces y de cabeceras con scripts |
| Integración | Sí | Contenedor local con las cabeceras |
| Seguridad negativa | Sí | Cabeceras de seguridad y ausencia de recursos de terceros |
| Humo / extremo a extremo | Sí | Publicación en Railway y redirección HTTP a HTTPS |
| Accesibilidad | Sí | Contraste, títulos y enlaces con nombre |
| Arquitectura | No | No aplica |

## 8. Decisiones
- **Railway:** el líder ya tiene un espacio contratado, no genera costo adicional y usa HTTPS; se descartó Azure Static Web Apps porque sus regiones no coinciden con las que permite la suscripción.
- **Estática:** menos superficie de ataque y costo cero.

## 9. Riesgos y dudas abiertas
- Ninguna duda abierta por ahora; se agregan aquí las que surjan al revisar la spec.

## Aprobación
- [x] Revisor 1 — nombre: José Julián Hernández Hernández fecha: 2026-11-04
- [x] Sin conflicto con la constitución
- **Estados:** Borrador → Aprobada (una persona; habilita el código) → Implementada (tras el merge)
