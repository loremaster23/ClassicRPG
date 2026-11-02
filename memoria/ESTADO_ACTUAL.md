# CLASSICRPG — ESTADO ACTUAL

Última actualización: 02/11/2026

Motor: Godot 4.7.2
Repositorio: https://github.com/loremaster23/ClassicRPG
Rama: main


## 1. Proyecto

RPG 3D de fantasía medieval en desarrollo, con prioridad actual de un solo jugador.

Objetivo vigente: completar primero el ciclo de juego individual. La base cliente-servidor y el modo de dos jugadores ya desarrollados se conservan íntegramente para una etapa futura; esta prioridad no autoriza eliminarlos ni sustituirlos.

Dirección artística:
- Fantasía medieval.
- Referencia visual principal: WoW Classic.
- Influencias de Skyrim, Harry Potter y Avatar.
- Identidad visual propia.

## 2. Estado Git comprobado

Última comprobación: 02/11/2026.

Rama: main
Último commit: 18c64f2 — Fase 6: sistema de combate autoritativo cuerpo a cuerpo y pruebas.

Cambios locales sin preparar:
- GUIA_CONTINUIDAD_CLASSICRPG.txt
- Jugador.gd
- Main.gd
- herramientas/PruebaCombate.gd
- memoria/CONTINUAR_CON_IA.md
- memoria/DECISIONES.md
- memoria/ESTADO_ACTUAL.md
- memoria/HISTORIAL.md
- memoria/LEEME_PRIMERO.md
- memoria/PENDIENTES.md
- memoria/REGLAS_IA.md
- scripts/cliente/Multijugador.gd
- scripts/servidor/Servidor.gd

Archivos sin seguimiento:
- herramientas/PruebaAnimacionCombate.gd y su .uid
- herramientas/PruebaCombate.gd.uid
- herramientas/PruebaDosClientesCombate.gd y su .uid
- herramientas/PruebaTargeting.gd.uid
- herramientas/iniciar_juego.ps1
- scripts/compartido/CatalogoObjetos.gd

No hay cambios preparados. Preservar todas estas modificaciones; no hacer reset, clean, commit ni push.


## 3. Escenas y arquitectura

Escena inicial configurada:
res://Mapa1/Escena1.tscn

Esta escena contiene un nodo Node3D que utiliza Main.gd.

Main.tscn también existe, utiliza Main.gd y contiene un nodo adicional transformado. No se encontró una referencia activa a Main.tscn en la búsqueda realizada.

Main.gd genera por código:
- Entorno e iluminación.
- Terreno.
- Camino.
- Bosque.
- Rocas.
- Personaje local.
- Cámara.
- HUD.
- Sistema multijugador.

Personajes/Jugador.tscn es la escena utilizada para instanciar personajes locales y remotos.

## 4. Personaje

Escena:
res://Personajes/Jugador.tscn

Script asociado:
res://Jugador.gd

El personaje utiliza CharacterBody3D y geometría primitiva de Godot.

Componentes identificados:
- Torso y pechera.
- Cinturón.
- Piernas y botas.
- Brazos y mangas.
- Escudo y espada.
- Hombreras.
- Cabeza, rostro y casco.
- Capa.

Estado de animación:
- Animación procedural mediante GDScript.
- Movimiento de brazos y piernas.
- Animación de reposo.
- Carrera.
- Salto y caída.
- Aterrizaje.
- Movimiento de torso, espada, hombreras y capa.

No utiliza actualmente:
- Skeleton3D.
- AnimationPlayer.
- AnimationTree.

La escena actual debe conservarse. No sustituirla por modelos experimentales sin autorización.

Existe scripts/cliente/Jugador.gd como implementación alternativa. No se encontraron referencias activas a este archivo en la búsqueda realizada. No eliminarlo.

## 5. Cámara y controles

Escena:
res://Camaras/Camara.tscn

Script:
res://Camara.gd

Cámara de tercera persona con:
- Órbita alrededor del personaje.
- Ajuste de distancia.
- Control de inclinación.
- Seguimiento suavizado.
- Raycast para evitar atravesar determinadas colisiones.

Los botones izquierdo y derecho del ratón activan modos de órbita que actualmente tienen comportamiento equivalente.

El zoom utiliza la rueda del ratón.

Controles identificados en Input Map:
- WASD y flechas: movimiento.
- Espacio: salto.
- Shift: correr.
- Ratón: cámara.
- Z: weapon_toggle.
- E: interact.
- Teclas 1–6: ability_1 a ability_6.
- También existen select_next_target y open_menu.

La existencia de estas acciones no demuestra que estén implementadas funcionalmente. No se encontraron usos activos para varias de ellas en los scripts inspeccionados.

El HUD anuncia Q/E para girar, pero no se encontró una implementación correspondiente confirmada.

No se ha confirmado un mapeo de mando en el Input Map inspeccionado.

## 6. Mundo procedural

Script compartido:
res://scripts/compartido/GeneradorTerreno.gd

Parámetros identificados:
- Tamaño del mundo: 110.
- Resolución: 44.
- Árboles: hasta 80.
- Intentos de colocación de rocas: 24.
- Generación mediante semillas determinísticas.
- Terreno con ruido y variaciones de altura.
- Camino central curvo.

Main.gd y Servidor.gd utilizan el generador compartido.

La configuración del mundo se transmite al cliente y se compara mediante semillas, dimensiones, resolución y cantidades generadas.

La validación de parámetros no constituye una comparación completa de las mallas generadas.

## 7. Arquitectura multijugador

Comunicación:
WebSocket.

Dirección local:
ws://127.0.0.1:9000

Servidor:
scripts/servidor/Servidor.gd

Cliente:
scripts/cliente/Multijugador.gd

Máximo configurado:
2 jugadores.

Funcionalidades identificadas:
- Conexión y desconexión.
- Identificación mediante ID.
- Recepción de jugadores existentes.
- Notificación de nuevas conexiones.
- Notificación de desconexiones.
- Envío periódico de posición.
- Sincronización de orientación.
- Sincronización de carrera y salto.
- Creación de personajes remotos.
- Interpolación de posiciones.
- Interpolación de orientación.
- Animación procedural de personajes remotos.
- Correcciones de posición enviadas por el servidor.
- Rechazo cuando el servidor está lleno.
- Validación de configuración del mundo.

El cliente envía posición, orientación, carrera y estado de salto aproximadamente cada 0,1 segundos.

Los personajes remotos no ejecutan su física local. Su posición y animación se actualizan mediante Multijugador.gd.

## 8. Limitaciones multijugador

La arquitectura todavía no es completamente autoritativa.

Limitaciones identificadas:
- El cliente comunica su propia posición.
- El servidor realiza validaciones parciales del movimiento.
- El servidor confía en el indicador de carrera enviado por el cliente.
- No existe predicción local con reconciliación completa.
- La interpolación utiliza directamente el último objetivo recibido, sin búfer temporal.
- No se encontró un procedimiento explícito de reconexión.
- La validación del mundo no bloquea por sí sola el movimiento cuando falla.
- No existe autenticación de cuentas.
- No existe persistencia de personajes.

La sincronización básica ha sido implementada, pero estas limitaciones deben resolverse antes de considerar el sistema adecuado para un MMORPG público.

## 9. Modelo Blender

Carpeta:
assets/modelos/caballero/

Archivos conocidos:
- Caballero.blend
- Caballero.blend1
- Caballero.glb
- Caballero_v2.blend
- Caballero_v2.blend1
- Caballero_v2.glb
- generar_caballero.py
- generar_caballero_v2.py

Blender: 5.2.3

El modelo es experimental y permanece separado del personaje actual.

El usuario considera que su apariencia es demasiado cúbica.

No integrar ni sustituir el personaje actual sin autorización.

## 10. Fases del desarrollo

Según la documentación histórica:
- Fases 1–3: completadas.
- Fase 4: base implementada.
- Fase 5: prototipo de terreno procedural.
- Fases posteriores: pendientes o en fase de planificación.

La auditoría técnica ha confirmado partes de la arquitectura y los sistemas existentes, pero no equivale a repetir todas las pruebas funcionales.

## 11. Sistemas pendientes

- Servidor completamente autoritativo.
- Validación avanzada del movimiento.
- Autenticación.
- Persistencia.
- Reconexión.
- Combate.
- Atributos y progresión.
- Inventario y equipamiento.
- Habilidades.
- Enemigos y NPC.
- Misiones.
- Economía.
- Contenido y regiones del mundo.
- Rigging y animaciones esqueléticas.
- Mejoras de cámara y controles.
- Pruebas de rendimiento y estabilidad.

## 12. Auditoría técnica del 01/11/2026

Se inspeccionaron:
- Main.tscn y Mapa1/Escena1.tscn.
- Main.gd.
- Personajes/Jugador.tscn.
- Jugador.gd.
- scripts/cliente/Jugador.gd.
- Camaras/Camara.tscn.
- Camara.gd.
- Input Map de project.godot.
- scripts/cliente/Multijugador.gd.
- scripts/servidor/Servidor.gd.
- scripts/compartido/GeneradorTerreno.gd.

También se comprobó el estado Git de la rama main.

La auditoría fue principalmente una revisión estática del contenido compartido. No se deben presentar todas las funcionalidades como si hubieran sido probadas nuevamente durante esta sesión.

## 13. Prioridad de continuidad

Desarrollar primero el RPG para un solo jugador y preservar intacto el código, las escenas, recursos y pruebas existentes para dos jugadores.

Prueba de capacidad del inventario completada en herramientas/PruebaCombate.gd con Godot 4.7.2 (código 0). Siguiente: auditar el flujo de inicio y las dependencias de red para definir cómo completar la experiencia individual sin exigir un segundo cliente. La revisión visual del panel queda a cargo del usuario.

Las mejoras exclusivamente online se conservan como trabajo futuro. Antes de cada tarea, revisar Git y los archivos reales afectados; no descartar cambios locales.

## 14. Regla de prioridad

Los archivos reales del proyecto y las comprobaciones actuales tienen prioridad sobre cualquier resumen histórico.

