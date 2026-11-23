import 'package:app/core/router/rutas.dart';
import 'package:app/core/widgets/pantalla_titulada.dart';
import 'package:app/features/avisos/presentation/avisos_screen.dart';
import 'package:app/features/chat/presentation/conversaciones_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

/// Pestaña Actividad: accesos a avisos, mensajes y agenda de visitas.
class ActividadScreen extends StatelessWidget {
  const ActividadScreen({super.key});

  @override
  Widget build(BuildContext context) => PantallaTitulada(
    titulo: 'Actividad',
    cuerpo: ListView(
      children: [
        ListTile(
          leading: const InsigniaAvisos(hijo: Icon(Icons.notifications_none)),
          title: const Text('Avisos'),
          onTap: () => context.go(Rutas.avisos),
        ),
        ListTile(
          leading: const InsigniaChat(hijo: Icon(Icons.chat_bubble_outline)),
          title: const Text('Mensajes'),
          onTap: () => context.go(Rutas.chats),
        ),
        ListTile(
          leading: const Icon(Icons.event_outlined),
          title: const Text('Agenda de visitas'),
          onTap: () => context.go(Rutas.agenda),
        ),
      ],
    ),
  );
}
