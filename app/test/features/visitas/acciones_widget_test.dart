import 'package:app/core/errores/failure.dart';
import 'package:app/core/router/rutas.dart';
import 'package:app/core/sesion/es_tecnico_provider.dart';
import 'package:app/features/visitas/data/visitas_repository_de_prueba.dart';
import 'package:app/features/visitas/domain/selector_fotos.dart';
import 'package:app/features/visitas/domain/visita.dart';
import 'package:app/features/visitas/domain/visita_acciones.dart';
import 'package:app/features/visitas/presentation/agenda_screen.dart';
import 'package:app/features/visitas/presentation/horarios_screen.dart';
import 'package:app/features/visitas/presentation/visita_screen.dart';
import 'package:app/features/visitas/visitas_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _FotosFalsas implements SelectorFotos {
  @override
  Future<List<String>> elegir({required int maximo}) async =>
      ['foto-1', 'foto-2'].take(maximo).toList();
}

Future<void> _montar(
  WidgetTester tester,
  VisitasRepositoryDePrueba repo,
  Widget home, {
  bool conFotos = false,
  bool tecnico = false,
  List<Override> extra = const [],
}) async {
  tester.view
    ..physicalSize = const Size(800, 1800)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        visitasRepositoryProvider.overrideWithValue(repo),
        if (conFotos) selectorFotosProvider.overrideWithValue(_FotosFalsas()),
        if (tecnico) esTecnicoProvider.overrideWith(_Tecnico.new),
        ...extra,
      ],
      child: MaterialApp(home: home),
    ),
  );
  await tester.pumpAndSettle();
}

class _Tecnico extends EsTecnicoNotifier {
  @override
  bool build() => true;
}

Finder _d(String texto) => find.descendant(
  of: find.byType(AlertDialog),
  matching: find.ancestor(
    of: find.text(texto),
    matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
  ),
);

VisitaScreen _pantalla(String id) => VisitaScreen(visitaId: id);

Future<void> _tocar(WidgetTester tester, String texto) async {
  await tester.ensureVisible(find.text(texto).last);
  await tester.tap(find.text(texto).last);
  await tester.pumpAndSettle();
}

Future<void> _escribir(WidgetTester tester, String clave, String texto) async {
  await tester.enterText(find.byKey(ValueKey('campo-$clave')), texto);
  await tester.pump();
}

