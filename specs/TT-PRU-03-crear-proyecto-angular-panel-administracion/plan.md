# plan.md — TT-PRU-03 Crear el proyecto Angular del panel de administración y su pantalla inicial

## 1. Mapeo de archivos
- **Reutilizar (buscado con `codemap.py --query`):** no hay proyecto `panel/` ni componentes del panel en este checkout; revisar de nuevo el mapa antes de implementar. Seguir la estructura y reglas existentes en `AGENTS.md` y `docs/DECISION_TECNICA.md` §9. El Product Backlog recibido contiene HU-046 (acceso administrativo con permisos), una historia funcional distinta y fuera del alcance de este bootstrap.
- **Crear:** proyecto base en `panel/`; pantalla inicial estática y pruebas necesarias, tras confirmar las decisiones abiertas de `spec.md` §8.
- **Modificar:** configuración de CI o documentación solo si la revisión de alcance confirma que el nuevo proyecto lo requiere; no se presupone ningún cambio en este borrador.
- **No tocar:** `contracts/`, clientes generados, `app/` y servicios de `knock-backend`; no agregar login, consumo de API ni datos reales.

## 2. Riesgos y efectos secundarios
- El título oficial, épica y puntos de KNOCK-31 no aparecen en el Product Backlog recibido; responsable Ángel Alexis Blas Castillo, Sprint S0 y área Prueba de roles fueron indicados por el usuario. Confirmar los metadatos restantes desde la fuente Jira/ficha autorizada.
- La versión de Angular/Node/npm y las opciones de generación condicionan el build reproducible; confirmarlas con el equipo antes de ejecutar `ng new`.
- No se encontraron los archivos de configuración de Panel que `docs/templates/README.md` dice que deben copiarse. Confirmar fuente y alcance antes de añadir configuración o dependencias.
- La pantalla debe permanecer estática y no introducir dependencias de autenticación o de la API. Evitar que el scaffolding genere o conserve pantallas de ejemplo como experiencia inicial.
- No se ejecuta ninguna implementación como parte de este borrador.

## 3. Pruebas por caso
| Caso | Prueba | Suite |
|---|---|---|
| TC-TT-PRU-03-01 | Instalación reproducible y build de producción. | `cd panel && npm ci && npx ng build` |
| TC-TT-PRU-03-02 | La pantalla raíz muestra el encabezado exacto; abrir también la ruta en navegador. | Prueba de componente nombrada con `TC-TT-PRU-03-02`; humo manual `npx ng serve --open`. |
| TC-TT-PRU-03-03 | Abrir ruta raíz sin sesión; confirmar que no hay login/redirección ni solicitudes a API/Firebase necesarias para renderizar. | Comprobación de navegador/red; automatización Playwright pendiente de decisión. |

## 4. Secuencia
1. Confirmar los metadatos pendientes de KNOCK-31 y las decisiones de versión Angular/Node y herramientas indicadas como abiertas en `spec.md`.
2. Generar el proyecto únicamente después de que una persona apruebe la spec.
3. Añadir la pantalla inicial y pruebas correspondientes a los casos de §2.
4. Ejecutar build, pruebas, gates de Panel y trazabilidad; registrar resultados reales.

## 5. Verificación (comandos exactos)
```bash
cd panel && npm ci
cd panel && npx ng build
cd panel && npx ng serve --open
python scripts/sdd_lint.py
python scripts/sdd_lint.py --trace TT-PRU-03
python scripts/codemap.py --check
python scripts/ci/check_exceptions.py
python scripts/sync_agents.py --check
```
