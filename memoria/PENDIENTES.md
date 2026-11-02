# CLASSICRPG — TAREAS PENDIENTES

Última revisión: 02/11/2026

Las tareas deben comprobarse antes de marcarlas como completadas.
Revisar un archivo no significa que el sistema esté terminado.

## Sistema de memoria

- [x] Crear estructura de carpetas.
- [x] Crear documentos principales.
- [x] Crear protocolo de memoria.
- [x] Revisar GuardarEstado.ps1.
- [x] Probar generación del informe.
- [x] Comprobar que el informe se copia correctamente.
- [ ] Evaluar automatización adicional.
- [ ] Registrar memoria/ en Git cuando corresponda y exista autorización.

## Auditoría técnica inicial

- [x] Inspeccionar Main.tscn y Mapa1/Escena1.tscn.
- [x] Comprobar la escena inicial configurada.
- [x] Inspeccionar Main.gd.
- [x] Inspeccionar Personajes/Jugador.tscn.
- [x] Inspeccionar Jugador.gd.
- [x] Comprobar referencias de scripts/cliente/Jugador.gd.
- [x] Inspeccionar Camaras/Camara.tscn y Camara.gd.
- [x] Revisar las acciones del Input Map.
- [x] Inspeccionar scripts/cliente/Multijugador.gd.
- [x] Inspeccionar scripts/servidor/Servidor.gd.
- [x] Inspeccionar scripts/compartido/GeneradorTerreno.gd.
- [x] Comprobar el estado Git de la rama main.
- [ ] Realizar pruebas funcionales adicionales cuando los cambios lo requieran.

## Modelo 3D

- [ ] Revisar Caballero_v2.blend.
- [ ] Mejorar silueta y proporciones.
- [ ] Reducir apariencia cúbica.
- [ ] Mejorar casco y armadura.
- [ ] Mejorar espada y escudo.
- [ ] Mejorar materiales.
- [ ] Exportar GLB mejorado.
- [ ] Comprobar en Godot.
- [ ] Evaluar integración sin reemplazar el personaje actual.

## Personaje

- [x] Inspeccionar Jugador.tscn.
- [x] Inspeccionar el script Jugador.gd asociado.
- [x] Identificar el sistema actual de animación procedural.
- [ ] Evaluar Skeleton3D.
- [ ] Diseñar e implementar rigging.
- [ ] Implementar animaciones esqueléticas.
- [ ] Animaciones de movimiento.
- [ ] Animaciones de combate.
- [ ] Equipamiento intercambiable.
- [ ] Evaluar integración de modelos mejorados sin sustituir el personaje actual.

## Cámara y controles

- [x] Inspeccionar Camara.tscn.
- [x] Inspeccionar Camara.gd.
- [x] Revisar las acciones del Input Map.
- [x] Usar `Point.png` como cursor conservando alfa, a 32×32 px, con hotspot en la punta.
- [x] Restaurar el giro libre con arrastre izquierdo sin girar al personaje; conservar clic de selección, TAB y giro con botón derecho.
- [x] Al terminar un arrastre izquierdo o derecho, devolver el cursor al punto donde empezó el gesto.
- [ ] El usuario verificará visualmente que el cursor vuelve al punto inicial al soltar los botones izquierdo y derecho.
- [ ] Revisar y unificar los modos de órbita.
- [ ] Revisar el zoom y la detección de obstáculos.
- [ ] Implementar o corregir los controles anunciados en el HUD.
- [ ] Evaluar compatibilidad con mando.
- [ ] Implementar las acciones de interacción, selección de objetivo y habilidades cuando corresponda.

## Multijugador — etapa futura (trabajo conservado)

Las tareas siguientes se mantienen en el backlog sin borrarlas. No son prioridad mientras se completa el RPG individual, salvo que haga falta una corrección para preservar la compatibilidad del código existente.

- [x] Inspeccionar el cliente actual.
- [x] Inspeccionar el servidor actual.
- [x] Revisar el intercambio de mensajes.
- [x] Identificar el sistema de interpolación remota.
- [x] Identificar la validación de configuración del mundo.
- [ ] Implementar simulación autoritativa.
- [ ] Mejorar validación de movimiento.
- [ ] Evitar confiar en estados declarados por el cliente.
- [ ] Evaluar predicción y reconciliación.
- [ ] Evaluar interpolación con búfer temporal.
- [ ] Implementar autenticación.
- [ ] Implementar persistencia.
- [ ] Implementar reconexión.
- [ ] Realizar pruebas adicionales de varios jugadores.
- [ ] Evaluar seguridad y rendimiento.

## Sistemas RPG para un jugador

- [x] Combate cuerpo a cuerpo inicial (Fase 6; quedan mejoras posteriores).
- [x] Atributos de Fuerza/Vitalidad configurables: +2 daño o +10 vida máxima/actual por punto; quedan balance y revisión visual.
- [x] Niveles y experiencia básicos; queda balancear y ampliar la progresión.
- [x] Inventario de 20 ranuras, apilado, pociones y descarte unitario; falta la revisión visual del HUD.
- [x] Espada inicial con bono de daño, equipamiento y auto-desequipado al descartarla; falta ampliar tipos y revisar su presentación visual.
- [x] Botín de tres criaturas y recompensas de misión; faltan más fuentes, reglas y balance.
- [x] Un NPC interactivo y cinco objetivos encadenados; faltan personajes, diálogos y variedad de actividades.
- [x] Tres enemigos con patrulla, combate, botín, XP y respawn; faltan variedad de comportamiento y balance.
- [x] Cadena individual de cinco misiones con entrega de objetos, caza, recompensas y persistencia; faltan más objetivos y revisión de ritmo.
- [x] Primera habilidad activa: golpe pesado, tecla 3, daño doble y recarga autoritativa de seis segundos; faltan más habilidades y balance.
- [x] Economía inicial: recompensas de oro, saldo persistente y compra validada de poción curativa al Habitante; quedan el balance, variedad de tienda y revisión visual.
- [x] Guardado/carga local inicial de inventario, progreso, equipo, vida y posición; el ciclo de continuar, guardar/cerrar y volver al menú tiene integración automatizada. Falta cerrar la auditoría amplia del juego.

## Mundo

- [x] Prototipo de zona inicial explorable con terreno procedural, camino, bosque, rocas, Habitante y tres criaturas.
- [ ] Crear regiones.
- [ ] Crear ciudades.
- [ ] Crear mazmorras.
- [x] Añadir una criatura original low-poly (Limo del Bosque) junto al lobo y al jabalí.
- [ ] Mejorar ambientación y verificarla visualmente.
- [ ] Incorporar música.