Nunca descartar cambios locales ni asumir que un sistema está terminado únicamente porque exista su archivo.
## 15. ESTADO OFICIAL ACORDADO — 01/11/2026

Esta sección actualiza el criterio de continuidad y prevalece sobre las descripciones históricas anteriores cuando exista alguna diferencia.

### Fases

- Fase 1 — Arquitectura y organización: COMPLETADA.
- Fase 2 — Conexión multijugador: COMPLETADA. Se conserva la verificación histórica documentada.
- Fase 3 — Sincronización básica: COMPLETADA. Se conserva la verificación histórica documentada.
- Fase 4 — Personajes, animaciones y estados: ACEPTADA COMO COMPLETADA PARA CONTINUAR, por decisión expresa del usuario.
- Fase 5 — Mundo y entidades: alcance inicial de terreno, entidades sincronizadas, lobo, patrulla y respawn implementado; contenido y variedad de mundo siguen pendientes.
- Fase 6 — Combate: ciclo inicial autoritativo y combate con dos clientes confirmados por el usuario; mejoras de balance/combate siguen abiertas.
- Fase 7 — Sistemas RPG: ACTUAL. El usuario confirmó combate, XP, niveles, daño escalado y botín; la siguiente implementación individual es completar inventario y su capacidad.
- Fase 8 — Cuentas y persistencia: PENDIENTE.
- Fase 9 — Red, acceso externo y lanzamiento: PENDIENTE.

La aceptación de la Fase 4 permite avanzar sin convertir en funcionalidades terminadas las mejoras técnicas que todavía faltan.

### Comprobaciones de esta continuidad

- Revisada la definición oficial de fases en GUIA_CONTINUIDAD_CLASSICRPG.txt.
- Confirmada la escena inicial Mapa1/Escena1.tscn y su referencia a Main.gd.
- Confirmada la referencia de Personajes/Jugador.tscn a Jugador.gd.
- Confirmada la referencia de Camaras/Camara.tscn a Camara.gd.
- Identificado el personaje actual como CharacterBody3D con geometría de mallas primitivas.
- Identificada la animación procedural mediante GDScript.
- Confirmadas las acciones de movimiento, salto, sprint, cámara, selección de objetivo, interacción, habilidades y menú en Input Map.
- La presencia de acciones en Input Map no demuestra que sus sistemas estén implementados.
- La inspección de scripts activos no encontró módulos identificables de NPC, enemigos, IA, combate, inventario, habilidades funcionales, misiones o botín.
- La inspección de funciones confirma que el código activo se concentra en personaje, cámara, construcción del mundo, terreno y comunicación multijugador.

### Validación del motor

Se conserva el resultado comunicado anteriormente:
- Godot 4.7.2 ejecutó la comprobación del editor en modo headless con código de salida 0.
- La ejecución headless de 120 fotogramas terminó con código de salida 0 y sin errores ni advertencias detectados.

Estas comprobaciones acreditan el arranque técnico, no una prueba visual completa ni una nueva sesión multijugador de dos clientes.

### Mejoras técnicas posteriores

Se mantienen pendientes, aunque las fases anteriores estén aceptadas para continuar:
- Rigging y animaciones esqueléticas.
- Modelos y recursos definitivos.
- Equipamiento intercambiable.
- Estados avanzados del personaje.
- Mejoras de cámara y controles.
- Autoritatividad y seguridad del servidor.
- Predicción, reconciliación e interpolación avanzada.
- Autenticación, persistencia y reconexión.

No se repitió una prueba multijugador de dos clientes durante esta auditoría. El usuario decidió aceptar el sistema multijugador existente para continuar.

La Fase 5 es el siguiente bloque de desarrollo. No marcarla como completada hasta implementar y comprobar sus sistemas.


## HITO FASE 5 — ENTIDADES SINCRONIZADAS — 01/11/2026

- Servidor actualizado y ejecutándose en PID 18428 durante la prueba.
- Entidad de prueba registrada por el servidor: ID 1, tipo prueba.
- El mensaje welcome incluye la lista de entidades.
- Cliente actualizado y validado con Godot 4.7.2, código de salida 0.
- Cliente conectado e identificado correctamente.
- Cliente recibió la entidad y creó EntidadRemota_1.
- Usuario confirmó visualmente que la esfera azul aparece en el mundo.
- Mundo compartido validado: 80 árboles, 21 rocas y semillas/dimensiones coincidentes.
- Prueba realizada con un cliente. No se repitió la prueba de dos clientes.
- No se ha probado todavía en ejecución la aparición dinámica entity_spawned ni la eliminación entity_removed.
- La Fase 5 continúa abierta.


## ACTUALIZACION DOCUMENTAL FASE 5 - 01/11/2026

## HITO FASE 5 - CICLO DINAMICO DE ENTIDADES VERIFICADO - 01/11/2026

Prueba real completada con Godot 4.7.2:
- El servidor registro la entidad inicial ID 1.
- Un cliente se conecto correctamente.
- El servidor creo dinamicamente la entidad ID 2.
- El cliente recibio entity_spawned y creo su representacion visual.
- El servidor elimino la entidad ID 2.
- El cliente recibio entity_removed y elimino su representacion.
- El usuario confirmo visualmente la presencia de ambas esferas y la desaparicion de la segunda.
- Los registros de servidor y cliente confirmaron ambos eventos.

Limpieza posterior:
- Retirada la variable y la funcion temporal de prueba automatica.
- Conservadas las funciones permanentes _registrar_entidad() y _eliminar_entidad().
- Creada copia de seguridad Servidor.gd.bak_limpieza_prueba_dinamica.
- El servidor limpio se inicio correctamente, PID 17324, sin errores.
- La entidad inicial de prueba ID 1 sigue registrandose al iniciar el servidor.

Estado:
- El flujo snapshot, entity_spawned y entity_removed ha sido probado.
- No se ha probado todavia el sistema con NPC o enemigos reales.
- No se ha repetido una prueba con dos clientes.
- Fase 5 sigue en desarrollo.

## 16. CORRECCIÓN DE ERRORES Y PUBLICACIÓN — 01/11/2026

Cambios aplicados:
- `Jugador.gd`: sangría restaurada a tabulaciones (estaba con 4 espacios en todo el archivo). El diff bajó de 492 a 374 líneas.
- `Jugador.gd`: `camera_mode` confirmado dentro de `_physics_process`, alineado con `var entrada`.
- `Jugador.gd`: la fuerza de aterrizaje usa la velocidad de caída previa a `move_and_slide`.
- `Camara.gd`: sin cambios respecto a `2b106a5`; zoom por `camera_zoom_in` / `camera_zoom_out`.
- `FabricaEntidades.gd`: el `Label3D` del nombre solo se crea si el NPC tiene nombre.
- `Multijugador.gd`: el `welcome` aplica el yaw sobre `Modelo`; eliminado el `print` por corrección.
- `.gitignore`: excluye `*.bak`, `*.bak_*` y `*.blend1`.

Comprobado:
- Los 8 scripts pasan `--check-only` con código 0.
- `PruebaFabricaEntidades.gd` pasa (antes fallaba con «Mallas incorrectas»).
- `PruebaNPCServidor.gd` pasa.
- Servidor y cliente reales: entidades 1 (`prueba`) y 2 (`npc`) creadas sin errores.
- Escena principal en headless: código 0.
- Importación del editor: código 0.

No probado:
- Partida de dos clientes con movimiento simultáneo.

## 17. HITO FASE 5 — CICLO DE VIDA Y ESTADO DE ENTIDADES — 01/11/2026

Cambios aplicados:
- `Servidor.gd`:
  - Entidades ampliadas con estructura completa de estado: `id`, `type`, `name`, `x`, `y`, `z`, `yaw`, `hp`, `hp_max`, `estado`, `activo`.
  - Entidad 1 (`prueba`): vida 100/100, estado `activo`.
  - Entidad 2 (`npc`): "Habitante", vida 100/100, estado `idle`.
  - Añadida función `_actualizar_entidad(id, cambios)` que propaga los cambios a `entidades[id]` y difunde el mensaje `entity_updated` en red.
  - Añadida función `_obtener_entidad(id)` para consultar el estado actual.
- `Multijugador.gd`:
  - Separación entre datos de red (`datos_entidades`), objetivos espaciales (`objetivos_entidades`) y nodos visuales (`entidades_remotas`).
  - Procesamiento del mensaje `entity_updated`: actualiza datos, posición, rotación `yaw` y nombre si procede.
  - Implementada interpolación suave de posición y rotación mediante `_actualizar_entidades_remotas(delta)` en `_process`.
  - Limpieza de datos y objetivos en `_eliminar_entidad_remota` y en `_mostrar_servidor_lleno`.
- `herramientas/PruebaEstadoEntidades.gd`:
  - Nueva prueba automatizada que valida la estructura de campos de las entidades, la función `_actualizar_entidad` y la eliminación.

Comprobado:
- `herramientas/PruebaEstadoEntidades.gd`: código de salida 0.
- `herramientas/PruebaFabricaEntidades.gd`: código de salida 0.
- `herramientas/PruebaNPCServidor.gd`: código de salida 0.
- Los 10 scripts del proyecto pasan `--check-only` con código de salida 0.
- Escena principal `Mapa1/Escena1.tscn` en headless arranca e inicializa mapa y multijugador sin errores.

Comprobado adicionalmente:
- Verificación visual interactiva en ventana de juego confirmada por el usuario: esfera azul (ID 1) y NPC "Habitante" (ID 2) visibles en el mundo en ejecución con servidor activo.

No probado:
- Partida de dos clientes con movimiento simultáneo.

## 18. HITO FASE 5 — CRIATURA LOBO Y PATRULLA BÁSICA AUTORITATIVA — 01/11/2026

Cambios aplicados:
- FabricaEntidades.gd:
  - Añadido el tipo "lobo": modelo cuadrúpedo con mallas primitivas (cuerpo, cabeza, 4 patas) y material acorde (marrón oscuro/grisáceo). Etiqueta de nombre destacada en color rojizo (Lobo del Bosque).
