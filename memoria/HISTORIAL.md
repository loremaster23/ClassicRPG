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