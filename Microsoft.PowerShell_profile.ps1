### Chris Titus Tech's PowerShell profile edit Alex

# 1. Cargar la base de Chris Titus (si existe) para heredar sus herramientas automáticamente
$profileDir = Split-Path $PROFILE
$baselinePath = Join-Path $profileDir "ChrisTitus_baseline.ps1"
if (Test-Path $baselinePath) { . $baselinePath }

$poshTheme = if (-not [string]::IsNullOrWhiteSpace($env:POSH_THEME)) {
    $env:POSH_THEME
} else {
    Join-Path $Home 'cobalt2.omp.json'
}

if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Import-Module -Name Terminal-Icons
} else {
    Write-Warning "Terminal-Icons module not found."
}

Write-Host "Use 'Show-Help' or 'alias' to list all available functions" -ForegroundColor Yellow

# History & Colors
Set-PSReadLineOption -PredictionViewStyle ListView -Colors @{
    Command   = '#87CEEB'
    Parameter = '#98FB98'
    Operator  = '#FFB6C1'
    Variable  = '#DDA0DD'
    String    = '#FFDAB9'
    Number    = '#B0E0E6'
    Type      = '#F0E68C'
    Comment   = '#D3D3D3'
    Keyword   = '#8367c7'
    Error     = '#FF6347'
}

#KeyBinds
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
Set-PSReadLineKeyHandler -Chord 'Ctrl+w' -Function BackwardDeleteWord
Set-PSReadLineKeyHandler -Chord 'Alt+d' -Function DeleteWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+LeftArrow' -Function BackwardWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+RightArrow' -Function ForwardWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+z' -Function Undo
Set-PSReadLineKeyHandler -Chord 'Ctrl+y' -Function Redo

# Functions
function Update-Profile {
    $profileDir = Split-Path $PROFILE
    $baselinePath = Join-Path $profileDir "ChrisTitus_baseline.ps1"
    Write-Host "🔄 Descargando última versión de Chris Titus de forma segura..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri https://github.com/ChrisTitusTech/powershell-profile/raw/main/Microsoft.PowerShell_profile.ps1 -OutFile $baselinePath
    Write-Host "✅ Base de Chris Titus actualizada en 'ChrisTitus_baseline.ps1'. Tus cambios están a salvo." -ForegroundColor Green
}

# File / Directory Utilities
function touch ($File) {
    if (Test-Path $File) {
        (Get-Item $File).LastWriteTime = Get-Date
    } else {
        New-Item $File -ItemType File | Out-Null
    }
}

function mkcd ($Path) {
    New-Item -Path $Path -ItemType Directory -Force | Out-Null
    Set-Location -Path $Path
}

