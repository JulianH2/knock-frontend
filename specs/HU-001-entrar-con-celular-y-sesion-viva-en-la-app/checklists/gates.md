# Checklist — HU-001 (app)

- [ ] Spec de 8 secciones con clave Jira (KNOCK-43), estado Aprobada por una persona distinta del autor y dudas de §8 resueltas
- [ ] Spec de TT-MOB-03 (KNOCK-38) aprobada; HU-001 del backend fusionada y desplegada con URL `https`
- [ ] Cada caso TC-HU-001-01…13 y 16 tiene su prueba (`sdd_lint.py --trace HU-001`); los casos 14, 15 y 17 tienen su evidencia o salida de comando en el PR
- [ ] Tokens solo en el almacén seguro y en memoria; ninguno en `shared_preferences` ni en registros
- [ ] Release nunca usa simulación; `INTERNET` en el manifiesto principal; `google-services.json` no está en el repositorio
- [ ] Casilla del aviso obligatoria y `aceptaAviso: true` solo con ella marcada
- [ ] Cerrar sesión limpia el almacén aunque falle la red
- [ ] Un solo refresco a la vez; si falla, vuelve a la entrada
- [ ] Textos en `app_es.arb` y `app_en.arb`; semántica y 48 dp; contraste en claro y oscuro
- [ ] Paquetes nuevos evaluados en `Memoria.md` y en el PR; SCA en verde
- [ ] Build, análisis estático, formato y pruebas en verde con cobertura ≥ 50 %
- [ ] `security-reviewer` LIBERA · `traceability-clerk` sin drift
- [ ] `Memoria.md` actualizado · informe final en el PR
