# Checklist — TT-WEB-02

- [ ] spec con 8 secciones + Aprobación, estado Aprobada y clave KNOCK-N
- [ ] Cada caso TC-TT-WEB-02-KK de este repo tiene prueba con su ID o comando con salida en el PR
- [ ] Amenazas de §6 con control y prueba
- [ ] Contrato y docs vivos actualizados (URLs de §4 comunicadas a TT-WEB-01, TT-MOB-06 y TT-TIE-03)
- [ ] Pruebas de `landing/tests/` en verde (resultados reales)
- [ ] Sin supresiones sin EXC-NNN; sin dependencias nuevas
- [ ] Texto legal aportado por el líder en un commit aparte; `data-estado="vigente"` puesto solo por él en un commit propio (o publicado como `borrador` con su aviso visible)
- [ ] Además del comentario obligatorio de par, Alexis y Guillermo comentaron el texto final antes de pasarlo a `vigente`
- [ ] Sin datos personales del equipo (correo, teléfono o domicilio particular) en las páginas (responsable Team Knock; contacto `soporte@tdevs.com.mx`)
- [ ] Páginas publicadas por HTTPS y enlazadas desde la landing (salida de `curl` en el PR)
- [ ] axe-core 4.14.0 con `wcag2a`, `wcag2aa`, `wcag21a` y `wcag21aa`: 0 violaciones en claro y oscuro (salida en el PR)
- [ ] Reglas compartidas R1 a R3 (confirmadas por el líder en el PR #43) idénticas en TT-WEB-01
- [ ] Decisión 2 y dudas 4, 5, 6, 12, 19, 20, 21, 22 y 23 de la spec §8 respondidas por el líder
- [ ] Inventario §5 coherente con el backend (HU-001, TT-API-12, TT-API-05) y columnas de Google Play revisadas en TT-TIE-03
- [ ] `security-reviewer` LIBERA · `traceability-clerk` sin drift
- [ ] `Memoria.md` actualizado · informe final en el PR
