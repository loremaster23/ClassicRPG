# CONTINUAR CLASSICRPG

Quiero que continúes el desarrollo de ClassicRPG como RPG 3D para un solo jugador, conservando íntegra la base multijugador para una etapa futura.

Proyecto:
C:\Users\Bruker\OneDrive\DESARROLLO_RPG\ClassicRPG

Repositorio:
https://github.com/loremaster23/ClassicRPG

Motor:
Godot 4.7.2.

## ANTES DE TRABAJAR

Leer:

1. memoria/LEEME_PRIMERO.md
2. memoria/ESTADO_ACTUAL.md
3. memoria/REGLAS_IA.md
4. memoria/DECISIONES.md
5. memoria/PENDIENTES.md
6. memoria/HISTORIAL.md
7. GUIA_CONTINUIDAD_CLASSICRPG.txt

Después inspeccionar el estado real del proyecto.

## OBJETIVO

Continuar exactamente donde quedó el desarrollo.

No empezar de cero.

No perder avances.

No sobrescribir trabajo local.

No modificar archivos sin autorización.

## DIRECCIÓN ACTUAL

Completar primero el RPG para un solo jugador. No eliminar ni reemplazar código, escenas, recursos o pruebas existentes para dos jugadores. Aplazar nuevas funciones exclusivamente online hasta que el usuario decida retomar esa etapa. El flujo individual final no debe exigir un segundo cliente.

## PROTOCOLO DE MEMORIA

Debés actualizar la memoria después de cada tarea importante.

No esperar a que el usuario lo solicite.

Registrar:
- Qué querías conseguir.
- Qué modificaste.
- Qué archivos afectaste.
- Qué probaste.
- Qué resultado obtuviste.
- Qué errores encontraste.
- Qué falta hacer.
- Cuál es el siguiente paso.

No considerar terminada una tarea importante hasta actualizar su memoria.

## COMUNICACIÓN

Responder en español.

Ser breve y directo.

Avanzar paso a paso.

Esperar resultados antes de continuar.

## PRIMERA ACCIÓN

Comprobar el estado real del proyecto y explicar brevemente:

1. Qué está implementado.
2. Qué cambios locales existen.
3. Qué tareas están pendientes.
4. Cuál es el siguiente paso recomendado.

No modificar nada hasta recibir autorización.

## PROTOCOLO OBLIGATORIO DE POWERSHELL

Siempre que una IA proporcione comandos para ejecutar en PowerShell:

1. Debe entregar comandos completos y listos para ejecutar.
2. Debe incluir un mecanismo para copiar automáticamente la salida al portapapeles.
3. Debe mostrar la salida en pantalla y copiarla al mismo tiempo.
4. Debe utilizar sintaxis compatible con Windows PowerShell 5.1.
5. No debe pedir al usuario que seleccione y copie manualmente los resultados.
6. Debe esperar a que el usuario comparta el resultado antes de continuar.

Formato recomendado:

& {
    # COMANDOS DE LA TAREA
} *>&1 | Tee-Object -Variable resultado

($resultado | Out-String) | Set-Clipboard

Este protocolo es una instrucción permanente para todas las IA que
trabajen en este proyecto. Deben respetarlo siempre que proporcionen
comandos de PowerShell.

## CONTINUIDAD — AUDITORÍA TÉCNICA 01/11/2026

### Situación del proyecto

Proyecto: ClassicRPG.
Motor: Godot 4.7.2.
Ruta: C:\Users\Bruker\OneDrive\DESARROLLO_RPG\ClassicRPG
Repositorio: https://github.com/loremaster23/ClassicRPG
Rama: main.

La auditoría técnica inicial está realizada. Fue principalmente una inspección estática de escenas, scripts, configuración y arquitectura. No significa que todos los sistemas estén terminados ni que se hayan repetido todas las pruebas funcionales.

### Escena y estructura

- Escena inicial configurada: res://Mapa1/Escena1.tscn.
- Main.tscn también existe, pero no se encontró una referencia activa a ella.
- Main.gd construye el entorno, iluminación, terreno, camino, bosque, rocas, personaje, HUD y conexión multijugador.
- Personajes/Jugador.tscn es la escena común del personaje local y los remotos.

### Personaje

- Raíz CharacterBody3D.
- Modelo compuesto por mallas primitivas.
- No se encontraron Skeleton3D, AnimationPlayer ni AnimationTree.
- Jugador.gd implementa animaciones procedurales mediante GDScript: movimiento, carrera, salto, caída, aterrizaje, reposo y movimiento de partes del cuerpo.
- scripts/cliente/Jugador.gd existe, pero no se encontraron referencias activas. No eliminarlo sin investigar.

### Cámara y controles

- Camaras/Camara.tscn y Camara.gd implementan cámara orbital en tercera persona.
- Incluye seguimiento suave, zoom mediante rueda y raycast.
- Clic izquierdo y derecho activan modos equivalentes en el código inspeccionado.
- Input Map incluye movimiento, salto, sprint, cámara, interacción, habilidades, selección de objetivo y menú.
- Algunas acciones no tienen usos activos detectados.
- El HUD anuncia controles que no tienen implementación confirmada.
- No se confirmó un mapeo específico de mando en project.godot. No asumir que Godot no recibe entradas de mando.

### Mundo procedural

- Generador compartido: scripts/compartido/GeneradorTerreno.gd.
- Tamaño del mundo: 110.
- Resolución: 44.
- Límite configurado: 80 árboles y 24 intentos de roca.
- Usa semillas determinísticas y genera un camino curvo.
- Main y servidor utilizan el generador compartido.
- La validación del mundo compara parámetros y cantidades, no las mallas completas.

### Multijugador existente — conservar; ampliaciones aplazadas

El bloque siguiente describe la arquitectura ya construida. Sus limitaciones quedan en el backlog futuro; no son la prioridad de desarrollo actual.



Cliente:
- scripts/cliente/Multijugador.gd.
- WebSocket configurado en ws://127.0.0.1:9000.
- Envío de movimiento cada 0,1 segundos.
- Sincroniza posición, yaw, sprint y salto.
- Crea personajes remotos e interpola posición y yaw.
- Aplica correcciones del servidor.
- Incluye validación de configuración del mundo.
- Si la validación falla, no bloquea por sí sola el movimiento.
- No se encontró reconexión explícita ni predicción y reconciliación completas.
- La interpolación se dirige al último objetivo sin búfer temporal.

Servidor:
- scripts/servidor/Servidor.gd.
- Capacidad configurada: 2 jugadores.
- Valida parcialmente posición, límites y velocidad.
- Confía en el indicador de sprint declarado por el cliente; todavía no es completamente autoritativo.
- No se encontró autenticación ni persistencia.
- Se observó discrepancia entre el spawn del servidor (x=0) y la posición inicial aproximada del cliente (x=2,67).

### Estado Git conocido

Última comprobación:
- Rama main.
- Último commit: 2b106a5 — Actualizar guía de continuidad y excluir respaldos.
- Modificados localmente: Jugador.gd, Main.gd, scripts/cliente/Multijugador.gd y scripts/servidor/Servidor.gd.
- Sin seguimiento: assets/modelos/, herramientas/, memoria/, scripts/compartido/GeneradorTerreno.gd y su archivo .uid.

Este estado es histórico: comprobar Git antes de cualquier operación futura. No descartar cambios locales ni ejecutar reset, clean o checkout destructivos.

### Documentación actualizada

- memoria/ESTADO_ACTUAL.md
- memoria/PENDIENTES.md
- memoria/HISTORIAL.md
- memoria/CONTINUAR_CON_IA.md

No se modificó código durante esta actualización documental. No se realizó commit ni push.

### Próxima continuación

La auditoría inicial está terminada. El siguiente paso es decidir qué sistema desarrollar y definir un alcance concreto.

Antes de implementar:
1. Revisar el estado actual de Git.
2. Identificar los archivos que resultarían afectados.
3. Explicar el resultado esperado.
4. Preservar todos los cambios locales existentes.
5. No confundir inspección de código con funcionamiento comprobado.
6. Actualizar la documentación de memoria con resultados reales.

Sistemas que siguen pendientes:
- Mejorar el modelo 3D y evaluar su integración.
- Evaluar Skeleton3D, rigging y animaciones esqueléticas.
- Revisar cámara y controles anunciados en el HUD.
- Implementar sistemas de juego MMORPG.
- Mejorar la arquitectura y seguridad multijugador.
- Desarrollar el mundo y sus regiones.

No comenzar una implementación nueva hasta definir su alcance y los archivos afectados.

## MODO DE TRABAJO AUTÓNOMO Y AUTORIZACIÓN

