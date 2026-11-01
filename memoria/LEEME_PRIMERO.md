# CLASSICRPG — SISTEMA DE CONTINUIDAD

Proyecto: ClassicRPG
Motor: Godot 4.7.2
Repositorio: https://github.com/loremaster23/ClassicRPG
Rama principal: main

## OBLIGATORIO ANTES DE TRABAJAR

Toda IA debe leer:

1. LEEME_PRIMERO.md
2. ESTADO_ACTUAL.md
3. REGLAS_IA.md
4. DECISIONES.md
5. PENDIENTES.md
6. HISTORIAL.md
7. CONTINUAR_CON_IA.md
8. GUIA_CONTINUIDAD_CLASSICRPG.txt

Después debe comprobar el estado real del proyecto y Git.

## REGLA PRINCIPAL

Continuar el proyecto existente.
Nunca empezar de cero ni descartar trabajo anterior.

## SISTEMA DE MEMORIA

La memoria es compartida entre ChatGPT, Copilot, OpenCode y cualquier otra IA.

Cada IA debe actualizarla durante el desarrollo.

No esperar al final de la sesión.

## CUÁNDO GUARDAR

Actualizar la memoria cuando:

- Se complete una tarea.
- Se modifique código.
- Se cree o elimine un archivo autorizado.
- Se resuelva un error.
- Se descubra un problema.
- Se tome una decisión.
- Se complete una fase.
- Cambie el siguiente paso del desarrollo.

## LIMITACIÓN

El sistema detecta cambios locales mediante Git.

No puede leer automáticamente las conversaciones privadas de otras IA.

Cada IA debe registrar sus propias decisiones y avances.

## PRIORIDAD

Preservar el trabajo existente y garantizar que cualquier IA pueda continuar sin depender de conversaciones anteriores.

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
