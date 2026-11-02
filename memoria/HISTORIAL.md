# CLASSICRPG — HISTORIAL

## 2026-11-01 — Auditoría técnica y actualización de continuidad

Objetivo:
Revisar la arquitectura y los scripts existentes para establecer el estado real del proyecto y facilitar su continuidad.

Trabajo realizado:
- Inspeccionadas Main.tscn y Mapa1/Escena1.tscn.
- Comprobada la escena inicial configurada en project.godot.
- Inspeccionado Main.gd.
- Inspeccionados Personajes/Jugador.tscn y Jugador.gd.
- Revisadas las animaciones procedurales del personaje.
- Comprobadas las referencias de scripts/cliente/Jugador.gd.
- Inspeccionadas Camaras/Camara.tscn y Camara.gd.
- Revisadas las acciones del Input Map.
- Inspeccionado scripts/cliente/Multijugador.gd.
- Inspeccionado scripts/servidor/Servidor.gd.
- Inspeccionado scripts/compartido/GeneradorTerreno.gd.
- Comprobado el estado de Git en la rama main.
- Actualizado memoria/ESTADO_ACTUAL.md.
- Actualizado memoria/PENDIENTES.md.

Archivos de código inspeccionados:
- Main.gd
- Jugador.gd
- Personajes/Jugador.tscn
- Camara.gd
- Camaras/Camara.tscn
- scripts/cliente/Multijugador.gd
- scripts/cliente/Jugador.gd
- scripts/servidor/Servidor.gd
- scripts/compartido/GeneradorTerreno.gd
- project.godot

Resultado:
- Confirmada la escena inicial Mapa1/Escena1.tscn.
- Confirmado el personaje procedural basado en CharacterBody3D.
- Confirmada la animación procedural mediante GDScript.
- Identificada la cámara orbital de tercera persona.
- Identificada la sincronización de personajes mediante WebSocket.
- Identificada la interpolación de personajes remotos.
- Identificada la validación parcial del movimiento en el servidor.
- Identificadas las limitaciones de la arquitectura multijugador.
- Confirmado que la auditoría fue principalmente estática y no repitió todas las pruebas funcionales.

Estado Git comprobado:
- Rama main.
- Último commit: 2b106a5.
- Modificados localmente: Jugador.gd, Main.gd, scripts/cliente/Multijugador.gd y scripts/servidor/Servidor.gd.
- Sin seguimiento: assets/modelos/, herramientas/, memoria/, GeneradorTerreno.gd y su archivo .uid.

Errores y limitaciones:
- El servidor todavía no es completamente autoritativo.
- No se encontró reconexión explícita.
- No existe predicción y reconciliación completas.
- La validación de mundo no bloquea por sí sola el movimiento si falla.
- Algunas acciones del Input Map no tienen uso activo detectado.
- No se repitieron todas las pruebas funcionales.

Archivos de memoria modificados:
- memoria/ESTADO_ACTUAL.md
- memoria/PENDIENTES.md
- memoria/HISTORIAL.md

Pendientes:
- Actualizar CONTINUAR_CON_IA.md.
- Decidir el siguiente sistema a desarrollar.
- Mantener los cambios locales existentes.
- Realizar pruebas funcionales focalizadas cuando corresponda.

Autorización:
El usuario autorizó la actualización de los documentos de memoria. No se modificó código ni se realizaron operaciones Git.

## 2026-11-01 — Unificación de GuardarEstado.ps1

Objetivo:
Unificar el script oficial de generación del informe de estado.

Trabajo realizado:
- Sustituido herramientas\GuardarEstado.ps1 por la versión revisada de GuardarEstado_v2.ps1.
- Actualizada la autorreferencia para usar el nombre oficial GuardarEstado.ps1.
- Conservado herramientas\GuardarEstado_v2.ps1 como respaldo.
- Verificados la sintaxis, el contenido del archivo y la generación del informe.
- Comprobada la copia del informe al portapapeles.

Resultado:
La versión oficial funcionó en las comprobaciones realizadas. No se modificó Jugador.gd ni se realizaron cambios Git.

Errores:
- Los documentos de memoria están en memoria\, no en la raíz del proyecto.

Pendientes:
- Evaluar automatización adicional cuando sea necesario.

Autorización:
Unificación autorizada por el usuario. No se eliminó el archivo de respaldo.

## 2026-10-31 — Sistema de continuidad

- Creación de memoria/.
- Creación de herramientas/.
- Creación de LEEME_PRIMERO.md.
- Creación de REGLAS_IA.md.
- Creación de ESTADO_ACTUAL.md.
- Creación de DECISIONES.md.
- Creación de HISTORIAL.md.
- Creación de PENDIENTES.md.
- Creación de CONTINUAR_CON_IA.md.
- Desarrollo de GuardarEstado.ps1.

## 2026-10-31 — Modelo 3D

- Generación de un caballero experimental con Blender 5.2.3.
- Creación de archivos BLEND y GLB.
- Generación de segunda versión.
- El usuario indicó que el resultado era demasiado cúbico.
- El modelo permanece separado del personaje actual.

## Historial anterior

Según GUIA_CONTINUIDAD_CLASSICRPG.txt:

- Fases 1–3 completadas.
- Base de fase 4 implementada.
- Fases posteriores pendientes o prototipos.

## FORMATO PARA NUEVAS ENTRADAS

### AAAA-MM-DD — Nombre de tarea

Objetivo:
Descripción del objetivo.

Trabajo realizado:
- Cambios efectuados.
- Archivos creados o modificados.

Resultado:
Qué se comprobó realmente.

Errores:
Problemas encontrados.

Pendientes:
Qué falta hacer.

Autorización:
Indicar si los cambios fueron autorizados.

No registrar como completadas tareas que solo fueron propuestas.
## 2026-11-01 — Cierre de fases anteriores y comienzo de Fase 5

Objetivo:
Consolidar el estado oficial de las fases tras revisar la guía original, los scripts activos y las escenas principales.

Trabajo realizado:
- Contrastada la numeración de fases con GUIA_CONTINUIDAD_CLASSICRPG.txt.
- Revisadas las funciones declaradas en los scripts activos y sus copias de respaldo.
- Confirmadas las referencias de scripts de la escena inicial, personaje y cámara.
- Revisadas las acciones configuradas en Input Map.
- Diferenciados los controles configurados de las funcionalidades realmente implementadas.
- Acordado con el usuario aceptar las fases 1–4 para continuar.
- Establecida la Fase 5 como fase actual.

Resultado:
- Fases 1–3 aceptadas como completadas según la documentación y las pruebas históricas.
- Fase 4 aceptada para continuar por decisión expresa del usuario.
- Fase 5 permanece pendiente y es el siguiente bloque de desarrollo.
- Fases 6–9 permanecen pendientes.

Limitaciones:
- La inspección de código fue estática.
- No se repitió una prueba multijugador con dos clientes; el usuario decidió aceptar el sistema existente para continuar.
- El arranque headless anterior no demuestra funcionamiento visual completo.
- La existencia de acciones en Input Map no acredita la implementación de sus sistemas.
- No se identificaron módulos activos de NPC, enemigos, IA, combate, inventario, habilidades funcionales, misiones o botín en los scripts revisados.
- Las mejoras técnicas pendientes de fases anteriores se conservan como trabajo posterior.

Archivos de código modificados:
Ninguno.

Archivos de memoria que se actualizarán:
- memoria/ESTADO_ACTUAL.md
- memoria/PENDIENTES.md
- memoria/HISTORIAL.md
- memoria/CONTINUAR_CON_IA.md

Autorización:
Actualización documental autorizada por el usuario. No realizar commit ni push.


## HITO FASE 5 — ENTIDADES SINCRONIZADAS — 01/11/2026

Se implementó el primer flujo de entidades de Fase 5:
- El servidor mantiene un registro de entidades con identificadores estables.
- La entidad de prueba se registra con ID 1.
- El snapshot welcome incluye las entidades existentes.
- El cliente procesa welcome, entity_spawned y entity_removed.
- El cliente crea y elimina representaciones visuales y evita duplicados.
- Se validó el proyecto con Godot 4.7.2, código de salida 0.
- Prueba real: servidor iniciado, un cliente conectado, entidad recibida y esfera azul visible, confirmada por el usuario.
- La aparición y eliminación dinámicas todavía no se han probado en ejecución.


## ACTUALIZACION DOCUMENTAL FASE 5 - 01/11/2026

## 2026-11-01 - Verificacion dinamica y limpieza de entidades

- Corregida la indentacion del bloque temporal de prueba en Servidor.gd.
- Validado el arranque real del servidor.
- Probada la creacion dinamica de la entidad ID 2.
- Confirmada en los registros la recepcion de entity_spawned por el cliente.
- Probada la eliminacion dinamica de la entidad ID 2.
- Confirmada en los registros la recepcion de entity_removed por el cliente.
- El usuario confirmo visualmente ambas esferas y la desaparicion de la segunda.
- Retirado el codigo temporal de prueba automatica.
- Conservadas las funciones permanentes de registro y eliminacion.
- Creada copia de seguridad antes de la limpieza.
- Servidor limpio iniciado con PID 17324, sin errores registrados.

Resultado: primer ciclo dinamico de entidades sincronizadas verificado. La Fase 5 permanece abierta. No se realizaron commits ni push.

## 2026-11-01 — Correccion de errores y verificacion de B3.4

Objetivo:
Cerrar las incidencias pendientes de camara y jugador, corregir los errores de las herramientas de prueba y dejar el proyecto listo para publicar.