- Trabajar de forma autónoma y continua: la IA decide el siguiente paso técnico lógico, lo ejecuta, verifica el resultado, documenta el avance y continúa.
- No preguntar al usuario qué tarea realizar después ni solicitar confirmación para pasos rutinarios dentro del alcance acordado.
- La autorización del usuario se considera afirmativa por defecto: siempre sí. No detener el trabajo esperando respuestas como «sí», «continúa» o equivalentes.
- Un mensaje que contenga únicamente `'` significa autorización afirmativa inmediata: sí, ya, continuar.
- Investigar y resolver errores de forma autónoma, tomando decisiones técnicas razonables.
- Mantener siempre visible la fase actual del proyecto y señalar con ✅ los avances completados y verificados. No marcar como completado algo que no se haya probado.
- Mantener actualizada la documentación de continuidad y elegir automáticamente la siguiente tarea al terminar.
- Para instrucciones que requieran intervención en el PC del usuario, proporcionar un único comando PowerShell 5.1 cada vez, mostrar su salida y copiarla automáticamente al portapapeles. Esperar únicamente el resultado necesario para continuar, nunca una decisión rutinaria.
- Preservar todo el trabajo local y los cambios existentes. No descartar ni sobrescribir modificaciones.
- Detenerse únicamente ante acciones destructivas o irreversibles, riesgos nuevos importantes o ampliaciones sustanciales del alcance que requieran una salvaguarda específica.
- No afirmar que se ejecutó, verificó o modificó algo si realmente no se hizo.

OBJETIVO: que ClassicRPG avance como un proyecto de desarrollo continuo, sin que el usuario tenga que dirigir cada paso ni autorizar repetidamente las tareas habituales.

## ESTADO DE CONTINUIDAD — FASE 5 — 01/11/2026

### Fases oficiales

El usuario ha decidido dar por completadas para continuar todas las fases anteriores a la Fase 5.

- Fase 1: completada.
- Fase 2: completada según pruebas históricas.
- Fase 3: completada según pruebas históricas.
- Fase 4: aceptada como completada para continuar por decisión del usuario.
- Fase 5: actual, pendiente.
- Fases 6–9: pendientes.

No volver a solicitar pruebas multijugador de dos clientes para desbloquear la continuidad. El usuario ha decidido aceptar el sistema existente para avanzar. No afirmar que se repitió esa prueba.

### Estado técnico confirmado en esta revisión

- Escena inicial: Mapa1/Escena1.tscn, con Main.gd.
- Personaje: Personajes/Jugador.tscn, con Jugador.gd.
- Cámara: Camaras/Camara.tscn, con Camara.gd.
- Personaje actual: CharacterBody3D y geometría de mallas primitivas.
- Animación: procedural mediante GDScript.
- Input Map: movimiento, salto, sprint, cámara, selección de objetivo, interacción, habilidades 1–6 y menú.
- Mundo: generador procedural compartido.
- Multijugador: cliente y servidor WebSocket en puerto 9000, capacidad configurada para dos jugadores.

No asumir que selección de objetivo, interacción o habilidades están implementadas solo porque existan acciones en Input Map.

### Fase 5 — Mundo y entidades

El código activo revisado no muestra todavía módulos identificables de NPC, enemigos, IA ni entidades compartidas.

Próximo trabajo recomendado:
1. Comprobar de nuevo Git y preservar todos los cambios locales.
2. Examinar la estructura real de escenas, nodos y recursos del mundo.
3. Diseñar una arquitectura de entidades compatible con el servidor multijugador actual.
4. Implementar primero una entidad de prueba sencilla y su ciclo de aparición/desaparición.
5. Añadir NPC y enemigos sobre esa base.
6. Verificar y documentar cada avance antes de ampliar el alcance.

No comenzar modificando múltiples sistemas a la vez.

### Reglas

- Mantener el proyecto existente; no empezar de cero.
- No sobrescribir cambios locales.
- No modificar ni eliminar respaldos sin motivo.
- No realizar commits ni push sin autorización explícita.
- Mantener un único paso PowerShell por mensaje y copiar su salida al portapapeles.
- Actualizar los documentos de memoria tras cada tarea importante.
- Mantener visible la fase actual.


## HITO FASE 5 — ENTIDADES SINCRONIZADAS — 01/11/2026

Estado al continuar:
- Servidor y primer cliente iniciados correctamente con los scripts actualizados.
- El servidor registra la entidad prueba, ID 1.
- El cliente recibe la entidad por welcome y muestra una esfera azul.
- El usuario confirmó que ve la esfera.
- Fase actual: Fase 5 — Mundo y entidades.

Siguiente tarea técnica:
1. Implementar una forma controlada de solicitar desde el servidor la aparición y eliminación de entidades de prueba.
2. Verificar los mensajes dinámicos entity_spawned y entity_removed en ejecución.
3. Después, diseñar la base común de entidades para NPC y criaturas.

No declarar terminada la Fase 5. No hacer commits ni push. Preservar todos los cambios locales.


## ACTUALIZACION DOCUMENTAL FASE 5 - 01/11/2026

## CONTINUIDAD ACTUALIZADA - FASE 5 - 01/11/2026

Estado tecnico:
- Proyecto: ClassicRPG.
- Godot: 4.7.2.
- Rama conocida: main.
- Fase actual: Fase 5 - Mundo y entidades.
- Ultimo commit conocido: 2b106a5. No crear commits ni hacer push sin autorizacion explicita.
- Preservar todos los cambios locales y respaldos.

Entidades sincronizadas:
- El servidor mantiene el registro y asigna identificadores.
- welcome incluye el snapshot de entidades.
- El cliente procesa entity_spawned y entity_removed.
- Prueba dinamica real completada: entidad ID 2 creada y eliminada.
- Servidor y cliente registraron ambos eventos.
- El usuario confirmo visualmente las dos esferas y la desaparicion de la segunda.
- Codigo temporal de prueba retirado.
- Funciones permanentes _registrar_entidad() y _eliminar_entidad() conservadas.
- Copia de seguridad: scripts/servidor/Servidor.gd.bak_limpieza_prueba_dinamica.
- Servidor limpio iniciado correctamente, PID 17324.
- El servidor sigue registrando una entidad inicial de prueba ID 1.

Siguiente tarea:
1. Inspeccionar la implementacion permanente de entidades en servidor y cliente.
2. Disenar una estructura comun reutilizable para NPC y criaturas.
3. Separar datos de red y representacion visual.
4. Implementar primero una entidad de mundo real sencilla.
5. Verificar cada cambio antes de ampliar el sistema.

No declarar terminada la Fase 5. No confundir la esfera de prueba con un NPC o enemigo funcional.

Reglas de trabajo:
- Continuar en espanol.
- Un solo comando PowerShell por paso, compatible con Windows PowerShell 5.1.
- Mostrar y copiar automaticamente la salida al portapapeles.
- Preservar cambios locales.
- No repetir confirmaciones rutinarias para tareas pequenas y no destructivas.
- No realizar operaciones destructivas ni commits/push sin autorizacion.

## CORRECCIONES Y PUBLICACION — 01/11/2026

Estado verificado antes de publicar:
- `Jugador.gd`: `camera_mode` dentro de `_physics_process`, sangria con tabulaciones.
- `Camara.gd`: zoom por `camera_zoom_in` / `camera_zoom_out`, identico a `2b106a5`.
- `FabricaEntidades.gd`: `Label3D` solo si el NPC tiene nombre.
- `Multijugador.gd`: yaw del `welcome` aplicado a `Modelo`.
- `Jugador.gd`: fuerza de aterrizaje con la velocidad de caida previa.
- `.gitignore`: excluye `*.bak`, `*.bak_*` y `*.blend1`.

Comprobado:
- 8 scripts con `--check-only` en 0.
- `herramientas/PruebaFabricaEntidades.gd` en 0.
- `herramientas/PruebaNPCServidor.gd` en 0.
- Servidor y cliente reales: entidades 1 y 2 creadas sin errores.
- Escena principal en headless en 0.

Siguiente tarea:
1. Definir el ciclo de vida y el estado de las entidades de la Fase 5.
2. Anadir actualizacion de estado desde el servidor.
3. Probar con dos clientes.

No declarar terminada la Fase 5.

## HITO FASE 5 — CICLO DE VIDA Y ESTADO DE ENTIDADES — 01/11/2026

Estado implementado y verificado:
- Entidades ampliadas con estructura completa: `id`, `type`, `name`, `x`, `y`, `z`, `yaw`, `hp`, `hp_max`, `estado` y `activo`.
- Funciones del servidor: `_registrar_entidad()`, `_actualizar_entidad()`, `_obtener_entidad()`, `_eliminar_entidad()`.
- Mensaje `entity_updated` implementado y difundido en red.
- Cliente (`Multijugador.gd`): separación entre datos de red (`datos_entidades`), objetivos espaciales (`objetivos_entidades`) y nodos visuales (`entidades_remotas`).
- Interpolación suave de posición y rotación (`_actualizar_entidades_remotas`).
- Creada suite de prueba `herramientas/PruebaEstadoEntidades.gd` (código 0).

