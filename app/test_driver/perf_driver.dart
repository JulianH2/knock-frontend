import 'package:flutter_driver/flutter_driver.dart' as driver;
import 'package:integration_test/integration_test_driver.dart';

/// Driver de TC-TT-MOB-04-01: convierte la traza de `traceAction` en el
/// resumen de *frames* (`build/mapa_rendimiento.timeline_summary.json`).
Future<void> main() {
  return integrationDriver(
    responseDataCallback: (data) async {
      final traza = data?['mapa_rendimiento'];
      if (traza is! Map<String, dynamic>) return;
      final resumen = driver.TimelineSummary.summarize(
        driver.Timeline.fromJson(traza),
      );
      await resumen.writeTimelineToFile(
        'mapa_rendimiento',
        pretty: true,
        includeSummary: true,
      );
    },
  );
}
