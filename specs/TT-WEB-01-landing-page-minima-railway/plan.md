# plan.md — TT-WEB-01 Landing page mínima en Railway: redirección a Google Play y enlace al aviso de privacidad

## 1. Mapeo de archivos
- **Reutilizar (buscado en el repositorio el 2026-10-26):**
  - Fuentes `app/assets/fonts/nunito/Nunito-Regular.ttf` y `Nunito-Bold.ttf` (base de los subconjuntos WOFF2, spec §8 decisión 1), `OFL.txt` y los tokens de color de `app/lib/core/tema/colores.dart` (rama de TT-MOB-02, KNOCK-25). Se copian o se derivan, porque Railway construye solo con `landing/` como contexto y no puede leer `../app`.
  - La fórmula de contraste de `app/lib/core/tema/contraste.dart`, reescrita en Python dentro de la prueba con los mismos valores de control (21:1 y 1:1).
  - Python 3.12 del CI y de los hooks para las pruebas, sin paquetes nuevos.
  - `codemap.py` no mapea `landing/` y no hace falta: no hay código reutilizable.
- **Crear (`landing/`):** `index.html`, `privacidad/index.html` (provisional), `404.html`, `css/landing.css`, `fonts/{nunito-400-latin.woff2,nunito-700-latin.woff2,OFL.txt}`, `nginx.conf`, `Dockerfile`, `.dockerignore`, `railway.json` (si el líder lo acepta), `README.md` y `tests/test_landing.py`.
- **Modificar:** `docs/VERSIONES_DESPLEGADAS.md` (fila del primer despliegue) y `Memoria.md` (entrada del issue y evaluación de la imagen de nginx).
- **Pedir al líder (no los toca esta tarea):** `.github/workflows/ci-pr.yml` (job `landing` y trazabilidad), `.github/dependabot.yml` (docker en `/landing`), `.agents/knock.json` (`test_globs`, `code_dirs` con `landing/**`, scope `landing` y `technical_tasks`) y el permiso de un agente sobre `landing/` (spec §8, decisiones 8 a 10).
- **No tocar:** `app/`, `panel/`, `contracts/`, clientes generados, `constitution.md`, `AGENTS.md` y la carpeta de TT-WEB-02 fuera de `landing/privacidad/index.html`.

## 2. Riesgos y efectos secundarios
- **Google Play:** la página provisional no se da a Play; prueba cerrada y producción siguen la regla compartida R1 de la spec §8, idéntica en TT-WEB-02.
- **Fecha dura (2026-10-27):** sin la URL publicada se atrasa la solicitud de producción en Play. El despliegue depende del líder (cuenta de Railway) y de la rama que siga Railway (spec §8 decisión 6). Pedirle hoy la configuración.
- **Conflicto con TT-WEB-02** en `landing/privacidad/index.html`: se resuelve quedándose con el contenido de TT-WEB-02. Avisar a quien tenga esa rama.
- **TT-MOB-02 sin fusionar:** las fuentes y la paleta vienen de su rama. Si no se fusiona a tiempo, se usa el origen oficial de Nunito (spec §8 duda 16).
- **CSP estricta:** cualquier `style=""` o `<style>` que se agregue después rompe el estilo en producción. La prueba TC-05 lo detecta antes.
- **HSTS:** al ser `max-age` de un año, servir después por HTTP en esa URL no es posible. Es aceptable porque Railway siempre da HTTPS.
- **Costo:** consume del espacio del líder. Una réplica y un límite de memoria bajo.
- **Trazabilidad:** sin el cambio de `test_globs`, `sdd_lint.py --trace TT-WEB-01` marcará FALTA aunque las pruebas existan; sin el cambio de `detect` en el CI, el PR no correrá `--trace`.