- Servidor.gd:
  - Registrada la entidad ID 3 tipo "lobo", 60/60 HP, estado "patrullando" en coordenadas del bosque (-4.0, 4.0).
  - Añadida rutina periódica de IA de patrulla autoritativa _actualizar_ia_entidades(delta): rota y avanza entre waypoints calculando la altura del terreno con _altura_terreno() y el ángulo yaw, transmitiendo su estado mediante _actualizar_entidad().
- herramientas/:
  - Actualizadas PruebaFabricaEntidades.gd, PruebaNPCServidor.gd y PruebaEstadoEntidades.gd para incluir la validación del lobo (6 mallas sin nombre, registro de 3 entidades y actualización de estado).

Comprobado:
- herramientas/PruebaFabricaEntidades.gd: código de salida 0.
- herramientas/PruebaNPCServidor.gd: código de salida 0.
- herramientas/PruebaEstadoEntidades.gd: código de salida 0.
- Los 10 scripts del proyecto pasan --check-only con código de salida 0.
- Escena principal Mapa1/Escena1.tscn en headless arranca sin errores.

No probado:
- Partida de dos clientes con movimiento simultáneo.

## 19. HITO FASE 5 — SISTEMA DE SELECCIÓN DE OBJETIVOS (TARGETING) Y HUD — 01/11/2026

Cambios aplicados:
- Multijugador.gd:
  - Implementado sistema de selección de objetivos (targeting) con señal objetivo_cambiado(id, datos, nodo).
  - Acción select_next_target (tecla Tab): cicla entre las entidades remotas disponibles ordenadas por distancia al jugador.
  - Tecla Escape: deselecciona el objetivo activo.
  - Al recibir entity_updated en la entidad fijada, se emite la señal para refrescar el HUD de objetivo automáticamente.
  - Al eliminarse la entidad (_eliminar_entidad_remota), se limpia el objetivo seleccionado.
- Main.gd:
  - Panel de marco de objetivo (Target Frame): contenedor con estilo visual MMORPG clásico (PanelContainer) que muestra: Nombre del objetivo, barra de vida (ProgressBar con valor actual y máximo), tipo y estado actual. Permanece oculto si no hay objetivo.
  - Indicador 3D circular en el suelo: aro dorado con brillo (TorusMesh con emisión) que sigue en tiempo real la posición sobre el terreno de la entidad seleccionada.
  - Controles actualizados en el HUD inicial para indicar Tab: objetivo y Escape: limpiar objetivo.
- herramientas/PruebaTargeting.gd:
  - Nueva suite de prueba que verifica la selección secuencial por distancia, ciclo continuo y deselección con código de salida 0.

Comprobado:
- herramientas/PruebaFabricaEntidades.gd: código 0.
- herramientas/PruebaNPCServidor.gd: código 0.
- herramientas/PruebaEstadoEntidades.gd: código 0.
- herramientas/PruebaTargeting.gd: código 0.
- Los 11 scripts del proyecto pasan --check-only con código de salida 0.
- Escena principal Mapa1/Escena1.tscn en headless arranca sin errores (código 0).

No probado:
- Partida de dos clientes con movimiento simultáneo.

## 20. HITO FASE 6 — SISTEMA DE COMBATE AUTORITATIVO CUERPO A CUERPO — 02/11/2026

Cambios aplicados:
- Servidor.gd:
  - Constantes añadidas: RANGO_ATAQUE_MELEE (4.5 unidades), TIEMPO_RECARGA_ATAQUE (1.2 segundos), DANIO_BASE_MELEE (15 puntos de daño).
  - Variable añadida: tiempos_ultimo_ataque (Dictionary para cooldown por jugador).
  - Señal añadida: ataque_procesado(id_jugador, resultado).
  - En _process: despacho de mensajes "attack" hacia _procesar_ataque().
  - Función _procesar_ataque(id, datos): validación autoritativa completa de jugador existente, objetivo válido y activo, cooldown de ataque, rango de distancia euclídea (pos_jugador a pos_entidad <= 4.5m). Reducción de HP, actualización de estado a "muerto" y activo=false si vida <= 0, y difusión en red con entity_updated. Respuesta al atacante con paquete attack_result (éxito/daño/vida restante/estado o motivo de rechazo: out_of_range, on_cooldown, target_dead, invalid_target).
  - Protección de socket desconectado en _enviar() y _enviar_texto() para estabilidad en pruebas y desconexiones.
  - IA del lobo (_actualizar_ia_entidades): validación de que el lobo esté activo y no muerto antes de mover su patrulla.
- Multijugador.gd:
  - Añadida señal resultado_ataque(datos).
  - Manejo de mensaje de red "attack_result" emitiendo resultado_ataque.
  - En _unhandled_input(): mapeo de la acción ability_1 (tecla 1) para llamar a atacar_objetivo().
  - Función atacar_objetivo(): envía paquete JSON {"type": "attack", "target_id": id_objetivo} si hay objetivo fijado y conexión activa.
- Main.gd:
  - Añadido indicador de combate en pantalla (etiqueta_combate) con tween de desvanecimiento dinámico.
  - Conexión de señal resultado_ataque hacia _al_resultado_ataque().
  - Feedback visual: texto con daño infligido y vida restante del objetivo, mensaje especial al derrotar al objetivo, y avisos de error claros ("¡Objetivo fuera de alcance!", "Ataque en tiempo de recarga...", "El objetivo ya está muerto").
  - Controles de HUD actualizados: "1: atacar".
- herramientas/PruebaCombate.gd:
  - Nueva suite de prueba unitaria que verifica: objetivo inválido, ataque fuera de rango (out_of_range), ataque exitoso melee con daño y vida correcta, cooldown inmediato (on_cooldown), golpe letal y transición a estado muerto con activo=false, y rechazo de ataque sobre cadáver (target_dead).

Comprobado:
- herramientas/PruebaCombate.gd: código 0 (todas las aserciones exitosas).
- herramientas/PruebaTargeting.gd: código 0.
- herramientas/PruebaEstadoEntidades.gd: código 0.
- herramientas/PruebaNPCServidor.gd: código 0.
- herramientas/PruebaFabricaEntidades.gd: código 0.
- Los 12 scripts del proyecto pasan --check-only con código 0.
- Escena principal Mapa1/Escena1.tscn en headless arranca sin errores (código 0).

No probado:
- Partida con dos clientes y combate simultáneo.
- Animación procedural de ataque con espada en Jugador.gd.


## 21. HITO FASE 6 — CORRECCIÓN DE ENVÍO DE COMBATE Y ANIMACIÓN PROCEDURAL DE ESPADA — 02/11/2026

Incidencia detectada y resuelta:
- Al presionar '1', el ataque no se enviaba porque `Multijugador.gd` llamaba a `cliente.send_text()`, función inexistente en `WebSocketMultiplayerPeer` (debe usar `put_packet`).
- Si el usuario pulsaba '1' sin objetivo o con teclado numérico, no había feedback descriptivo.

Cambios aplicados:
- `scripts/cliente/Multijugador.gd`:
  - Reemplazado `cliente.send_text(...)` por `cliente.put_packet(JSON.stringify(mensaje).to_utf8_buffer())`.
  - Captura ampliada en `_unhandled_input`: detecta `ability_1`, `KEY_1` y `KEY_KP_1` (físico y lógico).
  - Al no haber objetivo (`id_objetivo <= 0`), emite inmediatamente `resultado_ataque` con `reason = "no_target"`.
  - Si no está conectado, emite `reason = "not_connected"`.
  - Disparo de `animar_ataque()` en `jugador_local` para feedback visual instantáneo.
- `Jugador.gd`:
  - Variables de combate procedural: `tiempo_ataque`, `DURACION_ATAQUE = 0.35`.
  - Función pública `animar_ataque()`.
  - En `_animar(delta)`: arco de corte sinuidal en X/Z para `brazo_der` y `espada` (`arco_corte * 1.6`) con giro de torso sincronizado (`torso.rotation.y + arco_corte * 0.22`).
- `Main.gd`:
  - Añadido feedback descriptivo para `"no_target"` ("¡No tienes un objetivo seleccionado! Pulsa Tab para fijar uno") y `"not_connected"`.
- `herramientas/PruebaAnimacionCombate.gd`:
  - Nueva suite de prueba unitaria que verifica la animación de espada y el despacho de `resultado_ataque` sin objetivo (código 0).

Comprobado:
- `herramientas/PruebaAnimacionCombate.gd`: código 0.
- `herramientas/PruebaCombate.gd`: código 0.
- `herramientas/PruebaTargeting.gd`: código 0.
- `herramientas/PruebaEstadoEntidades.gd`: código 0.
- `herramientas/PruebaNPCServidor.gd`: código 0.
- `herramientas/PruebaFabricaEntidades.gd`: código 0.
- Los 14 scripts del proyecto pasan `--check-only` con código 0.
- Escena principal `Mapa1/Escena1.tscn` en headless arranca y finaliza con código 0.

No probado:
- Partida con dos clientes y combate simultáneo.
- Respawn autoritativo de criaturas en Servidor.gd tras morir.


## 22. HITO FASE 6 — REAPARICIÓN AUTORITATIVA (RESPAWN) DE CRIATURAS — 02/11/2026

Cambios aplicados:
- `scripts/servidor/Servidor.gd`:
  - Constante de respawn: `TIEMPO_RESPAWN = 6.0` segundos.
  - Registro de parámetros de origen en `datos_spawn_original[id]` al crear la entidad.
  - Al morir la entidad en `_procesar_ataque()`, se inicia el temporizador en `temporizadores_respawn[target_id] = TIEMPO_RESPAWN`.
  - Rutina periódica `_actualizar_respawn(delta)`: al expirar el temporizador, restaura la vida a `hp_max`, el estado a `patrullando`, `activo = true` y sus coordenadas iniciales, transmitiendo `entity_updated` a la red.
  - El lobo reinicia su índice de patrulla al volver a la vida.
  - Limpieza de datos en `_eliminar_entidad(id)`.
- `herramientas/PruebaCombate.gd`:
  - Ampliada la suite para verificar que la muerte de la criatura programa su respawn y que `_actualizar_respawn()` restablece al lobo con 60 HP y estado patrullando (código 0).