void main() {
  group('detalle por rol y estado', () {
    testWidgets('el cliente ve su código y no la acción de llegada', (
      tester,
    ) async {
      await _montar(tester, VisitasRepositoryDePrueba(), _pantalla('v1'));
      expect(find.textContaining('Código de la visita: 1234'), findsOneWidget);
      expect(find.text('Confirmar llegada'), findsNothing);
      expect(find.text('El cliente no se presentó'), findsNothing);
      expect(find.text('Avisar a alguien de confianza'), findsOneWidget);
    });

    testWidgets('el técnico ve colonia y dirección, sin código', (
      tester,
    ) async {
      await _montar(tester, VisitasRepositoryDePrueba(), _pantalla('t1'));
      expect(find.textContaining('Código de la visita'), findsNothing);
      expect(find.text('Colonia: Colonia Ficticia'), findsOneWidget);
      expect(find.text('Lugar: Calle Falsa 1'), findsOneWidget);
      expect(find.text('Confirmar llegada'), findsOneWidget);
      expect(find.text('Avisar a alguien de confianza'), findsNothing);
    });

    testWidgets('una visita cancelada no ofrece acciones', (tester) async {
      await _montar(
        tester,
        VisitasRepositoryDePrueba(
          visitas: const [
            Visita(
              id: 'z',
              rol: 'cliente',
              estado: 'cancelada',
              modalidad: 'taller',
              dia: 'Lunes',
              hora: '10:00',
              tope: 100,
              lugar: VisitaLugar(tipo: 'taller'),
              puedeLlegar: false,
            ),
          ],
        ),
        _pantalla('z'),
      );
      expect(find.byKey(const ValueKey('sin-acciones')), findsOneWidget);
      expect(find.text('Reprogramar'), findsNothing);
      expect(find.text('Cancelar visita'), findsNothing);
    });

    testWidgets('el motivo del código ausente se explica', (tester) async {
      await _montar(
        tester,
        VisitasRepositoryDePrueba(
          visitas: const [
            Visita(
              id: 'z',
              rol: 'cliente',
              estado: 'confirmada',
              modalidad: 'domicilio',
              dia: 'Lunes',
              hora: '10:00',
              tope: 100,
              lugar: VisitaLugar(tipo: 'domicilio'),
              motivoCodigo: 'vencido',
              puedeLlegar: false,
            ),
          ],
        ),
        _pantalla('z'),
      );
      expect(find.text('El código venció.'), findsOneWidget);
    });

    testWidgets('503 al cargar: Reintentar recarga', (tester) async {
      await _montar(
        tester,
        VisitasRepositoryDePrueba(falla: const ServicioNoDisponibleFailure()),
        _pantalla('v1'),
      );
      expect(find.text('Reintentar'), findsOneWidget);
    });
  });

  group('llegada del técnico', () {
    testWidgets('valida cuatro dígitos antes de enviar', (tester) async {
      final repo = VisitasRepositoryDePrueba();
      await _montar(tester, repo, _pantalla('t1'));
      await _tocar(tester, 'Confirmar llegada');
      await _escribir(tester, 'codigo', '12');
      await tester.tap(_d('Confirmar llegada'));
      await tester.pump();
      expect(find.text('El código tiene 4 dígitos.'), findsOneWidget);
      expect(repo.acciones, isEmpty);
    });

    testWidgets('solo acepta dígitos', (tester) async {
      await _montar(tester, VisitasRepositoryDePrueba(), _pantalla('t1'));
      await _tocar(tester, 'Confirmar llegada');
      await _escribir(tester, 'codigo', 'ab12');
      final campo = tester.widget<TextField>(
        find.byKey(const ValueKey('campo-codigo')),
      );
      expect(campo.controller!.text, '12');
    });

    testWidgets('código incorrecto deja el error dentro del diálogo', (
      tester,
    ) async {
      final repo = VisitasRepositoryDePrueba();
      await _montar(tester, repo, _pantalla('t1'));
      await _tocar(tester, 'Confirmar llegada');
      await _escribir(tester, 'codigo', '0000');
      await tester.tap(_d('Confirmar llegada'));
      await tester.pumpAndSettle();
      expect(find.textContaining('código no es correcto'), findsOneWidget);
      expect(find.byKey(const ValueKey('campo-codigo')), findsOneWidget);
    });

    testWidgets('al tercer intento la visita queda bloqueada', (tester) async {
      await _montar(tester, VisitasRepositoryDePrueba(), _pantalla('t1'));
      await _tocar(tester, 'Confirmar llegada');
      for (var i = 0; i < 3; i++) {
        await _escribir(tester, 'codigo', '0000');
        await tester.tap(_d('Confirmar llegada'));
        await tester.pumpAndSettle();
      }
      expect(find.textContaining('bloqueada'), findsOneWidget);
    });

    testWidgets('código correcto: visita en curso y llegada registrada', (
      tester,
    ) async {
      final repo = VisitasRepositoryDePrueba();
      await _montar(tester, repo, _pantalla('t1'));
      await _tocar(tester, 'Confirmar llegada');
      await _escribir(tester, 'codigo', '1234');
      await tester.tap(_d('Confirmar llegada'));
      await tester.pumpAndSettle();
      expect(repo.acciones, ['llegada:t1']);
      expect(
        find.text('Registramos tu llegada. La visita está en curso.'),
        findsOneWidget,
      );
      expect(find.text('Estado: En curso'), findsOneWidget);
      expect(find.textContaining('Llegaste a las'), findsOneWidget);
      // Ya en curso: aparecen terminar y cotizar, y se va la llegada.
      expect(find.text('Terminar visita'), findsOneWidget);
      expect(find.text('Confirmar llegada'), findsNothing);
    });
  });

  group('aviso de confianza', () {
    testWidgets('muestra el texto para copiar', (tester) async {
      final repo = VisitasRepositoryDePrueba();
      await _montar(tester, repo, _pantalla('v1'));
      await _tocar(tester, 'Avisar a alguien de confianza');
      expect(find.textContaining('Hoy un técnico de Knock'), findsOneWidget);
      expect(find.textContaining('No incluye el código'), findsOneWidget);
      await tester.tap(find.text('Copiar texto'));
      await tester.pumpAndSettle();
      expect(find.text('Texto copiado.'), findsOneWidget);
      await tester.tap(find.text('Cerrar'));
      await tester.pumpAndSettle();
      expect(find.text('Copiar texto'), findsNothing);
    });

    testWidgets('si la ruta no existe lo dice y permite reintentar', (
      tester,
    ) async {
      await _montar(
        tester,
        VisitasRepositoryDePrueba(
          fallaAcciones: const RutaNoDisponibleFailure(),
        ),
        _pantalla('v1'),
      );
      await _tocar(tester, 'Avisar a alguien de confianza');
      expect(
        find.text('Esta función todavía no está disponible.'),
        findsOneWidget,
      );
      expect(find.text('Reintentar'), findsOneWidget);
    });
  });

  group('terminar la visita', () {
    testWidgets('exige descripción y de 1 a 5 fotos', (tester) async {
      final repo = VisitasRepositoryDePrueba();
      await _montar(tester, repo, _pantalla('t2'));
      await _tocar(tester, 'Terminar visita');
      await tester.tap(_d('Terminar visita'));
      await tester.pump();
      expect(find.text('Describe el trabajo que hiciste.'), findsOneWidget);
      expect(find.text('Agrega de 1 a 5 fotos.'), findsOneWidget);
      expect(repo.acciones, isEmpty);
    });

    testWidgets('sin selector de fotos avisa que no está disponible', (
      tester,
    ) async {
      await _montar(tester, VisitasRepositoryDePrueba(), _pantalla('t2'));
      await _tocar(tester, 'Terminar visita');
      await tester.tap(find.text('Agregar fotos'));
      await tester.pumpAndSettle();
      expect(
        find.text('Agregar fotos todavía no está disponible.'),
        findsOneWidget,
      );
    });

    testWidgets('con fotos y descripción termina la visita', (tester) async {
      final repo = VisitasRepositoryDePrueba();
      await _montar(tester, repo, _pantalla('t2'), conFotos: true);
      await _tocar(tester, 'Terminar visita');
      await _escribir(tester, 'descripcion', 'Cambié la llave del lavabo');
      await tester.tap(find.text('Agregar fotos'));
      await tester.pumpAndSettle();
      expect(find.textContaining('2 de 5'), findsOneWidget);
      await tester.tap(_d('Terminar visita'));
      await tester.pumpAndSettle();
      expect(repo.acciones, ['terminar:t2:2']);
      expect(find.text('Estado: Terminada'), findsOneWidget);
      // El técnico no tiene más acciones tras terminar.
      expect(find.byKey(const ValueKey('sin-acciones')), findsOneWidget);
    });
  });

  group('cotización final', () {
    testWidgets('valida precio entero y descripción', (tester) async {
      final repo = VisitasRepositoryDePrueba();
      await _montar(tester, repo, _pantalla('t2'));
      await _tocar(tester, 'Enviar cotización final');
      await tester.tap(_d('Enviar cotización'));
      await tester.pump();
      expect(find.text('Escribe el precio.'), findsOneWidget);
      expect(find.text('Describe el trabajo que hiciste.'), findsOneWidget);
      await _escribir(tester, 'precio', '0');
      await tester.tap(_d('Enviar cotización'));
      await tester.pump();
      expect(find.text('El precio debe ser mayor que cero.'), findsOneWidget);
      expect(repo.acciones, isEmpty);
    });

    testWidgets('envía y una segunda cotización se rechaza', (tester) async {
      final repo = VisitasRepositoryDePrueba();
      await _montar(tester, repo, _pantalla('t2'));
      for (var i = 0; i < 2; i++) {
        await _tocar(tester, 'Enviar cotización final');
        await _escribir(tester, 'precio', '480');
        await _escribir(tester, 'descripcion', 'Cambio de tubería');
        await tester.tap(_d('Enviar cotización'));
        await tester.pumpAndSettle();
        if (i == 0) {
          expect(
            find.textContaining('Enviaste la cotización final de \$480'),
            findsOneWidget,
          );
        }
      }
      expect(repo.acciones, ['cotizacion:t2:480']);
      expect(find.text('La visita ya no permite esta acción.'), findsOneWidget);
    });
  });

  group('decisión de la cotización final (cliente)', () {
    testWidgets('aprobar', (tester) async {
      final repo = VisitasRepositoryDePrueba();
      await repo.enviarCotizacionFinal(
        'c1',
        precio: 300,
        descripcion: 'Trabajo',
      );
      await _montar(tester, repo, _pantalla('c1'));
      await _tocar(tester, 'Responder a la cotización final');
      expect(find.textContaining('definitiva'), findsOneWidget);
      await tester.tap(_d('Aprobar'));
      await tester.pumpAndSettle();
      expect(repo.acciones.last, 'decision:c1:true');
      expect(find.text('Aprobaste la cotización final.'), findsOneWidget);
    });

    testWidgets('rechazar dice que solo se paga la visita', (tester) async {
      final repo = VisitasRepositoryDePrueba();
      await repo.enviarCotizacionFinal(
        'c1',
        precio: 300,
        descripcion: 'Trabajo',
      );
      await _montar(tester, repo, _pantalla('c1'));
      await _tocar(tester, 'Responder a la cotización final');
      await tester.tap(_d('Rechazar'));
      await tester.pumpAndSettle();
      expect(repo.acciones.last, 'decision:c1:false');
      expect(find.textContaining('solo se paga la visita'), findsOneWidget);
    });

    testWidgets('sin cotización el servidor rechaza y el diálogo sigue', (
      tester,
    ) async {
      await _montar(tester, VisitasRepositoryDePrueba(), _pantalla('c1'));
      await _tocar(tester, 'Responder a la cotización final');
      await tester.tap(_d('Aprobar'));
      await tester.pumpAndSettle();
      expect(find.text('La visita ya no permite esta acción.'), findsOneWidget);
      expect(_d('Aprobar'), findsOneWidget);
    });

    testWidgets('el técnico no ve la decisión', (tester) async {
      await _montar(tester, VisitasRepositoryDePrueba(), _pantalla('t2'));
      expect(find.text('Responder a la cotización final'), findsNothing);
    });
  });

  group('visita terminada (cliente)', () {
    testWidgets('no terminado exige 8 caracteres y solo se reporta una vez', (
      tester,
    ) async {
      final repo = VisitasRepositoryDePrueba();
      await _montar(tester, repo, _pantalla('c2'));
      await _tocar(tester, 'Reportar que no se terminó');
      expect(find.textContaining('7 días'), findsOneWidget);
      await _escribir(tester, 'texto', 'corto');
      await tester.tap(_d('Enviar reporte'));
      await tester.pump();
      expect(find.text('Escribe al menos 8 caracteres.'), findsOneWidget);
      expect(repo.acciones, isEmpty);
      await _escribir(tester, 'texto', 'Quedó una fuga sin reparar');
      await tester.tap(_d('Enviar reporte'));
      await tester.pumpAndSettle();
      expect(repo.acciones, ['no_terminado:c2']);
      expect(
        find.text('Recibimos tu reporte. Lo vamos a revisar.'),
        findsOneWidget,
      );
      // Segundo reporte: el servidor lo rechaza y se muestra dentro.
      await _tocar(tester, 'Reportar que no se terminó');
      await _escribir(tester, 'texto', 'Quedó una fuga sin reparar');
      await tester.tap(_d('Enviar reporte'));
      await tester.pumpAndSettle();
      expect(find.text('La visita ya no permite esta acción.'), findsOneWidget);
    });

    testWidgets('permiso de fotos: autorizar y no autorizar', (tester) async {
      final repo = VisitasRepositoryDePrueba();
      await _montar(tester, repo, _pantalla('c2'));
      await _tocar(tester, 'Permiso para publicar las fotos');
      await tester.tap(_d('Autorizar'));
      await tester.pumpAndSettle();
      expect(
        find.text('Autorizaste publicar las fotos del trabajo.'),
        findsOneWidget,
      );
      await _tocar(tester, 'Permiso para publicar las fotos');
      await tester.tap(_d('No autorizar'));
      await tester.pumpAndSettle();
      expect(repo.acciones, ['permiso:c2:true', 'permiso:c2:false']);
    });

    testWidgets('el técnico no puede reportar ni dar permiso', (tester) async {
      await _montar(
        tester,
        VisitasRepositoryDePrueba(
          visitas: const [
            Visita(
              id: 'z',
              rol: 'tecnico',
              estado: 'terminada',
              modalidad: 'domicilio',
              dia: 'Lunes',
              hora: '10:00',
              tope: 100,
              lugar: VisitaLugar(tipo: 'domicilio'),
              puedeLlegar: false,
            ),
          ],
        ),
        _pantalla('z'),
      );
      expect(find.text('Reportar que no se terminó'), findsNothing);
      expect(find.text('Permiso para publicar las fotos'), findsNothing);
    });
  });

  group('cancelar, reprogramar y errores', () {
    testWidgets('cancelar valida el motivo (8 a 300) y no envía si falla', (
      tester,
    ) async {
      final repo = VisitasRepositoryDePrueba();
      await _montar(tester, repo, _pantalla('v1'));
      await _tocar(tester, 'Cancelar visita');
      await _escribir(tester, 'motivo', 'corto');
      await tester.tap(_d('Cancelar visita'));
      await tester.pump();
      expect(find.text('Escribe al menos 8 caracteres.'), findsOneWidget);
      expect(repo.acciones, isEmpty);
    });

    testWidgets('«Volver» cierra sin cancelar', (tester) async {
      final repo = VisitasRepositoryDePrueba();
      await _montar(tester, repo, _pantalla('v1'));
      await _tocar(tester, 'Cancelar visita');
      await tester.tap(find.text('Volver'));
      await tester.pumpAndSettle();
      expect(repo.acciones, isEmpty);
      expect(find.byKey(const ValueKey('campo-motivo')), findsNothing);
    });

    testWidgets('una acción lenta no se envía dos veces', (tester) async {
      final repo = VisitasRepositoryDePrueba(
        retraso: const Duration(milliseconds: 300),
      );
      await _montar(tester, repo, _pantalla('v1'));
      await _tocar(tester, 'Responder a un nuevo horario');
      await tester.tap(_d('Aceptar'));
      await tester.pump(const Duration(milliseconds: 50));
      // En curso: los botones están deshabilitados y hay un indicador.
      final boton = tester.widget<FilledButton>(find.byType(FilledButton).last);
      expect(boton.onPressed, isNull);
      expect(find.bySemanticsLabel('Enviando'), findsWidgets);
      await tester.pumpAndSettle();
      expect(repo.acciones, ['respuesta:v1:true']);
    });

    testWidgets('429 muestra el texto de límite dentro del diálogo', (
      tester,
    ) async {
      await _montar(
        tester,
        VisitasRepositoryDePrueba(
          fallaAcciones: const LimiteDePeticionesFailure(),
        ),
        _pantalla('v1'),
      );
      await _tocar(tester, 'Responder a un nuevo horario');
      await tester.tap(_d('Aceptar'));
      await tester.pumpAndSettle();
      expect(find.textContaining('muchas peticiones'), findsOneWidget);
    });
  });

  group('agenda', () {
    testWidgets('el rango elegido llega a la agenda', (tester) async {
      final repo = VisitasRepositoryDePrueba();
      await _montar(
        tester,
        repo,
        const AgendaScreen(),
        extra: [
          rangoAgendaProvider.overrideWith(() {
            return _RangoFijo();
          }),
        ],
      );
      expect(repo.ultimoDesde, DateTime(2026, 11, 20));
      expect(repo.ultimoHasta, DateTime(2026, 11, 30));
    });

    testWidgets('vacío con rango ofrece volver al rango por omisión', (
      tester,
    ) async {
      final repo = VisitasRepositoryDePrueba(visitas: const []);
      await _montar(
        tester,
        repo,
        const AgendaScreen(),
        extra: [rangoAgendaProvider.overrideWith(_RangoFijo.new)],
      );
      expect(
        find.text('No tienes visitas en ese rango de fechas'),
        findsOneWidget,
      );
      await tester.tap(find.text('Ver el rango por omisión'));
      await tester.pumpAndSettle();
      expect(find.text('No tienes visitas programadas'), findsOneWidget);
    });

    testWidgets('el cliente no ve los horarios', (tester) async {
      await _montar(tester, VisitasRepositoryDePrueba(), const AgendaScreen());
      expect(find.byTooltip('Mis horarios'), findsNothing);
    });

    testWidgets('el técnico ve los horarios', (tester) async {
      await _montar(
        tester,
        VisitasRepositoryDePrueba(),
        const AgendaScreen(),
        tecnico: true,
      );
      expect(find.byTooltip('Mis horarios'), findsOneWidget);
    });

    testWidgets('agenda a detalle, acción y regreso con la agenda al día', (
      tester,
    ) async {
      final repo = VisitasRepositoryDePrueba();
      final router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, _) => const AgendaScreen()),
          GoRoute(
            path: '${Rutas.agenda}/:id',
            builder: (_, e) => VisitaScreen(visitaId: e.pathParameters['id']!),
          ),
        ],
      );
      addTearDown(router.dispose);
      tester.view
        ..physicalSize = const Size(800, 1800)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [visitasRepositoryProvider.overrideWithValue(repo)],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Estado: Confirmada'), findsNothing);
      await tester.tap(find.textContaining('Miércoles 25 de noviembre'));
      await tester.pumpAndSettle();
      expect(find.text('Visita'), findsOneWidget);
      // Cancelar desde el detalle.
      await _tocar(tester, 'Cancelar visita');
      await _escribir(tester, 'motivo', 'Ya no lo necesito');
      await tester.tap(_d('Cancelar visita'));
      await tester.pumpAndSettle();
      final antes = repo.llamadasAgenda;
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Agenda de visitas'), findsOneWidget);
      expect(repo.llamadasAgenda, greaterThan(antes));
      expect(find.textContaining('Cancelada'), findsOneWidget);
    });
  });

  group('horarios del técnico', () {
    testWidgets('cargando, 404 de ruta y 503', (tester) async {
      await _montar(
        tester,
        VisitasRepositoryDePrueba(
          fallaHorarios: const RutaNoDisponibleFailure(),
        ),
        const HorariosScreen(),
      );
      expect(
        find.text('Esta función todavía no está disponible.'),
        findsOneWidget,
      );
      await _montar(
        tester,
        VisitasRepositoryDePrueba(
          fallaHorarios: const ServicioNoDisponibleFailure(),
        ),
        const HorariosScreen(),
      );
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('sin horario guardado muestra los siete días cerrados', (
      tester,
    ) async {
      await _montar(
        tester,
        VisitasRepositoryDePrueba(),
        const HorariosScreen(),
      );
      expect(find.text('Cerrado'), findsNWidgets(7));
      expect(find.text('Miércoles'), findsOneWidget);
      final guardar = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(guardar.onPressed, isNull);
    });

    testWidgets('abrir un día, agregar franja y guardar', (tester) async {
      final repo = VisitasRepositoryDePrueba();
      await _montar(tester, repo, const HorariosScreen());
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();
      expect(find.text('De 09:00'), findsOneWidget);
      expect(find.text('a 18:00'), findsOneWidget);
      await tester.tap(find.text('Agregar franja de Lunes'));
      await tester.pumpAndSettle();
      expect(find.text('De 19:00'), findsOneWidget);
      // Con dos franjas ya no se puede agregar otra.
      expect(find.text('Agregar franja de Lunes'), findsNothing);
      await tester.tap(find.text('Guardar horarios'));
      await tester.pumpAndSettle();
      expect(repo.acciones, ['horarios']);
      expect(find.text('Guardamos tus horarios.'), findsOneWidget);
      final h = await repo.horarios();
      expect(h.first.franjas.length, 2);
    });

    testWidgets('cerrar un día quita sus franjas', (tester) async {
      final repo = VisitasRepositoryDePrueba(
        horarios: [
          const HorarioDia(
            dia: 'lunes',
            abierto: true,
            franjas: [FranjaHorario(inicio: '09:00', fin: '13:00')],
          ),
          ...horarioCerrado().skip(1),
        ],
      );
      await _montar(tester, repo, const HorariosScreen());
      expect(find.text('De 09:00'), findsOneWidget);
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();
      expect(find.text('De 09:00'), findsNothing);
      await tester.tap(find.text('Guardar horarios'));
      await tester.pumpAndSettle();
      expect((await repo.horarios()).first.abierto, isFalse);
    });

    testWidgets('si guardar falla conserva el borrador y avisa', (
      tester,
    ) async {
      final repo = VisitasRepositoryDePrueba(
        fallaAcciones: const ServicioNoDisponibleFailure(),
      );
      await _montar(tester, repo, const HorariosScreen());
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Guardar horarios'));
      await tester.pumpAndSettle();
      expect(find.textContaining('no está disponible'), findsOneWidget);
      expect(find.text('De 09:00'), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull,
      );
    });

    testWidgets('salir con cambios pide confirmar', (tester) async {
      final repo = VisitasRepositoryDePrueba();
      tester.view
        ..physicalSize = const Size(800, 1800)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [visitasRepositoryProvider.overrideWithValue(repo)],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => Navigator.of(context).push<void>(
                    MaterialPageRoute(builder: (_) => const HorariosScreen()),
                  ),
                  child: const Text('Abrir'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('¿Descartar los cambios?'), findsOneWidget);
      await tester.tap(find.text('Seguir editando'));
      await tester.pumpAndSettle();
      expect(find.text('Mis horarios'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Descartar'));
      await tester.pumpAndSettle();
      expect(find.text('Abrir'), findsOneWidget);
    });
  });
}

class _RangoFijo extends RangoAgendaNotifier {
  @override
  DateTimeRange? build() =>
      DateTimeRange(start: DateTime(2026, 11, 20), end: DateTime(2026, 11, 30));
}
