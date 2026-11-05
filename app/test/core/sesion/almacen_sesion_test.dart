// KNOCK-228: los tokens van solo al almacenamiento seguro (security-core #10).
import 'package:app/core/sesion/almacen_sesion.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test(
    'guarda los dos tokens en el almacenamiento seguro y los borra',
    () async {
      const seguro = FlutterSecureStorage();
      final almacen = AlmacenSesionSeguro();

      expect(await almacen.tieneSesion(), isFalse);
      await almacen.guardarTokens(
        acceso: 'acceso-ficticio',
        renovacion: 'renovacion-ficticia',
      );

      expect(await seguro.readAll(), {
        AlmacenSesionSeguro.claveAcceso: 'acceso-ficticio',
        AlmacenSesionSeguro.claveRenovacion: 'renovacion-ficticia',
      });
      expect(await almacen.tieneSesion(), isTrue);

      await almacen.borrarTokens();
      expect(await seguro.readAll(), isEmpty);
      expect(await almacen.tieneSesion(), isFalse);
    },
  );

  test('el id del dispositivo se crea una vez y se reusa', () async {
    var creados = 0;
    final almacen = AlmacenSesionSeguro(
      nuevoId: () => '00000000-0000-4000-8000-00000000000${++creados}',
    );

    final primero = await almacen.idDeDispositivo();
    final segundo = await AlmacenSesionSeguro(nuevoId: () => 'no-se-usa')
        .idDeDispositivo();

    expect(primero, '00000000-0000-4000-8000-000000000001');
    expect(segundo, primero);
    expect(creados, 1);
  });

  test('el id por defecto es un UUID v4 de 36 caracteres', () async {
    final id = await AlmacenSesionSeguro().idDeDispositivo();
    expect(id, hasLength(36));
    expect(
      RegExp(
        '^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}',
      ).hasMatch(id),
      isTrue,
    );
  });

  test('borrar los tokens conserva el id del dispositivo', () async {
    final almacen = AlmacenSesionSeguro();
    final id = await almacen.idDeDispositivo();
    await almacen.guardarTokens(acceso: 'a', renovacion: 'r');
    await almacen.borrarTokens();
    expect(await almacen.idDeDispositivo(), id);
  });
}
