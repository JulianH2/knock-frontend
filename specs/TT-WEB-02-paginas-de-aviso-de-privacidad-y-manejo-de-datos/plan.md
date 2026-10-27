# plan.md — TT-WEB-02 Páginas de aviso de privacidad y manejo de datos de usuario

## 1. Mapeo de archivos
- **Reutilizar (buscado con `codemap.py --query`; el mapa no indexa `landing/`, por eso se revisa a mano lo que deje TT-WEB-01):**
  - Hoja de estilos, encabezado, pie de página y servidor estático de la landing (TT-WEB-01, KNOCK-148). No se crea otra hoja de estilos ni otro servidor.
  - Inventario de datos y fuentes de la spec §5; textos aportados por el líder.
- **Crear:**
  - `landing/privacidad/index.html` (aviso integral, 16 secciones de §7)
  - `landing/privacidad/simplificado/index.html` (aviso simplificado)
  - `landing/eliminar-cuenta/index.html` (manejo de datos y eliminación de cuenta)
  - `landing/tests/test_paginas_legales.py` (TC-02 a TC-10, `unittest` + `html.parser`)
- **Modificar:**
  - Pie de página de la landing de TT-WEB-01 (solo los enlaces a `/privacidad/` y `/eliminar-cuenta/`)
  - `Memoria.md`
- **No tocar:** `app/`, `panel/`, `contracts/`, clientes generados, `scripts/`, `.github/`, `.agents/` (los cambios de `test_globs`, `code_dirs` y CI de §8 decisión 5 son del Tech Lead o de TT-WEB-01), configuración de Railway y dominio (TT-WEB-01).

## 2. Riesgos y efectos secundarios
- **Legal:** publicar un texto que no es el aprobado o que no coincide con lo que hace la app. Mitigación: estado `borrador` visible (TC-07), inventario con fuentes del backend (TC-10) y la regla compartida R1 de la spec §8 (Google Play: prueba cerrada con `borrador`, producción solo con `vigente`), idéntica en TT-WEB-01.
- **Analítica:** el aviso declara que el sitio no usa cookies ni analítica (regla compartida R2). Si otra tarea agrega Google Analytics sin actualizar el aviso, el aviso miente; esa tarea debe cambiar la sección `cookies-y-analitica` en el mismo PR.
- **Coordinación con TT-WEB-01:** va en paralelo en otra rama; si cambia carpeta, rutas o estilos, hay conflicto en el pie de página. Mitigación: fusionar después de TT-WEB-01 o rebasar sobre ella antes del PR.
- **Trazabilidad y CI:** hoy el CI no detecta `landing/` y `--trace` no busca pruebas ahí (spec §8 decisión 5). Sin ese cambio, las pruebas se corren a mano y su salida va en el PR.
- **Datos del equipo:** el domicilio o correo del responsable puede exponer datos personales (spec §8 duda 1).
- **Dependencias:** ninguna nueva.

## 3. Pruebas por caso
| Caso | Prueba | Suite |
|---|---|---|
| TC-TT-WEB-02-01 | `curl` por HTTPS a las 3 rutas y por HTTP con redirección | (comando) salida en el PR |
| TC-TT-WEB-02-02 | `test_TC_TT_WEB_02_02_la_landing_enlaza_las_paginas_legales` + `curl` a `/` | `landing/tests/test_paginas_legales.py` · (comando) |
| TC-TT-WEB-02-03 | `test_TC_TT_WEB_02_03_aviso_integral_tiene_las_secciones_obligatorias` | `landing/tests/test_paginas_legales.py` |
| TC-TT-WEB-02-04 | `test_TC_TT_WEB_02_04_eliminar_cuenta_cumple_lo_que_pide_google_play` | `landing/tests/test_paginas_legales.py` |
| TC-TT-WEB-02-05 | `test_TC_TT_WEB_02_05_aviso_simplificado_remite_al_integral` | `landing/tests/test_paginas_legales.py` |
| TC-TT-WEB-02-06 | `test_TC_TT_WEB_02_06_version_y_fecha_visibles` | `landing/tests/test_paginas_legales.py` |
| TC-TT-WEB-02-07 | `test_TC_TT_WEB_02_07_texto_provisional_nunca_se_presenta_como_vigente` + `curl` del estado publicado | `landing/tests/test_paginas_legales.py` · (comando) |
| TC-TT-WEB-02-08 | `test_TC_TT_WEB_02_08_sin_recursos_de_terceros` | `landing/tests/test_paginas_legales.py` |
| TC-TT-WEB-02-09 | `test_TC_TT_WEB_02_09_estructura_accesible` + axe-core (`wcag2a`, `wcag2aa`, `wcag21a`, `wcag21aa`; 0 violaciones) sobre las URLs publicadas | `landing/tests/test_paginas_legales.py` · (comando) |
| TC-TT-WEB-02-10 | `test_TC_TT_WEB_02_10_inventario_completo_en_el_aviso` | `landing/tests/test_paginas_legales.py` |

Cada prueba debe fallar si se quita una sección, un `data-categoria`, la fecha o el aviso de borrador, o si se agrega un `<script>`, un `<form>` o un recurso de otro origen (comprobarlo una vez rompiendo un archivo a propósito y anotarlo en el PR).

## 4. Secuencia
1. Esperar o rebasar sobre TT-WEB-01 (carpeta, estilos, servidor y dominio).
2. Estructura de las 3 páginas con encabezados, `id`, índice, versión, fecha, `data-estado="borrador"` y marcadores `[PENDIENTE: …]`.
3. Pruebas TC-02 a TC-10 en `landing/tests/` (primero en rojo contra páginas incompletas, luego en verde).
4. Enlaces en el pie de la landing.
5. Texto del líder: se copia tal cual; solo el líder cambia el estado a `vigente` y la versión a `1.0`.
6. Despliegue en Railway y comandos de TC-01, TC-02, TC-07 y TC-09 contra la URL real.
7. Gates + `Memoria.md` + informe final con «Uso de IA».

## 5. Verificación (comandos exactos)
```bash
python -m unittest discover -s landing/tests -v
curl -sS -o /dev/null -w "%{http_code} %{content_type} %{url_effective}\n" https://<dominio>/privacidad/
curl -sS -o /dev/null -w "%{http_code} %{content_type} %{url_effective}\n" https://<dominio>/privacidad/simplificado/
curl -sS -o /dev/null -w "%{http_code} %{content_type} %{url_effective}\n" https://<dominio>/eliminar-cuenta/
curl -sSI http://<dominio>/privacidad/                     # 301/308 y Location: https://…
curl -sS https://<dominio>/ | grep -oE 'href="/(privacidad|eliminar-cuenta)/"'
curl -sS https://<dominio>/privacidad/ | grep -o 'data-estado="[a-z]*"'
# Accesibilidad (regla compartida R3): axe-core 4.14.0, etiquetas wcag2a, wcag2aa, wcag21a y wcag21aa, 0 violaciones
npx --yes @axe-core/cli@4.14.0 https://<dominio>/privacidad/ https://<dominio>/privacidad/simplificado/ https://<dominio>/eliminar-cuenta/ --tags wcag2a,wcag2aa,wcag21a,wcag21aa --exit
# Tema oscuro: axe DevTools con prefers-color-scheme: dark emulado; captura en el PR
PYTHONIOENCODING=utf-8 python scripts/sdd_lint.py
PYTHONIOENCODING=utf-8 python scripts/sdd_lint.py --trace TT-WEB-02
python scripts/codemap.py --check
python scripts/ci/check_exceptions.py
python scripts/sync_agents.py --check
```