Trabajo realizado:
- Verificado que `camera_mode` esta dentro de `_physics_process` y alineado con `var entrada`.
- Confirmado que `Camara.gd` es identico a `2b106a5`: el zoom usa `camera_zoom_in` y `camera_zoom_out` del InputMap.
- Normalizada la sangria de `Jugador.gd`: habia quedado con 4 espacios en todo el archivo; restaurada a tabulaciones.
- Corregido `FabricaEntidades.gd`: el `Label3D` del nombre solo se crea si hay nombre. `herramientas/PruebaFabricaEntidades.gd` fallaba con «Mallas incorrectas».
- Eliminado el `print` de depuracion de `Camara.gd`.
- Corregido `Multijugador.gd`: el `welcome` aplica el yaw sobre `Modelo`; eliminado el `print` por cada correccion.
- Corregido `Jugador.gd`: la fuerza de aterrizaje usa la velocidad de caida previa a `move_and_slide`.
- Ampliado `.gitignore` para excluir `*.bak`, `*.bak_*` y `*.blend1`.

Resultado comprobado:
- Los 8 scripts pasan `--check-only` con codigo 0.
- `PruebaFabricaEntidades.gd`: codigo 0 (antes 1).
- `PruebaNPCServidor.gd`: codigo 0.
- Servidor y cliente reales: entidades 1 (`prueba`) y 2 (`npc`) creadas en el cliente, sin errores.
- Escena principal en headless: codigo 0.
- Importacion del editor: codigo 0.

Errores encontrados:
- La prueba de la fabrica no contemplaba el `Label3D` del NPC.
- La fuerza de aterrizaje nunca superaba el minimo por el orden de `move_and_slide`.
- `Jugador.gd` habia sido reindentado con espacios.

Pendientes:
- Fase 5: ciclo de vida y estado de las entidades.
- Probar dos clientes con movimiento simultaneo.

Autorizacion:
El usuario pidio corregir los errores y actualizar el proyecto en GitHub.

## 2026-11-01 — Ciclo de vida y estado de entidades (Fase 5)

Objetivo:
Dar estructura de datos, estado y ciclo de vida a las entidades del mundo en servidor y cliente, preparando la sincronización dinámica y la ampliación de criaturas/NPC.

Trabajo realizado:
- scripts/servidor/Servidor.gd:
  - Ampliada la definición de entidad para incluir yaw, hp, hp_max, estado y ctivo.
  - Entidad 1 inicializada como prueba (hp 100/100, estado ctivo).
  - Entidad 2 inicializada como 
pc (nombre "Habitante", hp 100/100, estado idle).
  - Implementada la función _actualizar_entidad(id, cambios) que propaga modificaciones en memoria y difunde el paquete de red entity_updated.
  - Implementada la función _obtener_entidad(id) para consulta segura del estado.
- scripts/cliente/Multijugador.gd:
  - Separada la estructura de datos de red (datos_entidades), objetivos de interpolación (objetivos_entidades) y nodos visuales (entidades_remotas).
  - Añadido el manejo del mensaje entity_updated en _procesar_mensaje.
  - Implementada la interpolación suave de traslación y rotación (_actualizar_entidades_remotas) en cada frame.
  - Asegurada la limpieza de diccionarios en _eliminar_entidad_remota y _mostrar_servidor_lleno.
- herramientas/PruebaEstadoEntidades.gd:
  - Creada suite de prueba que verifica inicialización de campos, actualización de estado con _actualizar_entidad y eliminación con _eliminar_entidad.

Resultado comprobado:
- herramientas/PruebaEstadoEntidades.gd: código de salida 0.
- herramientas/PruebaFabricaEntidades.gd: código de salida 0.
- herramientas/PruebaNPCServidor.gd: código de salida 0.
- Los 10 scripts del proyecto pasan --check-only con código de salida 0.
- Escena principal Mapa1/Escena1.tscn en headless arranca e inicializa mapa y multijugador sin errores.
- Verificación visual interactiva en cliente real confirmada expresamente por el usuario ("si, funciona").

Errores:
- Ninguno en las pruebas ejecutadas.

Pendientes:
- Partida de dos clientes con movimiento simultáneo.
- Diseñar tipos adicionales de entidades (criaturas, enemigos, vendedores).
- Fase 5 continúa en desarrollo.

Autorización:
- Modo autónomo: continuación técnica acordada en la guía de Fase 5.

## 2026-11-01 — Criatura Lobo y patrulla básica autoritativa (Fase 5)

Objetivo:
Incorporar la primera criatura del mundo RPG en la fábrica de entidades y dotarla de comportamiento de patrulla autoritativo gobernado por el servidor.

Trabajo realizado:
- scripts/cliente/FabricaEntidades.gd:
  - Implementado el tipo "lobo" (cuerpo, cabeza y 4 patas mediante mallas primitivas con etiqueta de color rojizo para representar criaturas/monstruos).
- scripts/servidor/Servidor.gd:
  - Registrada la entidad 3 (lobo, nombre "Lobo del Bosque", 60 HP, estado "patrullando").
  - Implementada la función _actualizar_ia_entidades(delta) que ejecuta una ruta de patrulla autoritativa periódica actualizando posición, altura sobre el relieve procedural y ángulo yaw.
- herramientas/:
  - Actualizadas PruebaFabricaEntidades.gd, PruebaNPCServidor.gd y PruebaEstadoEntidades.gd para validar el nuevo tipo y las 3 entidades activas.

Resultado comprobado:
- herramientas/PruebaFabricaEntidades.gd: código de salida 0.
- herramientas/PruebaNPCServidor.gd: código de salida 0.
- herramientas/PruebaEstadoEntidades.gd: código de salida 0.
- 10 scripts con --check-only: código 0.
- Escena principal en headless: código 0.

Pendientes:
- Prueba visual del lobo y su patrulla en cliente gráfico.
- Prueba con dos clientes simultáneos.
- Sistema de selección de objetivo / target para entidades.

## 2026-11-01 — Sistema de selección de objetivos (Targeting) e interfaz de HUD (Fase 5)

Objetivo:
Implementar la selección de objetivos para entidades del mundo (jugadores remotos, NPC, criaturas) mediante tecla Tab / InputMap, con indicador visual en el suelo y panel de objetivo en el HUD.

Trabajo realizado:
- scripts/cliente/Multijugador.gd:
  - Declaradas variables id_objetivo, 
odo_objetivo y señal objetivo_cambiado(id, datos, nodo).
  - Implementada función seleccionar_siguiente_objetivo() que prioriza entidades por proximidad geométrica al jugador local.
  - Implementada función seleccionar_objetivo(id) y captura de select_next_target (Tab) y tecla Escape en _unhandled_input.
  - Integrada reactividad con entity_updated y _eliminar_entidad_remota.
- Main.gd:
  - Construido el Target Frame en el HUD (panel_objetivo con nombre, barra de vida y subtítulo tipo/estado).
  - Creado aro indicador 3D (indicador_objetivo_3d) que se proyecta sobre el terreno bajo los pies del objetivo seleccionado.
- herramientas/PruebaTargeting.gd:
  - Creada suite de prueba unitaria que verifica la selección, ciclado y deselección de objetivos.

Resultado comprobado:
- herramientas/PruebaTargeting.gd: código 0.
- herramientas/PruebaFabricaEntidades.gd: código 0.
- herramientas/PruebaNPCServidor.gd: código 0.
- herramientas/PruebaEstadoEntidades.gd: código 0.
- 11 scripts con --check-only: código 0.
- Escena principal Mapa1/Escena1.tscn en headless: código 0.

Pendientes:
- Selección alternativa por clic directo del ratón sobre la entidad.
- Prueba con dos clientes y movimiento simultáneo.
- Puente hacia combate (Fase 6): ataque básico o habilidad al objetivo fijado.

## 2026-11-02 — Sistema de combate autoritativo cuerpo a cuerpo (Fase 6)

Objetivo:
Implementar el núcleo del combate en red: ataque melee con validación autoritativa en el servidor (alcance, recarga/cooldown, objetivos vivos), aplicación de daño, reducción de vida sincronizada y feedback visual en HUD del cliente.

Trabajo realizado:
- scripts/servidor/Servidor.gd:
  - Constantes de combate: RANGO_ATAQUE_MELEE (4.5), TIEMPO_RECARGA_ATAQUE (1.2s), DANIO_BASE_MELEE (15).
  - Variable de seguimiento tiempos_ultimo_ataque por peer.
  - Función _procesar_ataque(): validación de jugador emisor, objetivo activo, distancia física en 3D, tiempo de reutilización, reducción de HP con maxi(0, hp - daño), actualización de estado a 'muerto' y 'activo: false' al llegar a 0 HP, y difusión en red con entity_updated.
  - IA del lobo detenida si la entidad está muerta o inactiva.
- scripts/cliente/Multijugador.gd:
  - Señal resultado_ataque declarada y emitida al recibir paquete attack_result del servidor.
  - Captura de input ability_1 (tecla 1) para disparar atacar_objetivo().
  - Función atacar_objetivo() que despacha el paquete JSON con target_id.
- Main.gd:
  - Conexión con resultado_ataque para mostrar feedback dinámico en HUD (etiqueta_combate con tween).
  - Avisos descriptivos de daño, muerte del objetivo y razones de fallo (fuera de alcance, en recarga, objetivo muerto).
  - Texto de ayuda en pantalla actualizado con tecla 1: atacar.
- herramientas/PruebaCombate.gd:
  - Creada suite de prueba unitaria que verifica validación de objetivo inválido, fuera de rango, daño e impacto a la vida, cooldown de ataque, muerte de entidad y rechazo de ataque sobre cadáver.

Resultado comprobado:
- herramientas/PruebaCombate.gd: código 0.
- herramientas/PruebaTargeting.gd: código 0.
- herramientas/PruebaEstadoEntidades.gd: código 0.
- herramientas/PruebaNPCServidor.gd: código 0.
- herramientas/PruebaFabricaEntidades.gd: código 0.
- 12 scripts con --check-only: código 0.
- Escena principal Mapa1/Escena1.tscn en headless: código 0.

Pendientes:
- Animación procedural de ataque con espada en Jugador.gd.
- Reaparición (respawn) de criaturas tras morir.
- Prueba con dos clientes y combate simultáneo.


## 2026-11-02 — Corrección de envío de ataque y animación de espada (Fase 6)

