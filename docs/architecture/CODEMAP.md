# Mapa de código

> Generado por `scripts/codemap.py` el 2026-11-22T23:28:59Z. No editar a mano.
> **Antes de crear una clase, método o archivo, busca aquí o corre `python scripts/codemap.py --query "<qué necesitas>"`.**

## Resumen

| Módulo | Capas | Archivos | Tipos | Métodos públicos |
|---|---|---|---|---|
| `actividad` | presentation | 1 | 1 | 1 |
| `app` | - | 2 | 1 | 2 |
| `avisos` | -, data, domain, presentation | 11 | 25 | 42 |
| `chat` | -, data, domain, presentation | 11 | 47 | 83 |
| `cuenta` | presentation | 1 | 1 | 1 |
| `datos` | core | 2 | 1 | 12 |
| `dispositivos` | -, data, domain, presentation | 6 | 15 | 23 |
| `errores` | core | 1 | 7 | 1 |
| `explorar` | presentation | 1 | 1 | 1 |
| `home` | components, pages | 2 | 2 | 0 |
| `inicio` | presentation | 1 | 1 | 1 |
| `layout` | core | 1 | 1 | 0 |
| `oficios` | -, data, domain, presentation | 8 | 12 | 11 |
| `panel` | - | 3 | 1 | 0 |
| `router` | core | 3 | 3 | 4 |
| `sesion` | core | 1 | 1 | 2 |
| `trabajo` | presentation | 1 | 1 | 1 |
| `visitas` | -, data, domain, presentation | 14 | 45 | 86 |
| `widgets` | core | 2 | 3 | 4 |

## Índice por módulo

### actividad

**presentation**

- `app/lib/features/actividad/presentation/actividad_screen.dart` — class `ActividadScreen`
  - `build()`:13

### app

**-**

- `app/lib/app.dart` — class `KnockApp`
  - `build()`:11
- `app/lib/main.dart` — —
  - `main()`:5

### avisos

**-**

- `app/lib/features/avisos/avisos_providers.dart` — —

**data**

- `app/lib/features/avisos/data/avisos_mapper.dart` — class `AvisosMapper`
  - `aviso()`:7, `pagina()`:21, `contador()`:26, `preferencias()`:34
- `app/lib/features/avisos/data/avisos_repository_de_prueba.dart` — class `AvisosRepositoryDePrueba`, class `PreferenciasAvisosRepositoryDePrueba`
  - `contador()`:48, `marcarLeido()`:58, `marcarTodosLeidos()`:70, `obtener()`:119, `guardar()`:134

**domain**

- `app/lib/features/avisos/domain/aviso.dart` — class `Aviso`, class `PaginaAvisos`, class `ContadorAvisos`, class `FiltroAvisos`
  - `copiaLeido()`:26
- `app/lib/features/avisos/domain/avisos_repository.dart` — class `AvisosRepository`
- `app/lib/features/avisos/domain/destino_aviso.dart` — class `DestinoAviso`
  - `ruta()`:13
- `app/lib/features/avisos/domain/preferencias_avisos.dart` — class `PreferenciaAviso`, class `PreferenciasAvisosRepository`
  - `conActivo()`:15

**presentation**

- `app/lib/features/avisos/presentation/avisos_controller.dart` — class `ContadorAvisosNotifier`, class `FiltroAvisosNotifier`, class `BandejaAvisos`, class `AvisosController`
  - `build()`:11, `bajarUno()`:15, `ponerEnCero()`:25, `restaurar()`:29, `confirmar()`:36, `build()`:55, `cambiar()`:57, `copiar()`:79, `build()`:95, `reintentar()`:106, `cargarMas()`:109, `refrescar()`:137, `marcarLeido()`:157, `marcarTodosLeidos()`:179