Comprobado:
- 10 scripts con `--check-only` en 0.
- `herramientas/PruebaFabricaEntidades.gd` en 0.
- `herramientas/PruebaNPCServidor.gd` en 0.
- `herramientas/PruebaEstadoEntidades.gd` en 0.
- Escena principal `Mapa1/Escena1.tscn` en headless en 0.

Siguiente tarea:
1. Diseñar tipos adicionales de entidades en `FabricaEntidades.gd` (criaturas / enemigos iniciales).
2. Probar con dos clientes y movimiento simultáneo.
3. Avanzar hacia comportamiento básico / IA de patrulla para entidades.

No declarar terminada la Fase 5.

## HITO FASE 5 — CRIATURA LOBO Y PATRULLA BÁSICA AUTORITATIVA — 01/11/2026

Estado implementado y verificado:
- Tipo "lobo" añadido a FabricaEntidades.gd (cuerpo, cabeza, 4 patas y etiqueta de nombre destacada).
- Entidad 3 registrada en el servidor: "Lobo del Bosque", 60/60 HP, estado "patrullando".
- Patrulla autoritativa periódica implementada en Servidor.gd con cálculo de orientación y relieve del terreno.
- Multijugador.gd interpola posición y giro del lobo suavemente.

Comprobado:
- 10 scripts con --check-only: código 0.
- herramientas/PruebaFabricaEntidades.gd: código 0.
- herramientas/PruebaNPCServidor.gd: código 0.
- herramientas/PruebaEstadoEntidades.gd: código 0.
- Escena principal Mapa1/Escena1.tscn en headless: código 0.

Siguiente tarea:
1. Diseñar el sistema de selección de objetivos (targeting) con raycast/clic o tecla Tab para seleccionar entidades (jugadores, NPC, criaturas).
2. Probar con dos clientes y movimiento simultáneo.

No declarar terminada la Fase 5.

## HITO FASE 5 — TARGETING Y MARCO DE OBJETIVO — 01/11/2026

Estado implementado y verificado:
- Tecla Tab (select_next_target): fija el objetivo más próximo y cicla secuencialmente entre entidades del mundo.
- Tecla Escape: limpia el objetivo.
- Target Frame en el HUD (Main.gd): muestra nombre, barra de vida actual/máxima y tipo/estado de la entidad seleccionada.
- Indicador 3D circular dorado (TorusMesh con brillo): se posiciona en el suelo bajo el objetivo y sigue su movimiento.
- Sincronización en red: si el objetivo recibe entity_updated en Multijugador.gd, el marco actualiza la vida en tiempo real.
- Nueva suite de prueba herramientas/PruebaTargeting.gd (código 0).

Comprobado:
- 11 scripts con --check-only: código 0.
- herramientas/PruebaFabricaEntidades.gd: código 0.
- herramientas/PruebaNPCServidor.gd: código 0.
- herramientas/PruebaEstadoEntidades.gd: código 0.
- herramientas/PruebaTargeting.gd: código 0.
- Escena principal Mapa1/Escena1.tscn en headless: código 0.

Siguiente tarea:
1. Avanzar hacia la Fase 6 (Combate): acción de ataque básico contra el objetivo seleccionado (solicitud al servidor, validación de rango y aplicación de daño a la entidad).
2. O bien prueba de dos clientes simultáneos.

## HITO FASE 6 — SISTEMA DE COMBATE AUTORITATIVO CUERPO A CUERPO — 02/11/2026

Estado implementado y verificado:
- Tecla 1 (ability_1): ejecuta ataque cuerpo a cuerpo sobre la entidad seleccionada.
- Servidor autoritativo: valida existencia del objetivo, distancia euclídea (rango <= 4.5m), recarga/cooldown (1.2s), reduce HP (15 de daño) y marca 'muerto' / activo=false al llegar a 0 de vida.
- La patrulla del lobo se interrumpe si la criatura muere.
- Mensaje de red entity_updated difunde la vida actualizada a todos los clientes.
- HUD (Main.gd): aviso visual dinámico con daño infligido, vida restante y advertencias ("¡Objetivo fuera de alcance!", "Ataque en tiempo de recarga...", "El objetivo ya está muerto").
- Nueva suite de prueba herramientas/PruebaCombate.gd (código 0).

Comprobado:
- 12 scripts con --check-only: código 0.
- herramientas/PruebaCombate.gd: código 0.
- herramientas/PruebaTargeting.gd: código 0.
- herramientas/PruebaEstadoEntidades.gd: código 0.
- herramientas/PruebaNPCServidor.gd: código 0.
- herramientas/PruebaFabricaEntidades.gd: código 0.
- Escena principal Mapa1/Escena1.tscn en headless: código 0.

Siguiente tarea:
1. Animación procedural de ataque con espada en Jugador.gd al pulsar habilidad 1.
2. Respawn autoritativo de criaturas en Servidor.gd tras morir.
3. Probar con dos clientes y movimiento/combate simultáneo.


## HITO FASE 6 — CORRECCIÓN DE ATAQUE Y ANIMACIÓN DE ESPADA — 02/11/2026

Incidencia resuelta:
- Al presionar '1' el cliente no enviaba el paquete porque intentaba llamar a `cliente.send_text()`, método inexistente en `WebSocketMultiplayerPeer`. Corregido a `cliente.put_packet(JSON.stringify(mensaje).to_utf8_buffer())`.
- Ampliada la captura en `_unhandled_input` para tecla 1 (`ability_1`, `KEY_1`, `KEY_KP_1`).
- Añadida validación de objetivo en `Multijugador.gd`: avisa `"¡No tienes un objetivo seleccionado! Pulsa Tab para fijar uno"`.
- Implementada la animación procedural de balanceo de espada en `Jugador.gd` (`animar_ataque()`, arco de corte en X/Z para brazo y espada y rotación de torso).
- Creada suite `herramientas/PruebaAnimacionCombate.gd` (código 0).

Comprobado:
- 14 scripts pasan `--check-only` en 0.
- Las 6 suites de prueba pasan con código de salida 0.

Siguiente tarea técnica:
1. Respawn autoritativo de criaturas en `Servidor.gd` tras retardo de muerte.
2. Probar con dos clientes simultáneos movimiento y combate.


## HITO FASE 6 — RESPAWN AUTORITATIVO COMPLETADO — 02/11/2026

Estado implementado y verificado:
- Sistema de respawn autoritativo en Servidor.gd (TIEMPO_RESPAWN = 6.0s).
- Al morir el lobo u otra entidad, se programa su temporizador. Al llegar a 0, reaparece con 60 HP, estado patrullando y en sus coordenadas originales, notificando a la red.
- Validado con código 0 en PruebaCombate.gd.

Comprobado:
- 15 scripts pasan --check-only en 0.
- 6 suites de prueba pasan al 100% (código 0).
- Escena principal en headless en 0.

Siguiente tarea técnica:
1. Partida simultánea de 2 clientes con movimiento y combate.

## ACTUALIZACION DE CONTINUIDAD — PRUEBA REAL DE DOS CLIENTES — 02/11/2026

Resultado confirmado por el usuario:
- El servidor se inicio en modo headless mediante la escena `escenas/servidor/Servidor.tscn`.
- Se abrieron dos clientes graficos.
- Movimiento y combate funcionaron correctamente entre ambos clientes.
- La ejecucion de logs fue configurada en el comando de prueba, pero los logs no se compartieron para inspeccion independiente.
- No se modifico codigo, no se hicieron commits ni push.

Estado:
- La prueba de dos clientes deja de ser un pendiente inmediato.
- La base de combate de Fase 6 y el respawn ya tenian pruebas automatizadas documentadas.
- Continuar con el siguiente sistema de juego, preservando cambios locales y revisando Git antes de cualquier modificacion.

## CONTINUIDAD — 02/11/2026

Prueba de dos clientes completada segun confirmacion del usuario: dos ventanas graficas, movimiento en distintas partes del mapa, combate cooperativo y respawn funcionaron.

Se actualizo herramientas/iniciar_juego.ps1 para lanzar escenas/servidor/Servidor.tscn, esperar confirmacion, permitir uno o dos clientes y guardar logs separados. El contenido se reviso estaticamente; el lanzador editado aun no se ha ejecutado como prueba propia.

Siguiente paso recomendado:
1. En una futura ejecucion, validar el lanzador actualizado.
2. Continuar con Fase 7: disenar e implementar una primera rebanada pequena de inventario/progresion, despues de inspeccionar de nuevo las interfaces de jugador/servidor.

Conservar todos los cambios locales. No hacer commit ni push sin autorizacion.

## CONTINUIDAD — FASE 7, INVENTARIO INICIAL — 02/11/2026

Ya esta escrito un primer bucle: catalogo compartido, colmillo como botin del lobo, inventario temporal por conexion, snapshot/actualizacion del servidor y panel visible en HUD. Archivos principales: scripts/compartido/CatalogoObjetos.gd, scripts/servidor/Servidor.gd, scripts/cliente/Multijugador.gd y Main.gd.

