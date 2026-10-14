# TT-PRU-03 — tareas

## T1 — Confirmar prerrequisitos y opciones de bootstrap [Panel]
- **Crear:** —
- **Modificar:** —
- **Verificar:** que TT-STD-01 esté completado y acordar versiones Angular/Node/npm y opciones exactas de `ng new` no definidas en la ficha.
- **No hacer:** iniciar implementación antes de satisfacer la dependencia TT-STD-01 ni inventar un contrato API provisional.
- **Agente:** persona responsable / equipo.

## T2 — Crear la pantalla inicial del Panel [Panel]
- **Crear:** ejecutar `ng new panel` con componentes standalone, enrutamiento y SCSS; establecer la estructura `core/` y `features/`, incorporar Angular Material y crear la pantalla raíz con encabezado “Panel Knock” y menú lateral estático con Verificaciones, Reportes y Métricas.
- **Modificar:** archivos del proyecto y de presentación estrictamente necesarios para el scaffold y el renderizado estático acordados.
- **Verificar:** TC-TT-PRU-03-01 y TC-TT-PRU-03-02; incluir `npm audit --audit-level=high` y documentar en el PR la necesidad, el mantenimiento y la licencia declarada de las dependencias directas.
- **No hacer:** agregar login ni doble factor (HU-066, Sprint 3), Firebase Auth, llamadas reales a la API, datos reales ni funcionalidad administrativa en las opciones del menú.
- **Agente:** panel-builder después de que la spec esté Aprobada.

## T3 — Verificar el menú lateral estático [Pruebas]
- **Crear:** prueba unitaria del componente del menú con el ID `TC-TT-PRU-03-04`.
- **Modificar:** configuración unitaria solo si hace falta para ejecutar `ng test`.
- **Verificar:** que `ng test` comprueba las etiquetas Verificaciones, Reportes y Métricas y que el menú no implementa acciones.
- **No hacer:** añadir navegación o funcionalidad a las opciones del menú.
- **Agente:** panel-builder después de que la spec esté Aprobada.

## T4 — Comprobar ausencia de autenticación y solicitudes remotas [Pruebas]
- **Crear:** comprobación de navegador según la herramienta acordada; las plantillas Playwright, axe y Stryker están pendientes de KNOCK-41 y no bloquean esta tarea.
- **Modificar:** configuración de pruebas solo si hace falta para el alcance confirmado.
- **Verificar:** TC-TT-PRU-03-03 y los gates de Panel aplicables.
- **No hacer:** afirmar que los gates o pruebas se ejecutaron antes de implementarlos.
- **Agente:** panel-builder / persona responsable tras aprobación.

## Decisión de cliente API
- **Crear ahora:** no agregar cliente ni contrato provisional, porque no existe `contracts/openapi.v1.json`.
- **Pendiente:** generar el cliente OpenAPI Generator `typescript-angular` en `panel/src/app/api` cuando el contrato del backend esté disponible; no realizar llamadas reales en TT-PRU-03.