Comprobado:
- `herramientas/PruebaCombate.gd`: código 0 (7/7 aserciones exitosas).
- `herramientas/PruebaAnimacionCombate.gd`: código 0.
- `herramientas/PruebaTargeting.gd`: código 0.
- `herramientas/PruebaEstadoEntidades.gd`: código 0.
- `herramientas/PruebaNPCServidor.gd`: código 0.
- `herramientas/PruebaFabricaEntidades.gd`: código 0.
- Los 15 scripts del proyecto pasan `--check-only` con código 0.
- Escena principal `Mapa1/Escena1.tscn` en headless arranca sin errores (código 0).

No probado:
- Partida con dos clientes y combate simultáneo.

## Verificacion interactiva de dos clientes — 02/11/2026

Resultado confirmado por el usuario: servidor headless y dos clientes graficos iniciaron; el usuario verifico movimiento y combate entre ambos y reporto que todo funciona correctamente.

Alcance: verificacion interactiva confirmada por el usuario. No se inspeccionaron los archivos de log de esta ejecucion. No se modifico codigo ni se hicieron operaciones Git.

Siguiente paso: continuar el desarrollo MMORPG desde el estado actual; considerar completada esta prueba de dos clientes y conservar mejoras de arte, persistencia y seguridad como tareas separadas.

## Actualizacion del lanzador y prueba multijugador — 02/11/2026

- El usuario confirmo que dos clientes graficos funcionaron simultaneamente: movio ambos personajes, probo combate cooperativo contra el lobo y confirmo que el ciclo completo funciono.
- Se actualizo herramientas/iniciar_juego.ps1 para lanzar el servidor mediante escenas/servidor/Servidor.tscn, esperar la confirmacion de inicio, abrir uno o dos clientes, separar los logs y cerrar los procesos al terminar.
- La prueba manual de juego fue confirmada por el usuario. El lanzador actualizado no se ejecuto por separado tras editarlo; queda pendiente su validacion inicial.
- No se modificaron otros archivos de codigo ni se hicieron operaciones Git.

## Fase 7 — primera rebanada de inventario (02/11/2026)

Estado: implementacion escrita; falta comprobarla en ejecucion.
- Catalogo compartido con el objeto Colmillo de lobo y limite de pila 20.
- El servidor mantiene inventario por conexion, otorga un colmillo al jugador que asesta el golpe final al lobo y envia snapshot/actualizaciones.
- El cliente recibe el estado y muestra nombre/cantidad en un panel del HUD.
- Inventario no persistente: se reinicia al desconectar; no hay espacios, equipamiento, uso ni iconos todavia.
- Revision estatica del cableado completada. No se ejecuto Godot ni se agregaron/ejecutaron pruebas; la funcionalidad de inventario no se considera verificada.

Siguiente paso: validacion interactiva con dos clientes: matar el lobo, comprobar que el atacante final recibe un colmillo y que el panel muestra la cantidad; verificar que el otro jugador no lo recibe y que respawn no duplica el premio.

## Verificacion de sintaxis del inventario inicial — 02/11/2026

- Godot 4.7.2 --check-only: Servidor.gd, Multijugador.gd, Main.gd y CatalogoObjetos.gd finalizaron con codigo 0.
- Parser de PowerShell: herramientas/iniciar_juego.ps1 sin errores de sintaxis.
- Esto valida el parseo, no la ejecucion del servidor ni el premio/render del objeto. La verificacion interactiva del inventario sigue pendiente.

## Verificacion manual del inventario inicial — 02/11/2026

Confirmado por el usuario: ambos clientes recibieron un Colmillo de lobo en sus inventarios al derrotar lobos por separado. Esto verifica en juego la recompensa individual, su sincronizacion por cliente y la recepcion en la interfaz reportada por el usuario.

El codigo actual corresponde al resultado: la recompensa se agrega al ID del atacante que da el golpe letal; welcome incluye el inventario y el cliente procesa inventory_updated para actualizar el panel HUD.

No se recibieron logs de esta ejecucion. No se hicieron cambios de codigo tras la confirmacion ni se ejecuto una prueba adicional. La persistencia despues de desconectar continua pendiente; tambien queda como comprobacion adicional contrastar que el segundo cliente no recibe el objeto cuando no dio el golpe final en una misma pelea.

## CONTINUIDAD — FASE 7, EXPERIENCIA Y NIVELES (02/11/2026)

Implementacion escrita para la progresion temporal por sesion:
- El servidor otorga 25 XP al jugador que da el golpe letal a un lobo; el cliente no decide ni calcula la recompensa.
- El servidor conserva nivel y XP por conexion. Cada 100 XP aumenta un nivel y conserva el excedente; al desconectar se reinicia.
- El mensaje welcome incluye la progresion inicial y progression_updated comunica cambios.
- El cliente procesa ambos mensajes y muestra Nivel y XP en un panel del HUD.
- Se corrigio la indentacion del snapshot welcome para que el cliente cargue correctamente.

Comprobado tecnicamente el 02/11/2026: Godot 4.7.2 --check-only termino con codigo 0 en Servidor.gd, Multijugador.gd y Main.gd; git diff --check no reporta errores de espacios. No se ejecuto una sesion de juego de XP ni pruebas funcionales. La recompensa de XP y el HUD quedan pendientes de confirmacion interactiva. Inventario y botin inicial siguen verificados por el usuario en la sesion anterior.

Proxima verificacion: matar lobos con dos clientes y confirmar que el que da cada golpe final gana 25 XP, que el otro no cambia y que el HUD actualiza; al acumular cuatro bajas, revisar el cambio a nivel 2 con 0/100. Fase 7 sigue abierta. Sin persistencia de inventario ni progresion.
## CONTINUIDAD — FASE 7, DAÑO ESCALADO POR NIVEL (02/11/2026)

Implementado en scripts/servidor/Servidor.gd: el daño cuerpo a cuerpo es 15 en nivel 1 y aumenta 2 por cada nivel superior. El servidor lee el nivel que conserva por conexión, calcula el daño y envía el valor aplicado en attack_result; Main.gd ya muestra el daño recibido. El cliente no puede elegir su daño. El bono de 2 es un valor inicial de balance, todavía no una decisión permanente.

Comprobado: Godot 4.7.2 --check-only terminó con código 0 para Servidor.gd después del cambio. No se ejecutaron pruebas ni partida funcional; no se ha confirmado en juego el daño de nivel 1 o superior. Fase 7 sigue abierta, con XP/HUD y progresión de combate pendientes de validación interactiva.
## FASE 7 — AVISO DE XP POR DERROTA (02/11/2026)

El resultado autoritativo `attack_result` incluye `xp_gained` para el golpe letal a un lobo. El HUD muestra el daño y el XP otorgado en el aviso de derrota. Otros objetivos no reciben XP con esta regla.

Godot 4.7.2 --check-only pasó en Servidor.gd y Main.gd. No se ejecutó una partida; el aviso y la recompensa XP siguen pendientes de confirmación interactiva.
## FASE 7 — AVISO DE SUBIDA DE NIVEL (02/11/2026)

El servidor añade al resultado del golpe letal `level_up` y `new_level`, comparando el nivel anterior y posterior a la XP otorgada. Si hubo subida, el HUD anuncia el nuevo nivel en el mismo mensaje de derrota. Si no hubo subida, conserva el aviso de daño y XP.

Godot 4.7.2 --check-only pasó en Servidor.gd y Main.gd. La presentación no se ha confirmado dentro de una partida; XP, subida de nivel y daño escalado siguen pendientes de verificación interactiva.
## FASE 7 — ANIMACIÓN DE ATAQUE EN CLIENTES REMOTOS (02/11/2026)

El usuario confirmó que el ciclo de XP, subida de nivel y daño escalado funciona en juego. Señaló un único problema restante: la animación de ataque se veía solo en el atacante.

Corrección implementada: tras validar un ataque exitoso, el servidor difunde `player_attack` a los demás jugadores, excluyendo al atacante. El cliente remoto busca el personaje por ID y llama a `animar_ataque()`. El bucle de actualización remota existente procesa su animación procedural.

Godot 4.7.2 --check-only pasó en Servidor.gd, Multijugador.gd y Jugador.gd. No se verificó todavía la nueva animación en partida. El ciclo XP/nivel/daño queda confirmado por el usuario; la animación remota queda pendiente.
## ACTUALIZACIÓN — ANIMACIÓN REMOTA CONFIRMADA Y BOTÍN AMPLIADO (02/11/2026)

El usuario confirmó que la animación de ataque ya se ve en el cliente observador. Queda resuelta en juego la sincronización visual del ataque exitoso.

Se añadió `piel_lobo` al catálogo compartido (material, pila máxima 10); el servidor la otorga junto a `colmillo_lobo` al atacante que derrota al lobo. Parseo de Godot 4.7.2 correcto en catálogo, servidor, cliente y Main.gd. La nueva piel todavía no se ha confirmado en una partida; el botín previo de colmillo y XP/progresión sí están confirmados por el usuario.
## PRUEBAS SOLICITADAS POR EL USUARIO — 02/11/2026

Se ejecutaron los siete scripts existentes con Godot 4.7.2: PruebaAnimacionCombate, PruebaCombate, PruebaDosClientesCombate, PruebaEstadoEntidades, PruebaFabricaEntidades, PruebaNPCServidor y PruebaTargeting; todos terminaron con código 0. Se reforzaron tres pruebas existentes con aserciones del mensaje player_attack, botín/XP al golpe final y asignación solo al jugador final; las tres ampliadas también pasaron.

Se inició un servidor headless y dos clientes gráficos. Ambos clientes conectaron y validaron la configuración del mundo según sus logs. Por instrucción del usuario, la comprobación visual de ataque remoto y botín en la interfaz queda a cargo del usuario; las ventanas siguen abiertas. No se ha registrado aún un ataque real de esos clientes después del cambio.
## Estado guardado — 02/11/2026

El usuario confirmó «todo funciona» tras su comprobación del cliente: combate/progresión, recompensas individuales de colmillo y piel, y animación de ataque visible en el otro cliente quedan confirmados en juego. Se cierra la comprobación visual anterior. No volver a abrir ni manejar clientes gráficos: el usuario pidió hacer personalmente esos chequeos.