## Próxima prioridad

Estado actual: el ciclo local de inicio, combate, cinco misiones, objetos, progreso, economía inicial y guardado/carga tiene pruebas automatizadas. Próxima prioridad: auditar requisitos y experiencia completa de la primera zona, ampliar contenido/balance y dejar al usuario la comprobación visual de menú, HUD e inventario.

El trabajo multijugador ya desarrollado se conserva; las mejoras exclusivamente online quedan aplazadas. No modificar una implementación existente sin revisar primero su estado real y preservar todo cambio local.

## Regla

No marcar como completado algo que no haya sido comprobado.

Actualizar esta lista después de cada tarea importante.

## Actualización vigente — guardado local inicial (02/11/2026)

- [x] En modo individual, guardar posición, orientación, salud, inventario, nivel/XP, estado/contador de misión y equipo en `user://classicrpg_partida.json`.
- [x] Guardar al cambiar estados RPG, al recibir daño/respawn, periódicamente cada 10 segundos y al desconectar/cerrar.
- [x] Cargar esos datos al conectar en modo individual y validar/normalizar campos antes de aplicarlos.
- [x] Mantener deshabilitada la lectura/escritura local en el modo de servidor externo.
- [x] Añadir una prueba de ida y vuelta a `herramientas/PruebaCombate.gd`; la prueba usa un nombre temporal único bajo `user://` y lo elimina.
- [x] Godot 4.7.2: las siete pruebas del proyecto terminaron con código 0; siete scripts pasaron `--check-only`.
- [x] La prueba real de `user://` restauró posición, yaw, vida, inventario, progresión, misión y equipo; no quedaron archivos temporales.
- [ ] El usuario revisará visualmente los paneles y controles del cliente. No abrir ventanas gráficas desde esta sesión.
- [ ] Ampliar la experiencia individual con más objetivos, misiones, contenido y un flujo de sesión más completo.

La comprobación de persistencia se aisló de `classicrpg_partida.json`: no existía antes de la prueba y no se creó ni modificó durante ella. No hubo commit ni push.
## Estado oficial de fases — actualización 01/11/2026

Criterio acordado con el usuario:

- [x] Fase 1 — Arquitectura y organización.
- [x] Fase 2 — Conexión multijugador.
- [x] Fase 3 — Sincronización básica.
- [x] Fase 4 — Personajes, animaciones y estados. Aceptada para continuar por decisión del usuario.
- [x] Fase 5 — Mundo y entidades, alcance inicial implementado; ampliar contenido y variedad sigue pendiente.
- [x] Fase 6 — Combate inicial y prueba de dos clientes confirmados; mejoras siguen pendientes.
- [ ] Fase 7 — Inventario y progresión RPG. FASE ACTUAL; falta confirmar XP/niveles/daño escalado en juego y completar operaciones de inventario.
- [ ] Fase 8 — Cuentas y persistencia.
- [ ] Fase 9 — Red, acceso externo y lanzamiento.

### Fase 5 — Mundo y entidades

- [ ] Definir arquitectura de entidades compartidas.
- [ ] Diseñar e implementar NPC.
- [ ] Diseñar e implementar enemigos.
- [ ] Implementar aparición y desaparición de entidades.
- [ ] Implementar IA inicial.
- [ ] Sincronizar entidades mediante el servidor.
- [ ] Comprobar funcionamiento en el mundo actual.
- [ ] Documentar y verificar cada sistema.

### Mejoras técnicas posteriores, no bloqueantes para la aceptación de fases anteriores

- [ ] Rigging y animaciones esqueléticas.
- [ ] Modelos definitivos e integración artística.
- [ ] Equipamiento intercambiable.
- [ ] Estados avanzados del personaje.
- [ ] Revisar controles anunciados en el HUD.
- [ ] Mejorar cámara y controles.
- [ ] Mejorar autoritatividad y validación del servidor.
- [ ] Evaluar predicción y reconciliación.
- [ ] Mejorar interpolación remota.
- [ ] Autenticación, persistencia y reconexión.

La aceptación de una fase para continuar no significa que todas sus mejoras estén implementadas o probadas. No convertir controles configurados en sistemas funcionales por inferencia.


## HITO FASE 5 — ENTIDADES SINCRONIZADAS — 01/11/2026

Completado:
- [x] Registro de entidad de prueba en el servidor.
- [x] Inclusión de entidades en el snapshot welcome.
- [x] Creación de representación visual en el cliente.
- [x] Prevención de duplicados por ID.
- [x] Verificación visual de la esfera azul en el mundo.

Pendiente:
- [ ] Probar aparición dinámica mediante entity_spawned.
- [ ] Probar eliminación mediante entity_removed.
- [ ] Incorporar una estructura de entidades preparada para NPC y criaturas.
- [ ] Definir ciclo de vida y datos de entidades más allá de la esfera de prueba.


## ACTUALIZACION DOCUMENTAL FASE 5 - 01/11/2026

## ACTUALIZACION FASE 5 - 01/11/2026

Completado y verificado:
- [x] Registro de entidad en el servidor.
- [x] Snapshot inicial de entidades mediante welcome.
- [x] Representacion visual de entidades en el cliente.
- [x] Aparicion dinamica mediante entity_spawned.
- [x] Eliminacion dinamica mediante entity_removed.
- [x] Verificacion de ambos eventos en los registros de servidor y cliente.
- [x] Retirada del mecanismo temporal de prueba.
- [x] Arranque del servidor limpio sin errores.

Siguiente trabajo:
- [ ] Disenar una estructura reutilizable para entidades del mundo.
- [ ] Definir datos comunes: identificador, tipo, posicion y ciclo de vida.
- [ ] Crear una escena o representacion base para entidades.
- [ ] Incorporar NPC sobre esa estructura.
- [ ] Incorporar criaturas y enemigos.
- [ ] Definir sincronizacion de estados y comportamiento.
- [ ] Probar las nuevas entidades en el mundo actual.

La Fase 5 no esta completada. La prueba actual utiliza esferas de demostracion, no NPC ni enemigos reales.

## Correcciones del 01/11/2026

