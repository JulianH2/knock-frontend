# Calidad, pruebas y DevSecOps — knock-frontend

> Matriz de controles realmente configurados en este repositorio. Si cambias una herramienta, actualiza esta tabla en el mismo PR.
> Nivel: **PR** = `ci-pr.yml` (bloquea vía `gate`) · **Nightly** = `nightly.yml` · **Deploy** = despliegues · **Local** = git hooks y guardián.

## 1. Comparación con los repositorios de referencia del profesor

| Práctica de referencia | Repo del profesor | En knock-frontend |
|---|---|---|
| Clean Architecture de 3 capas con DI | MobileDevSecOps (Compose + Koin) | ✅ Flutter `presentation/domain/data` + Riverpod, con prueba de capas |
| Análisis estático (Detekt, Ktlint) | MobileDevSecOps | ✅ `flutter analyze --fatal-infos` con lints estrictos, `dart format`; ESLint + `tsc` strict en el panel |
| Cobertura (Kover) | MobileDevSecOps | ✅ lcov (app ≥ 50 %) e Istanbul (panel ≥ 60 % líneas / 50 % ramas) |
| Pruebas instrumentadas | MobileDevSecOps | ✅ `integration_test` en emulador Android (nightly) |
| OWASP Dependency Check, CodeQL | MobileDevSecOps | ✅ OSV-Scanner, dependency-review, npm audit, CodeQL (TS y Actions) |
| Unit/E2E/SAST/SCA/DAST/secretos web | WebDevSecOps | ✅ unitarias y componentes, Playwright + axe, Semgrep, Gitleaks |
| — | — | ➕ Nuevo: contrato vendorizado y clientes generados verificados, mutación (mutation_test y StrykerJS), regresión visual, accesibilidad automática, compatibilidad iOS y 3 navegadores, reglas de ramas/commits/PR, mapa de código |

## 2. Pruebas

| Tipo | Valida | App (Flutter) | Panel (Angular) | Nivel | Bloquea |
|---|---|---|---|---|---|
| Unitarias | Casos de uso, controladores, servicios, guardas | flutter_test + mocktail | `ng test` | PR | Sí |
| Widget / componente | Estados de pantalla (cargando, vacío, error, datos) | `testWidgets` | TestBed | PR | Sí |
| Arquitectura | Capas y features sin cruces | `test/architecture/layer_rules_test.dart` + codemap | codemap + Semgrep | PR + Local | Sí |
| Aceptación | Un caso `TC-<ID>-KK` por criterio de este repo | ídem | ídem | PR (trazabilidad) | Sí |
| Contrato | Clientes = contrato; sin cambios incompatibles | `gen_clients.sh` + diff | ídem | PR | Sí |
| Accesibilidad | Contraste, etiquetas, tamaño táctil / WCAG AA | `meetsGuideline` en widget tests | `@axe-core/playwright` | PR | Sí |
| E2E | Recorrido principal de cada historia | `integration_test` (emulador) | Playwright (humo en PR) | PR (panel) · Nightly (app y panel completo) | Sí / Nightly |
| Compatibilidad | Android + iOS; 3 navegadores | build APK (PR), build iOS (nightly) | chromium, firefox, webkit (nightly) | PR + Nightly | Sí / Nightly |
| Regresión visual | Pantallas clave sin cambios inesperados | goldens | capturas Playwright | Nightly | Nightly |
| Mutación | Calidad de las pruebas | `mutation_test` sobre `domain/` (≥ 70 %) | StrykerJS sobre services y guardas | Nightly | Nightly |
| Usabilidad | SUS ≥ 70 con 5 personas | TT-QA-03 / TT-QA-05 | ídem | Manual | — |

## 3. Seguridad y cadena de suministro

| Control | Herramienta | Nivel | Bloquea |
|---|---|---|---|
| SAST | Semgrep (reglas de Knock para Dart y Angular + p/typescript, p/secrets, p/owasp-top-ten), CodeQL (TS, Actions) | PR | Sí |
| Dependencias | dependency-review (vulnerabilidades y licencias), OSV-Scanner (pub y npm), `npm audit --omit=dev` | PR | Sí (altas) |
| Secretos | Gitleaks (PR y pre-commit), push protection | PR + Local | Sí |
| Workflows | actionlint, pinning a SHA, permisos mínimos | PR | Sí |
| Firma de la app | Keystore solo en secretos del environment; se borra al terminar | Deploy | — |
| Excepciones | `check_exceptions.py` | PR + Local | Sí |

## 4. OWASP Mobile / Web → control → prueba

| Riesgo | Control | Prueba |
|---|---|---|
| Almacenamiento inseguro (M9) | Tokens en `flutter_secure_storage`; nada en SharedPreferences/localStorage | Semgrep + revisión de `core/` |
| Comunicación insegura (M5) | Solo HTTPS; sin desactivar certificados | Semgrep |
| Autenticación (M3) | Firebase + tokens propios; renovación; cierre de sesión borra push | Widget/E2E del flujo de sesión |
| Privacidad (M6) | Sin datos personales en logs/Sentry; IA etiquetada y sin datos personales | Revisión + pruebas del filtro (backend) |
| XSS (A03 web) | Sin `innerHTML` ni `bypassSecurityTrust` | Semgrep + guardián |
| Control de acceso en el panel (A01) | Guardas por permiso + 403 del backend + 2FA | E2E con roles |
| Componentes vulnerables (A06) | OSV, dependency-review, npm audit, Dependabot | CI |

## 5. Checks que bloquean el merge
`gate` (pr-meta, governance, contract, app, panel, sast, sca, secrets) y `CodeQL`. Configuración: `docs/BRANCH_PROTECTION.md`.

## 6. Requiere configuración externa
Firebase (apps Android/iOS registradas, números de prueba) · Google Play y Apple Developer · Azure Static Web Apps para el panel · protección de ramas y environments · `ANTHROPIC_API_KEY` (opcional).

## 7. Limitaciones conocidas
- Hasta TT-MOB-01 (app) y TT-PRU-03 (panel) no hay proyectos: sus jobs se saltan. Las configuraciones de lint, mutación y E2E están listas en `docs/templates/`.
- CodeQL no analiza Dart; la app se cubre con Semgrep, los analizadores de Dart y pruebas.
- La usabilidad (SUS) es manual por naturaleza.
