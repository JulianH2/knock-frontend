"""Comprobaciones estáticas de las páginas legales de la landing (TT-WEB-02, KNOCK-159).

Solo biblioteca estándar y sin red. Corre desde la raíz del repositorio con
`python -m unittest discover -s landing/tests -v`. Cada método lleva el ID del
caso con guiones bajos, que es lo que busca `sdd_lint.py --trace`. TC-01
(despliegue) se verifica con `curl` contra la URL publicada, no aquí.
"""

import datetime
import re
import unittest
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import urlsplit

LANDING = Path(__file__).resolve().parents[1]

INTEGRAL = "privacidad/index.html"
SIMPLIFICADO = "privacidad/simplificado/index.html"
ELIMINAR = "eliminar-cuenta/index.html"
LEGALES = (INTEGRAL, SIMPLIFICADO, ELIMINAR)
SITIO = ("index.html", "404.html") + LEGALES

CORREO = "soporte@tdevs.com.mx"
AVISO_PROVISIONAL = "Texto provisional: aún no es el aviso de privacidad vigente de Knock"

SECCIONES_INTEGRAL = [
    "responsable",
    "datos-tratados",
    "datos-sensibles",
    "finalidades-necesarias",
    "finalidades-voluntarias",
    "como-negarse",
    "transferencias-y-encargados",
    "lo-que-compartes-tu",
    "alojamiento-fuera-de-mexico",
    "derechos-arco",
    "revocar-consentimiento",
    "limitar-uso",
    "conservacion-y-eliminacion",
    "cookies-y-analitica",
    "menores-de-edad",
    "cambios-al-aviso",
    "contacto",
]
SECCIONES_ELIMINAR = [
    "como-solicitar-en-la-app",
    "como-solicitar-sin-la-app",
    "sin-tu-numero",
    "cuenta-de-tecnico",
    "que-se-borra",
    "que-se-conserva-y-por-cuanto-tiempo",
    "plazo-de-gracia",
    "contacto",
]
SECCIONES_SIMPLIFICADO = [
    "responsable",
    "datos-tratados",
    "finalidades",
    "limitar-uso",
    "aviso-integral",
]
# Lista cerrada: una fila por categoría del inventario de datos de la spec.
CATEGORIAS = [
    "celular", "perfil", "ubicacion", "direccion", "tecnico", "solicitudes",
    "mensajes", "opiniones", "reportes", "casa-auto", "contactos-confianza",
    "notificaciones", "sesion", "ia", "registros-tecnicos", "sitio-web",
    "atencion-por-correo",
]
CATEGORIA_SENSIBLE = "ine-selfie"

VACIAS = {"meta", "link", "br", "hr", "img", "input"}


class Nodo:
    def __init__(self, tag, attrs, padre):
        self.tag, self.attrs, self.padre = tag, attrs, padre
        self.hijos = []  # Nodo o str

    def descendientes(self):
        for hijo in self.hijos:
            if isinstance(hijo, Nodo):
                yield hijo
                yield from hijo.descendientes()

    def buscar(self, tag=None, **attrs):
        return [
            n
            for n in self.descendientes()
            if (tag is None or n.tag == tag)
            and all(n.attrs.get(k.replace("_", "-")) == v for k, v in attrs.items())
        ]

    def por_id(self, id_):
        encontrados = [n for n in self.descendientes() if n.attrs.get("id") == id_]
        return encontrados[0] if encontrados else None

    def texto(self):
        partes = []
        for hijo in self.hijos:
            partes.append(hijo.texto() if isinstance(hijo, Nodo) else hijo)
        return " ".join(" ".join(partes).split())