Objetivo:
Resolver la incidencia donde pulsar la tecla 1 no enviaba el ataque hacia el servidor, añadir la animación procedural de balanceo de espada al atacar y proporcionar avisos de error descriptivos.

Trabajo realizado:
- scripts/cliente/Multijugador.gd:
  - Corregido el envío de red: sustituido el método erróneo `cliente.send_text()` por `cliente.put_packet(JSON.stringify(mensaje).to_utf8_buffer())`.
  - Captura ampliada de tecla 1 (`ability_1`, `KEY_1`, `KEY_KP_1`).
  - Validación local de objetivo: si no hay objetivo, emite `resultado_ataque` con `reason = "no_target"` en vez de fallar en silencio.
  - Activada la animación de ataque inmediata en el jugador local (`jugador_local.animar_ataque()`).
- Jugador.gd:
  - Añadidas variables de animación de ataque (`tiempo_ataque`, `DURACION_ATAQUE`).
  - Implementada función pública `animar_ataque()`.
  - Añadido arco de corte procedural (*slash*) en brazo derecho, espada y torso en `_animar(delta)`.
- Main.gd:
  - Incorporados mensajes específicos para `no_target` ("¡No tienes un objetivo seleccionado! Pulsa Tab para fijar uno") y `not_connected`.
- herramientas/PruebaAnimacionCombate.gd:
  - Creada suite unitaria que valida la animación de espada y el flujo de `atacar_objetivo()` sin objetivo fijado.

Resultado comprobado:
- herramientas/PruebaAnimacionCombate.gd: código 0.
- herramientas/PruebaCombate.gd: código 0.
- herramientas/PruebaTargeting.gd: código 0.
- herramientas/PruebaEstadoEntidades.gd: código 0.
- herramientas/PruebaNPCServidor.gd: código 0.
- herramientas/PruebaFabricaEntidades.gd: código 0.
- 14 scripts con --check-only: código 0.
- Escena principal Mapa1/Escena1.tscn en headless: código 0.

Pendientes:
- Reaparición (respawn) autoritativa de criaturas en el servidor tras retardo de muerte.
- Partida simultánea de dos clientes con movimiento y combate.


## 2026-11-02 — Reaparición autoritativa (respawn) de criaturas (Fase 6)

Objetivo:
Implementar el ciclo de vida completo de combate: reaparición autoritativa de criaturas derrotadas tras un retardo de tiempo configurable en el servidor, restaurando vida completa y reanudando la patrulla.

Trabajo realizado:
- scripts/servidor/Servidor.gd:
  - Constante TIEMPO_RESPAWN = 6.0 segundos.
  - Almacenamiento de estado original en datos_spawn_original[id] durante _registrar_entidad().
  - Temporizador activo en temporizadores_respawn[target_id] al morir la criatura.
  - Nueva función _actualizar_respawn(delta) invocada en _process.
  - Al completarse el tiempo de respawn, el servidor actualiza la entidad con _actualizar_entidad() restaurando vida máxima, activo=true y estado original, notificando a todos los clientes conectados.
- herramientas/PruebaCombate.gd:
  - Validada aserción 7 de registro de temporizador de respawn y reaparición con 60 HP.

Resultado comprobado:
- herramientas/PruebaCombate.gd: código 0.
- herramientas/PruebaAnimacionCombate.gd: código 0.
- herramientas/PruebaTargeting.gd: código 0.
- herramientas/PruebaEstadoEntidades.gd: código 0.
- herramientas/PruebaNPCServidor.gd: código 0.
- herramientas/PruebaFabricaEntidades.gd: código 0.
- 15 scripts con --check-only: código 0.
- Escena principal Mapa1/Escena1.tscn en headless: código 0.

Pendientes:
- Partida simultánea de dos clientes con movimiento y combate.

## 2026-11-02 — Verificacion interactiva de dos clientes

Objetivo:
Comprobar en ejecucion el servidor y dos clientes con movimiento y combate simultaneos.

Trabajo realizado:
- Se proporciono un comando PowerShell para iniciar el servidor headless desde `escenas/servidor/Servidor.tscn`, abrir dos clientes graficos, capturar logs separados y cerrar el servidor al finalizar.
- El usuario ejecuto la prueba y confirmo: «todo funciona correcto».

Archivos del proyecto afectados:
- Ninguno de codigo.
- Se actualiza documentacion de memoria.

Resultado comprobado:
- Prueba interactiva de dos clientes, movimiento y combate confirmada por el usuario.
- Los logs de esta ejecucion no fueron compartidos para inspeccion independiente.

Errores:
- Ninguno reportado en esta ejecucion.

Pendientes:
- Continuar el desarrollo con el siguiente sistema priorizado; no repetir esta prueba salvo que un cambio lo requiera.

Autorizacion:
Actualizacion documental solicitada por el usuario. Sin commit ni push.

## 2026-11-02 — Verificacion de dos clientes y mejora del lanzador

Objetivo:
Cerrar la prueba pendiente de movimiento y combate con dos clientes, y conservar un lanzador reproducible para futuras sesiones.

Trabajo realizado:
- El usuario confirmo que el servidor y dos clientes graficos abrieron correctamente.
- El usuario probo movimiento, combate cooperativo contra el lobo y respawn; confirmo que todo funciono.
- Actualizado herramientas/iniciar_juego.ps1: ruta del proyecto basada en PSScriptRoot, escena servidor dedicada, espera de confirmacion, soporte de uno o dos clientes, logs separados y limpieza de procesos en finally.

Archivos afectados:
- herramientas/iniciar_juego.ps1.
- memoria/ESTADO_ACTUAL.md, memoria/HISTORIAL.md, memoria/PENDIENTES.md, memoria/CONTINUAR_CON_IA.md.

Resultado:
- Prueba interactiva de dos clientes confirmada por el usuario.
- El contenido del lanzador se reviso estaticamente tras editarlo.
- No se ejecuto una prueba del lanzador actualizado ni se inspeccionaron logs posteriores a la prueba manual.

Errores:
- Durante intentos previos con comandos distintos aparecio el error de carga de script de servidor; se resolvio usando la escena del servidor. No se reporto ese error en la prueba finalmente confirmada.

Pendiente:
- Validar en una ejecucion posterior el lanzador persistido herramientas/iniciar_juego.ps1.
- Continuar con sistemas MMORPG pendientes, empezando por inventario/progresion tras definir una primera entrega acotada.

Autorizacion:
El usuario autorizo actualizar el lanzador y pidio guardar el progreso. No hubo commit ni push.

## 2026-11-02 — Primera rebanada de inventario autoritativo (Fase 7)

Objetivo:
Iniciar un bucle simple de inventario conectado al combate: catalogar un objeto, otorgar botin desde el servidor y mostrar el inventario del jugador en el HUD.

Trabajo realizado:
- Creado scripts/compartido/CatalogoObjetos.gd con el item colmillo_lobo (nombre visible, tipo material y pila maxima de 20).
- Servidor.gd guarda el inventario por conexion, incluye su snapshot en welcome, envia inventory_updated y premia con un colmillo al jugador que da el golpe letal al lobo.
- Multijugador.gd procesa snapshot y actualizaciones, filtrando IDs desconocidos y cantidades fuera del limite de pila.
- Main.gd muestra el inventario en un panel HUD y refleja los cambios recibidos.
- Revision estatica detecto y corrigio un bloque mal insertado en el parser de mensajes antes de cerrar la edicion.

Archivos modificados:
- scripts/compartido/CatalogoObjetos.gd (nuevo).
- scripts/servidor/Servidor.gd.
- scripts/cliente/Multijugador.gd.
- Main.gd.
- Documentacion de memoria.

Resultado:
- El flujo esta conectado estaticamente desde muerte del lobo hasta el HUD.
- No se ejecuto Godot ni se probaron los cambios en runtime.
- El inventario es temporal por conexion y no persiste tras desconectar o reiniciar.

Pendiente:
- Verificar visualmente que el jugador que da el ultimo golpe recibe el objeto y el otro cliente no.
- Confirmar que la cantidad se conserva durante la sesion y que el respawn no duplica el premio.
- Desarrollar despues espacios, uso de objetos, equipo y persistencia.

Autorizacion:
El usuario pidio continuar el proyecto de forma autonoma. No hubo commit ni push.

## 2026-11-02 — Parseo estatico del inventario y lanzador

Resultado adicional:
- Godot 4.7.2, --check-only: scripts/servidor/Servidor.gd, scripts/cliente/Multijugador.gd, Main.gd y scripts/compartido/CatalogoObjetos.gd: codigo 0 cada uno.
- Parser de PowerShell: herramientas/iniciar_juego.ps1 sin errores de sintaxis.
- No se iniciaron clientes/servidor y no se ejecutaron pruebas funcionales. Falta la verificacion real de botin y HUD.

## 2026-11-02 — Verificacion manual del botin individual (Fase 7)

Objetivo:
Confirmar en ejecucion el primer ciclo del inventario: derrotar un lobo, recibir el objeto y mostrarlo por cliente.

Resultado reportado por el usuario:
- Cada uno de los dos clientes recibio Colmillo de lobo al derrotar un lobo por separado.
- La recompensa individual funciona en las sesiones probadas.
- El usuario reporto la recepcion en el inventario del juego; no se compartieron logs de esta ejecucion.

Contraste con el codigo actual:
- El servidor llama a la adicion de objeto con el ID del atacante del golpe letal.
- El snapshot de welcome y inventory_updated sincronizan el inventario.
- El cliente emite inventario_cambiado y Main.gd actualiza el panel.
- Parseo previo: cuatro scripts GDScript y el lanzador PowerShell sin errores de sintaxis.

Archivos de codigo afectados en esta comprobacion:
Ninguno. Sin pruebas adicionales, commits ni push.

Pendiente para siguientes iteraciones:
- Persistencia tras desconexion.
- Confirmacion adicional de que el cliente que no asesta el golpe final no recibe la recompensa en una misma pelea.

