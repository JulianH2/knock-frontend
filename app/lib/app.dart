import 'package:app/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Raíz de la app. El tema (paleta, claro/oscuro) y los idiomas llegan con
/// TT-MOB-02.
class KnockApp extends ConsumerWidget {
  const KnockApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Knock',
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
