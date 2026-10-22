# Checklist — TT-MOB-04

- [ ] spec con 8 secciones + Aprobación, estado Aprobada y clave KNOCK-N
- [ ] Cada caso TC-TT-MOB-04-KK de este repo tiene prueba con su ID (TC-01, TC-02 y TC-07 con salida de comando en el PR)
- [ ] Amenazas de §6 con control y prueba
- [ ] Contrato y docs vivos actualizados (sin contrato; documento de resultados en `docs/spikes/`)
- [ ] Build, análisis estático, formato y pruebas en verde (resultados reales); `flutter build apk --debug` sin clave
- [ ] Cobertura y mutación en metas; sin supresiones sin EXC-NNN
- [ ] `security-reviewer` LIBERA · `traceability-clerk` sin drift
- [ ] `Memoria.md` actualizado · informe final en el PR
- [ ] Dependencias nuevas (`google_maps_flutter`, `geolocator`, `flutter_driver` del SDK) evaluadas y registradas en `Memoria.md`
- [ ] Ninguna clave de Maps versionada ni en el PR, logs o prompts; gitleaks limpio
- [ ] Una sola clave (Android), creada con el plan Blaze ya activo y restringida por app (`app.knock.mobile` + SHA-1) y por API (solo Maps SDK for Android); captura con la clave tapada
- [ ] Cuota diaria de 1 000 cargas y alerta de presupuesto de 1 USD configuradas (captura sin datos de facturación)
- [ ] Sin cambios en `app/ios/` (iOS fuera de alcance)
- [ ] Video y resumen de frames de TC-01 (o declaración honesta de que no hubo dispositivo físico)
- [ ] `docs/spikes/TT-MOB-04-google-maps.md` con precio vigente (fecha y URL) y recomendación para HU-011
- [ ] La pantalla de prueba no se alcanza desde `lib/main.dart`