- [x] Verificar B3.4: `camera_mode` dentro de `_physics_process`.
- [x] Confirmar el zoom por InputMap en `Camara.gd`.
- [x] Restaurar la sangria con tabulaciones en `Jugador.gd`.
- [x] Corregir `PruebaFabricaEntidades.gd` con el `Label3D` condicional.
- [x] Eliminar `print` de depuracion en camara y multijugador.
- [x] Corregir la fuerza de aterrizaje del jugador.
- [x] Excluir respaldos y `.blend1` en `.gitignore`.
- [ ] Publicar los cambios en GitHub.
- [ ] Probar dos clientes con movimiento simultaneo.
- [ ] Continuar la Fase 5 con el ciclo de vida de entidades.

## Tareas Fase 6 — Combate y Progresión (02/11/2026)

- [x] Acción de ataque cuerpo a cuerpo autoritativo (ttack).
- [x] Validación de rango melee (distancia euclídea <= 4.5m).
- [x] Validación de tiempo de recarga / cooldown entre ataques (1.2s).
- [x] Aplicación de daño autoritativo y reducción de HP sincronizada (entity_updated).
- [x] Transición a estado muerto e inactivo (ctivo = false) al llegar a 0 HP.
- [x] Interrupción de IA de patrulla al morir la criatura.
- [x] Rechazo autoritativo de ataques a objetivos muertos o inválidos.
- [x] Mapeo de tecla 1 (bility_1) para atacar al objetivo actual.
- [x] Feedback dinámico de combate en HUD (daño, vida, errores de rango y cooldown).
- [x] Suite de prueba unitaria herramientas/PruebaCombate.gd.
- [ ] Animación procedural de ataque con espada en Jugador.gd.
- [ ] Reaparición (respawn) de criaturas tras morir tras un retardo en el servidor.
- [x] Probar combate y movimiento con dos clientes simultáneos (confirmado por el usuario).


## Actualización Fase 6 — Ataque y Animación de Espada (02/11/2026)

- [x] Corrección de put_packet en Multijugador.gd (reemplazado send_text erróneo).
- [x] Soporte robusto de tecla 1 (ability_1, KEY_1, KEY_KP_1 físico y lógico).
- [x] Manejo de error local si se ataca sin objetivo (reason: no_target).
- [x] Animación procedural de ataque con balanceo de espada en Jugador.gd.
- [x] Suite de prueba unitaria herramientas/PruebaAnimacionCombate.gd.
- [ ] Reaparición (respawn) de criaturas tras morir tras un retardo en el servidor.
- [x] Probar combate y movimiento con dos clientes simultáneos (confirmado por el usuario).


## Actualización Fase 6 — Respawn autoritativo (02/11/2026)

- [x] Reaparición (respawn) de criaturas tras morir tras un retardo en el servidor (TIEMPO_RESPAWN = 6.0s).
- [x] Restauración de vida máxima, estado inicial de patrulla y posición original.
- [x] Validación unitaria de respawn en herramientas/PruebaCombate.gd.
- [x] Probar combate y movimiento con dos clientes simultáneos (confirmado por el usuario).

## Verificacion multijugador — 02/11/2026

- [x] Ejecutar servidor y dos clientes graficos simultaneamente.
- [x] Confirmar movimiento y combate entre los dos clientes (confirmacion del usuario).
- [ ] Continuar los sistemas MMORPG restantes segun la prioridad de desarrollo; no volver a listar esta prueba como pendiente.

## Actualizacion — 02/11/2026

- [x] Probar combate y movimiento con dos clientes simultaneos (confirmado por el usuario).
- [x] Preparar herramientas/iniciar_juego.ps1 para iniciar servidor y uno o dos clientes con logs y cierre automatico.
- [ ] Ejecutar y validar el lanzador actualizado en una futura sesion.
- [ ] Definir e iniciar el primer alcance de inventario/progresion (Fase 7).

## Fase 7 — inventario inicial — 02/11/2026

Implementacion escrita, aun sin verificacion en Godot:
- Catalogo compartido con Colmillo de lobo.
- Premio autoritativo por golpe final al lobo.
- Snapshot y actualizaciones de inventario por WebSocket.
- Panel de inventario visible en HUD.

- [ ] Verificar en juego que el atacante final recibe exactamente un colmillo, que el otro cliente no lo recibe y que el contador se ve en el HUD.
- [ ] Confirmar comportamiento tras respawn y durante la sesion; documentar que no persiste al desconectar.

Comprobaciones tecnicas — 02/11/2026:
- [x] Parseo GDScript de los cuatro archivos del inventario (Godot 4.7.2, codigo 0).
- [x] Sintaxis de herramientas/iniciar_juego.ps1.
- [ ] Verificar el bucle de botin en una partida con dos clientes.

## Fase 7 — verificacion del botin — 02/11/2026

- [x] Confirmar que cada cliente puede recibir Colmillo de lobo al derrotar su propio lobo en ejecucion (resultado confirmado por el usuario).
- [x] Parsear los scripts del inventario y el lanzador sin errores de sintaxis.
- [ ] Verificar en una misma pelea que el cliente que no asesta el golpe final no recibe el objeto.
- [ ] Implementar persistencia del inventario tras desconexion cuando se aborde Fase 8.

La lista anterior de verificaciones pendientes del primer bucle queda actualizada por este resultado manual; no se compartieron logs.

## Fase 7 — progresion temporal de experiencia (02/11/2026)

Implementado, aun pendiente de verificacion en juego:
- [x] Premio autoritativo de 25 XP al jugador que da el golpe letal al lobo.
- [x] Nivel inicial 1, con subida cada 100 XP y conservacion del excedente.
- [x] Snapshot en welcome y mensaje progression_updated por WebSocket.
- [x] Panel de nivel/XP conectado al HUD.
- [x] Parseo con Godot 4.7.2 de servidor, cliente y Main.gd; git diff --check limpio.
- [ ] Confirmar con dos clientes que solo el atacante final recibe XP y que el HUD se actualiza.
- [ ] Confirmar la subida al nivel 2 al acumular 100 XP.
- [ ] Implementar persistencia de inventario/progresion cuando corresponda en Fase 8.

El inventario inicial y la recompensa individual del colmillo ya fueron confirmados por el usuario. No se compartieron logs de esa partida. Fase 7 permanece abierta.
## Fase 7 — efecto jugable de los niveles (02/11/2026)

- [x] Aplicar daño melee autoritativo de 15 en nivel 1 y +2 por nivel adicional.
- [x] Incluir en attack_result el daño que realmente aplicó el servidor; el HUD existente lo presenta.
- [x] Comprobar parseo de Servidor.gd con Godot 4.7.2 (código 0).
- [ ] Confirmar en juego que el nivel 1 causa 15 de daño y que un nivel superior aumenta el daño esperado.
- [ ] Revisar el balance del bono de +2 después de verificar la progresión y el combate.

