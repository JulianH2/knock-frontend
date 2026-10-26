import 'package:app/features/oficios/domain/modalidad.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TC-TT-PRU-02-06 modalidad', () {
    test('TC-TT-PRU-02-06 reconoce las modalidades del contrato', () {
      expect(Modalidad.desdeTexto('domicilio'), Modalidad.domicilio);
      expect(Modalidad.desdeTexto('taller'), Modalidad.taller);
      expect(Modalidad.domicilio.esDomicilio, isTrue);
      expect(Modalidad.taller.esTaller, isTrue);
      expect(Modalidad.domicilio.esConocida, isTrue);
      expect(Modalidad.taller.esConocida, isTrue);
    });

    test('TC-TT-PRU-02-06 conserva el texto de una modalidad desconocida', () {
      final remoto = Modalidad.desdeTexto('remoto');

      expect(remoto.valor, 'remoto');
      expect(remoto.esConocida, isFalse);
      expect(remoto.esDomicilio, isFalse);
      expect(remoto.esTaller, isFalse);
      expect(remoto, Modalidad.desdeTexto('remoto'));
      expect(remoto, isNot(Modalidad.taller));
    });
  });
}
