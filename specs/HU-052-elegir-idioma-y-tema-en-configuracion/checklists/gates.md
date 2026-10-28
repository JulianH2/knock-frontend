# Checklist — HU-052

- [ ] PR #16 (TT-MOB-02) fusionado en `sprint-02` y rama rebasada antes de escribir código
- [ ] Spec de 8 secciones con clave Jira (KNOCK-49), EP-10, 1 punto y estado aprobado por una persona distinta del autor; dudas de §8 resueltas
- [ ] Cada caso TC-HU-052-01…10 tiene su prueba (`sdd_lint.py --trace HU-052`); los casos 11 y 12 tienen su salida de comando en el PR
- [ ] Se reutiliza `preferenciasProvider` de TT-MOB-02 (sin un segundo proveedor de tema o idioma)
- [ ] English cambia la app sin reiniciar; Oscuro en todas las pantallas; Automático sigue al teléfono
- [ ] Respaldo al español probado sin romper TC-TT-MOB-02-02 (los ARB reales con las mismas claves)
- [ ] Idioma y tema se conservan al reiniciar desde el primer cuadro (sin parpadeo); evidencia manual del reinicio en el emulador
- [ ] Solo se guardan `knock.preferencias.tema` y `knock.preferencias.idioma`; nada de tokens ni datos personales; solo `core/preferencias/` importa `shared_preferences`
- [ ] Valores guardados inválidos o corruptos → español / Automático, sin excepción; fallos del almacenamiento no rompen la app ni se registran en logs
- [ ] Configuración visible en release; «Modo técnico (prueba)» solo fuera de release; el menú de prueba ya no tiene selectores de tema ni idioma
- [ ] Radios con semántica, encabezados, 48 dp, contraste ≥ 4.5:1 en claro y oscuro, texto al 200 % sin desbordes
- [ ] Textos nuevos en `app_es.arb` y `app_en.arb` con prefijo `configuracion`; claves `pruebaTema…`/`pruebaIdioma…` retiradas; generados de `gen-l10n` al día
- [ ] `shared_preferences` evaluada y registrada en `Memoria.md` y en el PR; OSV-Scanner sin hallazgos altos
- [ ] Pruebas de TT-MOB-02 ajustadas solo en camino y claves (declarado en el PR); TT-MOB-01 y TT-PRU-02 sin cambios y en verde
- [ ] `dart format --set-exit-if-changed`, `flutter analyze --fatal-infos` y `flutter test --coverage` con resultado real; cobertura ≥ 50 %
- [ ] `codemap.py --check`, `check_exceptions.py`, `sdd_lint.py` y `sync_agents.py --check` en OK
- [ ] `security-reviewer` LIBERA · `traceability-clerk` sin drift
- [ ] `Memoria.md` actualizado · informe en el PR con «Uso de IA» y capturas
