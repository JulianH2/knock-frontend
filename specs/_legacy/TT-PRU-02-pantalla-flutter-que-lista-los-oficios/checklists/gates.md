# Checklist — TT-PRU-02

- [ ] Spec de 8 secciones con clave Jira (KNOCK-30), EP-13, 1 punto y estado aprobado por una persona distinta del autor
- [ ] Cada caso TC-TT-PRU-02-01…10 tiene su prueba (`sdd_lint.py --trace TT-PRU-02`); los casos 11 y 12 tienen su salida de comando en el PR
- [ ] La pantalla muestra los 3 oficios del contrato en su orden, con ícono y texto por modalidad
- [ ] Estados de carga, error con Reintentar (vuelve a pedir, ≥ 48 dp) y vacío cubiertos con prueba de widget
- [ ] Modalidad desconocida tolerada (ícono genérico, sin excepción)
- [ ] `domain/` sin `flutter`/`dio`/`flutter_riverpod`/`knock_api`; `presentation/` sin HTTP ni `data/`
- [ ] `app/pubspec.yaml` y `app/pubspec.lock` sin cambios; sin `dio` ni cliente HTTP; sin datos reales ni llamadas de red
- [ ] Ruta `/explorar/oficios` agregada sin cambiar las 5 pestañas; pruebas de TT-MOB-01 en verde sin cambios
- [ ] Texto al 200 % sin desbordes y áreas táctiles ≥ 48 dp
- [ ] `dart format --set-exit-if-changed`, `flutter analyze --fatal-infos` y `flutter test --coverage` con **resultado real del CI** (el Flutter local es 3.29.0 y el proyecto pide 3.47.7); cobertura ≥ 50 %
- [ ] `codemap.py --check`, `check_exceptions.py`, `sdd_lint.py` y `sync_agents.py --check` en OK
- [ ] V1 de la ficha (los 3 oficios desde la API local) diferido a TT-MOB-03: dicho explícitamente en el PR
- [ ] `security-reviewer` LIBERA · `traceability-clerk` sin drift (antes del PR de implementación)
- [ ] `Memoria.md` actualizado · informe en el PR con «Uso de IA» (2 o 3 frases de qué hace y cómo se validó) y captura de la pantalla