class Arbol(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.raiz = Nodo("#raiz", {}, None)
        self.actual = self.raiz
        self.comentarios = []

    def handle_starttag(self, tag, attrs):
        nodo = Nodo(tag, dict(attrs), self.actual)
        self.actual.hijos.append(nodo)
        if tag not in VACIAS:
            self.actual = nodo

    def handle_startendtag(self, tag, attrs):
        self.actual.hijos.append(Nodo(tag, dict(attrs), self.actual))

    def handle_endtag(self, tag):
        nodo = self.actual
        while nodo is not None and nodo.tag != tag:
            nodo = nodo.padre
        if nodo is not None and nodo.padre is not None:
            self.actual = nodo.padre

    def handle_data(self, data):
        if self.actual.tag not in ("script", "style", "title"):
            self.actual.hijos.append(data)

    def handle_comment(self, data):
        self.comentarios.append(data)


def leer(ruta):
    return (LANDING / ruta).read_text(encoding="utf-8")


def arbol(html):
    a = Arbol()
    a.feed(html)
    a.close()
    return a


def raiz_html(html):
    return arbol(html).raiz.buscar("html")[0]


def es_externo(url):
    partes = urlsplit(url)
    return bool(partes.scheme or partes.netloc)


def estado(html):
    return raiz_html(html).attrs.get("data-estado")


def seccion(html, id_):
    nodo = raiz_html(html).por_id(id_)
    if nodo is None:
        raise AssertionError(f"Falta la sección «{id_}»")
    return nodo


def ids_h2(html):
    """`id` de la sección de cada h2, en orden de aparición."""
    ids = []
    for h2 in raiz_html(html).buscar("h2"):
        padre = h2.padre
        ids.append(padre.attrs.get("id") if padre is not None else None)
    return ids


# ---------- revisiones (reutilizadas por las pruebas y por sus controles) ----------


def revisar_estado(html):
    """TC-07: el borrador avisa; el vigente no tiene marcadores."""
    raiz = raiz_html(html)
    valor = raiz.attrs.get("data-estado")
    texto = raiz.texto()
    marcadores = re.findall(r"\[(?:PENDIENTE|DECISIÓN)", html)
    if valor == "borrador":
        main = raiz.buscar("main")[0]
        primero = next(h for h in main.hijos if isinstance(h, Nodo))
        if primero.texto() != AVISO_PROVISIONAL:
            raise AssertionError("El aviso de texto provisional no es lo primero de <main>")
        robots = [m for m in raiz.buscar("meta") if m.attrs.get("name") == "robots"]
        if not any(m.attrs.get("content") == "noindex" for m in robots):
            raise AssertionError("Falta <meta name=\"robots\" content=\"noindex\">")
    elif valor == "vigente":
        if marcadores:
            raise AssertionError("Una página vigente no puede tener marcadores")
        if AVISO_PROVISIONAL in texto:
            raise AssertionError("Una página vigente no muestra el aviso de provisional")
    else:
        raise AssertionError(f"data-estado inválido: {valor}")


def revisar_sin_terceros(html):
    """TC-08: sin scripts, estilos en línea ni recursos de otro origen ni claves internas."""
    a = arbol(html)
    raiz = a.raiz
    for prohibida in ("script", "style", "form", "input", "iframe"):
        if raiz.buscar(prohibida):
            raise AssertionError(f"<{prohibida}> no permitido")
    for nodo in raiz.descendientes():
        if "style" in nodo.attrs:
            raise AssertionError(f"Atributo style en <{nodo.tag}>")
        for nombre in nodo.attrs:
            if nombre.startswith("on"):
                raise AssertionError(f"Manejador {nombre} en <{nodo.tag}>")
        recurso = nodo.attrs.get("src") or (
            nodo.attrs.get("href") if nodo.tag != "a" else None
        )
        if recurso and es_externo(recurso):
            raise AssertionError(f"Recurso externo: {recurso}")
        for candidato in nodo.attrs.get("srcset", "").split(","):
            url = candidato.strip().split(" ")[0]
            if url and es_externo(url):
                raise AssertionError(f"srcset externo: {url}")
    claves = re.findall(r"(?:TT-|HU-|KNOCK-)[A-Za-z0-9]", html)
    if claves:
        raise AssertionError(f"Claves internas en el HTML: {claves}")


def revisar_datos_del_lider(integral, eliminar, simplificado):
    """TC-11: solo lo que el líder ya decidió."""
    for nombre, html, ids in (
        ("integral", integral, ("contacto", "derechos-arco")),
        ("eliminar", eliminar, ("contacto", "como-solicitar-sin-la-app")),
    ):
        for id_ in ids:
            if CORREO not in seccion(html, id_).texto():
                raise AssertionError(f"{id_} ({nombre}) sin {CORREO}")
    arco = seccion(integral, "derechos-arco").texto()
    for plazo in ("20 días hábiles", "15 días hábiles"):
        if plazo not in arco:
            raise AssertionError(f"derechos-arco sin «{plazo}»")
    if "18 años" not in seccion(integral, "menores-de-edad").texto():
        raise AssertionError("menores-de-edad sin 18 años")
    if "7 días" not in seccion(integral, "datos-sensibles").texto():
        raise AssertionError("datos-sensibles sin 7 días")
    if "se desvinculan de tu nombre" not in seccion(
        eliminar, "que-se-conserva-y-por-cuanto-tiempo"
    ).texto():
        raise AssertionError("Falta «se desvinculan de tu nombre»")
    for html in (integral, eliminar, simplificado):
        if "anonimiz" in raiz_html(html).texto().lower() or "anonimiz" in html.lower():
            raise AssertionError("«anonimiz» no se usa")


def revisar_confirmacion_sin_app(eliminar):
    """TC-12: 7 días para confirmar; sin confirmar, no se borra nada."""
    sin_app = seccion(eliminar, "como-solicitar-sin-la-app").texto()
    for frase in ("7 días", "se cancela", "no se borra nada"):
        if frase not in sin_app:
            raise AssertionError(f"como-solicitar-sin-la-app sin «{frase}»")
    if "7 días" in seccion(eliminar, "plazo-de-gracia").texto():
        raise AssertionError("«7 días» en plazo-de-gracia")


def con(html, viejo, nuevo):
    """Devuelve `html` con `viejo` cambiado por `nuevo`, exigiendo que cambie algo."""
    if viejo not in html:
        raise AssertionError(f"El control no encontró: {viejo}")
    return html.replace(viejo, nuevo, 1)


class PaginasLegales(unittest.TestCase):
    def test_TC_TT_WEB_02_02_la_landing_enlaza_las_paginas_legales(self):
        for nombre in SITIO:
            pie = raiz_html(leer(nombre)).buscar("footer")
            self.assertEqual(len(pie), 1, nombre)
            enlaces = {
                e.attrs.get("href"): e.texto() for e in pie[0].buscar("a")
            }
            self.assertEqual(enlaces.get("/privacidad/"), "Aviso de privacidad", nombre)
            self.assertEqual(
                enlaces.get("/eliminar-cuenta/"), "Eliminar mi cuenta y mis datos", nombre
            )
            for href in enlaces:
                self.assertFalse(es_externo(href), f"{href} en {nombre}")

    def test_TC_TT_WEB_02_03_aviso_integral_tiene_las_secciones_obligatorias(self):
        html = leer(INTEGRAL)
        raiz = raiz_html(html)
        self.assertEqual(len(raiz.buscar("h1")), 1)
        self.assertEqual(ids_h2(html), SECCIONES_INTEGRAL)
        indice = raiz.buscar("nav")
        self.assertEqual(len(indice), 1, "Falta el índice")
        enlazados = [e.attrs.get("href") for e in indice[0].buscar("a")]
        self.assertEqual(enlazados, [f"#{i}" for i in SECCIONES_INTEGRAL])
        # Control: sin una sección o en otro orden, la comprobación falla.
        sin_menores = con(html, 'id="menores-de-edad"', 'id="otra"')
        self.assertNotEqual(ids_h2(sin_menores), SECCIONES_INTEGRAL)

    def test_TC_TT_WEB_02_04_eliminar_cuenta_cumple_lo_que_pide_google_play(self):
        html = leer(ELIMINAR)
        raiz = raiz_html(html)
        self.assertIn("Knock", raiz.buscar("h1")[0].texto())
        for id_ in SECCIONES_ELIMINAR:
            self.assertIsNotNone(raiz.por_id(id_), id_)
        gracia = seccion(html, "plazo-de-gracia").texto()
        self.assertIn("no hay plazo de gracia", gracia)
        self.assertIn("definitiva", gracia)
        for prohibida in ("form", "input", "script"):
            self.assertEqual(raiz.buscar(prohibida), [], prohibida)
        self.assertNotIn("contraseña", html.lower())

    def test_TC_TT_WEB_02_05_aviso_simplificado_remite_al_integral(self):
        html = leer(SIMPLIFICADO)
        raiz = raiz_html(html)
        for id_ in SECCIONES_SIMPLIFICADO:
            self.assertIsNotNone(raiz.por_id(id_), id_)
        enlaces = [e.attrs.get("href") for e in seccion(html, "aviso-integral").buscar("a")]
        self.assertIn("/privacidad/", enlaces)
        finalidades = seccion(html, "finalidades")
        for valor in ("necesarias", "con-consentimiento"):
            bloques = finalidades.buscar(data_finalidad=valor)
            self.assertEqual(len(bloques), 1, valor)
            self.assertTrue(bloques[0].texto(), valor)
        responsable = seccion(html, "responsable").texto()
        self.assertTrue(responsable, "responsable vacío")
        for ausente in ("transferencias-con-consentimiento", "como-negarse"):
            self.assertIsNone(raiz.por_id(ausente), ausente)

    def test_TC_TT_WEB_02_06_version_y_fecha_visibles(self):
        versiones = set()
        for nombre in LEGALES:
            html = leer(nombre)
            raiz = raiz_html(html)
            declarada = raiz.attrs.get("data-version")
            self.assertRegex(declarada or "", r"^\d+\.\d+$", nombre)
            versiones.add(declarada)
            main = raiz.buscar("main")[0]
            antes_del_h2 = []
            for nodo in main.descendientes():
                if nodo.tag == "h2":
                    break
                antes_del_h2.append(nodo)
            texto = " ".join(n.texto() for n in antes_del_h2 if n.tag == "p")
            self.assertIn(f"Versión {declarada}", texto, nombre)
            tiempos = [n for n in antes_del_h2 if n.tag == "time"]
            self.assertEqual(len(tiempos), 1, nombre)
            fecha = datetime.date.fromisoformat(tiempos[0].attrs["datetime"])
            self.assertLessEqual(fecha, datetime.date.today(), nombre)
        self.assertEqual(len(versiones), 1, "Las tres páginas declaran la misma versión")

    def test_TC_TT_WEB_02_07_texto_provisional_nunca_se_presenta_como_vigente(self):
        for nombre in LEGALES:
            html = leer(nombre)
            self.assertEqual(estado(html), "borrador", nombre)
            revisar_estado(html)
        # Controles: cada regla rota debe hacer fallar la revisión.
        integral = leer(INTEGRAL)
        vigente_con_marcadores = con(integral, 'data-estado="borrador"', 'data-estado="vigente"')
        with self.assertRaises(AssertionError):
            revisar_estado(vigente_con_marcadores)
        sin_noindex = con(integral, '<meta name="robots" content="noindex">', "")
        with self.assertRaises(AssertionError):
            revisar_estado(sin_noindex)
        sin_aviso = con(integral, 'class="provisional"', 'class="otro"').replace(
            AVISO_PROVISIONAL, "Aviso"
        )
        with self.assertRaises(AssertionError):
            revisar_estado(sin_aviso)
        invalido = con(integral, 'data-estado="borrador"', 'data-estado="final"')
        with self.assertRaises(AssertionError):
            revisar_estado(invalido)

    def test_TC_TT_WEB_02_08_sin_recursos_de_terceros(self):
        for nombre in LEGALES:
            html = leer(nombre)
            revisar_sin_terceros(html)
            hojas = [
                e.attrs["href"]
                for e in raiz_html(html).buscar("link")
                if e.attrs.get("rel") == "stylesheet"
            ]
            self.assertEqual(hojas, ["/css/landing.css"], nombre)
        integral = leer(INTEGRAL)
        for malo in (
            integral.replace("</body>", "<script>1</script></body>"),
            integral.replace("<main", '<main style="color:red"', 1),
            integral.replace("</body>", '<img src="https://x.test/a.png"></body>'),
            integral.replace("</main>", "<!-- TT-WEB-02 --></main>"),
            integral.replace("[PENDIENTE: texto del aviso sobre cada", "[PENDIENTE: HU-001 cada", 1),
        ):
            with self.assertRaises(AssertionError):
                revisar_sin_terceros(malo)
        css = leer("css/landing.css")
        self.assertNotRegex(css, r"(?i)https?:|@import")

    def test_TC_TT_WEB_02_09_estructura_accesible(self):
        for nombre in LEGALES:
            html = leer(nombre)
            raiz = raiz_html(html)
            self.assertEqual(raiz.attrs.get("lang"), "es-MX", nombre)
            titulos = raiz.buscar("title")
            self.assertEqual(len(titulos), 1, nombre)
            titulo = re.search(r"<title>(.+?)</title>", html)
            self.assertTrue(titulo and titulo.group(1).endswith("Knock"), nombre)
            for region in ("header", "main", "footer"):
                self.assertEqual(len(raiz.buscar(region)), 1, f"<{region}> en {nombre}")
            saltar = [
                e for e in raiz.buscar("a") if e.texto() == "Saltar al contenido"
            ]
            self.assertEqual(len(saltar), 1, nombre)
            destino = saltar[0].attrs["href"].lstrip("#")
            self.assertEqual(raiz.por_id(destino).tag, "main", nombre)
            niveles = [int(n.tag[1]) for n in raiz.descendientes() if re.fullmatch(r"h[1-6]", n.tag)]
            self.assertEqual(niveles[0], 1, nombre)
            for anterior, siguiente in zip(niveles, niveles[1:]):
                self.assertLessEqual(siguiente, anterior + 1, f"Salto de encabezado en {nombre}")
            for enlace in raiz.buscar("a"):
                self.assertTrue(enlace.texto(), f"Enlace sin nombre en {nombre}")
                self.assertNotIn(enlace.texto().lower(), ("aquí", "click aquí", "más"), nombre)
            viewport = [m for m in raiz.buscar("meta") if m.attrs.get("name") == "viewport"]
            self.assertEqual(len(viewport), 1, nombre)
            self.assertNotRegex(viewport[0].attrs["content"], r"user-scalable|maximum-scale")

    def test_TC_TT_WEB_02_10_inventario_completo_en_el_aviso(self):
        html = leer(INTEGRAL)
        tratados = seccion(html, "datos-tratados")
        presentes = [n.attrs["data-categoria"] for n in tratados.buscar() if "data-categoria" in n.attrs]
        self.assertEqual(sorted(presentes), sorted(CATEGORIAS))
        sensibles = seccion(html, "datos-sensibles")
        sensibles_presentes = [
            n.attrs["data-categoria"] for n in sensibles.buscar() if "data-categoria" in n.attrs
        ]
        self.assertEqual(sensibles_presentes, [CATEGORIA_SENSIBLE])
        self.assertNotIn(CATEGORIA_SENSIBLE, presentes)
        for id_ in ("alojamiento-fuera-de-mexico", "datos-sensibles"):
            self.assertTrue(seccion(html, id_).texto().replace("Datos personales sensibles", "").strip(), id_)
        # Control: si falta una categoría, la comparación falla.
        sin_celular = con(html, 'data-categoria="celular"', 'data-categoria="otra"')
        tratados_roto = seccion(sin_celular, "datos-tratados")
        rotas = [n.attrs["data-categoria"] for n in tratados_roto.buscar() if "data-categoria" in n.attrs]
        self.assertNotEqual(sorted(rotas), sorted(CATEGORIAS))

    def test_TC_TT_WEB_02_11_datos_fijados_por_el_lider(self):
        integral, eliminar, simplificado = leer(INTEGRAL), leer(ELIMINAR), leer(SIMPLIFICADO)
        revisar_datos_del_lider(integral, eliminar, simplificado)
        # Controles: cada dato fijado, al quitarse o contradecirse, hace fallar la revisión.
        cambios = (
            (integral, "20 días hábiles", "30 días hábiles"),
            (integral, "15 días hábiles", "10 días"),
            (integral, "mayores de 18 años", "mayores de 16 años"),
            (integral, "a los 7 días", "a los 30 días"),
            (eliminar, "se desvinculan de tu nombre", "se anonimizan"),
        )
        for html, viejo, nuevo in cambios:
            roto = con(html, viejo, nuevo)
            args = {
                id(integral): (roto, eliminar, simplificado),
                id(eliminar): (integral, roto, simplificado),
            }[id(html)]
            with self.assertRaises(AssertionError, msg=viejo):
                revisar_datos_del_lider(*args)
        sin_correo = con(eliminar, f"Escribe a {CORREO}", "Escribe a soporte")
        with self.assertRaises(AssertionError):
            revisar_datos_del_lider(integral, sin_correo, simplificado)

    def test_TC_TT_WEB_02_12_sin_confirmacion_en_7_dias_no_se_borra_nada(self):
        eliminar = leer(ELIMINAR)
        revisar_confirmacion_sin_app(eliminar)
        for viejo in ("7 días", "se cancela", "no se borra nada"):
            roto = eliminar.replace(viejo, "otra cosa", 1)
            with self.assertRaises(AssertionError, msg=viejo):
                revisar_confirmacion_sin_app(roto)
        con_dias = con(eliminar, "la eliminación es definitiva", "tienes 7 días; es definitiva")
        with self.assertRaises(AssertionError):
            revisar_confirmacion_sin_app(con_dias)


if __name__ == "__main__":
    unittest.main()
