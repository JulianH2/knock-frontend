# Checklist — TT-WEB-02

- [ ] spec con 8 secciones + Aprobación, estado Aprobada y clave KNOCK-N
- [ ] Cada caso TC-TT-WEB-02-KK de este repo tiene prueba con su ID o comando con salida en el PR
- [ ] Amenazas de §6 con control y prueba
- [ ] Contrato y docs vivos actualizados (URLs de §4 comunicadas a TT-WEB-01, TT-MOB-06 y TT-TIE-03)
- [ ] Pruebas de `landing/tests/` en verde (resultados reales)
- [ ] Sin supresiones sin EXC-NNN; sin dependencias nuevas
- [ ] Texto legal aportado por el líder en un commit aparte; `data-estado="vigente"` puesto solo por él en un commit propio antes de la primera subida a la prueba cerrada (regla compartida R1); mientras tanto, `borrador` con su aviso visible, solo para pruebas internas y nunca en Google Play
- [ ] Además del comentario obligatorio de par, Alexis y Guillermo comentaron el texto final antes de pasarlo a `vigente`
- [ ] Sin datos personales del equipo (correo, teléfono o domicilio particular) en las páginas (nombre legal y domicilio del responsable, proveedores del canal de atención y número desde el que se envía la confirmación: los fija el líder; contacto `soporte@tdevs.com.mx`)
- [ ] Sin claves internas (`TT-`, `HU-`, `KNOCK-`) en el HTML público, ni en marcadores ni en comentarios (TC-08)
- [ ] Las tres páginas en `vigente`, sin `[PENDIENTE` ni `[DECISIÓN`, antes de la primera subida a la prueba cerrada (estado y conteo en el PR; regla compartida R1) y TT-MOB-06 en ese AAB
- [ ] Páginas publicadas por HTTPS y enlazadas desde la landing (salida de `curl` en el PR)
- [ ] axe-core 4.14.0 con `wcag2a`, `wcag2aa`, `wcag21a` y `wcag21aa`: 0 violaciones en claro y oscuro (salida en el PR)
- [ ] Reglas compartidas R1 a R3 (confirmadas por el líder en el PR #43) idénticas en TT-WEB-01 (R1 corregida el 2026-11-03 en las dos specs a la vez)
- [ ] Decisiones del líder de las dudas 1, 21, 24, 25 y 26 de la spec §8 fijadas antes de pasar a `vigente` (hasta entonces, marcadores `[DECISIÓN: …]`, que no bloquean la estructura ni el código); la decisión 2 y las dudas 4, 5, 6, 12, 19, 20, 22, 23, 27, 28 y 29 ya las respondió en el PR #43
- [ ] Inventario §5 coherente con el backend (HU-001, TT-API-12, TT-API-05) y columnas de Google Play revisadas en TT-TIE-03
- [ ] `security-reviewer` LIBERA · `traceability-clerk` sin drift
- [ ] `Memoria.md` actualizado · informe final en el PR
