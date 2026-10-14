# plan.md — TT-PRU-03 Crear el proyecto Angular del panel de administración y su pantalla inicial

## 1. Mapeo de archivos
- **Reutilizar (buscado con `codemap.py --query`):** no hay proyecto `panel/` ni componentes del panel en este checkout; revisar de nuevo el mapa antes de implementar. Seguir la estructura `core/`, `features/` y `api/` de la constitución.
- **Crear:** proyecto `panel/` con `ng new panel`, componentes standalone, enrutamiento, SCSS y Angular Material; pantalla estática con menú lateral y su prueba unitaria.
- **Cliente API:** `contracts/openapi.v1.json` no existe. Se pospone la generación del cliente OpenAPI Generator `typescript-angular` hasta que haya contrato; no crear contrato provisional ni realizar llamadas reales.
- **Modificar:** configuración de CI o documentación solo si la revisión de alcance confirma que el nuevo proyecto lo requiere; no se presupone ningún cambio en este borrador.
- **No tocar:** contrato ni clientes generados del otro repo, `app/` y servicios de `knock-backend`; no agregar login, doble factor, llamadas reales a la API ni datos reales.

## 2. Riesgos y efectos secundarios
- TT-PRU-03 depende de TT-STD-01; confirmar que el prerrequisito esté completado antes de implementar.
- La versión de Angular/Node/npm y las opciones de generación condicionan el build reproducible; confirmarlas con el equipo antes de ejecutar `ng new`.
- Las plantillas Playwright, axe y Stryker para Panel llegan con KNOCK-41; se registran como pendientes y no bloquean esta tarea.
- El criterio de ausencia de red remota incluye Knock, Firebase y cualquier otro host externo; los únicos recursos permitidos durante el humo manual son los servidos localmente por el servidor de desarrollo.
- La evaluación de dependencias cubre auditoría automática de vulnerabilidades y revisión documentada de necesidad, mantenimiento y licencia declarada de las dependencias directas.
- La pantalla debe permanecer estática y no introducir dependencias de autenticación ni llamadas a la API. Evitar que el scaffolding genere o conserve pantallas de ejemplo como experiencia inicial.
- Este cambio al PR alinea la documentación; no incluye implementación del panel.

## 3. Pruebas por caso
| Caso | Prueba | Suite |
|---|---|---|
| TC-TT-PRU-03-01 | Instalación reproducible, build de producción, auditoría sin vulnerabilidades altas/críticas y evaluación documentada de dependencias directas. | `cd panel && npm ci && npx ng build && npm audit --audit-level=high`; revisión de necesidad, mantenimiento y licencia declarada en el PR. |
| TC-TT-PRU-03-02 | La pantalla raíz muestra el encabezado exacto; abrir también la ruta en navegador. | Prueba de componente nombrada con `TC-TT-PRU-03-02`; humo manual `npx ng serve --open`. |
| TC-TT-PRU-03-03 | Abrir ruta raíz sin sesión; confirmar que no hay login/redirección ni solicitudes a hosts remotos necesarias para renderizar. | Comprobación manual de navegador/Network (solo recursos locales); automatización Playwright pendiente de decisión. |
| TC-TT-PRU-03-04 | El componente del menú muestra Verificaciones, Reportes y Métricas sin acciones. | Prueba unitaria nombrada con `TC-TT-PRU-03-04`, ejecutada con `cd panel && ng test`. |

## 4. Secuencia
1. Confirmar que TT-STD-01 esté completado; acordar versiones Angular/Node/npm y opciones de generación que la ficha no especifica.
2. Implementar según esta spec Aprobada, conservando el estado y la firma de revisión existentes.
3. Crear la pantalla inicial y la prueba unitaria del menú TC-TT-PRU-03-04 junto con las verificaciones de los otros casos.
4. Ejecutar build, auditoría, `ng test`, humo de navegador y gates de gobierno; registrar resultados reales. Las plantillas Playwright/axe/Stryker de Panel llegan con KNOCK-41 y no bloquean esta tarea.

## 5. Verificación (comandos exactos)
```bash
cd panel && npm ci
cd panel && npx ng build
cd panel && npm audit --audit-level=high
cd panel && ng test --watch=false
cd panel && npx ng serve --open
python scripts/sdd_lint.py
python scripts/sdd_lint.py --trace TT-PRU-03
python scripts/codemap.py --check
python scripts/ci/check_exceptions.py
python scripts/sync_agents.py --check
```