- `app/lib/features/avisos/presentation/avisos_screen.dart` — class `AvisosScreen`, class `_Filtros`, class `_Lista`, class `_ListaState`, class `InsigniaAvisos`
  - `build()`:72, `build()`:142, `cambiar()`:144, `initState()`:202, `dispose()`:210, `build()`:264, `build()`:334
- `app/lib/features/avisos/presentation/preferencias_avisos_controller.dart` — class `PendientesPreferencias`, class `PendientesPreferenciasNotifier`, class `PreferenciasAvisosController`
  - `build()`:27, `poner()`:29, `build()`:42, `reintentar()`:54, `cambiar()`:58, `descartar()`:82, `guardar()`:91
- `app/lib/features/avisos/presentation/preferencias_avisos_screen.dart` — class `PreferenciasAvisosScreen`, class `_BannerPendiente`
  - `build()`:20, `build()`:113

### chat

**-**

- `app/lib/features/chat/chat_providers.dart` — —

**data**

- `app/lib/features/chat/data/chat_de_prueba.dart` — class `ConversacionesRepositoryDePrueba`, class `ChatHubDePrueba`, class `ChatHubInactivo`
  - `llegaMensaje()`:54, `listar()`:58, `noLeidas()`:97, `obtener()`:103, `mensajes()`:109, `enviar()`:126, `crear()`:154, `marcarLeido()`:189, `emitir()`:242, `conectar()`:248, `desconectar()`:251, `unirseAConversacion()`:257, `salirDeConversacion()`:263, `unirseAVisita()`:269, `salirDeVisita()`:275, `enviarMensajeVisita()`:281, `conectar()`:299, `desconectar()`:302, `unirseAConversacion()`:305, `salirDeConversacion()`:309, `unirseAVisita()`:313, `salirDeVisita()`:317, `enviarMensajeVisita()`:321
- `app/lib/features/chat/data/chat_hub_cliente.dart` — class `TokenHub`, class `MensajeDeHub`, class `TransporteHub`, class `TransporteHubInactivo`, class `ChatHubCliente`
  - `iniciar()`:53, `detener()`:57, `invocar()`:60, `retardoDeReconexion()`:65, `conectar()`:114, `desconectar()`:122, `renovarSesion()`:137, `unirseAConversacion()`:259, `salirDeConversacion()`:263, `unirseAVisita()`:269, `salirDeVisita()`:273, `enviarMensajeVisita()`:279
- `app/lib/features/chat/data/chat_mapper.dart` — class `ChatMapper`
  - `item()`:27, `pagina()`:42, `conversacion()`:63, `mensaje()`:80, `paginaMensajes()`:91, `resultadoHub()`:97, `evento()`:113

**domain**

- `app/lib/features/chat/domain/chat.dart` — class `ContraparteChat`, class `UltimoMensaje`, class `ConversacionItem`, class `PaginaConversaciones`, class `Conversacion`, class `ConversacionCreada`, class `Mensaje`, class `PaginaMensajes`, class `ConversacionesRepository`
  - `copiar()`:49, `comoCerrada()`:112, `bytesDeMensaje()`:172, `validarTextoMensaje()`:176
- `app/lib/features/chat/domain/chat_hub.dart` — class `EventoChat`, class `MensajeConversacionRecibido`, class `NoLeidosActualizados`, class `MensajeVisitaRecibido`, class `ConexionRestablecida`, class `ResultadoHub`, class `ChatHub`

**presentation**

- `app/lib/features/chat/presentation/abrir_conversacion.dart` — class `BotonAbrirChat`, class `_BotonAbrirChatState`
  - `abrirConversacion()`:14, `build()`:78
- `app/lib/features/chat/presentation/chat_controller.dart` — enum `EstadoEnvio`, class `MensajePendiente`, class `EstadoChat`, class `ChatController`
  - `con()`:40, `esMio()`:77, `copiar()`:79, `build()`:123, `reintentar()`:153, `visible()`:157, `validar()`:261, `enviar()`:281, `reintentarEnvio()`:297, `descartar()`:316, `cargarAnteriores()`:396
