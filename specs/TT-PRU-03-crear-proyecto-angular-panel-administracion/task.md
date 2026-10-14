# TT-PRU-03 — tareas

## T1 — Confirmar metadatos y decisiones de bootstrap pendientes [Panel]
- **Crear:** —
- **Modificar:** —
- **Verificar:** título oficial, épica y puntos de KNOCK-31 desde Jira/ficha autorizada; versión Angular/Node/npm; gestor de paquetes y configuración inicial de pruebas. Responsable Ángel Alexis Blas Castillo, Sprint S0 y área Prueba de roles proceden del usuario; HU-046 del Product Backlog es referencia funcional relacionada, no parte del alcance.
- **No hacer:** generar el proyecto ni resolver decisiones sin aprobación.
- **Agente:** persona responsable / equipo.

## T2 — Crear la pantalla inicial del Panel [Panel]
- **Crear:** proyecto Angular en `panel/` y pantalla raíz con el encabezado “Knock — Panel de administración”.
- **Modificar:** solo los archivos necesarios para el scaffold y el renderizado estático acordados.
- **Verificar:** TC-TT-PRU-03-01 y TC-TT-PRU-03-02; incluir `npm audit --audit-level=high` y documentar en el PR la necesidad, el mantenimiento y la licencia declarada de las dependencias directas.
- **No hacer:** agregar login, Firebase Auth, llamadas API, datos reales o funciones administrativas.
- **Agente:** panel-builder después de que la spec esté Aprobada.

## T3 — Comprobar ausencia de autenticación y API [Pruebas]
- **Crear:** pruebas de navegador según la herramienta confirmada; mientras no se confirme automatización, comprobación manual documentada de que no hay solicitudes a hosts remotos, aparte de recursos servidos localmente.
- **Modificar:** configuración de pruebas solo si se aprueba como parte del alcance.
- **Verificar:** TC-TT-PRU-03-03 y los gates aplicables de Panel.
- **No hacer:** afirmar que los gates o pruebas se ejecutaron antes de implementarlos.
- **Agente:** panel-builder / persona responsable tras aprobación.