No verificado en ejecucion. No se corrieron pruebas. Inventario no persistente y sin espacios, equipamiento o uso de objetos.

Siguiente paso necesario: iniciar dos clientes, matar el lobo y confirmar que solo el jugador que dio el golpe final recibe un colmillo y que el panel refleja la cantidad. Despues continuar con una operacion sencilla de inventario (espacios/consumo) o persistencia segun la evidencia y mantener los cambios locales.

Verificacion reciente:
- Parseo con Godot 4.7.2 de Servidor.gd, Multijugador.gd, Main.gd y CatalogoObjetos.gd: codigo 0.
- Sintaxis del lanzador PowerShell: correcta.
- La partida con inventario no fue ejecutada; comprobar que el atacante final recibe Colmillo de lobo y ve la cantidad en HUD. Mantener el objetivo activo hasta esa verificacion.

## RESULTADO DE FASE 7 — INVENTARIO INICIAL VERIFICADO — 02/11/2026

El usuario confirmo que ambos clientes recibieron por separado un Colmillo de lobo al derrotar sus respectivos lobos. Se considera verificado el ciclo inicial de recompensa y recepcion por cliente. El servidor da el item al ID que asesta el golpe letal; el cliente sincroniza y refleja inventario en el HUD.

No se recibieron logs de esa ejecucion. No se hicieron cambios de codigo despues de la confirmacion.

Siguiente trabajo recomendado de Fase 7: definir espacios de inventario y una primera interaccion con objetos (por ejemplo, consumo de una pocion), preservando el estado autoritativo. La persistencia de inventario queda para Fase 8. Como comprobacion adicional, verificar en una pelea compartida que el cliente que no da el golpe final no recibe el premio.

## CONTINUIDAD — FASE 7, EXPERIENCIA Y NIVELES — 02/11/2026

Estado del codigo:
- Se anadio XP autoritativa: cada lobo derrotado concede 25 XP al atacante que da el golpe final.
- Cada jugador conectado comienza en nivel 1 con 0/100 XP. Al alcanzar 100, sube nivel y conserva XP sobrante.
- El servidor manda snapshot en welcome y actualizaciones progression_updated. El cliente guarda el estado recibido y Main.gd lo presenta en el HUD junto al panel de inventario.
- Nivel, XP e inventario son temporales por conexion; no persisten tras desconectar.
- Se corrigio la indentacion del manejo de welcome en Multijugador.gd.

Verificacion tecnica del 02/11/2026: Godot 4.7.2 --check-only paso en scripts/servidor/Servidor.gd, scripts/cliente/Multijugador.gd y Main.gd; git diff --check limpio. No se ejecutaron pruebas funcionales ni se verifico el sistema XP dentro de una partida. No afirmar que el XP funciona en juego hasta recibir esa confirmacion. El usuario si confirmo antes que ambos clientes recibieron colmillo al derrotar sus propios lobos.

Siguiente paso: ejecutar la partida habitual con dos clientes. Matar lobos y observar el panel: el atacante final deberia recibir 25 XP por lobo; cuatro lobos deberian llevar de nivel 1 a nivel 2. Confirmar que el jugador que no da el golpe final no recibe esa recompensa. Despues continuar Fase 7 con espacios/consumo de objetos o definir alcance de persistencia para Fase 8.

Conservar cambios locales. No hacer commit ni push sin autorizacion.
## CONTINUIDAD — FASE 7, DAÑO ESCALADO POR NIVEL — 02/11/2026

Se amplió el combate con una relación autoritativa entre progresión y daño:
- Nivel 1: 15 de daño cuerpo a cuerpo.
- Cada nivel después del 1 añade 2 de daño.
- Servidor.gd obtiene el nivel guardado para el jugador, aplica el daño y devuelve el valor real en attack_result. Main.gd ya muestra el daño informado.
- El bono de +2 es provisional y requiere ajuste de balance tras probarlo.

Verificación: Godot 4.7.2 --check-only de scripts/servidor/Servidor.gd terminó con código 0. No se ejecutaron suites ni pruebas funcionales y no se confirmó el nuevo daño en una partida. El XP/level/HUD también sigue pendiente de confirmación interactiva. El usuario confirmó previamente el botín individual de lobo.

Siguiente paso: en la siguiente ejecución de dos clientes, comprobar el XP por golpe final, la subida al nivel 2 y que el siguiente ataque del personaje de nivel 2 refleje 17 de daño; revisar que el otro jugador conserve su propio progreso. Después seguir con el inventario (espacios/consumo) o persistencia según el estado comprobado.

Conservar los cambios locales. No hacer commit ni push sin autorización.
## ESTADO ACTUAL DE FASES — 02/11/2026

Fase 7 es la actual. El alcance inicial de Fases 5 y 6 está implementado; el usuario confirmó combate y movimiento con dos clientes y el botín individual. XP, subida de nivel y daño escalado pasan parseo de Godot, pero todavía no tienen confirmación en partida. Persistencia continúa en Fase 8.
## CONTINUIDAD — FASE 7, AVISO DE XP — 02/11/2026

Se añadió `xp_gained` al resultado de combate del servidor cuando el golpe letal derrota a un lobo. Main.gd muestra el XP recibido en el aviso de derrota, además del daño; para los demás objetivos conserva el aviso anterior.

Verificación técnica: Godot 4.7.2 --check-only pasó en scripts/servidor/Servidor.gd y Main.gd. No se ejecutó una partida ni pruebas funcionales. Falta que el usuario confirme visualmente el mensaje, el XP por baja, el nivel y el daño escalado. Mantener cambios locales; sin commit ni push.

Siguiente comprobación cuando se abra el juego: derrotar un lobo y comprobar que el jugador que dio el golpe final recibe `+25 XP` en el aviso y en el panel; contrastar después el nivel/daño correspondiente. Fase 7 sigue actual.
## CONTINUIDAD — FASE 7, AVISO DE SUBIDA DE NIVEL — 02/11/2026

Se amplió `attack_result` con `level_up` y `new_level`. El servidor compara el nivel antes y después de conceder la XP por la baja. Main.gd ahora añade el nivel alcanzado al mensaje del HUD cuando esa baja hace subir de nivel; de lo contrario, muestra el XP ganado como antes.

Godot 4.7.2 --check-only pasó en Servidor.gd y Main.gd. No se ejecutaron pruebas funcionales ni partida. No afirmar que la notificación quedó verificada visualmente. La comprobación manual pendiente es obtener cuatro bajas de lobo con un jugador, observar +25 XP y el aviso de nivel 2, y comprobar el daño posterior de 17; el segundo cliente debe conservar su progreso individual.

Fase actual: 7. Preservar todos los cambios locales. Sin commit ni push.
## CONTINUIDAD — FASE 7, ANIMACIÓN DE ATAQUE REMOTA — 02/11/2026

El usuario confirmó que el ciclo de progresión probado funciona y reportó un problema: la animación de ataque no se mostraba en el otro cliente.

Corrección en código:
- Servidor.gd difunde el mensaje `player_attack` solo después de validar el ataque, excluyendo al jugador que lo inició.
- Multijugador.gd resuelve el ID del atacante en `jugadores_remotos` y llama a `animar_ataque()`.
- Jugador.gd ya permite que el bucle de interpolación remoto ejecute la animación; no hizo falta modificarlo.

Verificación técnica: Godot 4.7.2 --check-only pasó para Servidor.gd, Multijugador.gd y Jugador.gd; `git diff --check` pasó. No se ejecutó una partida después de la corrección. La animación remota sigue pendiente de confirmación visual. La verificación manual anterior del usuario cubre XP, subida de nivel y daño escalado.

Siguiente paso: iniciar dos clientes y comprobar que el cliente observador ve el balanceo de espada cada vez que el otro ejecuta un ataque exitoso. Si se confirma, cerrar este pendiente y continuar Fase 7 con el inventario.

Preservar cambios locales. Sin commit ni push.
## CONTINUIDAD — FASE 7, BOTÍN AMPLIADO — 02/11/2026

El usuario confirmó que la animación de ataque ya se reproduce en el segundo cliente. Se cierra ese pendiente interactivo.

Nuevo alcance implementado: `piel_lobo` (material, pila máxima 10) se añadió a CatalogoObjetos.gd y Servidor.gd la concede junto a `colmillo_lobo` y XP al jugador que asesta el golpe letal al lobo. Parseo Godot 4.7.2 correcto en catálogo, servidor, cliente y Main.gd. No se ejecutó prueba funcional de la nueva piel; queda pendiente confirmar que se muestra en inventario y que la recibe solo el atacante final.

Fase actual: 7. Conservar cambios locales; no hacer commit ni push.
## RESULTADO DE PRUEBAS — 02/11/2026

