# CLASSICRPG - CONTINUITY REPORT GENERATOR v2
# Read-only: does not modify project files or Git history.
# Compatible with Windows PowerShell 5.1 and PowerShell 7 on Windows.

$ErrorActionPreference = "Stop"

$Proyecto = "C:\Users\Bruker\OneDrive\DESARROLLO_RPG\ClassicRPG"
$ScriptPath = $PSCommandPath
$Utf8 = New-Object System.Text.UTF8Encoding($false)

if (-not (Test-Path -LiteralPath $Proyecto -PathType Container)) {
    throw "Project directory not found: $Proyecto"
}

if ([string]::IsNullOrWhiteSpace($ScriptPath) -or
    -not (Test-Path -LiteralPath $ScriptPath -PathType Leaf)) {
    throw "Cannot determine the path of the running script."
}

$Git = Get-Command git.exe -ErrorAction SilentlyContinue
if (-not $Git) {
    $Git = Get-Command git -ErrorAction SilentlyContinue
}
if (-not $Git) {
    throw "Git is not available in PATH."
}

$Fecha = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

function ConvertTo-WindowsCommandLineArgument {
    param([AllowEmptyString()][string]$Value)

    if ($null -eq $Value) {
        $Value = ""
    }

    if ($Value.Length -gt 0 -and $Value -notmatch '[\s"]') {
        return $Value
    }

    $Builder = New-Object System.Text.StringBuilder
    [void]$Builder.Append('"')
    $Backslashes = 0

    foreach ($Character in $Value.ToCharArray()) {
        if ($Character -eq '\') {
            $Backslashes++
            continue
        }

        if ($Character -eq '"') {
            if ($Backslashes -gt 0) {
                [void]$Builder.Append(('\' * (2 * $Backslashes)))
            }
            [void]$Builder.Append('\')
            [void]$Builder.Append('"')
            $Backslashes = 0
            continue
        }

        if ($Backslashes -gt 0) {
            [void]$Builder.Append(('\' * $Backslashes))
            $Backslashes = 0
        }

        [void]$Builder.Append($Character)
    }

    if ($Backslashes -gt 0) {
        [void]$Builder.Append(('\' * (2 * $Backslashes)))
    }

    [void]$Builder.Append('"')
    return $Builder.ToString()
}

function Obtener-Git {
    param([Parameter(Mandatory = $true)][string[]]$Argumentos)

    $Inicio = New-Object System.Diagnostics.ProcessStartInfo
    $Inicio.FileName = $Git.Source
    $Inicio.WorkingDirectory = $Proyecto
    $Inicio.UseShellExecute = $false
    $Inicio.CreateNoWindow = $true
    $Inicio.RedirectStandardOutput = $true
    $Inicio.RedirectStandardError = $true
    $Inicio.StandardOutputEncoding = [System.Text.Encoding]::UTF8
    $Inicio.StandardErrorEncoding = [System.Text.Encoding]::UTF8

    $TodosArgumentos = @(
        "-c", "i18n.logOutputEncoding=utf-8",
        "-c", "core.quotepath=false",
        "-C", $Proyecto
    ) + $Argumentos

    $ArgumentosCompletos = foreach ($Argumento in $TodosArgumentos) {
        ConvertTo-WindowsCommandLineArgument -Value ([string]$Argumento)
    }
    $Inicio.Arguments = $ArgumentosCompletos -join " "

    $Proceso = New-Object System.Diagnostics.Process
    $Proceso.StartInfo = $Inicio

    try {
        [void]$Proceso.Start()

        # Read both streams asynchronously to avoid pipe deadlocks.
        $TareaSalida = $Proceso.StandardOutput.ReadToEndAsync()
        $TareaError = $Proceso.StandardError.ReadToEndAsync()

        $Proceso.WaitForExit()

        $SalidaNormal = $TareaSalida.Result.Trim()
        $SalidaError = $TareaError.Result.Trim()
        $CodigoSalida = $Proceso.ExitCode

        if ($CodigoSalida -ne 0) {
            throw "Git error ($CodigoSalida): $SalidaError`n$SalidaNormal"
        }

        if ($SalidaError) {
            Write-Warning "Git warning: $SalidaError"
        }

        return $SalidaNormal
    }
    finally {
        $Proceso.Dispose()
    }
}

function Leer-ArchivoUtf8 {
    param([Parameter(Mandatory = $true)][string]$Ruta)

    return [System.IO.File]::ReadAllText($Ruta, [System.Text.Encoding]::UTF8)
}

# Collect repository information. These commands are read-only.
$Rama = Obtener-Git @("branch", "--show-current")
$Commit = Obtener-Git @("log", "-1", "--format=%h - %s")
$EstadoGit = Obtener-Git @("status", "--short", "--untracked-files=all")
$ResumenSinPreparar = Obtener-Git @("diff", "--stat")
$ResumenPreparado = Obtener-Git @("diff", "--cached", "--stat")
$ArchivosNuevos = Obtener-Git @("ls-files", "--others", "--exclude-standard")
$ArchivosModificados = Obtener-Git @("diff", "--name-only")
$ArchivosPreparados = Obtener-Git @("diff", "--cached", "--name-only")

$ArchivosMemoria = @(
    "memoria/LEEME_PRIMERO.md",
    "memoria/ESTADO_ACTUAL.md",
    "memoria/REGLAS_IA.md",
    "memoria/DECISIONES.md",
    "memoria/PENDIENTES.md",
    "memoria/HISTORIAL.md",
    "memoria/CONTINUAR_CON_IA.md",
    "GUIA_CONTINUIDAD_CLASSICRPG.txt"
)

$Informe = @"
# CLASSICRPG - INFORME DE CONTINUIDAD

Fecha: $Fecha
Proyecto: $Proyecto

## GIT

Rama:
$Rama

Ultimo commit:
$Commit

Estado (porcelain, incluye archivos nuevos):
$EstadoGit

Resumen de cambios no preparados:
$ResumenSinPreparar

Resumen de cambios preparados:
$ResumenPreparado

Archivos modificados no preparados:
$ArchivosModificados

Archivos preparados:
$ArchivosPreparados

Archivos nuevos sin seguimiento:
$ArchivosNuevos

## DOCUMENTOS DE CONTINUIDAD
"@

foreach ($Archivo in $ArchivosMemoria) {
    $Ruta = Join-Path $Proyecto ($Archivo -replace '/', '\')
    $Informe += "`r`n`r`n---`r`n## $Archivo`r`n"

    if (Test-Path -LiteralPath $Ruta -PathType Leaf) {
        $Informe += Leer-ArchivoUtf8 -Ruta $Ruta
    }
    else {
        $Informe += "[ARCHIVO NO ENCONTRADO: $Archivo]"
        Write-Warning "Continuity document not found: $Archivo"
    }
}

$Informe += "`r`n`r`n---`r`n## herramientas/GuardarEstado.ps1`r`n"
$Informe += Leer-ArchivoUtf8 -Ruta $ScriptPath

$Informe += @"

---

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

## INSTRUCCIONES PARA LA IA

1. Leer el informe completo.
2. Comprobar los archivos reales y el estado actual del proyecto.
3. Inspeccionar los cambios locales antes de trabajar.
4. No descartar trabajo existente.
5. No modificar archivos sin autorizacion.
6. No realizar commits ni pushes sin autorizacion.
7. Registrar los avances durante el desarrollo.
8. Actualizar la memoria despues de cada tarea importante.
9. Indicar siempre el siguiente paso.

## LIMITACIONES

Este informe no captura automaticamente conversaciones privadas de otras IA.

Git detecta archivos modificados y nuevos, pero este informe no incluye
automaticamente el contenido completo de todos los archivos nuevos ni los
diffs completos del codigo.

Los cambios staged y unstaged se resumen por separado.

La memoria debe ser actualizada por la IA que realiza el trabajo.

Este script no modifica archivos del proyecto ni el historial de Git.
"@

# Always emit the report to standard output.
Write-Output $Informe

# Prefer clipboard. If unavailable, save a UTF-8 copy under the user's TEMP folder.
try {
    if (-not (Get-Command Set-Clipboard -ErrorAction SilentlyContinue)) {
        throw "Set-Clipboard is not available in this PowerShell session."
    }

    Set-Clipboard -Value $Informe
    Write-Host "`nINFORME COPIADO AL PORTAPAPELES." -ForegroundColor Green
}
catch {
    $NombreAlternativo = "ClassicRPG_InformeContinuidad_{0}.md" -f (Get-Date -Format "yyyyMMdd_HHmmss")
    $RutaAlternativa = Join-Path ([System.IO.Path]::GetTempPath()) $NombreAlternativo

    try {
        [System.IO.File]::WriteAllText($RutaAlternativa, $Informe, $Utf8)
        Write-Warning "No se pudo copiar al portapapeles: $($_.Exception.Message)"
        Write-Host "Informe guardado como alternativa: $RutaAlternativa" -ForegroundColor Yellow
    }
    catch {
        Write-Warning "No se pudo copiar ni guardar el informe: $($_.Exception.Message)"
        throw
    }
}