## 3. Pruebas por caso
| Caso | Prueba | Suite |
|---|---|---|
| TC-TT-WEB-01-01 | `test_TC_TT_WEB_01_01_dockerfile` + build y ejecución local con `id -u` | `landing/tests/test_landing.py` · comando en el PR |
| TC-TT-WEB-01-02 | `test_TC_TT_WEB_01_02_enlaces` (estado disponible o próximamente, URL exacta, enlace a `/privacidad/`, versión en el pie) | `landing/tests/test_landing.py` |
| TC-TT-WEB-01-03 | `test_TC_TT_WEB_01_03_privacidad` | `landing/tests/test_landing.py` |
| TC-TT-WEB-01-04 | `test_TC_TT_WEB_01_04_cabeceras` + `curl -sI` en local y en la URL publicada (también `/no-existe`) | `landing/tests/test_landing.py` · comando en el PR |
| TC-TT-WEB-01-05 | `test_TC_TT_WEB_01_05_sin_terceros` + captura de la pestaña Network | `landing/tests/test_landing.py` · captura en el PR |
| TC-TT-WEB-01-06 | `test_TC_TT_WEB_01_06_accesibilidad` (incluye `alt` en cada `<img>`) + axe-core (`@axe-core/cli@4.14.0` en claro, axe DevTools en oscuro; `wcag2a`, `wcag2aa`, `wcag21a`, `wcag21aa`; 0 violaciones) | `landing/tests/test_landing.py` · captura en el PR |
| TC-TT-WEB-01-07 | Nu HTML Checker fijado por digest (`--version` en el PR) | comando en el PR |
| TC-TT-WEB-01-08 | `curl` por HTTPS (200 y certificado válido) y por HTTP (301/308) | comando en el PR |
| TC-TT-WEB-01-09 | `test_TC_TT_WEB_01_09_peso` (≤ 150 KB, WOFF2 ≤ 50 KB cada una) + `curl` con gzip + Lighthouse 13.5.0 móvil, mediana de 3 corridas ≥ 90 | `landing/tests/test_landing.py` · comando en el PR |

## 4. Secuencia
1. Confirmar con el líder las decisiones de §8 (sobre todo la 2, la 3, la 5 y la 6) y pedirle la configuración de Railway, el job de CI y `knock.json`.
2. Escribir primero las pruebas de `landing/tests/test_landing.py` (fallan sin los archivos).
3. Crear `css/landing.css` con los tokens y `@font-face`, generar los subconjuntos WOFF2 y copiar `OFL.txt` (comando y SHA-256 en `landing/README.md`), y crear `index.html`, `privacidad/index.html` y `404.html`.
4. Crear `nginx.conf`, `Dockerfile` (imagen fijada por digest), `.dockerignore` y `railway.json`. Construir y probar en local (TC-01 y TC-04 en local).
5. Pruebas en verde, Nu HTML Checker y capturas en 320 px y 1280 px, en claro y en oscuro.
6. PR a `sprint-01`. Cuando el líder despliegue: TC-04, 06, 07, 08 y 09 contra la URL, fila en `docs/VERSIONES_DESPLEGADAS.md` y `Memoria.md`.
7. `security-reviewer` y `traceability-clerk` antes de pedir la fusión.

## 5. Verificación (comandos exactos)
```bash
python -m unittest discover -s landing/tests -v
docker build -t knock-landing landing
docker run -d --rm -p 8080:8080 --name kl knock-landing
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8080/
docker exec kl id -u
curl -sI http://localhost:8080/
curl -sI http://localhost:8080/no-existe
docker stop kl
docker run --rm ghcr.io/validator/validator@sha256:8f21030474e68e06905cfa801b37376e99c0e37867c653c5b6cd7e2dcaf3f503 /vnu-runtime-image/bin/vnu --version
docker run --rm -v "$PWD/landing":/w ghcr.io/validator/validator@sha256:8f21030474e68e06905cfa801b37376e99c0e37867c653c5b6cd7e2dcaf3f503 /vnu-runtime-image/bin/vnu --skip-non-html /w
# Con la URL que publique el líder
curl -sS -o /dev/null -w "%{http_code} %{ssl_verify_result}\n" https://<URL>/
curl -sI http://<URL>/
curl -sI https://<URL>/
curl -sI https://<URL>/no-existe
curl -sI -H "Accept-Encoding: gzip" https://<URL>/
npx --yes @axe-core/cli@4.14.0 https://<URL>/ https://<URL>/no-existe --tags wcag2a,wcag2aa,wcag21a,wcag21aa --exit
npx --yes lighthouse@13.5.0 https://<URL>/ --only-categories=performance --throttling-method=simulate --output=json --output-path=./lh-1.json --chrome-flags="--headless=new"   # repetir con lh-2 y lh-3; mediana >= 90
# Gobierno
python scripts/sdd_lint.py
python scripts/sdd_lint.py --trace TT-WEB-01
python scripts/codemap.py --check
python scripts/ci/check_exceptions.py
python scripts/sync_agents.py --check
```
