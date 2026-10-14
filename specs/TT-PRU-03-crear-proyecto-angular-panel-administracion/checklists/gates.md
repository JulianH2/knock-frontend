# Checklist — TT-PRU-03

- [ ] Spec de 8 secciones con clave Jira, título/metadatos confirmados y estado aprobado por una persona
- [ ] Cada caso TC-TT-PRU-03-01…03 tiene su prueba o evidencia conforme a la spec
- [ ] Amenazas de §6 con control y caso verificador
- [ ] Auditoría de dependencias sin vulnerabilidades altas/críticas y revisión de necesidad, mantenimiento y licencia declarada documentada en el PR
- [ ] Decisiones abiertas de §8 resueltas en fuente autorizada antes de implementar
- [ ] Build, análisis estático, pruebas y accesibilidad ejecutados con resultados reales
- [ ] Cobertura conforme a `AGENTS.md`; política de mutación confirmada sin bajar umbrales
- [ ] `sdd_lint.py --trace TT-PRU-03`, `codemap.py --check`, `check_exceptions.py` y `sync_agents.py --check` en OK
- [ ] Sin login, redirección ni solicitudes a hosts remotos desde la ruta inicial; solo recursos locales del servidor de desarrollo
- [ ] `security-reviewer` LIBERA · `traceability-clerk` sin drift (antes del PR de implementación)
- [ ] `Memoria.md` actualizado · informe final en el PR
