String _dos(int n) => n.toString().padLeft(2, '0');

/// «14:05» en hora local.
String horaCorta(DateTime fecha) {
  final local = fecha.toLocal();
  return '${_dos(local.hour)}:${_dos(local.minute)}';
}

/// «21/11/2026 14:05» en hora local.
String fechaHoraCorta(DateTime fecha) {
  final local = fecha.toLocal();
  return '${_dos(local.day)}/${_dos(local.month)}/${local.year} '
      '${horaCorta(fecha)}';
}
