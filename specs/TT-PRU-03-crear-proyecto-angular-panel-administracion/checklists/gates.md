# Checklist — TT-PRU-03

- [ ] Spec de 8 secciones con clave Jira, EP-13, 1 punto, dependencia TT-STD-01 y estado aprobado por una persona
- [ ] Cada caso TC-TT-PRU-03-01…04 tiene su prueba o evidencia conforme a la spec
- [ ] Prueba `ng test` del menú confirma Verificaciones, Reportes y Métricas sin funcionalidad
- [ ] Amenazas de §6 con control y caso verificador
- [ ] Auditoría de dependencias sin vulnerabilidades altas/críticas y revisión de necesidad, mantenimiento y licencia declarada documentada en el PR
- [ ] Cliente `typescript-angular` pospuesto hasta contar con `contracts/openapi.v1.json`; no crear contrato provisional ni llamadas reales
- [ ] Plantillas Playwright, axe y Stryker registradas como pendientes de KNOCK-41, no bloqueantes
- [ ] Decisiones abiertas de §8 sobre versiones/opciones técnicas resueltas antes de implementar
- [ ] Build, análisis estático, pruebas y accesibilidad ejecutados con resultados reales
- [ ] Cobertura conforme a `AGENTS.md`; política de mutación confirmada sin bajar umbrales
- [ ] `sdd_lint.py --trace TT-PRU-03`, `codemap.py --check`, `check_exceptions.py` y `sync_agents.py --check` en OK
- [ ] Sin login ni doble factor (HU-066, Sprint 3), redirección ni solicitudes a hosts remotos desde la ruta inicial; solo recursos locales del servidor de desarrollo
- [ ] `security-reviewer` LIBERA · `traceability-clerk` sin drift (antes del PR de implementación)
- [ ] `Memoria.md` actualizado · informe final en el PR