- `app/lib/features/chat/presentation/chat_screen.dart` — class `ChatScreen`, class `_ChatScreenState`, class `_AvisoDeSeguridad`, class `_Mensajes`, class `_MensajesState`, class `_Globo`, class `_Burbuja`, class `_BurbujaPendiente`, class `_Redaccion`, class `_RedaccionState`
  - `textoDeFalloDeEnvio()`:23, `initState()`:44, `dispose()`:50, `didChangeAppLifecycleState()`:56, `build()`:63, `build()`:126, `initState()`:158, `dispose()`:164, `didUpdateWidget()`:187, `build()`:219, `build()`:302, `build()`:336, `build()`:371, `dispose()`:425, `build()`:442
- `app/lib/features/chat/presentation/conversaciones_controller.dart` — class `BandejaChats`, class `ConversacionesController`
  - `copiar()`:35, `build()`:53, `reintentar()`:68, `refrescar()`:73, `cargarMas()`:141
- `app/lib/features/chat/presentation/conversaciones_screen.dart` — class `ConversacionesScreen`, class `_Lista`, class `_Fila`, class `InsigniaChat`
  - `build()`:16, `build()`:80, `build()`:128, `build()`:171

### cuenta

**presentation**

- `app/lib/features/cuenta/presentation/cuenta_screen.dart` — class `CuentaScreen`
  - `build()`:14

### datos

**core**

- `app/lib/core/datos/formato_fecha.dart` — —
  - `horaCorta()`:4, `fechaHoraCorta()`:10
- `app/lib/core/datos/lectura_json.dart` — class `LecturaJson`
  - `objeto()`:8, `objetoONulo()`:15, `lista()`:18, `texto()`:40, `textoONulo()`:47, `booleano()`:57, `booleanoONulo()`:64, `entero()`:68, `enteroONulo()`:81, `fecha()`:84

### dispositivos

**-**

- `app/lib/features/dispositivos/dispositivos_providers.dart` — —

**data**

- `app/lib/features/dispositivos/data/dispositivos_de_prueba.dart` — class `DispositivosRepositoryDePrueba`, class `ProveedorTokenPushDePrueba`, class `PermisoNotificacionesDePrueba`
  - `registrar()`:15, `darDeBaja()`:35, `obtener()`:52, `estado()`:69, `solicitar()`:72, `abrirAjustes()`:79

**domain**

- `app/lib/features/dispositivos/domain/dispositivo.dart` — enum `PlataformaDispositivo`, class `RegistroDispositivo`, class `DispositivosRepository`, class `ProveedorTokenPush`
  - `validarIdentificadorDispositivo()`:24
- `app/lib/features/dispositivos/domain/permiso_notificaciones.dart` — enum `EstadoPermiso`, class `PermisoNotificaciones`

**presentation**

- `app/lib/features/dispositivos/presentation/notificaciones_screen.dart` — class `NotificacionesScreen`, class `_NotificacionesScreenState`, class `_Estado`
  - `initState()`:23, `dispose()`:33, `didChangeAppLifecycleState()`:40, `build()`:47, `build()`:228
- `app/lib/features/dispositivos/presentation/registro_push_controller.dart` — enum `EstadoPush`, class `RegistroPush`, class `RegistroPushController`
  - `con()`:46, `conPermiso()`:49, `build()`:61, `refrescarPermiso()`:69, `registrar()`:82, `aceptarExplicacion()`:91, `rechazarExplicacion()`:100, `abrirAjustes()`:105, `reintentarManual()`:111, `alIniciarSesion()`:121, `darDeBaja()`:176

### errores

**core**

- `app/lib/core/errores/failure.dart` — class `Failure`, class `DatosInvalidosFailure`, class `ServicioNoDisponibleFailure`, class `RutaNoDisponibleFailure`, class `NoEncontradoFailure`, class `LimiteDePeticionesFailure`, class `ReglaDeNegocioFailure`
  - `toString()`:10

