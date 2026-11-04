# Spec 009 — Seguridad y configuración del cliente

> **Estado:** Aprobada · **Repositorio:** knock-frontend · **Rector:** `constitution.md`

## 1. Objetivo
Definir los controles de seguridad comunes a la app, el panel y la landing, y cómo se manejan las claves y los entornos.

## 2. Alcance
**Dentro**
- Configuración por entorno.
- Gestión de claves de servicios de terceros.
- Almacenamiento seguro de la sesión.
- Comunicación solo por HTTPS.
- Permisos del teléfono y datos personales.

**Fuera**
- Flujos de inicio de sesión y de registro.

## 3. Requisitos
- **R-01:** Ninguna clave ni secreto vive en el repositorio; las claves se leen de archivos locales o variables.
- **R-02:** La sesión se guarda en el almacenamiento seguro del sistema y se borra al cerrar sesión.
- **R-03:** Toda comunicación va por HTTPS y no se aceptan certificados inválidos.
- **R-04:** Los permisos del teléfono se piden al usarlos, con su motivo, y la app no se rompe si se niegan.
- **R-05:** Los registros de la app no incluyen datos personales.
- **R-06:** El panel usa una política de seguridad de contenido y no inserta HTML sin sanear.
- **R-07:** La primera vez que se abre la app, genera un identificador de dispositivo aleatorio (UUID), lo guarda en el almacenamiento seguro y lo envía como `deviceId` al iniciar sesión (spec 015 del backend). No usa identificadores propios del teléfono.
- **R-08:** Antes del primer inicio de sesión la app muestra el aviso de privacidad y envía `aceptaAviso = true` solo si la persona lo acepta; sin aceptarlo no se llama al servidor.
- **R-09:** Cuando el servidor responde 429 con `Retry-After`, la app muestra el tiempo de espera y no reintenta antes; no hace reintentos automáticos en bucle.

## 4. Criterios de aceptación
- **CA-01:** Dado el repositorio, cuando corre el job de secretos, entonces no encuentra claves.
- **CA-02:** Dado un cierre de sesión, cuando se revisa el almacenamiento, entonces no queda el token.
- **CA-03:** Dado un permiso negado, cuando se usa la función, entonces la app muestra un aviso y sigue funcionando.
- **CA-04:** Dada la app recién instalada, cuando inicia sesión dos veces, entonces envía el mismo `deviceId` las dos veces y no es un identificador del teléfono.
- **CA-05:** Dada una persona que no acepta el aviso, cuando intenta iniciar sesión, entonces la app no hace la llamada y explica por qué.
- **CA-06:** Dada una respuesta 429 con `Retry-After: 30`, cuando la app la recibe, entonces muestra el aviso y no vuelve a llamar hasta pasados 30 segundos.

## 5. Contrato
No aplica. Interfaces que fija: dónde se leen las claves (archivos locales y variables) y la política de seguridad de contenido del panel.

## 6. Amenazas y controles
| Amenaza | Control |
|---|---|
| Claves en el repositorio | Lectura desde archivos locales ignorados por Git o variables; escáner de secretos en el CI |
| Robo del token de sesión | Almacenamiento seguro del sistema y borrado al cerrar sesión |
| Intercepción del tráfico | Solo HTTPS y certificados válidos |
| Datos personales en los registros de la app | Los registros no incluyen datos personales |

## 7. Plan de pruebas
| Tipo | ¿Aplica? | Motivo |
|---|---|---|
| Unitarias | Sí | Lectura de configuración y borrado de sesión |
| Seguridad negativa | Sí | Escáner de secretos, token tras el cierre de sesión y permisos negados |
| Integración | Sí | La app con almacenamiento seguro simulado |
| Accesibilidad | Sí | Avisos de permisos negados |
| Arquitectura | No | Se cubre en las specs de arquitectura |
| Contrato | No | No aplica |

## 8. Decisiones
- **Almacenamiento seguro del sistema:** el token no queda en preferencias legibles.
- **Claves fuera del código:** protege al repositorio aunque se haga público.

## 9. Decisiones de la revisión, riesgos y dudas
Decisiones tomadas en la revisión del 2026-11-04. Quien aprueba la spec las acepta; si alguna no convence, se cambia aquí antes de aprobar.

- **`deviceId` al reinstalar (decidido).** Si se borran los datos o se reinstala la app, el identificador cambia y cuenta como un dispositivo nuevo; el límite de 10 sesiones de la spec 015 del backend lo absorbe.
- **429 (decidido).** La app obedece `Retry-After` (spec 009 del backend) y no reintenta antes.

## Aprobación
- [x] Revisor 1 — nombre: José Julián Hernández Hernández fecha: 2026-11-04
- [x] Sin conflicto con la constitución
- **Estados:** Borrador → Aprobada (una persona; habilita el código) → Implementada (tras el merge)