## 2026-11-02 — Progresion inicial de XP por golpe letal (Fase 7)

Se implemento una primera progresion autoritativa temporal:
- El servidor da 25 XP por matar un lobo al ID del atacante cuyo golpe lleva la vida a cero, junto al botin que ya existia.
- Nivel inicial 1; cada 100 XP sube un nivel y conserva el excedente. Estado asociado a la conexion y borrado al desconectar.
- welcome incluye nivel/XP; progression_updated actualiza al cliente. Main.gd refleja nivel y XP en el HUD.
- Se corrigio la indentacion incorrecta de la llamada de snapshot de progresion en el cliente.

Verificacion: Godot 4.7.2 --check-only finalizo con codigo 0 en Servidor.gd, Multijugador.gd y Main.gd. git diff --check sin errores. No se ejecutaron pruebas funcionales ni partida interactiva de XP; por tanto la logica no se considera verificada en juego. El usuario habia confirmado previamente el botin individual con dos clientes.

No se hizo commit ni push. Proximo paso: el usuario puede confirmar el bucle de XP y la subida de nivel en la partida con dos clientes.
## 2026-11-02 — Daño cuerpo a cuerpo escalado por nivel (Fase 7)

Trabajo realizado:
- Servidor.gd ahora calcula 15 de daño en nivel 1 y +2 por cada nivel adicional.
- El resultado de ataque informa el daño efectivamente aplicado; el HUD ya presenta ese valor.
- El cálculo usa la progresión mantenida por servidor para la conexión.

Archivos de código afectados: scripts/servidor/Servidor.gd. No se cambió el HUD ni se modificaron las pruebas.

Verificación: Godot 4.7.2 --check-only en Servidor.gd terminó con código 0. No se ejecutaron pruebas funcionales ni una partida. El escalado aún no está verificado en juego; el bono de 2 es provisional para balance. Sin commit ni push.
## 2026-11-02 — Alineación del resumen de fases

Se actualizaron los resúmenes vigentes de ESTADO_ACTUAL.md y PENDIENTES.md para reflejar el historial posterior: la Fase 5 cuenta con su prototipo inicial de mundo/entidades; la Fase 6 con combate inicial confirmado por el usuario; y la Fase 7 es la fase actual. Se dejó claro que expansión del mundo y mejoras de combate siguen pendientes, y que XP/niveles/daño por nivel requieren comprobación interactiva.

No se modificaron las entradas históricas ni DECISIONES.md. Sin pruebas funcionales, commit ni push.
## 2026-11-02 — Aviso de experiencia por derrota (Fase 7)

Trabajo realizado:
- Servidor.gd añade `xp_gained` al resultado del golpe letal contra lobos.
- Main.gd muestra el XP otorgado junto al aviso de objetivo derrotado; conserva el mensaje actual cuando no hay XP.

Verificación: Godot 4.7.2 --check-only terminó con código 0 en Servidor.gd y Main.gd. Sin prueba funcional, commit ni push. La recepción visible del aviso queda pendiente de confirmación del usuario.
## 2026-11-02 — Aviso visual de subida de nivel (Fase 7)

El resultado autoritativo de combate ahora indica si la XP del golpe letal elevó al jugador y cuál es el nuevo nivel. El HUD incluye el nivel alcanzado en el aviso de derrota; cuando no hay subida, muestra el daño y XP habituales.

Archivos afectados: scripts/servidor/Servidor.gd y Main.gd. Godot 4.7.2 --check-only pasó en ambos. No se ejecutaron pruebas funcionales; el aviso sigue sin confirmación de partida. Sin commit ni push.
## 2026-11-02 — Sincronización de la animación de ataque remota (Fase 7)

El usuario confirmó que XP, subida a nivel 2 y daño del nivel superior funcionan; reportó como única excepción que el otro cliente no veía la animación del ataque.

Trabajo realizado:
- El servidor difunde `player_attack` tras aceptar un golpe en rango y fuera de cooldown, excluyendo al atacante para evitar duplicación local.
- El cliente procesa el ID y llama a `animar_ataque()` en el personaje remoto correspondiente.
- `Jugador.gd` ya era animado por `_actualizar_remotos`; no requirió cambios.

Verificación: Godot 4.7.2 --check-only pasó en Servidor.gd, Multijugador.gd y Jugador.gd. El primer parseo detectó una unión accidental de instrucciones en la inserción del servidor; se corrigió y el parseo posterior pasó. No se ejecutaron pruebas funcionales; falta confirmar en juego que el otro cliente vea la animación. Sin commit ni push.
## 2026-11-02 — Confirmación de animación remota y segundo material de botín

El usuario confirmó que la corrección de animación funciona y el otro cliente ve los ataques.

Se amplió el botín del lobo con `piel_lobo`, definido como material con pila máxima 10 y otorgado por el servidor junto al colmillo al atacante del golpe final. Archivos de código: scripts/compartido/CatalogoObjetos.gd y scripts/servidor/Servidor.gd.

Verificación técnica: Godot 4.7.2 --check-only pasó en CatalogoObjetos.gd, Servidor.gd, Multijugador.gd y Main.gd. La piel nueva no se ha probado en juego. Sin commit ni push.
## 2026-11-02 — Suite automatizada y preparación de dos clientes

A petición del usuario, se ejecutaron los siete tests existentes del proyecto con Godot 4.7.2; todos finalizaron con código 0. Se añadieron aserciones en los tests existentes PruebaAnimacionCombate.gd, PruebaCombate.gd y PruebaDosClientesCombate.gd para comprobar que el evento player_attack activa al remoto sin duplicación, que el golpe final otorga colmillo/piel/25 XP, y que los premios van solo al jugador que da el golpe final. Las tres pruebas ampliadas también pasaron.

Servidor headless y dos clientes gráficos iniciaron; los logs confirmaron conexión y validación del mundo en ambos. El usuario pidió realizar personalmente el chequeo del cliente; no se atacó al lobo ni se observó visualmente la nueva piel o animación en este turno. Los dos clientes quedan abiertos para esa comprobación. No se completó una verificación gráfica del último cambio.
## 2026-11-02 — Confirmación del usuario y capacidad del inventario (Fase 7)

El usuario confirmó «todo funciona» después de su chequeo de cliente. Se consideran confirmados el ciclo actual de combate/progresión, el botín individual (colmillo y piel) y la animación de ataque observada por el otro cliente. La comprobación gráfica anterior queda cerrada.

Se implementó una primera capacidad de inventario: 20 ranuras por tipo de objeto, contador `usadas/20`, lista desplazable en HUD y mensajes para pila/ranuras llenas. El servidor valida el límite antes de conceder objetos; el cliente muestra el rechazo recibido. Godot 4.7.2 `--check-only` pasó en CatalogoObjetos.gd, Servidor.gd, Multijugador.gd y Main.gd.

Pendiente de cierre: ampliar y ejecutar `herramientas/PruebaCombate.gd` para ranuras llenas, objetos ya apilados y pila máxima. La presentación del contador/desplazamiento y los avisos de rechazo no se han comprobado visualmente. El usuario mantiene a su cargo las comprobaciones del cliente; no se abrieron ventanas en esta continuación. Fase 7 activa. Sin commit ni push.
## 2026-11-02 — Cambio de prioridad: RPG para un jugador

El usuario decidió que el desarrollo a partir de ahora se enfoque en completar ClassicRPG como RPG para un solo jugador y que el multijugador se retome después. Indicó expresamente conservar todo lo desarrollado para dos jugadores.

Se actualizaron los documentos de instrucciones, decisiones y continuidad para reflejarlo: LEEME_PRIMERO, REGLAS_IA, DECISIONES, ESTADO_ACTUAL, PENDIENTES, CONTINUAR_CON_IA y GUIA_CONTINUIDAD_CLASSICRPG.txt. Las tareas multijugador pendientes permanecen registradas como trabajo futuro; no se borraron scripts, escenas, pruebas ni recursos.

La siguiente tarea técnica sigue siendo comprobar automáticamente los límites de capacidad del inventario. La interfaz nueva queda pendiente de revisión visual por el usuario. No se modificó código de juego ni se ejecutaron pruebas en esta actualización documental. Sin commit ni push.

## 2026-11-02 — Prueba de límites del inventario

Se añadieron aserciones a herramientas/PruebaCombate.gd para validar: apilar un colmillo existente con las 20 ranuras ocupadas sin consumir espacio adicional; rechazar una piel nueva con inventario lleno sin mutar el inventario; y rechazar un colmillo cuando su pila ya está en 20.

Godot 4.7.2 ejecutó herramientas/PruebaCombate.gd en modo headless y terminó con código 0. La prueba de combate, botín/XP, objetivo muerto y respawn incluidos en el mismo script también pasó. No se abrió el cliente. La revisión visual del panel de capacidad queda a cargo del usuario.

Siguiente tarea: auditar el flujo de inicio y las dependencias de red para completar la experiencia de un solo jugador sin exigir un segundo cliente, preservando la ruta multijugador existente. Sin commit ni push.

## 2026-11-02 — Vida y reaparición del jugador (Fase 7)

Se implementó combate enemigo básico: vida de 100, daño de lobo de 10 cada 1,5 s dentro de 2,5 m, derrota a 0 HP, respawn en el spawn tras 5 s y protección de 2 s. Se bloquean los controles y ataques del jugador derrotado. Se sincronizan salud y respawn por eventos de red; el HUD ahora presenta vida y cuenta atrás, y el cliente reposiciona personajes remotos al reaparecer. Todo permanece compatible con las pruebas de dos clientes.

Validación: las siete pruebas Godot 4.7.2 existentes terminaron con código 0; cinco scripts clave pasaron `--check-only`; `git diff --check` pasó; servidor y cliente headless conectaron y validaron el mundo. No se abrieron clientes gráficos. La UI aún requiere revisión visual del usuario; los números de combate son provisionales. Sin commit ni push.