Trabajo nuevo de Fase 7 ya escrito:
- Inventario con 20 ranuras, apilamiento por objeto y contador `usadas/20` en el HUD; lista dentro de un panel desplazable.
- El servidor rechaza un objeto nuevo si las ranuras están llenas y rechaza incrementos si la pila alcanzó su máximo; el cliente muestra el motivo recibido.
- Godot 4.7.2 `--check-only` pasó en CatalogoObjetos.gd, Servidor.gd, Multijugador.gd y Main.gd.
- La prueba automatizada de ranuras llenas y pila máxima todavía no se ha añadido/ejecutado. Tampoco se ha visto en juego el contador, el desplazamiento ni los avisos de rechazo.

Siguiente paso al retomar: añadir aserciones de servidor a `herramientas/PruebaCombate.gd`, ejecutar esa prueba, revisar `git diff --check` y actualizar este estado. Después, dejar al usuario la comprobación visual del panel de inventario. Fase 7 continúa; conservar los cambios locales y no hacer commit/push.
## DIRECCIÓN ACTUAL — DESARROLLO PARA UN JUGADOR (02/11/2026)

El usuario decidió completar primero ClassicRPG como RPG para un solo jugador. El modo de dos jugadores ya implementado y probado se mantiene preservado para una etapa posterior. No borrar ni reescribir scripts, escenas, sincronización, recursos o pruebas de red como parte de este cambio de prioridad.

Prioridades individuales: completar inventario y objetos, equipamiento, interacción con NPC, misiones, enemigos/IA, combate y progreso, contenido del mundo, y guardado/carga local. Los sistemas nuevos deben ser reutilizables cuando sea razonable y el flujo individual no debe exigir un segundo cliente.

Estado comprobado reciente: el usuario confirmó que combate/progresión, botín individual y animación remota funcionan. La capacidad de 20 ranuras pasó la prueba automatizada de apilado con inventario lleno, rechazo de objeto nuevo y máximo de pila. La comprobación visual del nuevo panel queda a cargo del usuario.

Siguiente tarea: auditar el flujo de inicio y las dependencias de red para definir cómo completar la experiencia individual sin exigir un segundo cliente; después implementar el siguiente sistema RPG prioritario. No abrir el cliente gráfico por el usuario. No commit ni push sin autorización.

## Fase 7 — vida, daño enemigo y reaparición del jugador (02/11/2026)

Implementado:
- Vida autoritativa del jugador: 100 HP. El lobo causa 10 de daño dentro de 2,5 m y puede volver a atacar cada 1,5 s.
- Al llegar a 0 HP, se bloquean movimiento y ataques, el servidor programa 5 s de espera y reaparece al jugador en su punto inicial con vida completa.
- La reaparición concede 2 s de protección. El estado y los eventos `player_health_updated` / `player_respawned` se comunican por la misma conexión actual, conservando el código multijugador.
- El cliente muestra una barra de vida, el daño recibido y la cuenta atrás; también recoloca a un personaje remoto al reaparecer.

Verificación automática del 02/11/2026 con Godot 4.7.2: los siete scripts de prueba existentes terminaron con código 0, incluida la prueba de dos clientes. `--check-only` pasó en Servidor.gd, Multijugador.gd, Jugador.gd, Main.gd y PruebaCombate.gd; `git diff --check` pasó. Además, un servidor headless y un cliente headless iniciaron, conectaron y validaron la configuración del mundo. Logs en `%TEMP%\ClassicRPG-headless-health-20261102`. No se abrió el cliente gráfico.

No afirmar que la barra o el contador quedaron comprobados visualmente: el usuario se reservó esa revisión. El daño, tiempo de espera y protección son valores iniciales de balance. El ciclo de vida del lobo, botín y progresión ya estaba preservado y la suite multijugador siguió pasando.

Siguiente: avanzar el flujo de RPG individual con objetos utilizables/equipamiento y una interacción de NPC/misión sencilla; después guardado/carga local. Mantener como comprobación pendiente la revisión visual de salud y del panel de inventario por el usuario. Conservar todos los recursos y pruebas multijugador; sin commit ni push.

## Inicio individual sin servidor externo — 02/11/2026

La escena normal ahora crea un nodo Servidor.gd dentro de Main antes de conectar Multijugador.gd; así el juego se abre como una sola partida y no depende de ejecutar otro proceso ni de abrir un segundo cliente. El lanzador herramientas/iniciar_juego.ps1 pasa `--servidor-externo` a sus clientes, por lo que sus pruebas con servidor dedicado y dos instancias siguen funcionando.

Comprobado: juego completo en headless sin servidor previo inicia el servidor integrado, conecta el cliente y valida el mundo; en modo `--servidor-externo`, cliente y servidor dedicado también conectan y validan. Las siete pruebas existentes pasan y el lanzador pasa el parser de PowerShell. El usuario sigue a cargo de cualquier revisión visual; no se abrió GUI.

## Fase 7 — primera misión individual (02/11/2026)

Se añadió «Caza de lobos»: seleccionar al Habitante con Tab y pulsar E cerca de él inicia la misión; derrotar tres lobos la completa y concede 50 XP adicionales. El servidor valida el objetivo y la distancia, mantiene progreso por jugador, incluye el estado en welcome y envía `quest_updated`. El HUD presenta el objetivo/progreso y avisos de aceptación, avance y recompensa. Los clientes externos conservan el mismo estado aislado por jugador.

La prueba PruebaCombate cubre interacción fuera de rango, aceptación cerca del NPC, contador de tres bajas, completado, 50 XP extra y 75 XP reportados en el golpe final. Godot 4.7.2 pasó las siete pruebas existentes (código 0), cinco chequeos estáticos y `git diff --check`. La escena carga y valida mundo headless en modo integrado y en modo de servidor externo. No se abrió GUI.

Pendiente visual a cargo del usuario: localizar al Habitante, aceptar con Tab + E, comprobar el panel de misión y el aviso de +50 XP. Próxima tarea de desarrollo: objetos utilizables/equipamiento, ampliación de misiones y guardado/carga local. Sin commit ni push.

## Fase 7 — consumible y equipo inicial (02/11/2026)

La misión «Caza de lobos» ahora entrega dos pociones curativas y la Espada del Habitante, además de 50 XP. La poción cura hasta 35 HP con límite en la vida máxima y solo se consume cuando tiene efecto; se usa con 2. La espada se equipa con Q, da +5 de daño y el servidor valida que el jugador la tenga antes de aplicarla. El HUD muestra el arma equipada y los avisos de uso/equipamiento. Los datos siguen siendo por conexión y todavía no persisten tras cerrar.

La prueba PruebaCombate verifica recompensa, curación parcial, rechazo al tener vida completa sin consumir, consumo de las dos pociones, equipamiento válido y daño de 22 a nivel 2 con espada. En Godot 4.7.2 pasaron las siete pruebas existentes, seis chequeos estáticos, parser PowerShell y `git diff --check`. Modo integrado individual y modo externo cargan mapa/HUD y validan la conexión en pruebas headless. No se abrió GUI.

Pendiente visual a cargo del usuario: comprobar Tab + E, panel de misión, pociones 2, espada Q, barra de salud y HUD de inventario. Próxima prioridad técnica: guardado/carga local de inventario, progreso, misión, equipo y estado del personaje; después ampliar contenido/misiones. Sin commit ni push.

## 18. Guardado local individual — actualización 02/11/2026

Estado del ciclo local:
- Modo individual: Main inicia el servidor local en el mismo proceso y el jugador se conecta sin un segundo proceso o cliente.
- Guardado: `Servidor.gd` escribe `user://classicrpg_partida.json` solo cuando `modo_individual` está activo.
- Datos incluidos: última posición y orientación, salud, inventario, nivel/XP, estado/contador de misión y equipo.
- Frecuencia: autosave cada 10 segundos, además de cambios RPG, daño/respawn, desconexión y cierre.
- Carga: al conectar el jugador; las estructuras cargadas se validan y normalizan. Una partida guardada con el jugador derrotado se restaura con vida completa.
- Modo externo: permanece sin persistencia local; la comprobación confirmó que no crea archivos.

Archivos modificados en esta tarea: `scripts/servidor/Servidor.gd` y `herramientas/PruebaCombate.gd`. La prueba añadió una ronda de guardado/carga con un nombre temporal único en `user://` y limpió ese archivo al finalizar. No se modificó `classicrpg_partida.json`.

Verificación Godot 4.7.2: las siete pruebas (`PruebaTargeting`, `PruebaNPCServidor`, `PruebaFabricaEntidades`, `PruebaEstadoEntidades`, `PruebaDosClientesCombate`, `PruebaCombate` y `PruebaAnimacionCombate`) terminaron con código 0. Siete scripts pasaron `--check-only`. La prueba de guardado restauró posición, yaw, HP, inventario, progresión, misión y espada; no quedaron archivos temporales.

La Fase 7 sigue activa por contenido y sistemas todavía pendientes. La persistencia local básica quedó implementada y comprobada; no equivale a persistencia del mundo, varios perfiles o cuentas, que quedan fuera de la prioridad individual actual. El usuario hará la revisión visual de los paneles y controles. Siguiente tarea: ampliar el contenido individual con una segunda misión basada en la entrega de materiales, conservando las pruebas y el modo multijugador externo.

## 19. Segunda misión y prueba de partida individual — 02/11/2026

Se añadió la continuación «Entrega de pieles» al Habitante después de completar «Caza de lobos». El jugador entrega tres pieles de lobo; se valida el objetivo/NPC, la distancia, el estado de misión y la cantidad disponible. Una entrega incompleta no consume materiales; una válida consume exactamente tres, conserva cualquier sobrante y da 75 XP. El HUD diferencia recolección, retorno al NPC y misión completada. La etapa de misión también se guarda en el archivo local.

Se creó `herramientas/PruebaPartidaIndividual.gd`: carga `Mapa1/Escena1.tscn` headless, confirma que el servidor local y un único cliente conectan y validan el mundo, y confirma que el cierre guarda la partida. Usa un nombre temporal `user://` y lo elimina.

