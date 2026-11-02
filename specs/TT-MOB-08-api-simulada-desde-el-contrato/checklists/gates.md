# Checklist — TT-MOB-08

- [ ] Spec de 8 secciones con clave Jira (KNOCK-191), EP-13, 2 puntos y estado aprobado por una persona distinta del autor
- [ ] D2 respetada: ninguna llamada HTTP escrita a mano (principio 4); el cliente real y la prueba de cambio de URL son de TT-MOB-03
- [ ] Cada caso TC-TT-MOB-08-01…11 tiene su prueba (`sdd_lint.py --trace TT-MOB-08`); los casos 12 y 13 tienen su salida de comando en el PR
- [ ] La pantalla de oficios corre contra la API simulada con los proveedores por defecto (criterio a de Jira)
- [ ] `clienteApiProvider` distingue simulado y real (criterio b de Jira, cumplido en diseño; D2)
- [ ] La prueba de contrato compara cada mock con la tabla de la §4 en las dos direcciones y falla con un mock alterado (criterio c de Jira)
- [ ] La tabla `contrato_s4.json` cita repositorio, rama, commit y spec de cada endpoint
- [ ] Escenarios 4xx y 5xx simulados y traducidos a `Failure`; sin detalles técnicos en pantalla
- [ ] Release nunca usa la simulación; con URL real y sin cliente real falla de forma explícita; solo `https` salvo hosts locales fuera de release
- [ ] Sin datos reales, tokens reales, URL real ni registros de URL, coordenadas o cuerpos
- [ ] `app/pubspec.yaml` y `app/pubspec.lock` sin cambios; nada escrito en `contracts/` ni `app/packages/`
- [ ] Pruebas de TT-PRU-02 y TT-MOB-01 en verde sin cambios
- [ ] `dart format --set-exit-if-changed`, `flutter analyze --fatal-infos`, `flutter test --coverage` (≥ 50 %) y `flutter build apk --debug` con resultado real del CI
- [ ] `codemap.py --check`, `check_exceptions.py`, `sdd_lint.py` y `sync_agents.py --check` en OK
- [ ] `security-reviewer` LIBERA · `traceability-clerk` sin drift (antes del PR de implementación)
- [ ] `Memoria.md` actualizado · informe en el PR con «Uso de IA» y captura de la pantalla