A petición del usuario se corrieron las siete pruebas existentes; las siete pasaron (código 0). Se reforzaron tres tests existentes y se volvieron a correr: PruebaAnimacionCombate comprueba el manejador `player_attack` y que no se repita en el atacante; PruebaCombate comprueba colmillo, piel y XP; PruebaDosClientesCombate comprueba que solo el atacante final recibe esos premios. Las tres ampliadas pasaron.

Se iniciaron un servidor headless y dos clientes gráficos; los dos clientes conectaron y validaron mundo según logs en `%TEMP%\ClassicRPG-test-20261102-012759`. El usuario indicó que hará personalmente la comprobación visual del cliente; las ventanas siguen abiertas. No se envió un ataque real ni se verificó el nuevo botín en UI en esta sesión. Esperar su resultado visual antes de marcar ese punto completado.
## AL RETOMAR — FASE 7, CAPACIDAD DE INVENTARIO (02/11/2026)

Confirmación reciente del usuario: «todo funciona» respecto al ciclo de juego que comprobó. Combate/progresión, botín individual de colmillo y piel, y animación remota se consideran verificados en juego. No abrir ni operar clientes gráficos; el usuario se reservó esa comprobación.

Código recién implementado para capacidad: 20 ranuras; apilar por ID; rechazo del servidor cuando no cabe un objeto nuevo o la pila está llena; señal cliente y mensaje HUD; contador y lista desplazable. Godot 4.7.2 `--check-only` pasó en CatalogoObjetos.gd, Servidor.gd, Multijugador.gd y Main.gd. No se ejecutó todavía una prueba funcional de los límites ni se revisó visualmente el HUD nuevo.

Continuar en este orden: (1) añadir aserciones de los límites a `herramientas/PruebaCombate.gd`; (2) ejecutar ese test con Godot 4.7.2 y revisar `git diff --check`; (3) guardar el resultado aquí y en PENDIENTES/ESTADO_ACTUAL; (4) dejar el chequeo visual del panel al usuario. Preservar los cambios locales existentes; sin commit ni push.
## CONTINUIDAD ACTUAL — 02/11/2026

El usuario confirmó la dirección: desarrollar primero un juego de un solo jugador y retomar después el multijugador, sin eliminar lo ya construido para dos jugadores.

Punto técnico exacto:
- La capacidad de inventario de 20 ranuras y el rechazo por falta de espacio/pila llena están implementados y pasaron el chequeo de sintaxis.
- Las aserciones de ranuras llenas, apilado en inventario lleno y límite máximo de pila ya pasaron en Godot 4.7.2 (código 0).
- El usuario hará la comprobación visual del panel; no abrir ni manejar clientes gráficos.

Siguiente: auditar el flujo de inicio y las dependencias de red para que el juego individual no requiera un segundo cliente. Después avanzar con objetos/equipamiento, NPC/misiones, mundo/enemigos, progreso y guardado local. Preservar cambios locales. Sin commit ni push.

## CONTINUIDAD — VIDA Y REAPARICIÓN (02/11/2026)

Se añadió la fase de defensa del jugador: el servidor mantiene 100 HP; el lobo inflige 10 a 2,5 m con recarga de 1,5 s. A 0 HP, el jugador no puede moverse ni atacar, reaparece tras 5 s en su spawn y tiene 2 s de protección. El cliente actualiza una barra y cuenta atrás; el evento de respawn también recoloca a los personajes remotos para mantener intacta la ruta de dos jugadores.

Comprobado en Godot 4.7.2: siete pruebas existentes con código 0 (Targeting, NPC, fábrica de entidades, estado de entidades, dos clientes/combate, combate/inventario y animación); `--check-only` pasó en los scripts principales; `git diff --check` pasó. Servidor y cliente headless conectaron y validaron el mundo. No abrí ninguna ventana gráfica. La comprobación visual de salud/inventario sigue a cargo del usuario.

Próximo trabajo individual: objetos utilizables y equipamiento, luego NPC/misión corta y guardado/carga local. Mantener la implementación de muerte/respawn y la suite de red. No commit ni push.

## CONTINUIDAD — ARRANQUE INDIVIDUAL INTEGRADO (02/11/2026)

Main.gd ahora inicia el nodo del servidor local antes del cliente cuando no encuentra el argumento de usuario `--servidor-externo`. El modo individual normal no requiere otro proceso ni un segundo cliente. herramientas/iniciar_juego.ps1 añade ese argumento a los clientes de prueba y mantiene el servidor dedicado externo para la verificación multicliente.

Verificación headless de ambos modos: servidor integrado y cliente conectan y validan el mundo; servidor dedicado y cliente externo también conectan y validan. Las siete pruebas Godot 4.7.2, los cinco chequeos estáticos, el análisis PowerShell del lanzador y `git diff --check` pasan. No se abrió el juego gráfico.

Continuar con equipo/consumibles, interacción NPC/misiones y guardado/carga local. Salud e inventario requieren revisión visual del usuario. Preservar la ruta de dos clientes. Sin commit ni push.

## CONTINUIDAD — PRIMERA MISIÓN (02/11/2026)

Se implementó «Caza de lobos». Al seleccionar el Habitante con Tab y pulsar E dentro de 4 m, el servidor acepta la misión. Cada baja de lobo avanza el contador individual; la tercera la completa y da 50 XP. El estado va en welcome y en eventos quest_updated. El HUD presenta el objetivo, el avance y los avisos. Se mantienen las estructuras por jugador para el modo externo.

PruebaCombate verifica rango, aceptación, tres bajas, completado y XP extra. Godot 4.7.2: siete pruebas existentes pasan; cinco scripts pasan `--check-only`; `git diff --check` pasa. Las escenas headless conectan tanto con el servidor integrado como con el externo. No abrí GUI. La revisión visual de misión/salud/inventario sigue reservada al usuario.

Continuar con uso/equipamiento de objetos y después guardado/carga local; ampliar NPC y misiones. Preservar multijugador. Sin commit ni push.

## CONTINUIDAD — POCIÓN Y ESPADA (02/11/2026)

La misión ahora da 50 XP, dos pociones y la Espada del Habitante. La tecla 2 solicita usar la poción; el servidor comprueba posesión, salud y estado, restaura hasta 35 HP sin exceder el máximo y no consume si no puede curar. La tecla Q solicita equipar la espada; el servidor valida que esté en inventario, la registra en la ranura arma y añade +5 al daño cuerpo a cuerpo. El HUD muestra el arma y ambos resultados.

PruebaCombate comprueba misión, curación limitada, rechazo sin consumo al estar a vida completa, consumo, equipamiento y 22 de daño a nivel 2 con espada. Godot 4.7.2: siete pruebas, seis `--check-only`, parser de PowerShell y `git diff --check` pasan. Arranque headless individual integrado y externo conectan y validan el mundo. No se abrió GUI.

Siguiente desarrollo: persistir localmente inventario, progresión, misión, equipo, salud y posición; luego ampliar misiones y mundo. La comprobación visual la hará el usuario. Mantener el modo externo y todos los tests. Sin commit ni push.

## CONTINUIDAD EXACTA — GUARDADO LOCAL VERIFICADO (02/11/2026)

La persistencia individual inicial está implementada en `scripts/servidor/Servidor.gd`. Se guarda en `user://classicrpg_partida.json` el último punto/orientación, HP, inventario, nivel/XP, misión y equipo; hay autosave de 10 s y guardado al cambiar estado, recibir daño/respawnear, desconectar y cerrar. La carga ocurre al entrar en modo individual. El modo de servidor externo mantiene `modo_individual = false` y no lee/escribe la partida local.

La prueba `herramientas/PruebaCombate.gd` valida el round-trip usando un nombre temporal único de `user://`, restaura todos los campos anteriores y borra el archivo temporal. No se tocó `classicrpg_partida.json`.

Comprobado con Godot 4.7.2: las siete pruebas existentes terminan en código 0; siete scripts (Servidor, Multijugador, Jugador, Main y tres pruebas de combate) pasan `--check-only`. El ensayo `user://` no dejó archivos temporales. No se abrieron clientes gráficos; la revisión visual de HUD/controles sigue a cargo del usuario. Sin commit ni push.

Próximo paso: ampliar el contenido para que la primera zona tenga más de una actividad. Implementar una segunda misión de entrega de materiales al Habitante que consuma inventario solo tras validar distancia, cantidad y estado; añadir cobertura automatizada. Después auditar el flujo completo de inicio, continuación y cierre, y ampliar el mundo/variedad de criaturas. Mantener la Fase 7 activa y preservar íntegramente las pruebas y rutas multijugador existentes.

## CONTINUIDAD — SEGUNDA MISIÓN Y ARRANQUE INTEGRADO VERIFICADOS (02/11/2026)

La misión «Entrega de pieles» sigue a «Caza de lobos». Al hablar con el Habitante cuando la primera misión está completada, se activa la entrega de tres pieles. Los objetos previos cuentan; el botín nuevo avanza el HUD. El servidor comprueba cercanía y cantidad: menos de tres no consume, y la entrega consume solo tres, deja sobrantes y da 75 XP. El estado se incluye en la persistencia local.