function trash ($Path) {
    if (Test-Path $Path -PathType Container) {
        [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory($Path,'OnlyErrorDialogs','SendToRecycleBin')
    } else {
        [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($Path,'OnlyErrorDialogs','SendToRecycleBin')
    }
}

function ff ($Name) {
    Get-ChildItem -Recurse -Filter $Name -File | Select-Object -ExpandProperty FullName
}

function head ($Path) {
    Get-Content $Path -Head 10
}

function sed ($File, $Find, $Replace) {
    (Get-Content $File).replace("$Find", $Replace) | Set-Content $file
}

function which ($Name) {
    (Get-Command $Name).Source
}

function pgrep ($Name) {
    Get-Process -Name $Name -ErrorAction SilentlyContinue
}

function pkill ($Name) {
    Get-Process -Name $Name -ErrorAction SilentlyContinue | Stop-Process -Force
}

function k9 ($Name) {
    pkill $Name
}

# System Utilities
function uptime {
    (Get-Date) - (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime | Select-Object Days, Hours, Minutes, Seconds
}

function winutil {
    Invoke-RestMethod https://christitus.com/win | Invoke-Expression
}

function winutildev {
    Invoke-RestMethod https://christitus.com/windev | Invoke-Expression
}

# Git Shortcuts
function gs { git status }
function ga { git add . }
Remove-Item Alias:gp -Force -ErrorAction SilentlyContinue
function gp { git push }
function gpush { git push }
function gpull { git pull }
function gcl { git clone $args }
function g { __zoxide_z github }

function gcom {
    git add .
    git commit -m "$args"
}

function lazyg {
    git add .
    git commit -m "$args"
    git push
}

function docs {
    Set-Location -Path ([Environment]::GetFolderPath("MyDocuments"))
}

# Listing / Viewing
function la {
    Get-ChildItem | Format-Table -AutoSize
}

function ll {
    Get-ChildItem -Force | Format-Table -AutoSize
}

# Aliases
Set-Alias -Name unzip -Value Expand-Archive
Set-Alias -Name grep -Value Select-String


# =====================================================================
# 🛠️ FUNCIÓN DE AYUDA / ALIAS PERSONALIZADOS
# =====================================================================
function Show-Help {
    $title    = $PSStyle.Foreground.BrightMagenta
    $section  = $PSStyle.Foreground.BrightBlue
    $command  = $PSStyle.Foreground.BrightGreen
    $desc     = $PSStyle.Foreground.BrightWhite
    $accent   = $PSStyle.Foreground.BrightYellow
    $dim      = $PSStyle.Foreground.BrightBlack
    $reset    = $PSStyle.Reset

    Clear-Host
    Write-Host @"
${title}󰘳 Mi Toolkit Personal & Ayuda${reset}
${dim}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${reset}

${section}🛠️ Mis Herramientas Personalizadas${reset}
${dim}────────────────────────────────────────────────────${reset}
  ${command}perfil${reset}           ${accent}→${reset} ${desc}Abre este perfil en Visual Studio Code${reset}
  ${command}admin${reset}            ${accent}→${reset} ${desc}Nueva pestaña de Terminal como Administrador${reset}
  ${command}update${reset}           ${accent}→${reset} ${desc}Actualiza las Apps (Winget) + PowerShell 7${reset}
  ${command}myip${reset}             ${accent}→${reset} ${desc}Muestra tu IP Local y Pública en tiempo real${reset}
  ${command}path${reset}             ${accent}→${reset} ${desc}Muestra las rutas del sistema línea por línea${reset}

${section}󰊢 Git Shortcuts${reset}
${dim}────────────────────────────────────────────────────${reset}
  ${command}g${reset}                ${accent}→${reset} ${desc}Ir al directorio de GitHub (Zoxide)${reset}
  ${command}ga${reset}               ${accent}→${reset} ${desc}git add .${reset}
  ${command}gs${reset}               ${accent}→${reset} ${desc}git status${reset}
  ${command}gcl <repo>${reset}      ${accent}→${reset} ${desc}git clone${reset}
  ${command}gcom <msg>${reset}      ${accent}→${reset} ${desc}git commit -m "mensaje"${reset}
  ${command}gp / gpush${reset}      ${accent}→${reset} ${desc}git push${reset}
  ${command}gpull${reset}            ${accent}→${reset} ${desc}git pull${reset}
  ${command}lazyg <msg>${reset}     ${accent}→${reset} ${desc}Automatiza: add + commit + push de golpe${reset}

${section}󰘴 System Shortcuts & Utilities${reset}
${dim}────────────────────────────────────────────────────${reset}
  ${command}docs${reset}             ${accent}→${reset} ${desc}Ir a la carpeta Documentos${reset}
  ${command}ll${reset} / ${command}la${reset}          ${accent}→${reset} ${desc}Listar archivos (la muestra ocultos)${reset}
  ${command}mkcd <dir>${reset}       ${accent}→${reset} ${desc}Crear directorio y entrar en él${reset}
  ${command}touch <file>${reset}     ${accent}→${reset} ${desc}Crear un archivo vacío${reset}
  ${command}trash <path>${reset}     ${accent}→${reset} ${desc}Enviar archivo/carpeta a la papelera${reset}
  ${command}unzip <file>${reset}     ${accent}→${reset} ${desc}Extraer archivo .zip${reset}
  ${command}ff <name>${reset}         ${accent}→${reset} ${desc}Buscar archivos por nombre${reset}
  ${command}grep <pat> [path]${reset} ${accent}→${reset} ${desc}Buscar texto dentro de archivos${reset}
  ${command}head <file>${reset}       ${accent}→${reset} ${desc}Ver las primeras 10 líneas de un archivo${reset}
  ${command}pgrep / pkill${reset}    ${accent}→${reset} ${desc}Buscar / Detener procesos por nombre${reset}
  ${command}k9 <name>${reset}         ${accent}→${reset} ${desc}Atajo rápido para forzar cierre de proceso${reset}
  ${command}uptime${reset}           ${accent}→${reset} ${desc}Tiempo que lleva encendido el sistema${reset}
  ${command}which <name>${reset}       ${accent}→${reset} ${desc}Localizar la ruta de un comando ejecutable${reset}
  ${command}winutil${reset}          ${accent}→${reset} ${desc}Ejecutar el script WinUtil de Chris Titus${reset}

${dim}💡 Nota: Para ver la lista nativa de Windows usa: Get-Alias${reset}
${dim}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${reset}
"@
}

# Redireccionamos el comando "alias" para que ejecute nuestra ayuda limpia
Remove-Item Alias:alias -Force -ErrorAction SilentlyContinue
function alias { Show-Help }


# =====================================================================
# 🔥 SECCIÓN PERSONALIZADA 
# =====================================================================

#Función de admin
function admin {
    Start-Process wt -Verb RunAs
}

#Función $PROFILE
function perfil {
    code $PROFILE
}

# Muestra las rutas del PATH del sistema línea por línea (súper legible)
function path {
    $env:Path -split ';' | Where-Object { $_ }
}

# Muestra tu IP local y tu IP pública al instante
function myip {
    $local = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike "127.*" -and $_.InterfaceAlias -notlike "*Loopback*"}).IPAddress[0]
    try {
        $public = (Invoke-RestMethod -Uri "https://api.ipify.org" -TimeoutSec 3).Trim()
    } catch {
        $public = "No disponible (Sin internet)"
    }
    Write-Host "📍 IP Local:   " -NoNewline; Write-Host $local -ForegroundColor Cyan
    Write-Host "🌐 IP Pública: " -NoNewline; Write-Host $public -ForegroundColor Green
}

# Actualiza todo el software del PC + Comprobación estricta de PowerShell 7
function update {
    Clear-Host
    Write-Host "🔍 Sincronizando repositorios y buscando actualizaciones..." -ForegroundColor Yellow
    
    # Fuerza a winget a actualizar su base de datos local
    winget source update | Out-Null 
    
    # Muestra la lista de aplicaciones desactualizadas (incluyendo las de versión desconocida)
    winget upgrade --include-unknown
    
    Write-Host "`n📋 ¿Cómo deseas proceder?" -ForegroundColor Cyan
    Write-Host "  [1] Actualizar TODO de golpe (Aceptando licencias automáticamente)" -ForegroundColor Green
    Write-Host "  [2] Actualizar una aplicación específica por su ID" -ForegroundColor Green
    Write-Host "  [3] Forzar actualización de PowerShell 7" -ForegroundColor Magenta
    Write-Host "  [4] Cancelar" -ForegroundColor Red
    
    $opcion = Read-Host "`nSelecciona una opción (1-4)"
    
    switch ($opcion) {
        "1" {
            Write-Host "`n🚀 Actualizando todo el sistema..." -ForegroundColor Green
            winget upgrade --all --include-unknown --accept-package-agreements --accept-source-agreements
        }
        "2" {
            $id = Read-Host "`nIntroduce el ID de la aplicación (ej: Anthropic.Claude)"
            if (-not [string]::IsNullOrWhiteSpace($id)) {
                Write-Host "`n🚀 Actualizando $id..." -ForegroundColor Green
                winget upgrade --id $id --accept-package-agreements --accept-source-agreements
            } else {
                Write-Host "❌ ID no válido." -ForegroundColor Red
            }
        }
        "3" {
            Write-Host "`n🚀 Saltando Winget: Descargando la última versión directamente desde GitHub..." -ForegroundColor Magenta
            # El script oficial de Microsoft consulta GitHub, descarga el MSI más reciente (7.6.3) y lo actualiza
            Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-powershell.ps1) } -UseMSI"
        }
        default {
            Write-Host "`n❌ Operación cancelada." -ForegroundColor Yellow
        }
    }
}