## 2026-11-02 — Inicio individual dentro del proceso del juego

El mapa principal ahora crea el servidor local como nodo antes de conectar el cliente. La partida normal de un jugador ya no exige lanzar un proceso de servidor aparte. `herramientas/iniciar_juego.ps1` manda `--servidor-externo` en sus clientes para conservar pruebas multijugador con un servidor dedicado.

Verificado headless: ambos modos conectan y validan el mundo. Las siete pruebas automatizadas existentes, cinco parseos de scripts, el parser de PowerShell y `git diff --check` terminaron correctamente. No se abrió la interfaz gráfica; queda la revisión visual del usuario. Sin commit ni push.

## 2026-11-02 — Primera misión individual: Caza de lobos

El jugador selecciona al Habitante y pulsa E cerca para aceptar una misión de tres lobos. Servidor.gd valida la interacción y el rango, conserva el progreso por jugador, registra las bajas y concede 50 XP al completarla. Multijugador.gd procesa welcome/quest_updated; Main.gd presenta un panel y avisos. Se preserva el modo de servidor externo.

La prueba existente PruebaCombate cubre distancia, aceptación, progreso, recompensa y XP final. Las siete pruebas, cinco parseos, `git diff --check` y los arranques headless en ambos modos pasaron con Godot 4.7.2. El chequeo visual queda pendiente para el usuario. Sin commit ni push.

## 2026-11-02 — Pociones curativas y espada de misión

Catálogo: poción consumible (35 HP, máximo 10 por pila) y espada de arma (+5 daño, una unidad). Caza de lobos recompensa dos pociones y una espada. El servidor valida uso/equipamiento, evita gastar poción sin curar, limita la vida al máximo y aplica el bono de arma; 2 usa poción y Q equipa la espada. Main.gd muestra arma y mensajes.

PruebaCombate valida recompensa, curación, conservación de poción con vida llena, consumo, equipo y daño total de 22 a nivel 2 con espada. Siete pruebas, seis chequeos GDScript, parser PowerShell, `git diff --check` y arranque headless integrado/externo pasan. La revisión visual sigue pendiente del usuario. Próximo: guardado/carga local. Sin commit ni push.

## 2026-11-02 — Guardado y carga local inicial

Se completó la persistencia del modo individual en `scripts/servidor/Servidor.gd`: guarda `user://classicrpg_partida.json` con posición/orientación, salud, inventario, nivel/XP, misión y equipo; carga al conectar y normaliza los datos. Guarda al cambiar estados RPG, recibir daño/respawn, cada 10 segundos, al desconectar y al cerrar. El modo externo no usa esta persistencia. El jugador guardado muerto se recupera con HP completo.

Se amplió `herramientas/PruebaCombate.gd` para comprobar los campos restaurados mediante un archivo temporal único bajo `user://`, y confirmar que el modo externo no escribe. El temporal se eliminó correctamente; `classicrpg_partida.json` no existía antes y no se tocó.

Validación con Godot 4.7.2: pasaron las siete pruebas disponibles (Targeting, NPCServidor, FabricaEntidades, EstadoEntidades, DosClientesCombate, Combate y AnimacionCombate). Siete scripts pasaron `--check-only`. El primer intento aislado dentro del entorno restringido no pudo abrir `user://`; tras concederse permiso limitado a la carpeta de datos Godot, el test con `user://` pasó y dejó cero archivos temporales. No se abrió GUI. Sin commit ni push.

La persistencia local básica está comprobada; faltan ampliación de contenido/misiones, revisión visual del usuario, balance y una pasada final del flujo de sesión. El siguiente bloque propuesto es una misión de entrega con consumo validado de materiales y pruebas de estado/inventario.

## 2026-11-02 — Segunda misión individual y arranque autónomo

Tras completar «Caza de lobos», el Habitante inicia «Entrega de pieles»: el jugador reúne tres pieles de lobo y vuelve a hablar con él. Las pieles existentes cuentan; el botín obtenido durante la misión avanza el contador. El servidor valida rango, misión activa y cantidad, no consume si faltan materiales, y al entregar consume exactamente tres, conserva los sobrantes y otorga 75 XP. Main.gd ahora muestra progreso, vuelta al NPC y completado. El estado se normaliza y persiste en el guardado local.

`herramientas/PruebaCombate.gd` comprueba el flujo completo, incluida entrega incompleta, no consumo, progreso por botín, sobrantes, XP y guardado/carga del resultado. Nueva `herramientas/PruebaPartidaIndividual.gd` instancia la escena inicial headless, valida el servidor integrado + un cliente y el mundo, y confirma que cerrar la escena guarda. Usa un archivo temporal único bajo `user://` y lo elimina.

Godot 4.7.2: ocho pruebas pasaron con código 0, seis scripts pasaron `--check-only`, `git diff --check` terminó correctamente y no quedaron guardados temporales. La suite conserva la prueba de dos clientes y animación remota. No se abrió GUI; el usuario hará la revisión visual de HUD/controles. No se modificó `classicrpg_partida.json`; sin commit ni push.

Siguiente paso recomendado: cubrir recuperación ante JSON corrupto/versión no compatible con pruebas aisladas, y ampliar el contenido de la primera zona con más criaturas/misiones y un flujo de juego más completo. Fase 7 continúa abierta.

## 2026-11-02 — Recuperación segura del guardado local

`Servidor.gd` cambió la lectura estática `JSON.parse_string` por `JSON.parse` para manejar JSON corrupto mediante un aviso recuperable. Se descartan documentos de otra versión y se añadieron normalizadores seguros para números/rangos en inventario, nivel/XP, salud, misiones, equipo y posición/yaw.

`PruebaCombate.gd` amplía los casos de `user://` aislado: JSON corrupto, versión 2 y campos con arrays/diccionarios donde se esperan números. Comprueba que la partida vuelve a valores permitidos y limpia el archivo temporal. La ronda válida de guardado/carga permanece en la prueba.

Validación Godot 4.7.2: ocho pruebas pasaron (incluidas las de dos clientes y el arranque individual integrado), seis chequeos `--check-only` y `git diff --check` pasaron. No quedaron temporales ni se modificó `classicrpg_partida.json`. No se abrió GUI; sin commit ni push.

Siguiente bloque: ampliar criaturas, misiones y habilidades de la primera zona y revisar el flujo de sesión. La revisión visual sigue a cargo del usuario; Fase 7 activa.

## 2026-11-02 — Reanudación completa entre sesiones individuales

Se amplió `herramientas/PruebaPartidaIndividual.gd` para realizar una reapertura real en dos sesiones consecutivas de la escena inicial. En la primera, el servidor local y un cliente conectan; el test fija estado temporal y cierra para guardar. En la segunda, la escena inicia de nuevo y el cliente recibe posición, inventario, nivel/XP, salud, misión de entrega activa, espada y HUD restaurados.

El test verifica el archivo JSON temporal y limpia el archivo al final. No se creó ni modificó `classicrpg_partida.json` ni se dejó ningún temporal.

Comprobación final con Godot 4.7.2: ocho pruebas pasaron con código 0, seis scripts pasaron `--check-only` y `git diff --check` terminó correctamente. La suite mantiene los dos tests multijugador. No se abrió GUI; la revisión visual queda reservada al usuario. Sin commit ni push.

Siguiente: ampliar la primera zona con más actividades/enemigos/habilidades, y luego completar la presentación, balance y flujo de sesión. La fase de contenido RPG sigue abierta.

## 2026-11-02 — Primera habilidad activa: golpe pesado

Se añadió el golpe pesado en la tecla 3. Multijugador.gd incluye el identificador de habilidad en el paquete; Servidor.gd valida el ID y aplica daño doble con recarga individual de 6 s, además del cooldown melee general. Jugador.gd usa una animación procedural más larga y amplia. La animación remota recibe el tipo; Main.gd anuncia el control y muestra el resultado/tiempo de espera.

Se ampliaron PruebaCombate.gd, PruebaAnimacionCombate.gd y PruebaDosClientesCombate.gd para daño/equipo/nivel, rechazo de habilidad inválida, recarga y aislamiento entre jugadores. PruebaPartidaIndividual.gd ahora manda el golpe por la conexión real al servidor integrado de la escena y comprueba el daño autoritativo; luego valida la reanudación del guardado temporal.

Verificación: Godot 4.7.2 pasó siete pruebas unitarias, la integración individual headless y los chequeos --check-only de scripts afectados; git diff --check pasó. El puerto 9000 quedó libre y se limpiaron los temporales. No se abrió GUI ni se modificó el archivo permanente de partida. Archivos: Jugador.gd, Main.gd, scripts/cliente/Multijugador.gd, scripts/servidor/Servidor.gd, herramientas/PruebaCombate.gd, herramientas/PruebaAnimacionCombate.gd, herramientas/PruebaDosClientesCombate.gd, herramientas/PruebaPartidaIndividual.gd, memoria/ESTADO_ACTUAL.md, memoria/PENDIENTES.md, memoria/CONTINUAR_CON_IA.md, memoria/HISTORIAL.md y GUIA_CONTINUIDAD_CLASSICRPG.txt.

Siguiente: sumar una segunda criatura a la primera zona con atributos, respuesta de combate y botín definidos por servidor, y cubrir su ciclo con pruebas; preservar la red multijugador existente. Sin commit ni push.

## 2026-11-02 — Jabalí, segunda criatura de la primera zona

Se registró el jabalí como entidad 4 con 80 HP, patrulla propia cada 4 s, ataque a 2,6 m que inflige 14 y recarga de 2 s. El servidor concede 35 XP, colmillo y carne, y lo devuelve a 80 HP tras el respawn. Se amplió la IA de ataques enemigos para usar cooldown por criatura, sin cambiar el daño/recarga del lobo. El modelo procedural del jabalí se crea desde la fábrica remota y muestra nombre/textura; se incorporaron los dos materiales al catálogo.