El sistema está implementado, no probado en partida. No se ejecutaron pruebas funcionales. El valor de balance puede ajustarse más adelante.
## Fase 7 — feedback de experiencia

- [x] Incluir en attack_result el XP otorgado por derrotar un lobo.
- [x] Mostrar el XP ganado en el aviso de combate del HUD.
- [x] Parseo de Servidor.gd y Main.gd con Godot 4.7.2, código 0.
- [ ] Confirmar el mensaje y el valor de XP en una partida con dos clientes.
- [ ] Confirmar que daño, XP y subida de nivel coinciden con el progreso individual.

Implementado en código; todavía no validado en juego.
## Fase 7 — aviso de subida de nivel

- [x] Marcar en el resultado del servidor si el golpe final produjo subida de nivel e incluir el nivel nuevo.
- [x] Mostrar el nuevo nivel en el aviso del HUD.
- [x] Parseo Godot 4.7.2 en Servidor.gd y Main.gd, código 0.
- [ ] Confirmar en juego el aviso de XP y la subida a nivel 2 al llegar a 100 XP.
- [ ] Confirmar que el daño del nivel 2 sea 17 según la regla provisional actual.

Implementado; la verificación sigue pendiente.
## Fase 7 — estado verificado y animación remota (02/11/2026)

Confirmado en juego por el usuario:
- [x] XP por bajas, subida de nivel y aumento de daño por nivel funcionan.
- [x] Combate, movimiento e inventario inicial ya habían sido confirmados en sesiones previas.

Implementado y parseado, pendiente de prueba visual:
- [x] El servidor envía `player_attack` a los otros clientes tras un golpe exitoso.
- [x] El cliente activa la animación procedural del atacante remoto identificado por ID.
- [x] Godot 4.7.2 --check-only pasó en Servidor.gd, Multijugador.gd y Jugador.gd.
- [x] Confirmar en una sesión de dos clientes que el segundo ve la animación del atacante (confirmado por el usuario).

El usuario reportó que la animación solo se veía en quien atacaba; esta sesión implementó el evento remoto. No se ejecutó una prueba funcional después del cambio.
## Fase 7 — botín ampliado del lobo (02/11/2026)

Implementado y parseado, pendiente de confirmación en juego:
- [x] Añadir Piel de lobo como material con pila máxima de 10.
- [x] Entregar una piel junto a un colmillo al atacante que da el golpe final al lobo.
- [x] Godot 4.7.2 --check-only pasó en CatalogoObjetos.gd, Servidor.gd, Multijugador.gd y Main.gd.
- [ ] Confirmar que ambos objetos aparecen en el panel y que solo los recibe el atacante final.
## Verificación solicitada — combate, botín y animación (02/11/2026)

- [x] Ejecutar siete pruebas existentes con Godot 4.7.2; todas terminaron en código 0.
- [x] Ampliar y pasar PruebaAnimacionCombate: evento `player_attack` anima al remoto y no duplica la animación del atacante.
- [x] Ampliar y pasar PruebaCombate: golpe final entrega un colmillo, una piel y 25 XP.
- [x] Ampliar y pasar PruebaDosClientesCombate: solo el jugador del golpe final recibe botín y XP.
- [x] Abrir servidor y dos clientes; ambos conectaron y validaron el mundo.
- [ ] El usuario comprobará en las ventanas abiertas que la animación se ve en el cliente observador y que el inventario muestra colmillo y piel solo en el atacante final.

La prueba automatizada del manejador no reemplaza la comprobación visual ni la prueba real de entrega entre procesos.
## Fase 7 — inventario con capacidad (estado actualizado 02/11/2026)

- [x] Capacidad inicial de 20 ranuras, apilamiento y límite de pila respetados por el servidor.
- [x] Contador de ranuras y lista desplazable añadidos al panel HUD.
- [x] El servidor envía rechazo por ranuras o pila llena y el cliente presenta el motivo.
- [x] Sintaxis Godot 4.7.2 comprobada en catálogo, servidor, cliente y Main.gd.
- [x] Añadir y ejecutar aserciones de ranuras llenas, apilado existente y pila máxima en PruebaCombate.gd; Godot 4.7.2 terminó con código 0.
- [ ] Comprobación visual del nuevo contador, desplazamiento y avisos en cliente (la hará el usuario).

El usuario confirmó que la funcionalidad de juego ya comprobada (incluidos combate, botín y animación remota) funciona. Esto no sustituye la futura comprobación visual del panel de capacidad, que todavía no se ha probado. Fase 7 permanece activa.
## ALCANCE VIGENTE — RPG PARA UN JUGADOR (02/11/2026)

Prioridad actual:
- [x] Acordar desarrollar primero el juego como experiencia de un solo jugador.
- [x] Preservar los sistemas y pruebas existentes para dos jugadores; aplazar ampliaciones online.
- [x] Prueba automatizada de capacidad del inventario: ranuras llenas, apilado existente y pila máxima; Godot 4.7.2 terminó con código 0.
- [ ] Dejar al usuario la comprobación visual del contador, desplazamiento, descarte y avisos del inventario.
- [x] Completar los objetos iniciales, uso de poción, equipamiento de espada y descarte validado por servidor.
- [x] Desarrollar interacción con NPC y cadena de cinco misiones individuales.
- [x] Implementar prototipo de mundo, tres enemigos con IA/combate y progresión; completar variedad/balance permanece pendiente.
- [x] Implementar guardado/carga local del personaje y su progreso, y comprobar inicio/cierre/reanudación en la integración individual.
- [x] Verificar conexión y combate con un único cliente sin requerir una segunda instancia.
- [ ] Auditar requisitos funcionales y hacer balance final de la primera zona.

Etapa posterior:
- El código, escenas, recursos y tests multijugador existentes se conservan.
- Retomar más adelante la revisión de sincronización, seguridad, persistencia compartida y pruebas de dos jugadores.
- No eliminar entradas históricas o tareas online del backlog.

## Fase 7 — salud y respawn
- [x] Vida autoritativa, daño del lobo, muerte, espera y reaparición con vida completa.
- [x] Bloqueo local de movimiento/ataque durante la muerte y sincronización del respawn.
- [x] Barra de salud y cuenta atrás añadidas al HUD.
- [x] Las siete pruebas existentes pasan en Godot 4.7.2, incluida la prueba cooperativa de dos clientes.
- [x] Servidor y cliente headless conectan y validan el mundo.
- [ ] El usuario revisará visualmente la barra y la cuenta atrás junto al panel de inventario.
- [ ] Ajustar el balance de daño y tiempos tras la revisión de juego.

