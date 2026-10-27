# TT-WEB-01 — tareas

## T1 — Confirmar decisiones y pedir lo que es del líder [Landing]
- **Crear:** —
- **Modificar:** —
- **Verificar:** que el líder confirme la spec §8: tecnología (1), privacidad provisional (2), estado de Play (3), sin analítica (5), configuración y rama de Railway (6) e idioma (7). Pedirle el job `landing` del CI y Dependabot (8), los cambios de `.agents/knock.json`, incluido `landing/**` en `code_dirs` (9) y quién escribe `landing/` (10).
- **No hacer:** empezar código con la spec en Borrador; pedir acceso a la cuenta de Railway o a sus tokens.
- **Agente:** persona responsable (Erick) con el líder.

## T2 — Pruebas estáticas primero [Pruebas]
- **Crear:** `landing/tests/test_landing.py` con `test_TC_TT_WEB_01_01_dockerfile`, `_02_enlaces`, `_03_privacidad`, `_04_cabeceras`, `_05_sin_terceros`, `_06_accesibilidad` y `_09_peso` (biblioteca estándar).
- **Modificar:** —
- **Verificar:** `python -m unittest discover -s landing/tests -v` falla por falta de archivos (rojo esperado).
- **No hacer:** agregar paquetes de pip o npm; aserciones vacías.
- **Agente:** el que decida el líder (spec §8 decisión 10).

## T3 — Páginas y estilos [Landing]
- **Crear:** `landing/index.html`, `landing/privacidad/index.html` (provisional, `data-estado="en-preparacion"`, `noindex`), `landing/404.html`, `landing/css/landing.css` (tokens claro y oscuro, `@font-face` con `font-display: swap`) y `landing/fonts/` (subconjuntos WOFF2 de Nunito 400 y 700 con `OFL.txt`; spec §8 decisión 1).
- **Modificar:** —
- **Verificar:** TC-02, 03, 05, 06 y 09 en verde; capturas a 320 px y 1280 px, en claro y en oscuro.
- **No hacer:** JavaScript, `style=""`, `<style>`, recursos de otros orígenes, texto legal inventado ni la insignia oficial de Play sin decisión.
- **Agente:** idem T2.

## T4 — Servidor y contenedor [Landing]
- **Crear:** `landing/nginx.conf` (cabeceras de la spec §6 con `always`, `server_tokens off`, `autoindex off`, gzip, 404 propio y `/favicon.ico` → 204), `landing/Dockerfile` (`nginxinc/nginx-unprivileged` alpine fijada por digest, puerto 8080, copia solo los archivos públicos), `landing/.dockerignore` y `landing/railway.json`.
- **Modificar:** `Memoria.md` (evaluación de la imagen: necesidad, licencia, mantenimiento y vulnerabilidades).
- **Verificar:** TC-01 y TC-04 en local (`docker build`, `docker run`, `curl -sI`, `id -u`).
- **No hacer:** `latest`, root, variables con secretos ni redirecciones que dependan de parámetros.
- **Agente:** idem T2.

## T5 — Validación y PR [Pruebas]
- **Crear:** `landing/README.md` (correr en local, cambiar el estado de Play, configuración de Railway y plan B).
- **Modificar:** —
- **Verificar:** TC-07 (Nu HTML Checker), los gates de gobierno de `plan.md §5`, `security-reviewer` y `traceability-clerk`. PR `KNOCK-148 · TT-WEB-01 …` a `sprint-01` con el informe, «Uso de IA» y la etiqueta `puntos-landing-N`.
- **No hacer:** dar por pasado lo que no se ejecutó; tocar `.github/` ni `.agents/`.
- **Agente:** idem T2; revisores sin edición.

## T6 — Despliegue y evidencia [Landing]
- **Crear:** —
- **Modificar:** `docs/VERSIONES_DESPLEGADAS.md` (fecha, Landing, versión, Railway, responsable) y `Memoria.md` (URL publicada y decisiones finales).
- **Verificar:** con la URL del líder, TC-04, 06, 07, 08 y 09 y la captura de la pestaña Network (TC-05), con la salida en el PR o en un comentario del PR.
- **No hacer:** desplegar a mano ni con la cuenta de otra persona; dar a Google Play la página provisional o pedir producción sin `/privacidad/` en `vigente` (regla compartida R1 de la spec §8).
- **Agente:** el líder despliega; Erick verifica y documenta.