`herramientas/PruebaCombate.gd` cubre escasez, progreso por loot, entrega, sobrantes y XP; también conserva el round-trip de guardado de la nueva misión. `herramientas/PruebaPartidaIndividual.gd` monta la escena inicial headless, verifica el servidor local + un cliente y la validación del mundo, y confirma guardado al cerrar usando un archivo temporal único que limpia.

Godot 4.7.2: ocho pruebas en código 0, seis `--check-only` en código 0 y `git diff --check` correcto. Puerto 9000 estaba libre antes de la integración; no se abrió GUI. No se tocó el guardado permanente del usuario ni hubo commit/push.

Siguiente: probar el comportamiento ante JSON corrupto/versión desconocida sin alterar la partida real; después diseñar más criaturas y misiones para la primera zona, completar habilidades/flujo de sesión y revisar balance. La inspección visual de HUD/controles sigue a cargo del usuario. Mantener Fase 7 activa y preservar toda la base multijugador.
## CONTINUIDAD — RECUPERACIÓN SEGURA DEL GUARDADO (02/11/2026)

`Servidor.gd` usa `JSON.parse` para leer la partida local, descarta JSON dañado/versiones desconocidas y vuelve al estado inicial. Los normalizadores rechazan tipos/estructuras inválidos, limitan inventario, XP/nivel, vida, contadores de misión, equipo y posición/yaw.

`PruebaCombate.gd` cubre JSON roto, versión 2 y documento de versión 1 con tipos incorrectos; verifica resultados seguros y limpia el archivo temporal. Conserva round-trip completo y comprobación de que servidor externo no persiste.

Godot 4.7.2: ocho pruebas en código 0, seis `--check-only` y `git diff --check` correctos. Incluye el inicio real integrado con un cliente y validación del mundo. No quedaron temporales, el archivo permanente no existe, no se abrió GUI y no hubo commit/push.

Siguiente: ampliar la primera zona con más criaturas/misiones y habilidades, completar el flujo de sesión y revisar balance. Fase 7 sigue activa; la revisión visual la hará el usuario. Conservar íntegra la base multijugador.

## CONTINUIDAD — REAPERTURA REAL DE PARTIDA VERIFICADA (02/11/2026)

La prueba `herramientas/PruebaPartidaIndividual.gd` monta dos sesiones headless consecutivas de `Mapa1/Escena1.tscn`. La primera conecta un cliente al servidor local integrado, coloca estado temporal en el servidor y cierra. La segunda vuelve a iniciar y confirma que el `welcome` restaura posición, inventario, progresión, salud, misión y equipo; comprueba también que el HUD indica «Entrega de pieles» 2/3.

El archivo es un nombre único `user://` que el test elimina. `classicrpg_partida.json` no existe y no se tocó. Las ocho pruebas, seis `--check-only` y `git diff --check` pasan con Godot 4.7.2. También siguen pasando los tests de dos clientes y animación remota. No se abrió GUI.

El núcleo local de guardar/cargar/reanudar ya está verificado entre cierres y reaperturas headless; no equivale a una revisión gráfica. Próxima tarea: ampliar actividades de la primera zona (más criaturas, habilidades/misiones) y después terminar el flujo de sesión y el balance. Fase 7 continúa activa; preservar multijugador; sin commit ni push.

## CONTINUIDAD MÁS RECIENTE — GOLPE PESADO VERIFICADO (02/11/2026)

La tecla 3 ejecuta golpe_pesado, que duplica el daño normal y tiene recarga separada de 6 s por jugador, validada por el servidor. Conserva las teclas 1 (ataque normal), 2 (poción) y Q (espada). La animación es más fuerte/larga y se replica con su tipo a clientes remotos.

Validación con Godot 4.7.2: siete pruebas unitarias y PruebaPartidaIndividual.gd pasan con código 0. La prueba integrada abrió la escena real, conectó un cliente al servidor dentro del proceso, envió el golpe por red y verificó 30 de daño a nivel 1; cerró y reabrió la partida temporal. Las comprobaciones --check-only y git diff --check pasaron. La prueba de dos jugadores confirma enfriamientos independientes. Puerto 9000 libre; temporales limpiados; sin GUI y sin tocar el guardado permanente.

Siguiente tarea: añadir una segunda criatura distinta para dar una actividad de combate nueva en la primera zona, con comportamiento, estadísticas y botín autoritativos y pruebas; después continuar la cadena de misiones y revisar balance. Fase 7 activa. El usuario conserva la revisión visual. Mantener toda la infraestructura multijugador y no hacer commit/push.

## CONTINUIDAD MÁS RECIENTE — JABALÍ DEL BOSQUE VERIFICADO (02/11/2026)

El jabalí es entidad 4 de la primera zona. Tiene 80 HP, patrulla propia, golpe de 14 de daño a 2,6 m cada 2 s, deja colmillo y carne y otorga 35 XP; reaparece con vida completa. Se añadió a la fábrica procedural con nueve mallas, catálogo y paquete de entidades compartido. El lobo/misión actual permanecen.

Comprobado con Godot 4.7.2: ocho pruebas en código 0 (siete unitarias y la integración de escena individual con reanudación), once --check-only y git diff --check. La prueba integrada conectó un único cliente, recibió la entidad, atacó al lobo con golpe pesado por red y reabrió el guardado temporal. Pruebas dedicadas validan patrulla del jabalí, daño/cooldown, botín, XP, respawn y modelo. Puerto 9000 libre; temporales limpiados; sin GUI ni modificación del guardado permanente.

Siguiente: añadir misión que use la carne de jabalí y ampliar el contenido de la primera zona; luego revisar balance y el flujo completo. Fase 7 activa; la revisión visual queda con el usuario. Preservar todo el código y las pruebas multijugador; sin commit ni push.

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

Estado comprobado en este relevo: el árbol de trabajo conserva cambios locales no preparados y archivos nuevos; no se hizo commit ni push. Godot 4.7.2 pasó la integración individual, PruebaDosClientesCombate, PruebaCombate y PruebaMenuInicio; `git diff --check` pasó. El botón real «Guardar y volver al título» ya se probó en la integración y escribió JSON válido con inventario y misión antes de cargar el menú. Sigue pendiente la revisión visual del usuario. No tocar el guardado de producción `user://classicrpg_partida.json`.

Siguiente paso al retomar: continuar la auditoría de requisitos y ampliar contenido/balance de Fase 7. La revisión visual del menú, HUD y controles queda a cargo del usuario. Mantener el modo individual como prioridad, preservar íntegra la infraestructura y pruebas de dos jugadores. No declarar terminado ni crear commit/push hasta cerrar el protocolo y las verificaciones pendientes.

## Punto exacto de continuidad — 02/11/2026

La integración individual ya pulsa la señal del botón «Guardar y volver al título» en la escena real: valida JSON temporal con inventario/misión, espera el cambio de `current_scene` a `MenuInicio.tscn` y limpia el temporal. Las nueve pruebas funcionales pasaron; --check-only de la prueba, Main.gd, MenuInicio.gd y Servidor.gd pasó; `git diff --check` pasó. No GUI, guardado real, commit ni push.

Retomar por la auditoría de requisitos de juego individual y más contenido/balance de la zona, manteniendo Fase 7 activa. El usuario tiene pendiente revisar visualmente el menú, el HUD y los controles. Leer protocolo y toda la memoria, comprobar el árbol de trabajo antes de modificar; preservar íntegra la base de dos jugadores.

## Continuidad — criatura y misión de gelatina (02/11/2026)

Último trabajo comprobado: Limo del Bosque (ID 5, 45 HP, 8 de daño, 20 XP, gelatina, patrulla y respawn) creado por la fábrica cliente; la quinta misión solicita entregar 3 gelatinas tras cobrar la recompensa de caza de jabalíes. Se verificaron el conteo de botín, faltantes, conservación de sobrantes, 120 XP y normalización de estado para persistencia. Nueve pruebas funcionales y nueve `--check-only` pasaron con Godot 4.7.2; `git diff --check` pasó; la integración individual recibió la entidad y validó el botón de guardado/retorno al menú. No GUI, guardado permanente, commit ni push.

Siguiente: continuar el contenido y balance de la primera zona y auditar cada parte del ciclo individual contra el estado actual. La revisión visual de menú, HUD, controles y modelo queda con el usuario. Fase 7 activa; conservar intacta la infraestructura de dos jugadores.

## Relevo por límite de uso — 02/11/2026

Se detuvo el trabajo nuevo para conservar el estado. Cambio parcial sin probar: `Main.gd` ofrece selección de objeto y botón «Descartar 1 seleccionado»; `scripts/cliente/Multijugador.gd` envía `discard_item` y recibe `discard_item_result`. Falta por completo el manejo autoritativo en `scripts/servidor/Servidor.gd`, así como pruebas y verificación. Antes de continuar, inspeccionar `git diff` y el árbol de trabajo para preservar cambios previos; completar servidor, pruebas y ejecutar Godot 4.7.2. La última tarea completa y comprobada es el Limo del Bosque y la misión de entrega de gelatinas, registrada arriba. Fase 7 activa; no GUI, no tocar guardado de producción, sin commit/push; conservar multijugador.