Verificación Godot 4.7.2: ocho pruebas pasaron con código 0 (las siete anteriores y la nueva prueba de partida individual); seis scripts pasaron `--check-only`; `git diff --check` terminó correctamente. La prueba de combate validó aceptación de la segunda misión, escasez sin consumo, progreso por botín, entrega exacta, XP sobrante y round-trip del estado completado. La prueba integrada validó la conexión local sin servidor externo ni segundo cliente.

No se abrió el juego gráfico. Sigue pendiente la revisión visual de paneles/controles por el usuario. Fase 7 continúa activa: falta ampliar las criaturas, misiones, habilidades, mundo y flujo de sesión, además de revisar balance. Los modos y pruebas multijugador se conservaron; no hubo commit ni push.

## 20. Recuperación segura de guardados — 02/11/2026

Se reforzó la lectura del JSON local. El parser maneja JSON dañado sin detener el juego; se ignoran versiones distintas a la 1 y se normalizan tipos/rangos para inventario, XP/nivel, misión, salud, equipo, posición y yaw. Valores no numéricos o estructuras inesperadas se descartan o sustituyen por valores iniciales seguros.

`herramientas/PruebaCombate.gd` ahora prepara solo en un archivo temporal `user://` tres casos adicionales: JSON corrupto, versión desconocida y diccionarios/campos mal formados. Comprueba la recuperación, limpia el temporal y conserva la prueba anterior de round-trip. No modifica `classicrpg_partida.json`.

Verificación Godot 4.7.2: las ocho pruebas pasan con código 0; seis scripts pasaron `--check-only`; `git diff --check` terminó correctamente. Incluye la conexión de un solo cliente al servidor local integrado y el test automatizado de dos clientes. Los temporales se limpiaron y el archivo de partida permanente no existe ni fue creado.

La Fase 7 sigue activa. Siguiente prioridad: desarrollar más contenido de la primera zona (criaturas/misiones/habilidades) y completar el flujo de sesión. El usuario mantiene la revisión visual; no abrir GUI. Preservar multijugador y cambios locales; sin commit ni push.

## 21. Reanudación entre sesiones comprobada — 02/11/2026

La prueba `herramientas/PruebaPartidaIndividual.gd` ahora realiza dos sesiones completas en el mismo proceso headless: inicia la escena real con servidor integrado y un único cliente, modifica estado de prueba, cierra la escena para guardar, la vuelve a abrir y verifica los datos recibidos en el cliente y el HUD.

Se restauraron y verificaron: posición, inventario, nivel/XP, HP, misión activa con 2/3 pieles, arma equipada y texto visible del panel de misión. El guardado usa una ruta temporal `user://` única; se limpió tras la prueba. El archivo de partida permanente no existe ni se modificó.

Validación final de este bloque: las ocho pruebas del proyecto pasaron con código 0; seis scripts pasaron `--check-only`; `git diff --check` pasó. La suite conserva las comprobaciones de dos clientes, combate cooperativo y animación remota. No se abrió cliente gráfico.

Estado: guardado/carga local inicial y reanudación individual están comprobados técnicamente. Falta ampliar contenido, habilidades, variedad de criaturas, balance y flujo de sesión más amplio; Fase 7 sigue activa. La revisión visual la hará el usuario. No commit ni push.

## 23. Habilidad activa: golpe pesado — 02/11/2026

Se incorporó la primera habilidad activa aparte del ataque normal. La tecla 3 envía el identificador golpe_pesado; el servidor valida habilidad, objetivo, vida, alcance y enfriamiento, duplica el daño base del personaje y aplica una recarga propia de seis segundos por jugador. Mantiene el enfriamiento general de 1,2 s compartido con el ataque normal. La tecla 2 sigue usando poción y Q sigue equipando.

El golpe tiene una animación procedural más larga y con mayor arco. El identificador se replica en player_attack para que las animaciones remotas usen el mismo movimiento; los eventos anteriores o ataques normales siguen usando la animación estándar. El HUD anuncia la tecla 3 y muestra la recarga restante o el daño y resultado del golpe.

Verificación Godot 4.7.2: siete pruebas funcionales unitarias pasaron; la prueba de dos jugadores confirmó que la recarga pesada de un cliente no bloquea al otro. La prueba integrada PruebaPartidaIndividual.gd envió el golpe por la conexión cliente-servidor local y comprobó 30 de daño al lobo a nivel 1; luego cerró/reabrió la escena y restauró la partida. Los scripts afectados pasaron --check-only y git diff --check no encontró errores de whitespace. Puerto 9000 libre tras la prueba; los guardados temporales se limpiaron. No se abrió GUI ni se tocó el guardado permanente.

La habilidad está comprobada por servidor, conexión local y animación. Quedan más habilidades, enemigos/actividades de zona, balance y revisión visual del usuario. Fase 7 continúa activa; preservar la base multijugador. Sin commit ni push.

## 24. Segunda criatura: jabalí del bosque — 02/11/2026

Se añadió el jabalí como entidad 4 en la primera zona (80 HP, patrulla propia y respawn). Su ataque autoritativo inflige 14 de daño a 2,6 m con recarga independiente de 2 s. Derrotarlo da 35 XP, un colmillo y una carne; ambos materiales ya están en el catálogo y usan la capacidad normal del inventario. El lobo conserva sus atributos, patrulla, botín y misión.

FabricaEntidades crea un modelo low-poly procedural distinto con cuerpo, cabeza, hocico, colmillos y patas. La misma representación se crea desde los datos de entidad compartidos, compatible con el cliente individual y la ruta de red.

Verificación Godot 4.7.2: las ocho pruebas del proyecto terminaron con código 0, incluida la de dos clientes y la escena individual de dos sesiones. PruebaCombate validó ataque, cooldown, botín, XP y respawn del jabalí; PruebaEstadoEntidades probó la patrulla; la fábrica comprobó sus nueve mallas. Once scripts pasaron --check-only y git diff --check pasó. La prueba integrada recibió al jabalí en el único cliente, envió el golpe pesado y reabrió la partida. Puerto 9000 libre; temporales limpiados; sin GUI ni cambios al guardado permanente.

Fase 7 sigue activa. Próximo: continuar la cadena de misiones usando los materiales nuevos, ampliar actividades/atributos y revisar el balance; la revisión visual continúa a cargo del usuario. Mantener el multijugador y no hacer commit ni push.

## Continuidad — misión de carne de jabalí verificada (02/11/2026)

La tercera misión de la cadena solicita 3 carnes de jabalí. Cuenta las existentes y el botín nuevo, no consume si faltan, mantiene sobrantes y recompensa 100 XP. Se conserva en la partida local. PruebaCombate.gd terminó con código 0 en Godot 4.7.2: cubre la misión, reanudación/restauración del estado completado, JSON corrupto/versión desconocida/campos malformados y combate/botín/respawn del jabalí. Los temporales del test se escriben en Documents/Codex por restricción de escritura user:// en este entorno; no se cambió la ruta de guardado permanente del juego. git diff --check pasó. Pendiente ejecutar el resto de la suite y la integración individual; fase 7 activa, sin commit/push, preservando multijugador.

## Reanudación individual verificada — 02/11/2026

PruebaPartidaIndividual.gd terminó con código 0 en Godot 4.7.2: inicia escena real con servidor local y un cliente, cierra y reabre, restaura inventario, nivel/XP, salud, misión activa, arma, posición y HUD. El archivo temporal se guarda y elimina en Documents/Codex por restricción del entorno; el guardado de producción sigue en user://classicrpg_partida.json. La prueba de combate también pasó con código 0 e incluye misión de 3 carnes de jabalí, entrega exacta/sobrantes, 100 XP, normalización/persistencia, recuperación de JSON malformado y loot/respawn. Seis pruebas adicionales (targeting, NPC, fábrica, estado, dos clientes y animación) pasaron. Próximo: correr chequeos sintácticos de todos los scripts, diff check y revisión visual del usuario; Fase 7 sigue activa, no es cierre final. Preservar modo multijugador y sin commit/push.

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

## Cierre de sesión — retorno al título validado (02/11/2026)

La prueba `herramientas/PruebaPartidaIndividual.gd` ejecuta el botón real «Guardar y volver al título» desde el panel de pausa: valida JSON temporal versión 1 con inventario y misión, espera la carga de `MenuInicio.tscn` y limpia el temporal. También establece `SceneTree.current_scene` durante el ciclo. Godot 4.7.2: las nueve pruebas funcionales de la suite terminaron con código 0; `--check-only` de la prueba, `Main.gd`, `MenuInicio.gd` y `Servidor.gd` exit 0; `git diff --check` pasó. No se abrió GUI ni se tocó el guardado de producción. La Fase 7 sigue activa; el usuario conserva la revisión visual del menú y HUD, y falta continuar contenido/balance y auditoría final.

## Fase 7 — Limo y quinta misión individual (02/11/2026)

✅ Añadido el Limo del Bosque como entidad 5 en la zona: 45 HP, ataque de 8, rango 2,1, recarga propia de 2,5 s, patrulla autoritativa y respawn de 6 s con vida completa. Al derrotarlo entrega una Gelatina de limo y 20 XP. La fábrica procedural crea su modelo low-poly y el catálogo reconoce el material.

✅ Tras reclamar las dos pociones de la misión de caza de jabalíes, hablar otra vez con el Habitante inicia la quinta misión: reunir y entregar 3 gelatinas. El servidor cuenta solo objetos realmente añadidos, limita el contador al objetivo, no consume entregas insuficientes y conserva sobrantes; completar otorga 120 XP. El HUD muestra el avance y la normalización de guardado/carga reconoce el estado activo y completado.

Verificación Godot 4.7.2: nueve pruebas funcionales exit 0, nueve chequeos `--check-only` exit 0 y `git diff --check` limpio. Incluye integración individual real que recibe el limo, pruebas de modelo/entidades, recompensa/entrega de misión, botín/XP/respawn y regresión de dos clientes. No se abrió GUI ni se tocó el guardado permanente. Fase 7 continúa; revisión visual del usuario, más contenido y balance/auditoría siguen pendientes.