PruebaNPCServidor y PruebaEstadoEntidades ahora validan registro/estadísticas/patrulla; PruebaFabricaEntidades prueba nueve mallas; PruebaCombate cubre daño, recarga, botín, XP y respawn. Se mantuvo la prueba integrada de golpe pesado y reapertura individual; se ajustó su aserción horizontal porque la física del personaje puede corregir la altura al aparecer. Un primer parseo detectó ConeMesh no reconocido por Godot 4.7.2; se sustituyó por una malla cilíndrica puntiaguda y todos los chequeos pasaron.

Verificación final: ocho pruebas Godot 4.7.2 en código 0 (siete unitarias y una integración individual de dos sesiones), once scripts --check-only y git diff --check. El modo de dos clientes pasó; la integración recibió al jabalí, confirmó el golpe pesado local y restauró la partida. Puerto 9000 libre y temporales limpiados; no GUI ni guardado permanente. Sin commit/push.

Siguiente: una misión que use carne de jabalí, más contenido de zona y balance; preservar multijugador.

## 25. Misión de carne y continuidad individual verificada — 02/11/2026

La cadena incluye la entrega de tres carnes de jabalí: progreso por inventario y botín nuevo, no consume al faltar cantidad, deja sobrantes y recompensa 100 XP. PruebaCombate pasó con Godot 4.7.2, incluyendo restauración de la misión completada, casos de guardado inválido y jabalí. PruebaPartidaIndividual pasó con conexión local real, cierre/reapertura y restauración de inventario, nivel/XP, salud, misión, equipo, posición y HUD. Seis pruebas adicionales (targeting, NPC, fábrica, entidades, dos clientes y animación) pasaron; 14 scripts pasaron --check-only; git diff --check pasó. Temporales en Documents/Codex por limitación de escritura user:// del entorno; la ruta de guardado de producción no cambió. No commit/push. Multijugador preservado.

## Misión de caza de jabalíes — 02/11/2026

Tras entregar las provisiones se habilita la caza de tres jabalíes. El servidor cuenta las bajas autoritativamente, actualiza el HUD, recompensa 60 XP al completar además de XP normal por criatura y guarda/restaura el estado de misión. PruebaCombate.gd pasó con código 0 y ya valida aceptación, tres bajas, XP total y normalización de estado completado. Servidor.gd y Main.gd pasaron --check-only previamente; diff check pasó tras esta ampliación. La fase individual sigue abierta para más contenido, balance y auditoría final. No commit/push; preservar multijugador.

Verificación posterior a misión de caza (02/11/2026): las ocho pruebas funcionales completas pasaron con código 0 en Godot 4.7.2, incluida la integración de dos sesiones individuales y la prueba automatizada de dos clientes. git diff --check también pasó. No se abrió GUI ni se tocaron guardados permanentes. La misión de caza de jabalí quedó cubierta por PruebaCombate.

Actualización de recompensa final de misión (02/11/2026): al completar la caza de tres jabalíes, se pueden reclamar dos pociones curativas una sola vez hablando con el Habitante. La marca recompensa_reclamada persiste en la misión normalizada, evitando duplicación tras reconexión. PruebaCombate valida la reclamación única; Godot 4.7.2 --check-only en servidor y prueba pasó, PruebaCombate exit 0 y git diff --check pasó. Pendiente repetir integración individual completa tras cambio de serialización de misión.

Revalidación de marca de recompensa (02/11/2026): tras persistir recompensa_reclamada, PruebaPartidaIndividual, PruebaDosClientesCombate y PruebaCombate pasaron con código 0 en Godot 4.7.2. La integración confirma carga/guardado/reapertura y HUD; la prueba de dos clientes conserva el modo de red. git diff --check pasó. Temporales de integración en Documents/Codex; sin modificación del guardado permanente, sin GUI ni commit/push.

Menú de inicio individual añadido (02/11/2026): la escena principal ahora presenta nueva partida, continuar cuando hay un guardado local y salir. Para evitar pérdida accidental, Nueva partida se desactiva si ya hay guardado; Continuar se habilita solo con archivo existente. El menú no arranca servidor hasta entrar al mapa y muestra controles básicos. MenuInicio.gd pasó --check-only; ejecutar la escena por defecto headless con --quit-after 2 terminó con código 0; git diff --check pasó. La revisión gráfica corresponde al usuario. Falta probar interacción de botones gráficamente y cubrir estados del menú; el proyecto sigue abierto, multijugador preservado, sin commit/push.

Prueba del menú inicial (02/11/2026): se añadió PruebaMenuInicio.gd con ruta temporal en Documents/Codex. Comprueba en headless que sin guardado permite Nueva partida y bloquea Continuar, y con guardado hace lo inverso; el temporal se elimina. MenuInicio.gd y su prueba pasan --check-only; PruebaMenuInicio terminó con código 0 y git diff --check pasó. No lee, modifica ni elimina el guardado real. Revisión gráfica de disposición y navegación por botones aún pendiente del usuario.

Regresión completa tras cambio a menú inicial (02/11/2026): nueve pruebas pasaron con código 0: menú, targeting, NPC, fábrica, entidades, dos clientes, combate, animación e integración individual. Dieciséis scripts pasaron --check-only y git diff --check pasó. El menú ahora es escena principal; el mapa conserva su uso directo en las pruebas y en el cliente. Continúan pendientes la revisión gráfica del usuario, balance/experiencia de sesión y auditoría final de requisitos; Fase 7 abierta. Sin commit/push; multijugador preservado.

Verificación adicional: PruebaCombate ahora normaliza la misión después de reclamar las pociones y confirma que recompensa_reclamada queda persistida; la segunda interacción no duplica el premio. PruebaCombate terminó con código 0 y git diff --check pasó en Godot 4.7.2.

Resistencia a inventario lleno en recompensas (02/11/2026): el servidor valida que quepan las dos pociones antes de marcar la recompensa como reclamada. Si la pila está en 9/10, no consume ni bloquea la reclamación; al bajar a 8/10 permite recibir hasta 10 y luego evita duplicación. PruebaCombate cubre este caso, normalización de la marca y recompensa única; prueba exit 0, servidor/test --check-only y diff check pasan.

Flujo de reinicio seguro (02/11/2026): el menú permite borrar el archivo local solo mediante un ConfirmationDialog que explica que el progreso se eliminará. Sin guardado, borrar está deshabilitado; con guardado, nueva partida se bloquea y continuar/borrar se habilitan. Tras confirmar el borrado, nueva partida queda disponible. PruebaMenuInicio valida los tres estados y la conexión del diálogo usando un archivo temporal aislado; Godot 4.7.2 test exit 0, ambos scripts --check-only y diff check pasan. El guardado real solo se elimina tras confirmación explícita del jugador.

Regresión del ciclo de sesión tras habilitar borrado confirmado (02/11/2026): nueve pruebas funcionales terminaron con código 0; dieciséis scripts pasaron --check-only; git diff --check pasó. Se cubren estados del menú, confirmación de borrado en temporal, escenas de red de uno y dos clientes, combate, misiones, guardado/reanudación. La prueba no borra ni modifica la partida permanente. Pendiente: prueba manual visual de menú/controles y auditoría final contra requisitos de cierre de RPG individual.

Pausa y retorno al título verificados (02/11/2026): P abre panel con árbol pausado; Reanudar lo cierra. Guardar/volver llama a persistencia antes del cambio de escena. La integración individual de dos sesiones pasó con código 0 y valida pausa/reanudación, guardado/carga, HUD y estado. Para evitar colisiones WebSocket al reiniciar en la misma prueba, el servidor integrado elige un puerto libre entre 9000–9099 y configura el cliente local con esa dirección; Multijugador.gd conserva ws://127.0.0.1:9000 por defecto para servidores externos. PruebaDosClientesCombate, PruebaCombate y PruebaMenuInicio pasaron; Main/servidor/cliente/test de integración pasaron --check-only; diff check pasó. Pendiente revisión gráfica del usuario y auditoría final. Sin commit/push.

## Relevo urgente — 02/11/2026

Estado comprobado en este relevo: el árbol de trabajo conserva cambios locales no preparados y archivos nuevos; no se hizo commit ni push. La nota previa documenta que Godot 4.7.2 pasó la integración individual (reapertura/guardado, estado y HUD), más PruebaDosClientesCombate, PruebaCombate y PruebaMenuInicio; `git diff --check` pasó. El menú inicial, la pausa P, el reanudar y el guardado antes de pedir volver al título están implementados. Precisión: la integración citada ejercitó pausa/reanudación y reabrir sesión; el clic real de «Guardar y volver al título» y la revisión visual del menú aún requieren comprobación del usuario. No tocar el guardado de producción `user://classicrpg_partida.json`.

Siguiente paso al retomar: abrir el juego en Godot 4.7.2, revisar menú/controles, iniciar o continuar, abrir pausa y comprobar «Guardar y volver al título»; luego continuar auditoría de contenido/balance de Fase 7. Mantener el modo individual como prioridad, preservar íntegra la infraestructura y pruebas de dos jugadores. No declarar terminado ni crear commit/push hasta cerrar el protocolo y la revisión pendiente.

## 02/11/2026 — Verificación de Guardar y volver al título

Objetivo: cerrar el hueco de verificación entre pausar y regresar al menú en una partida individual.
Trabajo: ampliada `herramientas/PruebaPartidaIndividual.gd` para mantener la escena como `current_scene`, emitir la señal `pressed` del botón real, comprobar el cambio a `MenuInicio.tscn` y validar JSON versión 1 con inventario y misión antes de cargar el título. El test elimina su archivo temporal al final. Ningún script de producción ni guardado del usuario se modificó.
Resultado comprobado con Godot 4.7.2: integración individual/round-trip y las otras ocho pruebas de la suite (menú, targeting, NPC, fábrica, estado de entidades, combate, animación y dos clientes) terminaron con código 0; chequeos `--check-only` en la prueba, `Main.gd`, `MenuInicio.gd` y `Servidor.gd` exit 0; `git diff --check` limpio. Una ejecución previa sin permiso de loopback no conectó; con la autorización de red local, la integración pasó. No hubo commit ni push.

