# plan.md — TT-WEB-02 Páginas de aviso de privacidad y manejo de datos de usuario

## 1. Mapeo de archivos
- **Reutilizar (buscado con `codemap.py --query`; el mapa no indexa `landing/`, por eso se revisa a mano lo que deje TT-WEB-01):**
  - Hoja de estilos, encabezado, pie de página y servidor estático de la landing (TT-WEB-01, KNOCK-148). No se crea otra hoja de estilos ni otro servidor.
  - Inventario de datos y fuentes de la spec §5; textos aportados por el líder.
- **Crear:**
  - `landing/privacidad/index.html` (aviso integral, 17 secciones de §7, incluida `lo-que-compartes-tu`)
  - `landing/privacidad/simplificado/index.html` (aviso simplificado: `responsable`, `datos-tratados`, `finalidades`, `limitar-uso`, `aviso-integral`)
  - `landing/eliminar-cuenta/index.html` (manejo de datos y eliminación de cuenta, con `sin-tu-numero` y `cuenta-de-tecnico`)
  - `landing/tests/test_paginas_legales.py` (TC-02 a TC-11, `unittest` + `html.parser`)
- **Modificar:**
  - Pie de página de la landing de TT-WEB-01 (solo los enlaces a `/privacidad/` y `/eliminar-cuenta/`)
  - `Memoria.md`
- **No tocar:** `app/`, `panel/`, `contracts/`, clientes generados, `scripts/`, `.github/`, `.agents/` (los cambios de `test_globs`, `code_dirs` y CI de §8 decisión 5 son del Tech Lead o de TT-WEB-01), configuración de Railway y dominio (TT-WEB-01).

## 2. Riesgos y efectos secundarios
- **Legal:** publicar un texto que no es el aprobado o que no coincide con lo que hace la app. Mitigación: estado `borrador` visible (TC-07), inventario con fuentes del backend (TC-10) y la regla compartida R1 de la spec §8 (Google Play: texto `vigente` antes de la primera subida a la prueba cerrada y en producción; el `borrador` solo para pruebas internas, nunca en Google Play), idéntica en TT-WEB-01.
- **Analítica:** el aviso declara que el sitio no usa cookies ni analítica (regla compartida R2). Si otra tarea agrega Google Analytics sin actualizar el aviso, el aviso miente; esa tarea debe cambiar la sección `cookies-y-analitica` en el mismo PR.
- **Coordinación con TT-WEB-01:** va en paralelo en otra rama; si cambia carpeta, rutas o estilos, hay conflicto en el pie de página. Mitigación: fusionar después de TT-WEB-01 o rebasar sobre ella antes del PR.
- **Trazabilidad y CI:** hoy el CI no detecta `landing/` y `--trace` no busca pruebas ahí (spec §8 decisión 5). Sin ese cambio, las pruebas se corren a mano y su salida va en el PR.
- **Primera subida a la prueba cerrada:** el texto debe estar `vigente`, sin `[PENDIENTE` ni `[DECISIÓN` (regla compartida R1), y TT-MOB-06 debe ir en ese AAB con el enlace al aviso (spec §8 decisión 2 y duda 4). Si el texto del líder o sus decisiones (`[DECISIÓN]`) se retrasan, se retrasa esa subida; el `borrador` no se da a Google Play como sustituto (spec §8 duda 27).
- **Datos del equipo:** el nombre legal y el domicilio del responsable, los proveedores del canal de atención y el número desde el que se envía la confirmación del canal sin app los decide el líder (spec §8 dudas 1, 21, 24 y 25); mientras tanto, marcadores `[DECISIÓN: …]`, que no bloquean la estructura ni el código. El contacto, también para pedir la eliminación sin la app, es `soporte@tdevs.com.mx` (dudas 2 y 3). Si el domicilio o el número fueran de una persona del equipo, se publicaría un dato personal.
- **Claves internas:** los marcadores y comentarios del HTML no citan `TT-`, `HU-` ni `KNOCK-` (TC-08).
- **Sin abogado:** el texto legal no tiene revisión de abogado; riesgo aceptado por el líder (spec §8 duda 14 y `Memoria.md`).
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
| TC-TT-WEB-02-11 | `test_TC_TT_WEB_02_11_datos_fijados_por_el_lider` | `landing/tests/test_paginas_legales.py` |

Cada prueba debe fallar si se quita una sección, un `data-categoria`, la fecha, el aviso de borrador o un dato fijado por el líder, si queda un `[PENDIENTE` o un `[DECISIÓN` en una página `vigente`, si vuelven los `id` `transferencias-con-consentimiento` o `como-negarse` al simplificado, si aparece «contraseña» en `/eliminar-cuenta/` o una clave interna (`TT-`, `HU-`, `KNOCK-`) en cualquier página, o si se agrega un `<script>`, un `<form>` o un recurso de otro origen (comprobarlo una vez rompiendo un archivo a propósito y anotarlo en el PR).

## 4. Secuencia
1. Esperar o rebasar sobre TT-WEB-01 (carpeta, estilos, servidor y dominio).
2. Estructura de las 3 páginas con encabezados, `id`, índice, versión, fecha, `data-estado="borrador"`, los datos que el líder ya fijó (TC-11), marcadores `[PENDIENTE: …]` para su texto y `[DECISIÓN: …]` para las decisiones abiertas (responsable, domicilio, proveedores del canal de atención, número desde el que se envía la confirmación, `sin-tu-numero`), sin claves internas.
3. Pruebas TC-02 a TC-11 en `landing/tests/` (primero en rojo contra páginas incompletas, luego en verde).
4. Enlaces en el pie de la landing.
5. Texto del líder: lo aporta él en un commit aparte (A10). Además del comentario obligatorio de par, Alexis y Guillermo comentan el texto final; después, solo el líder cambia el estado a `vigente` y la versión a `1.0` en un commit propio.
6. Despliegue en Railway (sigue `develop` de forma temporal, spec §8 duda 5) y comandos de TC-01, TC-02, TC-07 y TC-09 contra la URL real. Antes de la primera subida a la prueba cerrada, las tres páginas están en `data-estado="vigente"` y su conteo de `[PENDIENTE` y `[DECISIÓN` es 0 (regla compartida R1); el `borrador` solo sirve para pruebas internas.
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
for r in privacidad/ privacidad/simplificado/ eliminar-cuenta/; do curl -sS "https://<dominio>/$r" | grep -cE '\[(PENDIENTE|DECISIÓN)'; done   # 0 y data-estado vigente antes de la primera subida a la prueba cerrada (R1)
# Accesibilidad (regla compartida R3): axe-core 4.14.0, etiquetas wcag2a, wcag2aa, wcag21a y wcag21aa, 0 violaciones
npx --yes @axe-core/cli@4.14.0 https://<dominio>/privacidad/ https://<dominio>/privacidad/simplificado/ https://<dominio>/eliminar-cuenta/ --tags wcag2a,wcag2aa,wcag21a,wcag21aa --exit
# Tema oscuro: axe DevTools con prefers-color-scheme: dark emulado; captura en el PR
PYTHONIOENCODING=utf-8 python scripts/sdd_lint.py
PYTHONIOENCODING=utf-8 python scripts/sdd_lint.py --trace TT-WEB-02
python scripts/codemap.py --check
python scripts/ci/check_exceptions.py
python scripts/sync_agents.py --check
```
