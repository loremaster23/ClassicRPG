# CLASSICRPG — DECISIONES

No modificar estas decisiones sin consultar al usuario.

## Motor

- Godot 4.7.2.
- No migrar a Unity ni Unreal.
- Mantener GDScript.

## Arquitectura

- Mantener separación cliente-servidor.
- Comunicación WebSocket.
- Evolucionar hacia un servidor autoritativo.

## Continuidad

- Continuar el proyecto existente.
- No empezar de cero.
- No descartar cambios locales.
- Mantener la guía histórica.
- Utilizar memoria/ como sistema compartido.

## Personaje

- Conservar el personaje actual.
- Los modelos nuevos deben desarrollarse independientemente.
- No sustituir el personaje sin autorización.

## Dirección artística

- Fantasía medieval.
- Referencia visual principal: WoW Classic.
- Influencias distribuidas de Skyrim, Harry Potter y Avatar.
- Identidad visual propia.
- No copiar literalmente diseños protegidos.

## Modelo de caballero

- Blender 5.2.3.
- Conservar archivos BLEND, GLB y scripts.
- Mejorar la calidad antes de integrar.

## Git

- No commits sin autorización.
- No pushes sin autorización.
- No operaciones destructivas sin autorización.

## NUEVAS DECISIONES

### 2026-11-02 — Prioridad de desarrollo para un jugador

Decisión:
Desarrollar primero ClassicRPG como RPG 3D para un solo jugador. Aplazar la siguiente expansión de funciones exclusivamente multijugador hasta completar el alcance individual. No eliminar ni sobrescribir el trabajo para dos jugadores ya desarrollado; se retomará en una etapa posterior.

Motivo:
Completar primero el ciclo central de juego RPG y reducir dependencias de una segunda persona durante el desarrollo y la comprobación del contenido.

Consecuencias:
- Priorizar combate individual, mundo, enemigos, NPC, inventario, objetos, equipamiento, misiones, progresión y guardado local.
- Hacer que el flujo individual no dependa de abrir un segundo cliente.
- Mantener el modo de dos jugadores y su código/pruebas existentes preservados.
- Al retomar el multijugador, reutilizar y completar la base existente en vez de empezar de cero.
- No cambiar de motor ni descartar decisiones arquitectónicas existentes por esta prioridad.

Archivos afectados:
memoria/DECISIONES.md, memoria/LEEME_PRIMERO.md, memoria/REGLAS_IA.md, memoria/ESTADO_ACTUAL.md, memoria/PENDIENTES.md, memoria/CONTINUAR_CON_IA.md, memoria/HISTORIAL.md y GUIA_CONTINUIDAD_CLASSICRPG.txt.
### AAAA-MM-DD — Título

Decisión:
Motivo:
Consecuencias:
Archivos afectados:

### 2026-11-02 — Mantener el atuendo Ranger y usar solo la cabeza UBC Standard

Decisión:
Conservar Male_Ranger y añadir únicamente cabeza/cuello, ojos y cejas extraídos del UBC Standard masculino gratuito. No superponer el cuerpo UBC Superhero completo ni reemplazar el personaje por otro paquete.

Motivo:
El README del atuendo indica que sus piezas visibles ya conforman el cuerpo vestido y que añadir el cuerpo base completo causa clipping. El UBC Standard disponible solo contiene la variante masculina Superhero, mientras el atuendo Ranger está hecho para Regular. Las posiciones de reposo de cabeza/cuello coinciden entre rigs.

Consecuencias:
- La locomoción sigue siendo procedural en Jugador.gd y se mapea por nombres humanoides a los rigs del atuendo y de la cabeza.
- Si se necesita una malla corporal Regular bajo la ropa, buscar una fuente compatible o solicitar autorización antes de comprar UBC Source; no improvisar una malla ni usar el cuerpo Superhero completo.
- La integración técnica queda pendiente de revisión visual del usuario.

Archivos afectados:
Jugador.gd, Personajes/Jugador.tscn, assets/modelos/quaternius/universal_base_characters_standard/.

### 2026-11-02 — Animar Male_Ranger con UAL Standard sin alterar locomoción

Decisión:
Usar el GLB in-place de Universal Animation Library Standard como fuente de clips, retargetear su esqueleto humanoide al Ranger y a la cabeza mediante `RetargetModifier3D`, y mantener el `AnimationTree` como parte visual del jugador. Alinear visualmente el frente Quaternius al vector de velocidad en `VisualQuaternius`, sin rotar el nodo lógico Modelo.

Motivo:
El GLB de Male_Ranger no incluye clips; el UAL Standard oficial provee locomoción, carrera/sprint y salto que coinciden en nombres de huesos. Los ciclos in-place mantienen el control del desplazamiento en el controlador existente.

Consecuencias:
- Se conserva Jugador.gd, el movimiento, controles, yaw lógico y el modelo provisional oculto. El cálculo de salto solo comunica el inicio al árbol de animación.
- El paquete Standard tiene un único clip Walk y no incluye Fall: se reutiliza Walk en los ocho puntos del BlendSpace y Jump durante la caída. No hay ciclos distintos de strafe/retroceso.
- La prueba automatizada valida retarget, pose y transiciones; la inspección visual dentro del juego queda a cargo del usuario.

Archivos afectados:
Jugador.gd, Personajes/Jugador.tscn, herramientas/PruebaModeloAnimacionesQuaternius.gd, assets/modelos/quaternius/universal_animation_library_standard/ y memorias.