Siguiente prioridad individual: completar uso/equipamiento de objetos, NPC y una misión corta, y luego guardado/carga local. El juego todavía usa la conexión local cliente-servidor; el script de inicio admite un solo cliente y no exige una segunda instancia. No eliminar ni modificar destructivamente el código multijugador.

## Inicio individual integrado
- [x] El mapa principal inicia un servidor local dentro del mismo proceso por defecto.
- [x] El lanzador multicliente selecciona explícitamente el modo de servidor externo.
- [x] Comprobados ambos caminos headless: conexión y validación del mundo correctas.
- [x] Siete pruebas automatizadas y cinco chequeos estáticos pasaron después del cambio.
- [ ] El usuario revisará visualmente salud, respawn e inventario en el cliente.

Siguiente: objetos utilizables/equipamiento, NPC y misión corta, persistencia local. Mantener los sistemas de dos clientes íntegros para la etapa posterior.

## Misión individual: Caza de lobos
- [x] Interacción E con NPC seleccionado y validación de proximidad en el servidor.
- [x] Aceptación de misión individual, progreso por tres lobos y estado completado.
- [x] Recompensa de 50 XP y actualización del HUD.
- [x] Prueba automatizada de distancia, aceptación, contador, finalización y XP; pasa dentro de PruebaCombate.
- [x] Siete pruebas, cinco chequeos estáticos y arranques headless integrados/externos correctos.
- [ ] El usuario revisará visualmente selección Tab + E, panel de misión y avisos.

Siguiente prioridad: objetos utilizables y equipamiento, luego persistencia local y más contenido/misiones. Mantener los sistemas existentes de dos jugadores.

## Consumible y equipo
- [x] Poción curativa de hasta 35 HP, consumo validado por el servidor y límite de vida máxima.
- [x] Rechazo al usarla con vida completa sin gastar el objeto; tecla 2.
- [x] Espada del Habitante como recompensa; equipamiento validado y +5 de daño; tecla Q.
- [x] HUD de arma equipada y avisos de consumo/equipamiento.
- [x] Prueba de combate verifica pociones y daño nivel 2 + espada = 22.
- [x] Siete pruebas, seis chequeos estáticos y ambos arranques headless pasan.
- [ ] El usuario revisará visualmente los controles 2/Q y paneles de salud, misión, arma e inventario.
- [ ] Guardar/cargar localmente inventario, XP/nivel, misión, equipo, vida y posición.

Después del guardado, ampliar NPC/misiones y contenido de mundo. Preservar la suite y los recursos multijugador.

## CONTINUIDAD MÁS RECIENTE — 02/11/2026

Guardado/carga local inicial completados y verificados. Se persisten posición/orientación, HP, inventario, XP/nivel, misión y equipo en `user://classicrpg_partida.json`; autosave cada 10 s y al cambiar estado, daño/respawn, desconexión y cierre. El servidor externo no lee ni escribe el archivo. La prueba de round-trip en `user://` pasa y borra el temporal.

Verificación: las siete pruebas Godot 4.7.2 pasan; siete scripts pasan `--check-only`. No se abrió GUI y la revisión visual de HUD/controles sigue a cargo del usuario. Sin commit ni push.

Siguiente: crear una segunda misión de entrega de materiales al Habitante, validar cercanía/estado/cantidad y consumo del inventario, añadir cobertura automatizada; después revisar el ciclo de inicio, continuación y cierre y ampliar el contenido de la primera zona.
## CONTINUIDAD MÁS RECIENTE — SEGUNDA MISIÓN (02/11/2026)

- [x] Tras «Caza de lobos», iniciar «Entrega de pieles» al hablar con el Habitante.
- [x] Registrar pieles de lobo reunidas durante la misión y reflejar el avance en el HUD.
- [x] Validar NPC, cercanía, estado y cantidad antes de aceptar la entrega.
- [x] Rechazar cantidades incompletas sin consumir; al completar, consumir exactamente tres y preservar sobrantes.
- [x] Otorgar 75 XP y guardar/cargar el estado de esta misión.
- [x] Añadir cobertura a `PruebaCombate.gd` y `PruebaPartidaIndividual.gd`.
- [x] Ocho pruebas Godot 4.7.2 pasan; seis scripts pasan `--check-only`; `git diff --check` pasa.
- [x] Probar el inicio individual integrado y el guardado al cerrar con un cliente headless, sin un segundo cliente.
- [ ] El usuario revisará visualmente el HUD y los controles. No abrir GUI desde esta sesión.
- [ ] Ampliar variedad de misiones/criaturas, mundo y habilidades; revisar el flujo de sesión y balance.

Siguiente tarea: auditar guardados inválidos y cierres/reaperturas, y luego desarrollar el siguiente contenido de la primera zona. Mantener la base de dos jugadores intacta. No commit ni push.
## CONTINUIDAD MÁS RECIENTE — RECUPERACIÓN SEGURA DE PARTIDAS (02/11/2026)

- [x] Recuperar una partida nueva ante JSON corrupto sin detener Godot.
- [x] Rechazar versiones de guardado no compatibles.
- [x] Normalizar tipos y valores inválidos en inventario, progresión, salud, misión, equipo y posición.
- [x] Probar los tres escenarios en un archivo temporal aislado y eliminarlo al terminar.
- [x] Ocho pruebas Godot 4.7.2 pasan; seis `--check-only` pasan; `git diff --check` termina correctamente.
- [x] Probar la escena inicial individual con servidor integrado y un único cliente headless; validar mundo y guardado al cerrar.
- [ ] Revisión visual de HUD/controles por el usuario; no abrir GUI desde esta sesión.
- [ ] Ampliar criaturas, misiones y habilidades; revisar flujo de sesión y balance.

No se tocó ni creó `classicrpg_partida.json`; la base y pruebas multijugador siguen presentes. Siguiente: ampliar contenido de la primera zona y después revisar el flujo completo de sesión. Sin commit ni push.
## CONTINUIDAD MÁS RECIENTE — REANUDAR PARTIDA (02/11/2026)