# Detectar si la sesión actual es Administrador
$currentPrincipal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin) {
    # 1. Cambia el título de la pestaña/ventana
    $Host.UI.RawUI.WindowTitle = "⚡ ADMINISTRADOR ⚡"

    # 2. Muestra un aviso rojo llamativo al abrirse
    Write-Host "`n    ⚠️  MODO ADMINISTRADOR  ⚠️`n" -ForegroundColor Red

    # 3. Intercepta el tema y fuerza el color naranja de peligro
    if (Test-Path $poshTheme) {
        try {
            $themeContent = Get-Content $poshTheme -Raw
            
            # Reemplaza cualquier variante de azul/cian de fondo por el naranja de advertencia (#D65D0E)
            $themeContent = $themeContent -replace '#193549', '#D65D0E'
            $themeContent = $themeContent -replace '#007acc', '#D65D0E'
            $themeContent = $themeContent -replace '#0077c2', '#D65D0E'
            
            if ($themeContent -match '"background"\s*:\s*"([^"]+)"') {
                $detectedColor = $Matches[1]
                if ($detectedColor -like '#*') {
                    $themeContent = $themeContent -replace [regex]::Escape($detectedColor), '#D65D0E'
                }
            }
            
            $adminThemePath = Join-Path $env:TEMP 'oh-my-posh-admin.json'
            Set-Content -Path $adminThemePath -Value $themeContent -Force
            $poshTheme = $adminThemePath
        } catch {}
    }
}


# =====================================================================
# 🚀 INICIALIZACIÓN DE ENTORNO (SIEMPRE AL FINAL DEL ARCHIVO)
# =====================================================================
$shouldInitPosh = $false
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    if (Test-Path $poshTheme) {
        $shouldInitPosh = $true
    } else {
        Write-Warning "oh-my-posh theme not found at $poshTheme."
    }
} else {
    Write-Warning "oh-my-posh is not installed."
}

$shouldInitZoxide = $false
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    $shouldInitZoxide = $true
} else {
    Write-Warning "zoxide is not installed."
}

if ($shouldInitPosh) {
    Invoke-Expression (& { (oh-my-posh init pwsh --config $poshTheme | Out-String) })
}
if ($shouldInitZoxide) {
    Invoke-Expression (& { (zoxide init --cmd z powershell | Out-String) })
}