### explorar

**presentation**

- `app/lib/features/explorar/presentation/explorar_screen.dart` — class `ExplorarScreen`
  - `build()`:14

### home

**components**

- `panel/src/app/features/home/components/static-menu.component.ts` — class `StaticMenuComponent`

**pages**

- `panel/src/app/features/home/pages/home-page.component.ts` — class `HomePageComponent`

### inicio

**presentation**

- `app/lib/features/inicio/presentation/inicio_screen.dart` — class `InicioScreen`
  - `build()`:10

### layout

**core**

- `panel/src/app/core/layout/app-shell.component.ts` — class `AppShellComponent`

### oficios

**-**

- `app/lib/features/oficios/oficios_providers.dart` — —

**data**

- `app/lib/features/oficios/data/oficio_mapper.dart` — class `OficioMapper`
  - `listaDesdeContrato()`:13, `desdeContrato()`:21
- `app/lib/features/oficios/data/oficios_repository_de_prueba.dart` — class `OficiosRepositoryDePrueba`
  - `listar()`:24

**domain**

- `app/lib/features/oficios/domain/modalidad.dart` — class `Modalidad`
- `app/lib/features/oficios/domain/oficio.dart` — class `Oficio`
- `app/lib/features/oficios/domain/oficios_repository.dart` — class `OficiosRepository`

**presentation**

- `app/lib/features/oficios/presentation/oficios_controller.dart` — class `OficiosController`
  - `build()`:9, `reintentar()`:13
- `app/lib/features/oficios/presentation/oficios_screen.dart` — class `OficiosScreen`, class `_Cargando`, class `_Vacio`, class `_ConError`, class `_Lista`, class `_FilaOficio`
  - `build()`:15, `build()`:39, `build()`:48, `build()`:65, `build()`:93, `build()`:105

### panel

**-**

- `panel/src/app/app.routes.ts` — —
- `panel/src/app/app.ts` — class `App`
- `panel/src/main.ts` — —

### router

**core**

- `app/lib/core/router/app_router.dart` — —
- `app/lib/core/router/app_shell.dart` — class `_Destino`, class `AppShell`
  - `ramasVisibles()`:31, `build()`:44, `Scaffold()`:48
- `app/lib/core/router/rutas.dart` — class `Rutas`
  - `redireccionPorRol()`:38

### sesion

**core**

- `app/lib/core/sesion/es_tecnico_provider.dart` — class `EsTecnicoNotifier`
  - `build()`:13, `cambiar()`:16

### trabajo

**presentation**

- `app/lib/features/trabajo/presentation/trabajo_screen.dart` — class `TrabajoScreen`
  - `build()`:10

### visitas

**-**

- `app/lib/features/visitas/visitas_providers.dart` — class `RangoAgendaNotifier`
  - `build()`:29, `cambiar()`:31

**data**

- `app/lib/features/visitas/data/visitas_mapper.dart` — class `VisitasMapper`
  - `visita()`:17, `agendaItem()`:53, `agenda()`:66, `propuesta()`:71, `respuesta()`:81, `cancelacion()`:106, `ausencia()`:115, `aviso()`:124, `termino()`:133, `noTerminado()`:142, `cotizacionFinal()`:147, `decision()`:157, `permisoFotos()`:166, `horarios()`:175, `horariosAJson()`:193
- `app/lib/features/visitas/data/visitas_repository_de_prueba.dart` — class `VisitasRepositoryDePrueba`
  - `agenda()`:101, `obtener()`:131, `reprogramar()`:137, `responderReprogramacion()`:153, `cancelar()`:169, `noSePresento()`:186, `llegada()`:198, `avisoConfianza()`:228, `terminar()`:246, `noTerminado()`:270, `enviarCotizacionFinal()`:288, `decidirCotizacionFinal()`:313, `permisoFotos()`:331, `horarios()`:340, `guardarHorarios()`:349