- [x] La prueba individual inicia la escena real con servidor integrado y un único cliente headless.
- [x] Cierra la escena y guarda una sesión local temporal.
- [x] Reabre la escena y comprueba restauración de posición, inventario, nivel/XP, salud, misión, arma y HUD.
- [x] El guardado temporal se elimina; no se creó ni tocó `classicrpg_partida.json`.
- [x] Ocho pruebas pasan; seis `--check-only` pasan; `git diff --check` pasa.
- [ ] Revisión visual de HUD/controles a cargo del usuario.
- [ ] Añadir más contenido/variedad de criaturas, habilidades y misiones; revisar balance y flujo de sesión.

El núcleo de guardado/carga individual está verificado entre sesiones. Mantener Fase 7 abierta y conservar intacta la base multijugador. Siguiente: ampliar contenido de la primera zona. Sin commit ni push.

## ACTUALIZACIÓN VIGENTE — GOLPE PESADO (02/11/2026)

- [x] Tecla 3 ejecuta golpe pesado; tecla 2 para poción y Q para equipo permanecen intactas.
- [x] Servidor valida la habilidad, el objetivo y la recarga exclusiva de 6 s; el golpe inflige el doble del daño normal.
- [x] Animación local/remota distinta con transmisión del tipo de habilidad.
- [x] Cobertura unitaria de daño, habilidad inválida, recarga y aislamiento entre jugadores.
- [x] Prueba headless de escena real envía el golpe por el servidor integrado; ocho pruebas del proyecto terminaron con código 0.
- [ ] Añadir variedad de criaturas, actividades/misiones y habilidades; revisar balance.
- [ ] El usuario revisará visualmente los controles y el HUD; no abrir clientes gráficos en esta sesión.

Pruebas Godot 4.7.2: siete pruebas unitarias y la prueba individual integrada pasaron; --check-only pasó en los scripts de juego y prueba; git diff --check terminó sin errores. La integración volvió a abrir y validar el guardado temporal; no creó ni tocó classicrpg_partida.json. Puerto 9000 quedó libre. Sin commit ni push.

## ACTUALIZACIÓN VIGENTE — JABALÍ DEL BOSQUE (02/11/2026)

- [x] Segunda criatura registrada en la zona como entidad 4 y creada por la fábrica cliente.
- [x] Patrulla autoritativa independiente y ataque enemigo de 14 de daño con recarga propia de 2 s.
- [x] Botín de colmillo/carne, 35 XP y respawn a 80 HP.
- [x] Ocho pruebas funcionales pasan; once scripts pasan --check-only; git diff --check pasa.
- [x] La prueba individual recibe al jabalí y envía golpe pesado por la conexión local; luego valida guardar/reabrir.
- [ ] El usuario revisará visualmente la criatura, los controles y el HUD; no se abrió GUI.
- [ ] Añadir más actividades/variedad, continuar misiones con los nuevos materiales y balancear.

Godot 4.7.2; puerto 9000 quedó libre. No se tocaron los guardados permanentes ni se hizo commit/push. Fase 7 sigue activa.


## Seguimiento tras tercera misión — 02/11/2026

Completado y comprobado: misión de carne de jabalí, guardado/reanudación de la partida individual, batería funcional de ocho pruebas, 14 chequeos GDScript y diff check. Pendiente: revisión visual de HUD/controles por el usuario; ampliar contenido de zona, variedad de misiones/habilidades y balance; auditar flujo de sesión completo y requisitos de cierre de Fase 7. No declarar proyecto terminado hasta completar esa auditoría. Mantener dos jugadores y sus pruebas intactos; no commit/push.

## Misión de caza de jabalíes — 02/11/2026

Tras entregar las provisiones se habilita la caza de tres jabalíes. El servidor cuenta las bajas autoritativamente, actualiza el HUD, recompensa 60 XP al completar además de XP normal por criatura y guarda/restaura el estado de misión. PruebaCombate.gd pasó con código 0 y ya valida aceptación, tres bajas, XP total y normalización de estado completado. Servidor.gd y Main.gd pasaron --check-only previamente; diff check pasó tras esta ampliación. La fase individual sigue abierta para más contenido, balance y auditoría final. No commit/push; preservar multijugador.

Actualización de recompensa final de misión (02/11/2026): al completar la caza de tres jabalíes, se pueden reclamar dos pociones curativas una sola vez hablando con el Habitante. La marca recompensa_reclamada persiste en la misión normalizada, evitando duplicación tras reconexión. PruebaCombate valida la reclamación única; Godot 4.7.2 --check-only en servidor y prueba pasó, PruebaCombate exit 0 y git diff --check pasó. Pendiente repetir integración individual completa tras cambio de serialización de misión.

Revalidación de marca de recompensa (02/11/2026): tras persistir recompensa_reclamada, PruebaPartidaIndividual, PruebaDosClientesCombate y PruebaCombate pasaron con código 0 en Godot 4.7.2. La integración confirma carga/guardado/reapertura y HUD; la prueba de dos clientes conserva el modo de red. git diff --check pasó. Temporales de integración en Documents/Codex; sin modificación del guardado permanente, sin GUI ni commit/push.

Menú de inicio individual añadido (02/11/2026): la escena principal ahora presenta nueva partida, continuar cuando hay un guardado local y salir. Para evitar pérdida accidental, Nueva partida se desactiva si ya hay guardado; Continuar se habilita solo con archivo existente. El menú no arranca servidor hasta entrar al mapa y muestra controles básicos. MenuInicio.gd pasó --check-only; ejecutar la escena por defecto headless con --quit-after 2 terminó con código 0; git diff --check pasó. La revisión gráfica corresponde al usuario. Falta probar interacción de botones gráficamente y cubrir estados del menú; el proyecto sigue abierto, multijugador preservado, sin commit/push.

Prueba del menú inicial (02/11/2026): se añadió PruebaMenuInicio.gd con ruta temporal en Documents/Codex. Comprueba en headless que sin guardado permite Nueva partida y bloquea Continuar, y con guardado hace lo inverso; el temporal se elimina. MenuInicio.gd y su prueba pasan --check-only; PruebaMenuInicio terminó con código 0 y git diff --check pasó. No lee, modifica ni elimina el guardado real. Revisión gráfica de disposición y navegación por botones aún pendiente del usuario.

Regresión completa tras cambio a menú inicial (02/11/2026): nueve pruebas pasaron con código 0: menú, targeting, NPC, fábrica, entidades, dos clientes, combate, animación e integración individual. Dieciséis scripts pasaron --check-only y git diff --check pasó. El menú ahora es escena principal; el mapa conserva su uso directo en las pruebas y en el cliente. Continúan pendientes la revisión gráfica del usuario, balance/experiencia de sesión y auditoría final de requisitos; Fase 7 abierta. Sin commit/push; multijugador preservado.