## 02/11/2026 — Limo del bosque y misión de gelatina

Objetivo: ampliar el contenido individual de la zona y dar uso de misión al material nuevo.
Trabajo: `Servidor.gd` registra la entidad 5 con patrulla, ataque/cooldown y respawn propios; el botín es una Gelatina de limo y da 20 XP. `FabricaEntidades.gd` crea su modelo procedural; `CatalogoObjetos.gd` define el material apilable. Tras cobrar la recompensa de caza de jabalíes, una segunda conversación inicia «Entrega de gelatina de limo»: cuenta tres gelatinas, consume exactamente tres, conserva excedente, otorga 120 XP y persiste progreso normalizado. `Main.gd` presenta el contador en el HUD. Se actualizaron pruebas de entidad/NPC/fábrica/combate e integración individual.
Resultado: nueve pruebas funcionales y nueve `--check-only` terminaron con código 0 en Godot 4.7.2; `git diff --check` pasó. La integración individual recibió y creó visualmente la entidad remota; dos clientes también pasaron. Se corrigieron anotaciones de tipo en la prueba y el conteo esperado de entidades del test NPC; la integración de WebSocket pasó después de autorizar loopback. No GUI, guardado permanente, commit ni push.

## 02/11/2026 — relevo rápido de opción de inventario

Se revisó el estado real tras la petición de detenerse pronto y conservar progreso. Se confirmó que la UI de `Main.gd` y el cliente `scripts/cliente/Multijugador.gd` contienen una implementación parcial para descartar un objeto seleccionado; `scripts/servidor/Servidor.gd` aún no contiene el manejador. No se modificó el código durante este relevo ni se ejecutaron pruebas nuevas. Se añadió esta nota de continuidad para evitar que el cambio parcial se confunda con trabajo completado. Próximo paso: completar servidor y prueba automatizada, verificar Godot 4.7.2 y actualizar memoria con resultados reales.

## 02/11/2026 — descarte de objetos del inventario

Objetivo: completar la opción parcial del inventario para liberar espacio y mantener el estado del personaje y la misión coherentes.

Trabajo: `scripts/servidor/Servidor.gd` ahora procesa `discard_item` con validaciones de jugador vivo, objeto del catálogo y posesión; descarta una unidad, sincroniza el progreso de misiones de materiales, desarma el arma si se elimina su última unidad y guarda el estado individual. `Main.gd` reserva puertos sucesivos en el rango local y los detecta con el mismo bind comodín del servidor, evitando que sesiones consecutivas intenten reutilizar de inmediato el mismo puerto. `herramientas/PruebaCombate.gd` cubre éxito, faltantes, ID desconocido, jugador derrotado, progreso de misión, equipo y persistencia. `herramientas/PruebaPartidaIndividual.gd` ahora selecciona un material en el HUD y verifica la operación por WebSocket contra servidor y cliente.

Resultado: los chequeos `--check-only` de Main, cliente, servidor y ambas pruebas pasaron. Las nueve pruebas funcionales (menú, targeting, NPC, fábrica, entidades, dos clientes, combate, animación e integración individual) terminaron con código 0. La integración probó dos sesiones sucesivas en puertos 9001/9002, descarte en UI, carga del guardado y retorno al menú. `git diff --check` limpio. No GUI, no guardado permanente, sin commit/push; multijugador preservado.

## 02/11/2026 — confirmación antes de descartar

Se añadió un diálogo de confirmación en español al botón de descarte para prevenir pérdidas accidentales de materiales de misión o del arma. La integración individual ahora pulsa Cancelar y comprueba que las dos unidades se conservan; luego confirma y valida que cliente y servidor quedan con una. Godot 4.7.2 `--check-only` pasó en Main y la prueba de integración; las nueve pruebas funcionales volvieron a pasar con código 0. No se abrió GUI ni se tocó el guardado permanente. También se observó un error intermitente de `git status` («not a work tree»); `git rev-parse` sí reconoce el repositorio y no se hicieron operaciones de Git mutativas.

## 02/11/2026 — atributos del personaje

Objetivo: hacer que la progresión por nivel permita mejorar atributos con efectos en combate y supervivencia, conservando la compatibilidad de partidas existentes.

Trabajo: `scripts/servidor/Servidor.gd` otorga un punto por nivel, normaliza asignaciones y guardados legacy, suma +2 daño por Fuerza y +10 vida máxima/actual por Vitalidad, aplica la vida al usar pociones/respawn y valida servidor-side asignaciones no permitidas. `scripts/cliente/Multijugador.gd` envía las solicitudes y recibe la progresión/resultado. `Main.gd` muestra puntos, valores y botones. `PruebaCombate.gd` cubre daño, vida, migración y rechazos; `PruebaPartidaIndividual.gd` cubre botones, WebSocket y restauración del guardado.

Resultado comprobado: cinco scripts `--check-only` y nueve pruebas funcionales pasaron con Godot 4.7.2; la partida individual asignó ambos atributos y la sesión reabierta restauró Fuerza 1, Vitalidad 1 y 110 de vida máxima. `git diff --check` limpio. Fase 7 continúa; usuario revisa visualmente el HUD, sin GUI/guardado permanente/commit/push.

## 02/11/2026 — economía inicial

Se incorporó saldo de oro en servidor y HUD. Las cinco recompensas de misión están configuradas (30 por caza del lobo, 15 por entrega de pieles, 25 por carne de jabalí, 30 por caza de jabalíes y 35 por gelatinas); el Habitante vende pociones curativas por 20. Compra autoritativa valida proximidad, jugador vivo, producto, saldo, pila e inventario. Se añadió persistencia del oro con valor predeterminado 0 para guardados anteriores.

Verificación: suite funcional de nueve pruebas en Godot 4.7.2 pasó; PruebaCombate valida compra/rechazos y pago de la primera misión, y PruebaPartidaIndividual compra por el HUD/WebSocket, guarda y restaura 20 de oro y una poción. Sigue pendiente aserción explícita de los pagos de pieles, carne, caza de jabalíes y gelatinas, además del balance y revisión gráfica. Fase 7 continúa; no se tocó el guardado de producción ni se hicieron commit/push; multijugador preservado.

Verificación de recompensas de oro (02/11/2026): PruebaCombate ahora comprueba que la entrega de pieles, la entrega de carne, la caza de jabalíes y la entrega de gelatina suman exactamente sus recompensas al saldo previo a cada objetivo. Godot 4.7.2 terminó la prueba con código 0; las advertencias de JSON corrupto/versión desconocida son fixtures deliberados del caso de recuperación. git diff --check también terminó con código 0. Fase 7 sigue abierta.

## 02/11/2026 — regresión completa antes de revisión gráfica

Revalidación en Godot 4.7.2: pasaron las nueve pruebas funcionales (menú, targeting, NPC, fábrica, estado de entidades, dos clientes, combate, animación e integración individual). La integración verificó conexión local de una sola persona en dos sesiones, compra desde el HUD, estado restaurado y retorno al menú. En el primer intento, la prueba individual no conectó mientras la red local estaba restringida en el entorno; al habilitar loopback pasó sin cambios de código y luego la suite completa terminó 9/9. El árbol de trabajo conserva todos los cambios anteriores. Logs en C:\Users\Bruker\Documents\Codex\ClassicRPG-suite-20261102-193000. Partida de producción intacta; sin commit/push. La revisión gráfica corresponde al usuario.

## 02/11/2026 — cursor Point y giro libre con botón izquierdo

Objetivo: instalar el cursor descargado Point.png y restaurar la rotación de cámara al arrastrar con el botón izquierdo, conservando selección de enemigos, TAB y el comportamiento del botón derecho.

Trabajo: assets/cursores/Point.png se copió sin conversión desde Descargas; los SHA-256 del original y la copia coinciden. project.godot apunta al PNG transparente de 32×32 px con hotspot predeterminado (0, 0). Camara.gd conserva la selección por raycast al pulsar; al acumular 4 px de movimiento con el botón izquierdo activa órbita libre y al soltarla la desactiva. Jugador.gd ya selecciona modo libre y no sincroniza el yaw del modelo con la cámara. El botón derecho conserva su órbita vinculada.

Verificación con Godot 4.7.2: importación del recurso; PruebaTargeting.gd exit 0; prueba temporal de entrada exit 0 (selección en clic, umbral, rotación de cámara, yaw del jugador sin cambio durante física y giro derecho); prueba TAB real exit 0; y comprobación gráfica temporal del cursor transparente y el cambio de vista al arrastrar. Se cerró Godot y se retiraron los archivos temporales creados; no se tocó el guardado de producción. La lectura final de Git falló de forma intermitente con error de worktree/permisos; no se ejecutaron operaciones Git mutativas, commit ni push. Fase 7 sigue abierta.

## 02/11/2026 — cursor Point y giro libre con botón izquierdo

Objetivo: instalar el cursor descargado Point.png y restaurar la rotación de cámara al arrastrar con el botón izquierdo, conservando selección de enemigos, TAB y el comportamiento del botón derecho.

Trabajo: assets/cursores/Point.png se copió sin conversión desde Descargas; los SHA-256 del original y la copia coinciden. project.godot apunta al PNG transparente de 32×32 px con hotspot predeterminado (0, 0). Camara.gd conserva la selección por raycast al pulsar; al acumular 4 px de movimiento con el botón izquierdo activa órbita libre y al soltarla la desactiva. Jugador.gd ya selecciona modo libre y no sincroniza el yaw del modelo con la cámara. El botón derecho conserva su órbita vinculada.

