# ClassicRPG

RPG 3D en desarrollo con **Godot 4.7.2**. La prioridad actual es completar la experiencia para un jugador. La arquitectura multijugador que ya existe se conserva para retomarla más adelante.

## Ejecutar el juego

1. Abre esta carpeta como proyecto en Godot 4.7.2.
2. Usa **Ejecutar proyecto**. La escena inicial configurada es `MenuInicio.tscn`.
3. Desde el menú, inicia una partida nueva o continúa la partida guardada. El menú abre `Mapa1/Escena1.tscn`.

En Windows también se puede usar `herramientas/iniciar_juego.ps1 -Clientes 2` para iniciar un servidor externo y dos clientes de prueba. Ese lanzador es para probar el flujo multijugador; el juego individual normal se inicia desde el menú.

## Controles principales

- `WASD`: movimiento.
- `Tab` o clic: selección/cambio de objetivo.
- `E`: interacción con NPC.
- `1`: ataque.
- `2`: poción.
- `3`: golpe pesado.
- `B`: inventario.
- `Q`: equipo.
- Ratón: selección de objetivo y control de cámara.

El mapa de entradas de Godot en `project.godot` es la referencia para cualquier control adicional.

## Pruebas

Las pruebas automatizadas están en `herramientas/Prueba*.gd`. Con el ejecutable de consola de Godot disponible como `godot`, se puede ejecutar una prueba así:

```powershell
godot --headless --path . --script herramientas/PruebaPartidaIndividual.gd
```

Para recorrerlas todas desde PowerShell 5.1, situado en la raíz del proyecto:

```powershell
$godot = 'godot'
$proyecto = (Get-Location).Path
$fallos = @()
Get-ChildItem .\herramientas\Prueba*.gd | Sort-Object Name | ForEach-Object {
    & $godot --headless --path $proyecto --script (Join-Path 'herramientas' $_.Name)
    if ($LASTEXITCODE -ne 0) { $fallos += $_.Name }
}
if ($fallos.Count -gt 0) { throw "Fallaron: $($fallos -join ', ')" }
```

Si Godot no está en `PATH`, sustituye `godot` por la ruta al ejecutable de consola de Godot 4.7.2.

## Estructura del proyecto

- `scripts/cliente`, `scripts/servidor`, `scripts/compartido`: lógica separada por responsabilidad de red y código compartido.
- `Mapa1`, `Personajes`, `Camaras`, `escenas`: escenas del mapa y módulos de juego.
- `assets`: cursor, interfaz y modelos; los recursos de terceros incluyen sus licencias/README junto al paquete.
- `herramientas`: pruebas, lanzadores y utilidades de desarrollo.
- `datos`: espacio para datos del juego.
- `memoria`: continuidad, decisiones, historial y tareas internas del proyecto.

Algunos controladores (`Main.gd`, `Jugador.gd`, `Camara.gd`) siguen en la raíz por compatibilidad con las rutas actuales de las escenas. No los muevas sin actualizar las referencias `res://` y comprobar el proyecto.

La escena activa se define en `project.godot`. `Main.tscn` permanece como escena de prototipo/recuperación y no es la entrada actual del juego.

## Modelos y licencias

El jugador actual utiliza Male_Ranger de Quaternius, la cabeza UBC preparada para el Ranger y Universal Animation Library Standard. Los archivos fuente/licencias se conservan bajo `assets/modelos/quaternius/`. Los modelos anteriores del caballero están preservados en `assets/modelos/caballero/` como material histórico; consulta allí su nota de archivo antes de reutilizarlos.

La descripción pública y las instrucciones de usuario están aquí. Los documentos de `memoria/` son registros internos de desarrollo y no sustituyen esta guía.