Resistencia a inventario lleno en recompensas (02/11/2026): el servidor valida que quepan las dos pociones antes de marcar la recompensa como reclamada. Si la pila está en 9/10, no consume ni bloquea la reclamación; al bajar a 8/10 permite recibir hasta 10 y luego evita duplicación. PruebaCombate cubre este caso, normalización de la marca y recompensa única; prueba exit 0, servidor/test --check-only y diff check pasan.

Flujo de reinicio seguro (02/11/2026): el menú permite borrar el archivo local solo mediante un ConfirmationDialog que explica que el progreso se eliminará. Sin guardado, borrar está deshabilitado; con guardado, nueva partida se bloquea y continuar/borrar se habilitan. Tras confirmar el borrado, nueva partida queda disponible. PruebaMenuInicio valida los tres estados y la conexión del diálogo usando un archivo temporal aislado; Godot 4.7.2 test exit 0, ambos scripts --check-only y diff check pasan. El guardado real solo se elimina tras confirmación explícita del jugador.

Regresión del ciclo de sesión tras habilitar borrado confirmado (02/11/2026): nueve pruebas funcionales terminaron con código 0; dieciséis scripts pasaron --check-only; git diff --check pasó. Se cubren estados del menú, confirmación de borrado en temporal, escenas de red de uno y dos clientes, combate, misiones, guardado/reanudación. La prueba no borra ni modifica la partida permanente. Pendiente: prueba manual visual de menú/controles y auditoría final contra requisitos de cierre de RPG individual.

Pausa y retorno al título verificados (02/11/2026): P abre panel con árbol pausado; Reanudar lo cierra. Guardar/volver llama a persistencia antes del cambio de escena. La integración individual de dos sesiones pasó con código 0 y valida pausa/reanudación, guardado/carga, HUD y estado. Para evitar colisiones WebSocket al reiniciar en la misma prueba, el servidor integrado elige un puerto libre entre 9000–9099 y configura el cliente local con esa dirección; Multijugador.gd conserva ws://127.0.0.1:9000 por defecto para servidores externos. PruebaDosClientesCombate, PruebaCombate y PruebaMenuInicio pasaron; Main/servidor/cliente/test de integración pasaron --check-only; diff check pasó. Pendiente revisión gráfica del usuario y auditoría final. Sin commit/push.

## Relevo urgente — 02/11/2026

Estado comprobado en este relevo: el árbol de trabajo conserva cambios locales no preparados y archivos nuevos; no se hizo commit ni push. La nota previa documenta que Godot 4.7.2 pasó la integración individual (reapertura/guardado, estado y HUD), más PruebaDosClientesCombate, PruebaCombate y PruebaMenuInicio; `git diff --check` pasó. El menú inicial, la pausa P, el reanudar y el guardado antes de pedir volver al título están implementados. Precisión: la integración citada ejercitó pausa/reanudación y reabrir sesión; el clic real de «Guardar y volver al título» y la revisión visual del menú aún requieren comprobación del usuario. No tocar el guardado de producción `user://classicrpg_partida.json`.

Siguiente paso al retomar: abrir el juego en Godot 4.7.2, revisar menú/controles, iniciar o continuar, abrir pausa y comprobar «Guardar y volver al título»; luego continuar auditoría de contenido/balance de Fase 7. Mantener el modo individual como prioridad, preservar íntegra la infraestructura y pruebas de dos jugadores. No declarar terminado ni crear commit/push hasta cerrar el protocolo y la revisión pendiente.

## Actualización — retorno al título

- [x] Verificar mediante la integración individual el botón «Guardar y volver al título», JSON válido con inventario/misión, persistencia previa al cambio de escena y carga de `MenuInicio.tscn`.
- [x] Suite funcional de nueve pruebas Godot 4.7.2: menú, targeting, NPC, fábrica, estado de entidades, combate/misiones, animación remota, dos clientes y partida individual; todas exit 0.
- [ ] Revisión visual del menú, HUD y controles por el usuario; esta sesión no abrió GUI.
- [ ] Seguir ampliando contenido y balance, y auditar requisitos del RPG individual antes de cerrar Fase 7.

No se modificó `user://classicrpg_partida.json`. Mantener los archivos locales existentes y la infraestructura multijugador; sin commit ni push.

## Estado actual — contenido del limo (02/11/2026)

- [x] Tercera criatura del bosque integrada con visual, IA de patrulla/ataque, botín, XP y respawn comprobados.
- [x] Quinta misión individual: entrega de tres gelatinas, contador, rechazo sin consumo, sobrantes, XP y normalización de guardado.
- [x] Suite funcional de nueve pruebas, nueve chequeos sintácticos y diff check pasan con Godot 4.7.2.
- [ ] Revisión visual por el usuario de menú, HUD, controles y criatura; no abrir GUI desde esta sesión.
- [ ] Continuar contenido de zona, revisar balance y auditar el ciclo individual completo antes de cerrar Fase 7.

Preservar la red y pruebas de dos clientes. No tocar el guardado de producción ni hacer commit/push.

## Opción para descartar objetos (02/11/2026)

- [x] Completar UI de selección y botón, envío/recepción cliente y procesamiento autoritativo en servidor.
- [x] Validar objeto conocido, propiedad y estado vivo; retirar una unidad, auto-desequipar si se elimina la última unidad del arma activa, actualizar contador de misión, inventario y guardado local.
- [x] Pedir confirmación en español; cancelar conserva los objetos y confirmar descarta exactamente una unidad.
- [x] Cubrir casos válidos y rechazos en `PruebaCombate`; verificar el flujo del HUD sobre WebSocket en `PruebaPartidaIndividual`.
- [x] Suite de nueve pruebas Godot 4.7.2 y `git diff --check` pasan.
- [ ] Revisión visual del usuario para inventario/HUD; no se abrió GUI.

## Economía inicial — 02/11/2026

