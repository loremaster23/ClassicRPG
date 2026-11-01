# CONTINUAR CLASSICRPG

Quiero que continúes el desarrollo de mi MMORPG 3D ClassicRPG.

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

### Multijugador

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