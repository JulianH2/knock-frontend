# Checklist — TT-WEB-01

- [ ] Spec con 8 secciones + Aprobación, estado Aprobada por una persona y clave KNOCK-148
- [ ] Decisiones de §8 confirmadas por el líder (tecnología, privacidad provisional, estado de Play, sin analítica, Railway y rama, idioma)
- [ ] Pedidos al líder resueltos o registrados: job `landing` en el CI, Dependabot docker, `test_globs`, `code_dirs` con `landing/**`, scope `landing` y `technical_tasks` en `.agents/knock.json`, y quién edita `landing/`
- [ ] Cada caso TC-TT-WEB-01-01…09 con su prueba `test_TC_TT_WEB_01_KK` o con la salida de su comando en el PR
- [ ] `python -m unittest discover -s landing/tests -v` en verde (resultado real)
- [ ] Imagen fijada por versión y digest, sin root, puerto 8080; evaluación de la imagen en `Memoria.md`
- [ ] Cabeceras de §6 presentes en local y en la URL publicada (`curl -sI`, también en el 404)
- [ ] Sin recursos de terceros, sin JavaScript, sin estilos en línea, sin formularios ni cookies
- [ ] Contraste con los pares permitidos de TT-MOB-02 (≥ 4.5:1), `alt` en cada `<img>` y axe-core (`wcag2a`, `wcag2aa`, `wcag21a`, `wcag21aa`) con 0 violaciones, en claro y oscuro
- [ ] Nu HTML Checker fijado por digest sin errores (con su `--version` en el PR)
- [ ] HTTPS 200 con certificado válido y HTTP → HTTPS en la URL publicada
- [ ] Peso ≤ 150 KB con fuentes WOFF2 ≤ 50 KB cada una, gzip activo, Lighthouse 13.5.0 móvil con mediana de 3 corridas ≥ 90
- [ ] `/privacidad/` provisional sin texto legal y con `noindex` (o ya reemplazada por TT-WEB-02); reglas compartidas R1 a R3 confirmadas por el líder e idénticas en TT-WEB-02
- [ ] App de GitHub de Railway limitada a `knock-frontend`, sin tokens ni deploy keys; miembros del proyecto de Railway informados por el líder
- [ ] Fila en `docs/VERSIONES_DESPLEGADAS.md` y etiqueta `puntos-landing-N` en el PR
- [ ] `sdd_lint.py`, `sdd_lint.py --trace TT-WEB-01`, `codemap.py --check`, `check_exceptions.py` y `sync_agents.py --check` en OK
- [ ] `security-reviewer` LIBERA · `traceability-clerk` sin drift
- [ ] `Memoria.md` actualizado · informe final en el PR con «Uso de IA»
