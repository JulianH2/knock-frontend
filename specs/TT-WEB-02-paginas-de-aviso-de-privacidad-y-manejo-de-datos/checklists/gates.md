# Checklist — TT-WEB-02

- [ ] spec con 8 secciones + Aprobación, estado Aprobada y clave KNOCK-N
- [ ] Cada caso TC-TT-WEB-02-KK de este repo tiene prueba con su ID o comando con salida en el PR
- [ ] Amenazas de §6 con control y prueba
- [ ] Contrato y docs vivos actualizados (URLs de §4 comunicadas a TT-WEB-01, TT-MOB-06 y TT-TIE-03)
- [ ] Pruebas de `landing/tests/` en verde (resultados reales)
- [ ] Sin supresiones sin EXC-NNN; sin dependencias nuevas
- [ ] Texto legal aportado por el líder en un commit aparte; `data-estado="vigente"` puesto solo por él en un commit propio (o publicado como `borrador` con su aviso visible; sobre la prueba cerrada, spec §8 duda 27)
- [ ] Además del comentario obligatorio de par, Alexis y Guillermo comentaron el texto final antes de pasarlo a `vigente`
- [ ] Sin datos personales del equipo (correo, teléfono o domicilio particular) en las páginas (nombre legal y domicilio del responsable y número de WhatsApp del canal: los fija el líder; contacto `soporte@tdevs.com.mx`)
- [ ] Sin claves internas (`TT-`, `HU-`, `KNOCK-`) en el HTML público, ni en marcadores ni en comentarios (TC-08)
- [ ] Sin `[PENDIENTE` ni `[DECISIÓN` en las tres páginas antes de la primera subida a la prueba cerrada (conteo en el PR) y TT-MOB-06 en ese AAB
- [ ] Páginas publicadas por HTTPS y enlazadas desde la landing (salida de `curl` en el PR)
- [ ] axe-core 4.14.0 con `wcag2a`, `wcag2aa`, `wcag21a` y `wcag21aa`: 0 violaciones en claro y oscuro (salida en el PR)
- [ ] Reglas compartidas R1 a R3 (confirmadas por el líder en el PR #43) idénticas en TT-WEB-01
- [ ] Dudas 1, 21, 24, 25, 26, 27 y 28 de la spec §8 respondidas por el líder (la decisión 2 y las dudas 4, 5, 6, 12, 19, 20, 22 y 23 ya las respondió en el PR #43)
- [ ] Inventario §5 coherente con el backend (HU-001, TT-API-12, TT-API-05) y columnas de Google Play revisadas en TT-TIE-03
- [ ] `security-reviewer` LIBERA · `traceability-clerk` sin drift
- [ ] `Memoria.md` actualizado · informe final en el PR