**domain**

- `app/lib/features/visitas/domain/selector_fotos.dart` — class `SelectorFotos`, class `SelectorFotosNoDisponible`
  - `elegir()`:17
- `app/lib/features/visitas/domain/visita.dart` — class `VisitaTecnico`, class `VisitaLugar`, class `Visita`, class `AgendaItem`, class `PaginaAgenda`, class `PropuestaReprogramacion`, class `RespuestaReprogramacion`, class `ResultadoCancelacion`, class `ResultadoAusencia`, class `VisitasRepository`
  - `validarMotivoCancelacion()`:166
- `app/lib/features/visitas/domain/visita_acciones.dart` — class `AvisoConfianza`, class `ResultadoTermino`, class `ResultadoNoTerminado`, class `CotizacionFinal`, class `DecisionCotizacion`, class `PermisoFotos`, class `FranjaHorario`, class `HorarioDia`, class `LimitesVisita`, class `AccionesVisita`
  - `copiar()`:104, `horarioCerrado()`:124, `errorDeTexto()`:146, `errorMotivoCancelacion()`:165, `errorTextoNoTerminado()`:172, `errorDescripcionTrabajo()`:179, `errorRecomendacion()`:186, `errorCodigoLlegada()`:193, `errorPrecio()`:199, `errorFotos()`:214, `errorFechaReprogramacion()`:220, `errorRangoAgenda()`:226, `minutosDeHora()`:245, `nombreDeDia()`:253, `errorHorarioDia()`:262, `errorHorarios()`:290

**presentation**

- `app/lib/features/visitas/presentation/agenda_screen.dart` — class `AgendaScreen`
  - `build()`:39, `textoEstadoVisita()`:145
- `app/lib/features/visitas/presentation/dialogo_aviso.dart` — class `DialogoAviso`, class `_DialogoAvisoState`
  - `build()`:33
- `app/lib/features/visitas/presentation/dialogo_formulario.dart` — class `CampoFormulario`, class `OpcionDialogo`, class `DialogoFormulario`, class `_DialogoFormularioState`
  - `dispose()`:89, `build()`:167, `OutlinedButton()`:247
- `app/lib/features/visitas/presentation/horarios_controller.dart` — class `HorariosController`
  - `build()`:12, `reintentar()`:15, `guardar()`:19
- `app/lib/features/visitas/presentation/horarios_screen.dart` — class `HorariosScreen`, class `_Editor`, class `_EditorState`, class `_DiaEditor`
  - `build()`:14, `didUpdateWidget()`:76, `build()`:197, `PopScope()`:199, `build()`:286
- `app/lib/features/visitas/presentation/mensajes_visita.dart` — —
  - `mensajeDeErrorVisita()`:22
- `app/lib/features/visitas/presentation/visita_screen.dart` — class `VisitaScreen`, class `_Detalle`, class `_Boton`, class `_Codigo`
  - `build()`:22, `showDialog()`:277, `build()`:284, `horaDeLlegada()`:456, `build()`:476, `build()`:503
- `app/lib/features/visitas/presentation/visitas_controller.dart` — class `EstadoAgenda`, class `AgendaController`, typedef `ResultadoAccion`, class `VisitaController`
  - `build()`:26, `reintentar()`:34, `cargarMas()`:36, `build()`:85, `reintentar()`:88, `reprogramar()`:112, `responder()`:124, `cancelar()`:134, `noSePresento()`:142, `llegada()`:149, `terminar()`:171, `noTerminado()`:192, `enviarCotizacionFinal()`:202, `decidirCotizacion()`:221, `permisoFotos()`:234

### widgets

**core**

- `app/lib/core/widgets/estados.dart` — class `CargandoCentrado`, class `MensajeCentrado`
  - `build()`:11, `build()`:29, `mensajeDeError()`:54
- `app/lib/core/widgets/pantalla_titulada.dart` — class `PantallaTitulada`
  - `build()`:14
