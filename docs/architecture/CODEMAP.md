# Mapa de código

> Generado por `scripts/codemap.py` el 2026-11-22T23:22:47Z. No editar a mano.
> **Antes de crear una clase, método o archivo, busca aquí o corre `python scripts/codemap.py --query "<qué necesitas>"`.**

## Resumen

| Módulo | Capas | Archivos | Tipos | Métodos públicos |
|---|---|---|---|---|
| `actividad` | presentation | 1 | 1 | 1 |
| `app` | - | 2 | 1 | 2 |
| `avisos` | -, data, domain, presentation | 9 | 19 | 27 |
| `chat` | -, data, domain, presentation | 11 | 47 | 83 |
| `cuenta` | presentation | 1 | 1 | 1 |
| `datos` | core | 2 | 1 | 12 |
| `dispositivos` | -, data, domain, presentation | 5 | 10 | 8 |
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
| `visitas` | -, data, domain, presentation | 7 | 21 | 30 |
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
  - `contador()`:48, `marcarLeido()`:58, `marcarTodosLeidos()`:67, `obtener()`:104

**domain**

- `app/lib/features/avisos/domain/aviso.dart` — class `Aviso`, class `PaginaAvisos`, class `ContadorAvisos`, class `FiltroAvisos`
  - `copiaLeido()`:26
- `app/lib/features/avisos/domain/avisos_repository.dart` — class `AvisosRepository`
- `app/lib/features/avisos/domain/preferencias_avisos.dart` — class `PreferenciaAviso`, class `PreferenciasAvisosRepository`
  - `conActivo()`:15

**presentation**

- `app/lib/features/avisos/presentation/avisos_controller.dart` — class `FiltroAvisosNotifier`, class `BandejaAvisos`, class `AvisosController`
  - `build()`:14, `cambiar()`:16, `copiar()`:38, `build()`:54, `reintentar()`:65, `cargarMas()`:68, `marcarLeido()`:95, `marcarTodosLeidos()`:107
- `app/lib/features/avisos/presentation/avisos_screen.dart` — class `AvisosScreen`, class `_Filtros`, class `_Lista`, class `InsigniaAvisos`
  - `build()`:13, `build()`:70, `cambiar()`:72, `build()`:123, `build()`:179
- `app/lib/features/avisos/presentation/preferencias_avisos_screen.dart` — class `PreferenciasAvisosController`, class `PreferenciasAvisosScreen`
  - `build()`:12, `reintentar()`:15, `cambiar()`:18, `build()`:47

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

- `app/lib/features/dispositivos/data/dispositivos_de_prueba.dart` — class `DispositivosRepositoryDePrueba`, class `ProveedorTokenPushDePrueba`
  - `registrar()`:14, `darDeBaja()`:34, `obtener()`:51

**domain**

- `app/lib/features/dispositivos/domain/dispositivo.dart` — enum `PlataformaDispositivo`, class `RegistroDispositivo`, class `DispositivosRepository`, class `ProveedorTokenPush`
  - `validarIdentificadorDispositivo()`:24

**presentation**

- `app/lib/features/dispositivos/presentation/notificaciones_screen.dart` — class `NotificacionesScreen`
  - `build()`:14
- `app/lib/features/dispositivos/presentation/registro_push_controller.dart` — enum `EstadoPush`, class `RegistroPush`, class `RegistroPushController`
  - `build()`:31, `registrar()`:33, `darDeBaja()`:61

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
  - `ramasVisibles()`:27, `build()`:40, `Scaffold()`:44
- `app/lib/core/router/rutas.dart` — class `Rutas`
  - `redireccionPorRol()`:34

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

- `app/lib/features/visitas/visitas_providers.dart` — —

**data**

- `app/lib/features/visitas/data/visitas_mapper.dart` — class `VisitasMapper`
  - `visita()`:16, `agendaItem()`:52, `agenda()`:65, `propuesta()`:70, `respuesta()`:80, `cancelacion()`:105, `ausencia()`:114
- `app/lib/features/visitas/data/visitas_repository_de_prueba.dart` — class `VisitasRepositoryDePrueba`
  - `agenda()`:35, `obtener()`:62, `reprogramar()`:68, `responderReprogramacion()`:84, `cancelar()`:100, `noSePresento()`:131

**domain**

- `app/lib/features/visitas/domain/visita.dart` — class `VisitaTecnico`, class `VisitaLugar`, class `Visita`, class `AgendaItem`, class `PaginaAgenda`, class `PropuestaReprogramacion`, class `RespuestaReprogramacion`, class `ResultadoCancelacion`, class `ResultadoAusencia`, class `VisitasRepository`
  - `validarMotivoCancelacion()`:165

**presentation**

- `app/lib/features/visitas/presentation/agenda_screen.dart` — class `AgendaScreen`
  - `build()`:13, `textoEstadoVisita()`:86
- `app/lib/features/visitas/presentation/visita_screen.dart` — class `VisitaScreen`, class `_Detalle`, class `_DialogoMotivo`, class `_DialogoMotivoState`
  - `mensajeDeErrorVisita()`:12, `build()`:26, `build()`:162, `dispose()`:232, `build()`:238
- `app/lib/features/visitas/presentation/visitas_controller.dart` — class `EstadoAgenda`, class `AgendaController`, typedef `ResultadoAccion`, class `VisitaController`
  - `build()`:24, `reintentar()`:29, `cargarMas()`:31, `build()`:79, `reintentar()`:82, `reprogramar()`:96, `responder()`:104, `cancelar()`:114, `noSePresento()`:122

### widgets

**core**

- `app/lib/core/widgets/estados.dart` — class `CargandoCentrado`, class `MensajeCentrado`
  - `build()`:11, `build()`:29, `mensajeDeError()`:54
- `app/lib/core/widgets/pantalla_titulada.dart` — class `PantallaTitulada`
  - `build()`:14
