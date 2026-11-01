# CLASSICRPG — ESTADO ACTUAL

Última actualización: 01/11/2026

Motor: Godot 4.7.2
Repositorio: https://github.com/loremaster23/ClassicRPG
Rama: main

## 1. Proyecto

MMORPG 3D de fantasía medieval en desarrollo.

Objetivo: construir un mundo multijugador persistente con personajes, combate, progresión, equipamiento y exploración.

Dirección artística:
- Fantasía medieval.
- Referencia visual principal: WoW Classic.
- Influencias de Skyrim, Harry Potter y Avatar.
- Identidad visual propia.

## 2. Estado Git comprobado

Última comprobación: 01/11/2026.

Rama: main

Último commit:
2b106a5 — Actualizar guía de continuidad y excluir respaldos.

Archivos modificados localmente:
- Jugador.gd
- Main.gd
- scripts/cliente/Multijugador.gd
- scripts/servidor/Servidor.gd

Archivos y carpetas sin seguimiento:
- assets/modelos/
- herramientas/
- memoria/
- scripts/compartido/GeneradorTerreno.gd
- scripts/compartido/GeneradorTerreno.gd.uid

Estos cambios no deben descartarse ni sobrescribirse.

La carpeta memoria/ todavía no está registrada en Git.

Este estado es una fotografía de la última comprobación. Volver a consultar Git antes de trabajar.

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

La auditoría inicial de arquitectura y scripts está avanzada.

El siguiente paso es decidir qué sistema desarrollar a continuación, teniendo en cuenta las limitaciones actuales y preservando los cambios locales.

Antes de modificar código:
- Revisar el estado real de Git.
- Identificar los archivos afectados.
- Definir el alcance.
- Obtener autorización cuando corresponda.

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
- Fase 5 — Mundo y entidades: ACTUAL. Prototipo de terreno existente; sistemas de entidades pendientes.
- Fase 6 — Combate: PENDIENTE.
- Fase 7 — Inventario y progresión RPG: PENDIENTE.
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