## Relevo rápido — opción de descartar objeto (02/11/2026)

Se interrumpió la nueva tarea para preservar el uso restante. Hay cambios locales parciales y NO VERIFICADOS en `Main.gd` y `scripts/cliente/Multijugador.gd`: lista seleccionable de inventario, botón para descartar una unidad y envío/recepción del mensaje `discard_item`. El servidor no procesa todavía ese mensaje, así que la función no está terminada ni debe considerarse utilizable. No se corrió ninguna prueba después de esos cambios parciales. La última verificación completa anterior sigue siendo la de Limo del Bosque/quinta misión registrada arriba. Retomar inspeccionando el diff actual; implementar validación autoritativa y actualización de inventario/equipo/progreso de misión en `scripts/servidor/Servidor.gd`, ampliar `herramientas/PruebaCombate.gd` y la integración individual si procede, y ejecutar suite antes de marcarlo listo. Mantener Fase 7 abierta. Sin commit/push ni guardado de producción.

## Opción para descartar objetos — completada y comprobada (02/11/2026)

La interfaz presenta el inventario en una lista seleccionable y permite descartar una unidad del objeto elegido. El cliente transmite `discard_item`; el servidor valida que el objeto exista, esté en posesión y el personaje esté vivo, reduce una unidad, actualiza el inventario y persiste el cambio en modo individual. Al eliminar la última unidad del arma equipada, la desequipa y sincroniza el equipo. Si se descarta piel de lobo, carne de jabalí o gelatina durante su misión de entrega activa, actualiza el contador para que coincida con lo que queda.

Verificación con Godot 4.7.2: pruebas de servidor y UI cubiertas en `PruebaCombate.gd`; `PruebaPartidaIndividual.gd` recorrió selección en HUD, botón, WebSocket y estado coherente cliente/servidor. La sesión también volvió a abrir el guardado y regresó al menú. Las nueve pruebas de regresión pasaron con código 0, incluida la prueba de dos clientes; los chequeos `--check-only` de los scripts tocados pasaron; `git diff --check` pasó. Se corrigió el buscador de puertos locales para comprobar el mismo bind comodín que usa el servidor y avanzar desde el último puerto asignado; la integración usó 9001 y 9002. No se abrió GUI ni se tocó el guardado de producción; sin commit/push.

Fase 7 sigue abierta. Pendiente: revisión visual del usuario de menú, HUD, inventario y controles; seguir desarrollando y equilibrando la zona, y completar la auditoría de requisitos del ciclo individual. Preservar las pruebas y el código de dos jugadores.

Mejora de seguridad de interfaz (02/11/2026): el botón ahora abre un `ConfirmationDialog` en español antes de descartar; cancelar no cambia el inventario y confirmar continúa por el flujo validado. La integración individual pasó ambas ramas, el descarte WebSocket y el round-trip de guardado. Tras el ajuste, las nueve pruebas funcionales volvieron a terminar con código 0. `git diff --check` pasa. `git status --short` dio intermitentemente «this operation must be run in a work tree» aunque `git rev-parse` reconoce el repositorio; no se ejecutó ninguna operación Git que lo modifique. El último status legible mostró los cambios locales previos; no se descartó ninguno.

## Fuerza y Vitalidad — progresión de atributos (02/11/2026)

Cada nivel ganado entrega un punto de atributo, incluido retroactivamente para guardados viejos. El servidor valida las asignaciones de Fuerza (+2 daño cuerpo a cuerpo por punto) y Vitalidad (+10 vida máxima y actual por punto), mantiene los puntos gastados dentro del nivel, persiste los valores y rechaza nombres inválidos, falta de puntos o jugador derrotado. Vitalidad se refleja en vida, pociones y respawn; los atributos son parte del JSON de progresión. El HUD muestra valores, puntos y botones para asignarlos.

Verificación Godot 4.7.2: cinco `--check-only` pasan; `PruebaCombate` valida migración legacy, límites de puntos, daño, salud y rechazos; `PruebaPartidaIndividual` usa los dos botones por WebSocket y verifica que la segunda sesión restaura Fuerza, Vitalidad y vida máxima 110. La suite de nueve pruebas, incluida la de dos clientes, terminó con código 0. `git diff --check` pasa. No se abrió GUI ni se cambió el guardado permanente. `git status` continúa intermitente con error de worktree; no hubo operaciones Git mutativas.

Fase 7 sigue abierta: pendiente balance de progresión, revisión visual del usuario y auditoría general de la primera zona/ciclo individual.

## Economía inicial — estado comprobado (02/11/2026)

Se añadió un saldo de oro individual que el servidor entrega en cinco objetivos de misión: 30 por la caza del lobo, 15 por las pieles, 25 por la carne de jabalí, 30 por la caza de jabalíes y 35 por la gelatina. El Habitante vende la poción curativa a 20 de oro. La compra se valida en servidor (jugador vivo, proximidad, artículo permitido, saldo, capacidad de pila e inventario), y el saldo se guarda/restaura en el JSON local; un guardado anterior sin gold comienza con saldo 0. El HUD muestra el saldo y permite iniciar la compra.

Comprobación registrada: PruebaCombate.gd cubre límites del oro, compra/rechazos, saldo de la primera misión y guardado; PruebaPartidaIndividual.gd compra desde el HUD real por WebSocket y restaura saldo 20 y la poción en la siguiente sesión. La suite funcional de nueve pruebas pasó con Godot 4.7.2. PruebaCombate ya verifica los cinco pagos: los otros cuatro se comparan con el saldo leído inmediatamente antes de completar cada objetivo; la ejecución final terminó con código 0. No se abrió GUI ni se tocó la partida de producción.

Fase 7 sigue abierta. Próximo paso técnico: auditar requisitos y ritmo de la primera zona, continuar el balance y ampliar contenido según los huecos encontrados. Revisión visual de menú/HUD/controles sigue a cargo del usuario. Preservar multijugador; sin commit/push.

## Regresión actual antes de revisión gráfica (02/11/2026)

Godot 4.7.2 ejecutó las nueve pruebas funcionales con código 0: menú, targeting, NPC, fábrica, estado de entidades, combate de dos clientes, combate/misiones/inventario/progresión, animación y ciclo individual. La integración individual se ejecutó con loopback habilitado y verificó dos sesiones consecutivas, compra por HUD, oro, persistencia, atributos, misión restaurada y Guardar/volver al menú. La suite tuvo un primer intento 8/9 cuando el entorno no tenía habilitado loopback; la integración sola y luego la suite completa pasaron tras habilitarlo, sin cambiar código de producto.

La versión está lista para tu prueba gráfica en Godot 4.7.2: F5 abre MenuInicio.tscn y la nueva partida incluye servidor local integrado. Resultado de la revisión visual aún no recibido. Fase 7 permanece abierta por contenido, balance y auditoría; no tocar guardado de producción ni crear commit/push.
## 25. CIERRE DE AUDITORÍA Y PULIDO DE BALANCE — 02/11/2026

Estado técnico consolidado:
- Auditoría de balance completada: tabla de criaturas (lobo, jabalí, limo), progresión (Fuerza, Vitalidad, escalado), economía (135 oro de misiones, pociones por 20) y cadena de 5 misiones documentada en uditoria_fase7.md.
- Pulido de cierre de cadena: diálogo final narrativo al completar la 5.ª misión implementado en scripts/servidor/Servidor.gd.
- Suite automatizada: 9/9 pruebas funcionales pasadas con éxito en Godot 4.7.2.
- Chequeos de sintaxis: 0 errores en todos los scripts del núcleo.
- Guardado real intacto, sin commits ni push, multijugador preservado.
- Pendiente: revisión visual del usuario.
## 26. SELECCIÓN POR CLIC Y TOGGLE DE INVENTARIO (TECLA B) — 02/11/2026

- Controles de selección: selección con clic izquierdo implementada mediante rayo desde cámara en Camara.gd + Multijugador.gd. Selección secuencial con TAB intacta.
- Inventario: inicia cerrado por defecto; tecla B alterna visibilidad sin afectar lógica de guardado ni pruebas.
- Regresión automatizada: 10/10 pruebas funcionales pasadas en verde con Godot 4.7.2.
- Sin cambios en misiones, equipamiento ni lógica de compra. Sin commit ni push.
## 27. CURSOR GUANTELETE Y TARGETING DE RATÓN LIBRE — 02/11/2026

- Cursor: Guantelete medieval extraído con fondo transparente (64×64 px) en es://assets/cursores/guantelete_64.png con hotspot en la punta del índice (13, 1) configurado en project.godot.
- Controles ratón: Clic izquierdo ya no captura el cursor; lanza selección por rayo directa con cursor visible. Clic derecho mantiene rotación de cámara. TAB conserva su ciclo secuencial intacto.
- Suite de regresión: 10/10 pruebas pasadas en verde (100% OK) en Godot 4.7.2.

## 28. CURSOR POINT Y ROTACIÓN LIBRE CON ARRASTRE IZQUIERDO — 02/11/2026

- El cursor ahora usa `assets/cursores/Point.png`, copiado sin conversión desde Descargas; conserva su transparencia y tamaño nativo de 32×32 px. `project.godot` usa el archivo y el hotspot predeterminado `(0, 0)`, que coincide con la punta superior izquierda.
- `Camara.gd` conserva la selección por clic izquierdo y el giro con botón derecho. Un arrastre izquierdo que supera 4 px activa órbita libre; el estado existente de `Jugador.gd` mantiene la orientación del personaje independiente de la cámara.
- Comprobado con Godot 4.7.2: importación del PNG; `PruebaTargeting.gd`; prueba temporal de clic, umbral, giro libre, orientación del modelo del jugador durante física, giro derecho y asignación de TAB; prueba visual con una escena temporal, donde el cursor se mostró transparente y la cámara cambió de ángulo.
- Se retiraron los archivos temporales de prueba. No se abrió ni alteró el guardado de producción. Fase 7 sigue abierta. No se hizo commit ni push. La lectura final de Git quedó intermitente: `git status`/`git diff --check` devolvieron error de worktree aunque `.git` existe; no se ejecutaron operaciones Git mutativas.

