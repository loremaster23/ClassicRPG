# CLASSICRPG — TAREAS PENDIENTES

Última revisión: 01/11/2026

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
- [ ] Revisar y unificar los modos de órbita.
- [ ] Revisar el zoom y la detección de obstáculos.
- [ ] Implementar o corregir los controles anunciados en el HUD.
- [ ] Evaluar compatibilidad con mando.
- [ ] Implementar las acciones de interacción, selección de objetivo y habilidades cuando corresponda.

## Multijugador

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

## Sistemas MMORPG

- [ ] Combate.
- [ ] Atributos.
- [ ] Niveles y experiencia.
- [ ] Inventario.
- [ ] Equipamiento.
- [ ] Botín.
- [ ] NPC.
- [ ] Enemigos.
- [ ] Misiones.
- [ ] Habilidades.
- [ ] Economía.
- [ ] Guardado de progreso.

## Mundo

- [ ] Desarrollar el mundo inicial.
- [ ] Crear regiones.
- [ ] Crear ciudades.
- [ ] Crear mazmorras.
- [ ] Crear criaturas originales.
- [ ] Mejorar ambientación.
- [ ] Incorporar música.

## Próxima prioridad

La auditoría inicial de arquitectura y scripts está realizada.

El siguiente paso es decidir qué sistema desarrollar, definiendo un alcance concreto y preservando los cambios locales existentes.

No comenzar una implementación nueva sin identificar primero los archivos afectados y comprobar el estado actual del proyecto.

## Regla

No marcar como completado algo que no haya sido comprobado.

Actualizar esta lista después de cada tarea importante.
## Estado oficial de fases — actualización 01/11/2026

Criterio acordado con el usuario:

- [x] Fase 1 — Arquitectura y organización.
- [x] Fase 2 — Conexión multijugador.
- [x] Fase 3 — Sincronización básica.
- [x] Fase 4 — Personajes, animaciones y estados. Aceptada para continuar por decisión del usuario.
- [ ] Fase 5 — Mundo y entidades. FASE ACTUAL.
- [ ] Fase 6 — Combate.
- [ ] Fase 7 — Inventario y progresión RPG.
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