Verificación con Godot 4.7.2: importación del recurso, PruebaTargeting.gd exit 0 y prueba temporal de entrada exit 0 (selección en clic, umbral, rotación de cámara, yaw del jugador sin cambio durante física, giro derecho, liberación y asignación TAB). La prueba gráfica temporal confirmó el cursor en pantalla con fondo transparente y cambio de vista al arrastrar. Se cerró Godot y se retiraron los archivos temporales creados; no se tocó el guardado de producción. La lectura final de Git falló de forma intermitente con error de worktree/permisos; no se ejecutaron operaciones Git mutativas, commit ni push. Fase 7 sigue abierta.

## 02/11/2026 — posición final del cursor tras órbita

Se atendió el reporte de que, aunque el cursor ya no volvía al centro, reaparecía en una ubicación distinta al terminar el arrastre. Camara.gd ahora guarda el inicio en coordenadas de ventana (transformadas desde el viewport), acumula el movimiento no escalado screen_relative durante la captura y restaura esa posición con Input.warp_mouse al liberar cualquiera de los dos botones. Se conserva el giro libre izquierdo, la órbita vinculada derecha, la selección por clic y TAB.

Verificación automática Godot 4.7.2: prueba temporal de eventos sintéticos exit 0 para selección, inicio y cierre de ambas órbitas y cálculo de posición final en coordenadas de pantalla; PruebaTargeting.gd exit 0. El entorno headless mantiene su mouse_mode en visible y no puede demostrar el movimiento físico del puntero; la prueba cubre el cálculo/restauración solicitados. Por indicación del usuario no se harán más pruebas visuales; esa comprobación queda a su cargo. Se limpiaron los archivos temporales. Sin cambios al guardado de producción, commit ni push.

Corrección posterior solicitada por el usuario (02/11/2026): el punto de retorno es el inicio del gesto, no el extremo del arrastre. `Camara.gd` conserva la posición del clic inicial izquierdo y la posición de pulsación derecha mientras continúa aplicando el movimiento relativo al giro. Godot 4.7.2: prueba headless temporal de selección, giro y retorno al inicio con ambos botones; `PruebaTargeting.gd`; y chequeo sintáctico de `Camara.gd`, todos con código 0. No se abrió la ventana gráfica; el usuario verificará el cursor físico. El arnés temporal fue retirado y el guardado de producción queda intacto.

## 02/11/2026 — HUD inicial medieval

Se añadió `scripts/cliente/HUDInicial.gd` y se conectó desde `Main.gd`. Incluye retrato generado desde el modelo actual del caballero, barras de vida real y maná vacío preparado, seis ranuras visuales vacías, marco de objetivo con nombre y salud, y minimapa con posición global y orientación del jugador. El módulo usa marcos oscuros con borde metálico/remaches y patrón de cuero procedural. `herramientas/PruebaHUDInicial.gd` verifica los callbacks de salud, nivel y objetivo, el retrato, minimapa y cantidad de espacios.

Godot 4.7.2: tres chequeos `--check-only`, PruebaHUDInicial, PruebaTargeting y PruebaPartidaIndividual terminaron con código 0. No hubo errores nuevos en el arranque de la escena/pruebas. No se abrió la ventana gráfica ni se evaluó la estética; el usuario hará la revisión. No se alteraron movimiento, cámara, targeting, controles, servidor ni cliente multijugador. El maná y las acciones no tienen lógica de juego; no se les asignó ninguna. No se tocó el guardado permanente ni se hizo commit/push.

## 02/11/2026 — Integración de atuendo Quaternius

Objetivo: sustituir visualmente el caballero provisional por un personaje masculino del paquete Modular Character Outfits – Fantasy sin cambiar la lógica del jugador.

Se comprobó que el paquete no estaba descargado localmente. Se obtuvo la versión Standard gratuita oficial y se inspeccionó su contenido, licencia, materiales y rig; también se verificó la disponibilidad y compatibilidad del paquete estándar Universal Base Characters. La variante masculina de combate disponible en Standard es Male_Ranger; no se encontró un modelo nombrado Knight. El glTF ensamblado incluye la malla de cabeza/hood, 9 mallas, seis imágenes, 2 materiales y 65 huesos. No incluye animaciones ni arma. El UBC no se añadió a la escena porque el ensamblado seleccionado no lo requiere como recurso externo.

Archivos del proyecto: Personajes/Jugador.tscn y assets/modelos/quaternius/modular_character_outfits_fantasy/ (Male_Ranger.gltf/.bin, seis PNG, licencia y README; Godot creó archivos .import). Jugador.tscn oculta, sin eliminar, los 17 nodos raíz del visual anterior y añade la instancia Quaternius bajo Modelo. No se tocaron Jugador.gd, movimiento, colisión/física, cámara, controles, targeting, HUD ni scripts multijugador.

Comprobación Godot 4.7.2 headless: carga de escena, 9 mallas con materiales texturados, esqueleto de 65 huesos, cotas 1,869 m con pies a y≈0, referencias antiguas del script, colisión original y movimiento move_forward; todas las comprobaciones pasaron. PruebaHUDInicial.gd y PruebaTargeting.gd exit 0. La importación en modo editor completó la conversión del GLTF; el proceso reportó un error aparte al guardar preferencias globales de Godot en %APPDATA% por el acceso limitado del entorno. No hubo error de importación del asset ni del runtime headless. Las comprobaciones headless se repitieron con APPDATA aislado en Documents/Codex y terminaron limpias. No se abrió GUI ni se hizo commit/push. Pendiente revisión visual del usuario; el nuevo mesh no tiene animaciones, por lo que requiere retarget de locomoción posteriormente.

## 02/11/2026 — Cabeza y animación procedural del atuendo Quaternius

El usuario informó que Male_Ranger se veía como ropa sin cabeza/cuerpo y quedaba estático. La inspección confirmó que el GLTF carga nueve mallas visibles, pero no incluye una cabeza facial ni animaciones. Jugador.gd seguía calculando locomoción procedimental para los nodos provisionales ocultos; el rig humanoide del nuevo modelo nunca recibía esas rotaciones. El README del atuendo explica que sus piezas corporales visibles ya están incluidas y pide añadir solo una cabeza, pues el cuerpo completo del UBC causa clipping. La descarga gratuita UBC Standard disponible contiene cuerpo masculino Superhero, mientras el Ranger usa proporciones Regular.

Se extrajo de la geometría UBC masculina únicamente la región de cabeza/cuello asociada al hueso Head, más ojos y cejas; la cabeza se colocó como recurso GLB bajo Modelo y conserva su rig/pesos. No se añadió el cuerpo Superhero bajo la ropa. Jugador.gd ahora proyecta las curvas preexistentes de reposo, marcha, carrera/sprint, ascenso, caída y aterrizaje en huesos nombrados del Ranger y de la cabeza; los brazos salen de la T mediante pose de hombros. Movimiento, constantes de física, cámara, colisión, controles, targeting, HUD y scripts de red no se modificaron.

Archivos modificados: Jugador.gd, Personajes/Jugador.tscn y memorias. Archivo de prueba nuevo: herramientas/PruebaModeloAnimacionesQuaternius.gd. Recursos añadidos bajo assets/modelos/quaternius/universal_base_characters_standard/: GLTF/bin, texturas, licencia Standard y Cabeza_Superhero_Male.glb derivada. El anterior modelo provisional sigue oculto como respaldo.

Godot 4.7.2: comprobación de modelo/rig/cara/texturas y poses procedurales; las 12 pruebas de herramientas terminaron con exit code 0, incluidas integración individual por WebSocket y sincronización de dos clientes. El primer intento de integración individual falló con la red local restringida; con permiso de loopback pasó sin modificación de código de servidor/cliente. `--headless --editor --import` terminó importando el GLB; produjo además el aviso existente `Safe save failed` al persistir ajustes del editor, sin error de importación de la escena. No se hizo prueba visual: el usuario revisará la cara/ajuste del atuendo en juego. No hay clips externos y la animación continúa siendo procedural. No se adquirió la versión Source ni se hizo commit/push.

## 02/11/2026 — Orientación y Universal Animation Library

Se corrigió la orientación del atuendo mediante el contenedor visual `VisualQuaternius`, sin tocar el giro lógico del jugador ni la física/controles. Se integró el paquete oficial UAL Standard in-place y se conservó el ZIP original con licencia/README. Un `RetargetModifier3D` con perfil de 65 huesos alimenta el `AnimationTree` en ejecución y anima tanto Male_Ranger como la cabeza UBC. El BlendSpace representa ocho direcciones de marcha, trote y sprint usan Jog_Fwd/Sprint; Jump_Start, Jump en ascenso/caída y Jump_Land forman el ciclo aéreo.

Godot 4.7.2: `PruebaModeloAnimacionesQuaternius.gd` comprobó la mirada hacia ocho vectores de movimiento, las ocho posiciones del BlendSpace, Idle, yaw lógico sin cambios, cambio real de poses en cuerpo/cabeza y cada transición de estado. Se corrigió el cálculo de transformaciones al montar el retarget para que no dependa de `global_transform` en instancias fuera del árbol. La prueba específica pasó limpia y las 12 pruebas `Prueba*.gd` terminaron con código 0, incluyendo combate, dos clientes, HUD, targeting y partida individual. No se abrió la GUI; la verificación visual corresponde al usuario.

Límite del paquete Standard: solo trae un ciclo Walk, por eso el BlendSpace reutiliza ese clip en sus ocho puntos; tampoco tiene animación Fall dedicada y el estado Caida reutiliza el ciclo Jump. La animación de biblioteca es in-place, evitando duplicar movimiento del controlador. Sin commit/push.

## 02/11/2026 — Limpieza del proyecto

Se revisaron las referencias de los sobrantes y se retiraron las carpetas/copias locales antiguas `RESPALDO_*` y `*.bak`, los archivos de cursor de guantelete que ya no usa el proyecto y la escena vacía `node_3d.tscn` (sin referencias; la escena principal es `MenuInicio.tscn`). Se conservaron el modelo anterior oculto como respaldo y los recursos fuente originales de Quaternius. No se modificó código de juego en esta limpieza. La verificación headless inmediatamente anterior había pasado 12/12; no se repitió tras retirar archivos sin referencias.