## 29. POSICIÓN DEL CURSOR TRAS GIRAR LA CÁMARA — 02/11/2026

- La captura de ratón centraba el puntero; la primera reparación evitaba el centro pero podía reaparecer desplazado por mezclar coordenadas de viewport y píxeles de pantalla.
- `Camara.gd` transforma a coordenadas de ventana la posición donde empezó cada gesto: el clic inicial para la órbita izquierda y la pulsación para la derecha. La conserva sin sumar los movimientos del arrastre y llama a `Input.warp_mouse` al liberar. La lógica de giro y selección permanece intacta.
- Godot 4.7.2: la prueba headless de entradas sintéticas pasó para selección con clic, giro y retorno al punto inicial con ambos botones; `PruebaTargeting.gd` y `--check-only` de `Camara.gd` también pasaron. El modo headless valida la posición calculada y el estado, pero no el movimiento físico del cursor; la revisión visual queda a cargo del usuario.

## 30. HUD INICIAL DE FANTASÍA MEDIEVAL — 02/11/2026

- Se creó `scripts/cliente/HUDInicial.gd` como módulo ampliable con únicamente los seis elementos pedidos: retrato del caballero, vida, maná preparado, seis espacios de acción, marco del objetivo y minimapa.
- El retrato renderiza una copia del modelo `Modelo` del jugador local en un `SubViewport`. La vida y el nivel reciben el estado local; nombre y vida del objetivo usan los datos de `objetivo_cambiado`. El minimapa lee la posición global del jugador y el giro del modelo que representa su orientación.
- El maná queda vacío y marcado como preparado; no hay atributo ni sistema de maná. Los seis espacios son visuales sin acciones conectadas. Marcos de doble tono, remaches, patrón de cuero procedural y colores de metal, sangre y maná componen el estilo medieval; la valoración estética queda a cargo del usuario.
- `Main.gd` conserva sus callbacks y controles existentes, conecta la vida, progresión y objetivo al módulo y entrega el jugador local al retrato/minimapa. No se cambiaron movimiento, cámara, targeting, inputs ni `scripts/cliente/Multijugador.gd`.
- Verificación Godot 4.7.2: chequeos `--check-only` de HUDInicial, Main y PruebaHUDInicial; PruebaHUDInicial comprueba callbacks, datos de vida/objetivo, retrato, nivel, minimapa y seis espacios; PruebaTargeting e integración individual PruebaPartidaIndividual terminaron con código 0. No se abrió la ventana gráfica. Pendiente la revisión visual del usuario y la futura implementación de datos/acciones mágicas.

## 31. MODELO VISUAL QUATERNIUS — 02/11/2026

- Personajes/Jugador.tscn instancia el modelo ensamblado Male_Ranger.gltf bajo el nodo Modelo, conservando intacta la estructura y la escena de personaje existentes.
- Los 17 nodos raíz del modelo provisional permanecen en la escena, ocultos como respaldo. Las rutas usadas por Jugador.gd siguen resolviendo. No se modificaron scripts de movimiento, cámara, targeting, HUD o red; ni la cápsula, controles o física.
- Recursos del atuendo añadidos bajo assets/modelos/quaternius/modular_character_outfits_fantasy/: GLTF, BIN, 6 texturas, README y licencia CC0; Godot generó sidecars .import.
- El GLTF tiene 9 mallas, 2 materiales, 6 imágenes, 65 huesos de esqueleto humanoide y cero animaciones. El paquete Standard disponible incluye el atuendo masculino Ranger, no uno llamado Knight. Su cabeza/hood forma parte del ensamblado importado; UBC no es dependencia de runtime.
- Verificado con Godot 4.7.2 headless: importación y carga de Jugador.tscn, materiales con texturas, jerarquía y respaldo oculto, altura 1,869 m, pies en y≈0, colisión (altura 1,8 m/radio 0,42) y movimiento move_forward. PruebaHUDInicial.gd y PruebaTargeting.gd pasaron.
- No se abrió GUI: orientación y presentación visual quedan a cargo del usuario. El esqueleto queda listo para retarget posterior, pero el modelo visible todavía no reproduce movimiento/combate; tampoco incluye arma. Fase 7 sigue abierta. Sin commit ni push.

## 32. CUERPO FACIAL Y LOCOMOCIÓN QUATERNIUS — 02/11/2026

- La revisión técnica tras el reporte del usuario encontró que Male_Ranger.gltf sí importa sus 9 mallas y texturas; no es un modelo desactivado. El ensamblado no incluye cabeza/cara ni clips de animación. Jugador.gd seguía calculando las curvas procedurales, pero solo aplicaba rotaciones a los nodos provisionales ocultos, por lo que el esqueleto activo conservaba su pose T.
- El README de Modular Character Outfits indica que el atuendo ya cubre las piezas corporales visibles y que debe combinarse solo con la cabeza: añadir el cuerpo completo provoca clipping. La descarga UBC Standard local solo incluye cuerpo masculino de proporción Superhero, no Regular. Se evitó superponerlo al atuendo Regular.
- Se añadió Cabeza_Superhero_Male.glb, derivada de la geometría facial/cuello con pesos Head del UBC Standard masculino gratuito, junto con ojos y cejas. Sus cotas coinciden técnicamente con el hueco del capuchón. El modelo base y la licencia Standard originales se conservan en assets/modelos/quaternius/universal_base_characters_standard/.
- Jugador.tscn añade la cabeza bajo Modelo. Jugador.gd conserva el cálculo y el movimiento existentes y transmite sus curvas de reposo, marcha, carrera/sprint, salto, caída y aterrizaje a huesos humanoides nombrados del atuendo y de la cabeza. La pose T se baja mediante rotación de hombros; el esqueleto de la cabeza comparte los rests y poses de Head/columna del Ranger. No se tocó _physics_process ni cliente/servidor, colisiones, controles, cámara, HUD o targeting.
- Se añadió herramientas/PruebaModeloAnimacionesQuaternius.gd. Con Godot 4.7.2 se importaron los recursos, se verificaron mallas y texturas de cara, unión de rigs, brazos descendidos, zancada alterna, mayor amplitud de sprint, salto/caída diferenciados y compresión al aterrizar. Las 12 pruebas de herramientas/Prueba*.gd terminaron con código 0, incluidas dos sesiones de partida individual y combate de dos clientes. La prueba individual requirió habilitar loopback de red del entorno; entonces pasó sin cambios en código de red.
- No se abrió el juego ni se revisó visualmente. Pendiente la comprobación del usuario de cara bajo el capuchón, integración del conjunto y aspecto en movimiento. No hay clips de animación importados: la locomoción sigue siendo procedural. No se obtuvo el UBC Source de pago ni se añadió un cuerpo Regular subyacente; el atuendo sigue siendo la malla corporal visible del personaje. Fase 7 continúa abierta; sin commit/push.

## 33. ORIENTACIÓN Y ANIMACIONES UAL DEL JUGADOR — 02/11/2026

- Se corrigió el eje visual de Male_Ranger con el nodo `Modelo/VisualQuaternius`: el rig se alinea al vector horizontal de movimiento mediante interpolación; no se gira `Modelo` ni se invierten controles o fórmulas de movimiento. El giro lógico/de red permanece intacto.
- Se incorporó la descarga oficial Universal Animation Library Standard bajo `assets/modelos/quaternius/universal_animation_library_standard/`, conservando el ZIP original, GLB in-place, licencia CC0 y README. El GLB importado contiene Idle, Walk, Jog_Fwd, Sprint, Jump_Start, Jump y Jump_Land.
- `Jugador.gd` crea y activa un `AnimationTree` de máquina de estados al iniciar, usa `RetargetModifier3D` y un perfil de 65 huesos para animar el Ranger y la cabeza desde el rig UAL. El BlendSpace2D cubre ocho direcciones; la edición Standard solo incluye un clip Walk compartido entre puntos, no ocho ciclos direccionales separados. No incluye Fall: se usa el ciclo Jump en el estado de caída. Los clips importados son in-place para no duplicar el desplazamiento que ya calcula el controlador.
- El estado de salto activa Jump_Start, pasa al ciclo aéreo, distingue descenso, reproduce Jump_Land y vuelve a locomoción; correr selecciona Jog_Fwd y sprint selecciona Sprint. Las curvas procedurales quedan como respaldo si la biblioteca no se carga y continúan disponibles para el modelo antiguo oculto.
- Se actualizó `herramientas/PruebaModeloAnimacionesQuaternius.gd`: Godot 4.7.2 verifica rig/cara y texturas, retarget real en cuerpo y cabeza, Idle y Walk, las ocho direcciones del BlendSpace, que el yaw lógico no cambie y transiciones de trote/sprint/salto/caída/aterrizaje. La prueba específica pasó sin errores; las 12 pruebas headless de `herramientas/Prueba*.gd` terminaron con código 0, incluidas combate, targeting, HUD, partida individual y dos clientes.
- No se abrió la interfaz gráfica ni se hizo revisión estética. El usuario comprobará dentro del juego que la orientación y los ciclos se perciban bien. Fase 7 sigue abierta; sin reset/clean, commit ni push.

## 34. LIMPIEZA DE ARCHIVOS ANTIGUOS — 02/11/2026

- Se eliminaron las copias locales `RESPALDO_*` y `*.bak` ya obsoletas, que estaban excluidas de Git y no se referenciaban desde recursos activos.
- Se retiraron los cursores alternativos `guantelete_32/64` y sus sidecars; el único cursor configurado es `assets/cursores/Point.png`.
- Se eliminó `node_3d.tscn`, una escena vacía de la plantilla inicial sin referencias ni uso como escena principal. Se conserva el modelo provisional oculto en `Personajes/Jugador.tscn` y se conservan los paquetes fuente originales de Quaternius.
- No se modificaron scripts de juego durante la limpieza. La última batería previa a esta limpieza había terminado 12/12 con código 0; la limpieza retiró solo recursos sin referencias y respaldos locales. No se hizo `reset` ni `clean`.