## Punto exacto de continuidad — 02/11/2026 — descarte terminado

La función «Descartar 1 seleccionado» ya está completa. Servidor: valida ID de catálogo, posesión y vida; quita una unidad, mantiene alineado el contador de misión de piel/carne/gelatina, desequipa el arma si se descarta la última copia y guarda los cambios locales. Cliente/HUD: lista seleccionable, botón, mensaje de resultado y canal `discard_item`/`discard_item_result`.

Comprobación Godot 4.7.2: nueve pruebas funcionales pasaron; `PruebaCombate` verifica servidor y persistencia, y `PruebaPartidaIndividual` selecciona la gelatina en la lista, pulsa el botón y confirma por WebSocket la cantidad en ambos lados. Dos sesiones sucesivas validaron selector de puertos y reapertura/retorno al título. `git diff --check` pasó. No se abrió GUI, no se tocó el guardado de producción ni se hicieron commits/pushes.

Continuación (02/11/2026): se añadió un `ConfirmationDialog` en español antes de descartar. `PruebaPartidaIndividual` verifica cancelar (mantiene 2 unidades) y confirmar (queda 1 en cliente y servidor); las nueve pruebas vuelven a pasar. `git status` está fallando intermitentemente con «not a work tree», aunque `git rev-parse` detecta la raíz correcta; no ejecutar operaciones destructivas ni descartar modificaciones. `git diff --check` es el chequeo actual legible.

Siguiente paso del objetivo, manteniendo Fase 7 abierta: auditar contra el estado real el ciclo individual completo y seguir con contenido/balance. El usuario conserva la revisión visual del menú, HUD, inventario y controles. Leer el protocolo/memoria antes de cualquier nueva tarea; preservar íntegra la base multijugador.

## Punto exacto de continuidad — economía inicial (02/11/2026)

La economía base quedó implementada en scripts/servidor/Servidor.gd, scripts/cliente/Multijugador.gd, Main.gd y scripts/compartido/CatalogoObjetos.gd: recompensas de misión de 30/15/25/30/35 de oro, poción por 20, compra validada en servidor, oro persistido y saldo/compra en HUD. PruebaCombate.gd y PruebaPartidaIndividual.gd cubren las validaciones principales, compra y restauración del saldo; la suite funcional completa de nueve pruebas pasó en Godot 4.7.2.

Comprobación inmediata completada: herramientas/PruebaCombate.gd compara los cuatro pagos restantes con el saldo previo a cada misión y terminó con código 0 en Godot 4.7.2. Siguiente tarea: auditar los requisitos/ritmo de la primera zona y continuar contenido/balance; el chequeo visual sigue a cargo del usuario. La revisión visual del menú, HUD, inventario y controles queda con el usuario. Fase 7 sigue abierta; no modificar el guardado de producción, no hacer commit/push y preservar íntegra la infraestructura/pruebas multijugador.

## Punto exacto tras regresión — 02/11/2026

Suite funcional de nueve pruebas pasó en Godot 4.7.2. La prueba individual está confirmada con permiso de loopback del entorno: dos sesiones consecutivas, conexión de un cliente, mundo validado, habilidad, descarte con confirmación, atributos, tienda, oro, guardado, reapertura, restauración del HUD y Guardar/volver al menú. Un primer fallo en este turno fue únicamente porque no se había habilitado loopback; reintentada con la red local permitida, pasó sin modificar código. No hay una instancia Godot abierta por la automatización.

El usuario puede iniciar la prueba visual: abrir el proyecto en Godot 4.7.2 y pulsar F5; el menú principal es MenuInicio.tscn y la escena del mapa integra el servidor individual. Mantener su guardado real; elegir Continuar si quiere revisar su progreso existente. Esperar su feedback visual, mientras se continúa la auditoría/cobertura de Fase 7. Fase 7 sigue abierta; ampliar/balancear contenido de la primera zona, preservar multijugador, no commit/push.
## CIERRE DE AUDITORÍA Y PULIDO DE BALANCE DE ZONA — 02/11/2026

