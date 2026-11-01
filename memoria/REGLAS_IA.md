# REGLAS OBLIGATORIAS PARA TODAS LAS IA

## 1. Continuidad

- Trabajar siempre sobre ClassicRPG.
- No empezar de cero.
- No reconstruir sistemas existentes sin necesidad.
- Leer la memoria antes de trabajar.
- Comprobar los archivos reales.
- No asumir que la documentación está actualizada.

## 2. Protección

- No borrar archivos sin autorización.
- No sobrescribir trabajo existente.
- No modificar archivos fuera del alcance autorizado.
- No descartar cambios locales.
- No crear copias de seguridad innecesarias.
- No reemplazar el personaje actual por modelos experimentales.

## 3. Autorización

Antes de modificar archivos:

1. Explicar qué se modificará.
2. Indicar los archivos afectados.
3. Explicar el resultado esperado.
4. Esperar autorización expresa.

La autorización para una tarea no autoriza otras modificaciones.

## 4. Git

- Comprobar git status antes de trabajar.
- Identificar cambios locales y archivos nuevos.
- No ejecutar git reset, git clean o checkout destructivos.
- No hacer commits sin autorización.
- No hacer pushes sin autorización.
- No cambiar de rama sin autorización.

## 5. Código

- Respetar la arquitectura existente.
- No inventar funciones, nodos o rutas.
- Inspeccionar implementaciones antes de utilizarlas.
- Evitar cambios que rompan funcionalidades.
- Comprobar los resultados reales.

## 6. Godot

- Versión actual: Godot 4.7.2.
- No cambiar de motor.
- No migrar de versión sin autorización.
- Comprobar nodos, señales y recursos.
- No asumir que un recurso está integrado porque existe en una carpeta.

## 7. Modelado 3D

- Utilizar Blender 5.2.3.
- Conservar archivos fuente y exportaciones.
- No eliminar versiones anteriores.
- No integrar modelos experimentales sin autorización.
- Priorizar calidad visual y coherencia artística.

## 8. PROTOCOLO OBLIGATORIO DE MEMORIA

La IA es responsable de mantener actualizada la memoria.

No debe esperar a que el usuario solicite guardar los avances.

### Antes de comenzar una tarea

- Leer la memoria.
- Comprobar el estado real.
- Identificar los cambios locales existentes.
- Determinar el objetivo.

### Después de completar una tarea

Actualizar inmediatamente:

ESTADO_ACTUAL.md:
- Qué cambió.
- Qué está implementado.
- Qué está comprobado.
- Qué continúa pendiente.

HISTORIAL.md:
- Fecha.
- Objetivo.
- Trabajo realizado.
- Archivos afectados.
- Resultado comprobado.

PENDIENTES.md:
- Marcar tareas completadas.
- Añadir nuevas tareas.
- Actualizar prioridades.

DECISIONES.md:
- Registrar decisiones permanentes.
- Explicar sus motivos y consecuencias.

CONTINUAR_CON_IA.md:
- Actualizar el punto exacto de continuidad.
- Indicar la siguiente tarea.

No modificar documentos que no necesiten cambios.

### Durante tareas largas

No esperar a terminar toda la tarea.

Registrar los avances importantes a medida que se producen.

Si se modifica código y después se resuelve un error, registrar ambos resultados.

### Antes de terminar una sesión

Comprobar que:

- La memoria refleja el estado actual.
- No hay cambios importantes sin documentar.
- Los errores pendientes están registrados.
- El siguiente paso está indicado.
- No se ha perdido información importante.

### Regla de finalización

Una tarea importante no se considera completamente terminada hasta que:

1. El resultado haya sido comprobado.
2. La memoria correspondiente esté actualizada.
3. El siguiente paso esté identificado.

## 9. Registro de resultados

Diferenciar siempre:

- Planificado.
- Implementado.
- Probado.
- Verificado.
- Pendiente.

Nunca afirmar que algo funciona si no se ha comprobado.

## 10. Comunicación

- Responder en español.
- Ser breve y directo.
- Avanzar paso a paso.
- No realizar pruebas innecesarias.
- No ocultar errores.
- Esperar resultados antes de continuar.

## 11. Edición de archivos

Cuando el usuario autorice editar:

1. Dar un comando para abrir el archivo.
2. Proporcionar el contenido completo.
3. No pedir inserciones manuales de fragmentos.

Para crear archivos nuevos se permite creación directa si está autorizada.

## 12. Regla final

La continuidad del proyecto es responsabilidad de cada IA.

Nunca depender de que el usuario recuerde pedir un resumen o guardar los avances.

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
