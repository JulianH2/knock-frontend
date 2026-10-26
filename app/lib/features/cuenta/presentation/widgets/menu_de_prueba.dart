import 'package:app/core/preferencias/preferencias_provider.dart';
import 'package:app/core/sesion/es_tecnico_provider.dart';
import 'package:app/l10n/generado/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controles de prueba de Mi cuenta: modo técnico, tema e idioma.
///
/// Solo se muestran fuera de release (`interruptorDePruebaProvider`); los
/// reemplazan la sesión real (rol) y la pantalla de Configuración de HU-052
/// (tema e idioma). TT-MOB-01 y TT-MOB-02.
class MenuDePrueba extends ConsumerWidget {
  const MenuDePrueba({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final preferencias = ref.watch(preferenciasProvider);
    final notifier = ref.read(preferenciasProvider.notifier);

    return ListView(
      children: [
        SwitchListTile(
          title: Text(textos.pruebaModoTecnico),
          value: ref.watch(esTecnicoProvider),
          onChanged: (valor) =>
              ref.read(esTecnicoProvider.notifier).cambiar(esTecnico: valor),
        ),
        _Encabezado(textos.pruebaTema),
        RadioGroup<ThemeMode>(
          groupValue: preferencias.modoTema,
          onChanged: (modo) {
            if (modo != null) notifier.cambiarTema(modo);
          },
          child: Column(
            children: [
              _Opcion(ThemeMode.system, textos.pruebaTemaSistema),
              _Opcion(ThemeMode.light, textos.pruebaTemaClaro),
              _Opcion(ThemeMode.dark, textos.pruebaTemaOscuro),
            ],
          ),
        ),
        _Encabezado(textos.pruebaIdioma),
        RadioGroup<Locale>(
          groupValue: preferencias.idioma,
          onChanged: (idioma) {
            if (idioma != null) notifier.cambiarIdioma(idioma);
          },
          child: Column(
            children: [
              _Opcion(const Locale('es'), textos.pruebaIdiomaEspanol),
              _Opcion(const Locale('en'), textos.pruebaIdiomaIngles),
            ],
          ),
        ),
      ],
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
    child: Semantics(
      header: true,
      child: Text(texto, style: Theme.of(context).textTheme.titleSmall),
    ),
  );
}

class _Opcion<T> extends StatelessWidget {
  const _Opcion(this.valor, this.texto);

  final T valor;
  final String texto;

  @override
  Widget build(BuildContext context) =>
      RadioListTile<T>(value: valor, title: Text(texto));
}