- [x] El servidor otorga oro por cinco hitos: caza del lobo (30), entrega de pieles (15), entrega de carne de jabalí (25), caza de jabalíes (30) y entrega de gelatina de limo (35).
- [x] El Habitante vende pociones curativas por 20 de oro; el servidor comprueba proximidad, vida del jugador, objeto, saldo, pila e inventario antes de cobrar.
- [x] El saldo se incluye en el guardado local; las partidas antiguas sin el campo gold cargan con 0.
- [x] Pruebas recientes: normalización de oro, compra correcta y rechazos, persistencia, recompensa de la primera misión e integración del botón de compra por WebSocket con reapertura.
- [x] PruebaCombate verifica los pagos de pieles, carne, caza de jabalíes y gelatina respecto al saldo previo; prueba exit 0 en Godot 4.7.2.
- [ ] Auditoría final de requisitos y experiencia completa de la primera zona. Fase 7 sigue abierta.

No se modificó el guardado de producción; no se hicieron commit ni push. La base y las pruebas multijugador siguen preservadas.

## Regresión para prueba del usuario — 02/11/2026

- [x] La escena principal sigue siendo MenuInicio.tscn; Nueva partida/Continuar y la apertura del mundo individual están cubiertos por pruebas.
- [x] Las nueve pruebas funcionales terminaron con código 0 en Godot 4.7.2: menú, targeting, NPC, fábrica de entidades, estado, dos clientes, combate, animación e integración individual.
- [x] PruebaPartidaIndividual abre dos sesiones individuales, valida compra por HUD/WebSocket, guardado, carga, atributos, misión y retorno al menú.
- [ ] Falta la comprobación visual del usuario y continuar contenido/balance/auditoría de la primera zona.

La primera repetición de la integración en este turno no conectó por falta de permiso de loopback del entorno; tras habilitarlo, la prueba pasó sin cambio de código. Logs de la suite guardados en Documents/Codex/ClassicRPG-suite-20261102-193000. No se modificó la partida de producción; sin commit/push; conservar las pruebas multijugador.

## HUD inicial — estado 02/11/2026

- [x] Retrato del modelo actual, vida conectada, marco de objetivo con nombre/vida real, minimapa con posición y orientación del jugador.
- [x] Maná visual sin simular estado de juego y seis espacios vacíos de acción, sin interacciones ni habilidades nuevas.
- [x] Pruebas automatizadas del HUD, targeting e integración individual pasaron con Godot 4.7.2.
- [ ] El usuario revisará el resultado visual dentro del juego. No abrir GUI desde esta sesión.
- [ ] Conectar maná o acciones solo cuando existan sus datos y sistemas de juego.

## Modelo 3D del jugador — Quaternius (02/11/2026)

- [x] Localizar el paquete Standard oficial y revisar modelos, texturas, licencia y rig.
- [x] Comprobar UBC: no estaba instalado; revisar su paquete Standard y confirmar nombres de huesos compatibles. La escena usa el ensamblado Male_Ranger con su propia malla Head_Hood, sin dependencia UBC en runtime.
- [x] Importar las 9 mallas, 6 texturas y esqueleto humanoide de 65 huesos en Godot 4.7.2.
- [x] Instanciarlo bajo Modelo y conservar oculto el aspecto provisional, sin borrar nodos ni alterar Jugador.gd.
- [x] Verificar escala, materiales, colisión, referencias, movimiento move_forward, HUD y targeting mediante comprobaciones headless.
- [ ] Revisión visual del usuario dentro del juego: orientación, ajuste del atuendo y retrato.
- [ ] Añadir retarget de locomoción/combate solo en una tarea posterior. El modelo aún no anima y no trae arma.
- [ ] Si el usuario desea un Knight concreto en vez del atuendo Ranger disponible en Standard, evaluar después la versión Source; no se adquirió ni se descargó su contenido de pago.

Fase 7 continúa abierta. Sin commit/push y con la base multijugador preservada.

## Revalidación de cabeza y locomoción Quaternius — 02/11/2026

- [x] Corregir la escena estática: el esqueleto Ranger y el rig de la cabeza reciben las curvas procedurales existentes para reposo, marcha/carrera, sprint, salto, caída y aterrizaje.
- [x] Completar la cara con malla de cabeza/cuello, ojos y cejas del UBC Standard masculino; conservar las proporciones y el atuendo Male_Ranger, y mantener el personaje provisional oculto como respaldo.
- [x] Godot 4.7.2: 12/12 pruebas headless pasan, incluidas prueba nueva del rig y animaciones, prueba de dos clientes y partida individual WebSocket.
- [ ] El usuario comprobará visualmente la cara dentro del capuchón, el ajuste de ropa/cuerpo y el movimiento en juego. No se abrió la ventana gráfica.
- [ ] Si la inspección demuestra que hace falta una malla Regular de piel bajo el atuendo, conseguir una base Regular compatible: la descarga Standard local solo trae cuerpo masculino Superhero y el propio README advierte clipping al poner el cuerpo completo. No se obtuvo el paquete Source de pago.
- [ ] No hay clips de animación externos; el movimiento animado continúa en el controlador Jugador.gd con curvas procedurales.

No tocar sistemas de movimiento/física, cámara, controles, targeting, HUD, guardado o multijugador. Fase 7 sigue activa; preservar el trabajo local; sin commit/push.

## Revalidación de orientación y animaciones oficiales — 02/11/2026

- [x] Male_Ranger mira hacia el vector de movimiento mediante su nodo visual, sin cambiar yaw lógico, controles ni movimiento.
- [x] UAL Standard está importada y retargetea 65 huesos para el Ranger y la cabeza. `AnimationTree` cubre Idle, ocho direcciones de BlendSpace, Jog_Fwd, Sprint, inicio de salto, ciclo aéreo, caída y aterrizaje.
- [x] Godot 4.7.2: prueba específica limpia y batería completa 12/12 con código 0.
- [ ] El usuario hará la revisión visual final de la orientación, la transición al cambiar de dirección y la apariencia de los ciclos.
- [ ] Limitación de UAL Standard: los ocho puntos direccionales comparten el único clip Walk disponible; no hay ciclos de caminar separados por dirección ni clip Fall dedicado. Se usa Jump durante la caída. Si se desea animación direccional/caída específica, evaluar un paquete compatible que incluya esos clips.

No abrir GUI ni evaluar estética por cuenta del agente. Fase 7 sigue activa; conservar todos los cambios locales; sin commit/push.

## Limpieza solicitada — 02/11/2026

- [x] Retirar copias locales `.bak`/`RESPALDO` sin referencias, cursores alternativos no usados y escena vacía no referenciada.
- [x] Conservar el modelo anterior como respaldo de escena y los paquetes fuente originales.
- [ ] El usuario decidirá si más adelante quiere retirar otros recursos fuente de paquetes; se conservaron para respetar la instrucción anterior de no eliminar originales.
