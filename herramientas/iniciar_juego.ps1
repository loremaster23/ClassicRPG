# iniciar_juego.ps1 - Lanza servidor headless y uno o dos clientes graficos.
# Uso recomendado en PowerShell 5.1 (muestra y copia la salida):
# & { .\herramientas\iniciar_juego.ps1 -Clientes 2 } *>&1 | Tee-Object -Variable resultado
# ($resultado | Out-String) | Set-Clipboard

param(
    [ValidateRange(1, 2)]
    [int]$Clientes = 1,
    [ValidateRange(5, 60)]
    [int]$EsperaServidor = 15
)

$ErrorActionPreference = 'Stop'
$rutaProyecto = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$godotGUI = Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Links\godot.exe'
$godotConsola = Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe'

if (-not (Test-Path -LiteralPath (Join-Path $rutaProyecto 'project.godot'))) {
    throw "No se encontro project.godot en $rutaProyecto"
}
if (-not (Test-Path -LiteralPath $godotGUI)) {
    throw "No se encontro Godot GUI en $godotGUI"
}
if (Test-Path -LiteralPath $godotConsola) {
    $ejecutableServidor = $godotConsola
} else {
    $ejecutableServidor = $godotGUI
}

$marcaTiempo = Get-Date -Format 'yyyyMMdd-HHmmss'
$directorioLogs = Join-Path $env:TEMP (Join-Path 'ClassicRPG-logs' $marcaTiempo)
New-Item -ItemType Directory -Path $directorioLogs -Force | Out-Null

$servidorStdout = Join-Path $directorioLogs 'servidor-stdout.log'
$servidorStderr = Join-Path $directorioLogs 'servidor-stderr.log'
$servidorGodot = Join-Path $directorioLogs 'servidor-godot.log'
$procesosCliente = @()
$servidor = $null
$falla = $null

function Mostrar-Log([string]$Ruta) {
    Write-Host ''
    Write-Host ("--- {0} ---" -f (Split-Path -Leaf $Ruta))
    if (Test-Path -LiteralPath $Ruta) {
        Get-Content -LiteralPath $Ruta
    } else {
        Write-Host '(sin archivo)'
    }
}

try {
    Write-Host 'Iniciando servidor headless...'
    $argumentosServidor = '--headless --path "{0}" --log-file "{1}" "escenas/servidor/Servidor.tscn"' -f $rutaProyecto, $servidorGodot
    $servidor = Start-Process -FilePath $ejecutableServidor -ArgumentList $argumentosServidor -WorkingDirectory $rutaProyecto -RedirectStandardOutput $servidorStdout -RedirectStandardError $servidorStderr -PassThru

    $limite = (Get-Date).AddSeconds($EsperaServidor)
    $iniciado = $false
    while ((Get-Date) -lt $limite) {
        $servidor.Refresh()
        if ($servidor.HasExited) {
            throw 'El servidor termino antes de confirmar el arranque.'
        }

        $textoServidor = ''
        foreach ($archivo in @($servidorStdout, $servidorStderr, $servidorGodot)) {
            if (Test-Path -LiteralPath $archivo) {
                $textoServidor += Get-Content -LiteralPath $archivo -Raw -ErrorAction SilentlyContinue
            }
        }
        if ($textoServidor -match 'Servidor iniciado') {
            $iniciado = $true
            break
        }
        Start-Sleep -Milliseconds 250
    }
    if (-not $iniciado) {
        throw "El servidor no confirmo el arranque en $EsperaServidor segundos."
    }

    Write-Host 'Servidor listo; abriendo clientes.'
    for ($i = 1; $i -le $Clientes; $i++) {
        $stdoutCliente = Join-Path $directorioLogs ("cliente{0}-stdout.log" -f $i)
        $stderrCliente = Join-Path $directorioLogs ("cliente{0}-stderr.log" -f $i)
        $godotCliente = Join-Path $directorioLogs ("cliente{0}-godot.log" -f $i)
        $argumentosCliente = '--path "{0}" --log-file "{1}" "Mapa1/Escena1.tscn" -- --servidor-externo' -f $rutaProyecto, $godotCliente
        Write-Host ("Abriendo cliente {0}..." -f $i)
        $cliente = Start-Process -FilePath $godotGUI -ArgumentList $argumentosCliente -WorkingDirectory $rutaProyecto -RedirectStandardOutput $stdoutCliente -RedirectStandardError $stderrCliente -PassThru
        $procesosCliente += $cliente
        if ($i -lt $Clientes) { Start-Sleep -Seconds 2 }
    }

    Write-Host ''
    Write-Host 'Prueba movimiento y combate en las ventanas abiertas.'
    Write-Host 'Cierra todos los clientes para terminar y detener el servidor.'
    $idsClientes = @($procesosCliente | ForEach-Object { $_.Id })
    Wait-Process -Id $idsClientes
} catch {
    $falla = $_.Exception.Message
    Write-Host ("ERROR: {0}" -f $falla)
} finally {
    foreach ($cliente in $procesosCliente) {
        $cliente.Refresh()
        if (-not $cliente.HasExited) {
            Stop-Process -Id $cliente.Id -Force -ErrorAction SilentlyContinue
        }
    }
    if ($servidor) {
        $servidor.Refresh()
        if (-not $servidor.HasExited) {
            Stop-Process -Id $servidor.Id -Force -ErrorAction SilentlyContinue
            $servidor.WaitForExit()
        }
    }

    foreach ($archivo in @(
        $servidorStdout, $servidorStderr, $servidorGodot,
        (Join-Path $directorioLogs 'cliente1-stdout.log'),
        (Join-Path $directorioLogs 'cliente1-stderr.log'),
        (Join-Path $directorioLogs 'cliente1-godot.log'),
        (Join-Path $directorioLogs 'cliente2-stdout.log'),
        (Join-Path $directorioLogs 'cliente2-stderr.log'),
        (Join-Path $directorioLogs 'cliente2-godot.log')
    )) {
        Mostrar-Log $archivo
    }
    Write-Host ''
    Write-Host ("Logs guardados en: {0}" -f $directorioLogs)
}

if ($falla) {
    throw $falla
}