Completada la auditoría técnica profunda de balance y progresión de la primera zona (Fase 7):
- Análisis de combate y recompensas: 5 misiones otorgan un total de 405 XP y 135 de oro, llevando al jugador a nivel 7-8 con sus combates intermedios.
- Cierre narrativo implementado: al finalizar la 5.ª misión (entrega de gelatina de limo), el Habitante reconoce el logro con diálogo final ('¡El bosque está en calma gracias a ti! Has completado todas las tareas.') evitando el mensaje genérico anterior.
- Verificación exhaustiva: 9/9 pruebas funcionales pasan en verde con Godot 4.7.2 (PruebaAnimacionCombate, PruebaCombate, PruebaDosClientesCombate, PruebaEstadoEntidades, PruebaFabricaEntidades, PruebaMenuInicio, PruebaNPCServidor, PruebaTargeting y PruebaPartidaIndividual).
- Chequeo sintáctico --check-only exitoso en todos los scripts clave (Servidor.gd, Multijugador.gd, CatalogoObjetos.gd, Main.gd, MenuInicio.gd, Jugador.gd).
- Se preserva íntegramente la arquitectura de dos jugadores y las pruebas de red. No se modificó la partida real (user://classicrpg_partida.json) ni se crearon commits/push.
- Fase 7 permanece abierta a la espera de la comprobación visual del usuario (F5 desde MenuInicio.tscn).
## SELECCIÓN POR CLIC Y TOGGLE DE INVENTARIO CON TECLA B — 02/11/2026

Implementadas las mejoras de control e interfaz solicitadas respetando íntegramente la arquitectura existente:
1. Selección de objetivo con clic izquierdo:
   - Se añadió seleccionar_objetivo_por_rayo(origen, direccion, distancia_max) a scripts/cliente/Multijugador.gd, reutilizando el registro entidades_remotas sin alterar las mallas ni el conteo de nodos de FabricaEntidades.gd.
   - Se actualizó Camara.gd para detectar clics izquierdos sin arrastre significativo (UMBRAL_ARRASTRE_ORBITA), proyectando el rayo desde la cámara y fijando el objetivo, mientras se conserva la órbita con arrastre y la selección alternativa con tecla Tab.
2. Toggle de inventario con tecla B:
   - El panel de inventario (panel_inventario) en Main.gd ahora inicia oculto (isible = false).
   - Se añadió la captura de la tecla B en Main.gd (_input) para alternar la visibilidad (_alternar_inventario()).
   - El descarte de objetos y la tienda siguen funcionando idénticamente. No se modificó la lógica de misiones, ni equipamiento con Q, ni la compra de pociones.
3. Pruebas y verificación:
   - Nueva suite herramientas/PruebaToggleInventario.gd verificada con éxito (arranque oculto, alternancia por función y por evento de tecla B).
   - Suite herramientas/PruebaTargeting.gd ampliada con aserciones de selección por rayo y selección directa.
   - Las 10 pruebas del proyecto pasaron con código 0 (10/10 OK) en Godot 4.7.2.
   - Verificación sintáctica --check-only limpia (código 0) en los 7 scripts principales.
## CURSOR PERSONALIZADO Y CORRECCIÓN DE TARGETING POR RATÓN — 02/11/2026

Completada la corrección de targeting con ratón y la integración del cursor personalizado:
1. Comportamiento del ratón y targeting:
   - En Camara.gd, el clic izquierdo (MOUSE_BUTTON_LEFT) ya NO captura el ratón (Input.MOUSE_MODE_CAPTURED se reserva únicamente para el clic derecho al rotar la cámara).
   - El cursor permanece siempre visible y libre en pantalla.
   - Al hacer clic izquierdo, se lanza instantáneamente el raycast desde la cámara hacia el mundo mediante _seleccionar_objetivo_con_cursor(pos_pantalla).
   - La selección alternativa con **TAB** sigue funcionando al 100%.
2. Cursor personalizado de guantelete:
   - Se procesó la imagen original recortando con precisión el guantelete (aislado de la flecha con canal alfa transparente).
   - Se exportaron versiones en es://assets/cursores/guantelete_64.png (64×64 píxeles) y guantelete_32.png (32×32 píxeles).
   - El hotspot exacto quedó definido en la punta del dedo índice: Vector2(13, 1) para la versión de 64 px.
   - Configurado en project.godot:
     - display/mouse_cursor/custom_image="res://assets/cursores/guantelete_64.png"
     - display/mouse_cursor/custom_image_hotspot=Vector2(13, 1)
3. Verificación y regresión:
   - La suite completa de 10 pruebas pasó con código de salida 0 (10/10 OK) en Godot 4.7.2.
   - Todos los scripts clave pasan --check-only sin errores.
   - Guardado local de producción intacto; sin commits ni push; modo multijugador preservado.

## Punto exacto de continuidad — 02/11/2026

La petición más reciente quedó implementada y comprobada: assets/cursores/Point.png es byte por byte la descarga original (32×32 con transparencia), aparece como cursor en la ejecución gráfica de prueba y está configurado en project.godot. En Camara.gd, un clic izquierdo sigue disparando la selección por rayo y solo un arrastre acumulado de 4 px o más activa el orbitado libre; el modo libre de Jugador.gd conserva el yaw del personaje. El botón derecho conserva su modo de giro vinculado. PruebaTargeting.gd y una prueba temporal de cámara/entrada pasaron con Godot 4.7.2. Una prueba adicional envió KEY_TAB por Multijugador.gd y confirmó que selecciona el objetivo siguiente (exit 0). El arnés temporal fue retirado y no se modificó el guardado real.

Cuando se retome el desarrollo general, Fase 7 sigue abierta; continuar con la auditoría de contenido/balance y el flujo individual, preservando todos los cambios locales y la base multijugador. No hacer commit/push ni modificar el archivo de guardado de producción. Nota: la comprobación final de Git volvió a fallar intermitentemente (not a work tree/Permission denied); no se hizo ninguna operación Git mutativa.

Último ajuste de cámara: al soltar el giro izquierdo o derecho, `Camara.gd` devuelve el cursor al punto donde empezó el gesto: el clic inicial en el giro izquierdo y la pulsación en el derecho. Los movimientos posteriores siguen girando la cámara, pero no desplazan el punto guardado. Prueba headless de eventos sintéticos, `PruebaTargeting.gd` y `--check-only` de `Camara.gd` terminaron con código 0. El modo headless no puede validar el puntero físico; por indicación del usuario, él hará esa comprobación y no se abrirá otra prueba gráfica. No se conserva el arnés temporal ni se toca el guardado real.

## Punto exacto de continuidad — HUD inicial — 02/11/2026

HUD inicial implementado en `scripts/cliente/HUDInicial.gd`, conectado desde `Main.gd`: retrato del modelo real, vida y nivel del jugador, barra de maná vacía (solo preparación), seis ranuras visuales, objetivo con datos reales y minimapa que sigue posición/orientación. `herramientas/PruebaHUDInicial.gd` cubre la conexión desde callbacks de `Main.gd`; PruebaHUDInicial, PruebaTargeting e integración `PruebaPartidaIndividual` pasaron con Godot 4.7.2, al igual que los tres chequeos sintácticos. No abrir ni revisar visualmente la GUI: el usuario hará esa evaluación. Siguiente paso: incorporar su feedback de presentación y, solo cuando existan sistemas de juego, conectar maná/acciones. No tocar cámara, movimiento, targeting, controles ni base multijugador.

## Integración técnica de personaje Quaternius — 02/11/2026

Se descargó y revisó el paquete estándar oficial Modular Character Outfits – Fantasy. La versión gratuita contiene Male_Ranger y Male_Peasant, no una variante nombrada Knight; se eligió Male_Ranger como el atuendo masculino orientado a combate disponible. El ensamblado glTF incluye 9 mallas, una malla Male_Ranger_Head_Hood, seis mapas de textura, 65 huesos humanoides y no contiene animaciones. Se verificó además el paquete gratuito Universal Base Characters: no estaba instalado localmente; su paquete estándar se revisó para comprobar compatibilidad de huesos. El ensamblado completo elegido se importa sin instancia externa de UBC.

En Personajes/Jugador.tscn, el nuevo glTF se instanció bajo Modelo. Los 17 nodos raíz del aspecto provisional se ocultaron, no se borraron, para que sigan disponibles como respaldo y para conservar las rutas que espera Jugador.gd. Jugador.gd, colisión, cámara, inputs, targeting, HUD y scripts de red no se editaron.

Godot 4.7.2 importó el modelo y sus texturas. La comprobación headless cargó la escena real del jugador, comprobó 9 mallas con materiales texturados, 65 huesos, altura importada 1,869 m con los pies en y≈0, colisión CapsuleShape3D sin cambios y desplazamiento al mantener move_forward. PruebaHUDInicial.gd y PruebaTargeting.gd terminaron con código 0. No se abrió la ventana gráfica. El modelo no trae clips y aún no se retargetearon las animaciones procedurales, así que la representación nueva permanecerá estática al desplazarse hasta añadir locomoción.

Pendiente: revisión visual del usuario dentro del juego, especialmente orientación, ajuste de la cabeza/atuendo y apariencia del retrato. El paquete estándar no trae arma. Si se necesita una variante Knight concreta o una pieza adicional, revisar esa necesidad después de la revisión; no se adquirió la versión Source de pago. No commit ni push; conservar cambios locales y multijugador.

## Punto exacto de continuidad — cabeza/locomoción Quaternius — 02/11/2026

Se atendió el reporte de que Male_Ranger aparecía estático y sin una cabeza facial. El GLTF no tenía cabeza/cara ni clips; Jugador.gd animaba aún el respaldo provisional oculto, no el rig nuevo. El README del outfit pide solo la cabeza UBC porque el cuerpo completo causa clipping. El UBC Standard descargado localmente trae solo cuerpo masculino Superhero, incompatible en proporción con el Ranger Regular; se preservaron sus recursos, se derivó solo cabeza/cuello con pesos Head y se añadieron ojos/cejas.

Cambios: Personajes/Jugador.tscn instancia la cabeza bajo Modelo; Jugador.gd aplica al rig Ranger y al rig facial las mismas curvas procedurales existentes mediante nombres/rests humanoides, con brazos bajados desde T. Añadida herramientas/PruebaModeloAnimacionesQuaternius.gd. No se tocó el movimiento/física, cámara, colisión, controles, HUD, targeting, cliente/servidor ni sus referencias. La escena provisional sigue disponible, oculta, como respaldo.

Comprobado con Godot 4.7.2 headless: 9 mallas del Ranger con texturas, 3 mallas faciales con texturas, 65 huesos por rig, coincidencia de la posición/pose del hueso Head, brazos descansados hacia abajo, marcha alterna, sprint con mayor amplitud, salto/caída distintos y compresión de aterrizaje. Las 12 pruebas existentes/de regresión terminaron con código 0; PruebaPartidaIndividual requirió habilitar loopback del entorno y después pasó sin tocar el código de red. La importación GLB completó; Godot también mostró el aviso Safe save failed de ajustes del editor. No se abrió GUI ni se afirmó comprobación visual: el usuario hará esa revisión.

Pendiente ahora: pedir al usuario feedback visual de cabeza bajo el capuchón, cuerpo/ropa y locomoción. Si solicita un cuerpo desnudo Regular bajo el atuendo, no añadir el cuerpo Superhero que causa clipping; el UBC Standard no trae Regular y no se adquirió Source de pago. La animación aún es procedural; no hay clips externos. Fase 7 continúa activa. Preservar todos los cambios locales, guardado de producción y pruebas multijugador; no commit/push.

## Punto exacto de continuidad — orientación y animaciones UAL — 02/11/2026

Se corrigió la orientación visual y se integró Universal Animation Library Standard. En `Jugador.gd`, `AnimationTree`/`RetargetModifier3D` están activos en el jugador; el perfil de 65 huesos anima Male_Ranger y la cabeza. La corrección de rumbo solo rota `Modelo/VisualQuaternius`, dejando intactos el yaw lógico, los controles y el movimiento. Los clips verificados son Idle, Walk, Jog_Fwd, Sprint, Jump_Start, Jump y Jump_Land; la prueba nueva verifica las ocho direcciones y transiciones hasta regreso a locomoción.

Recursos conservados en `assets/modelos/quaternius/universal_animation_library_standard/` (ZIP fuente, GLB in-place, licencia y README). `herramientas/PruebaModeloAnimacionesQuaternius.gd` pasó limpio; las 12 pruebas headless de `herramientas/Prueba*.gd` finalizaron con código 0. Sin GUI ni revisión visual. Standard trae un único Walk, reutilizado en ocho muestras BlendSpace, y no tiene Fall separado (Jump hace de ciclo de caída). El usuario debe comprobar presentación y transiciones en juego. No reset/clean, commit ni push.

## Limpieza previa a publicación — 02/11/2026

Se eliminaron respaldos locales antiguos `.bak`/`RESPALDO` sin referencias, cursores de guantelete no configurados y la escena vacía inicial `node_3d.tscn`. Permanecen el respaldo visual antiguo dentro de `Personajes/Jugador.tscn` y los recursos fuente originales de Quaternius. El código de juego no se tocó durante la limpieza; la comprobación anterior fue 12/12 headless. La rama local `main` tenía dos commits adelantados sobre `origin/main` y no había cambios remotos entrantes al último fetch. El siguiente agente debe revisar `git status` antes de cualquier otra publicación y mantener todos los cambios existentes.
