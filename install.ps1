# ==============================================================================
# Script: install.ps1
# Descripción: Despliegue automático y restauración del entorno PowerShell 7
# ==============================================================================

Write-Host "🚀 Iniciando instalación automatizada del entorno..." -ForegroundColor Cyan

# 1. Asegurar que estamos en PowerShell 7
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "⚠️ Se detectó Windows PowerShell clásico. Instalando PowerShell 7 vía WinGet..." -ForegroundColor Yellow
    winget install --id Microsoft.PowerShell --source winget --accept-source-agreements --accept-package-agreements
    Write-Host "✅ PowerShell 7 instalado. Por favor, cierra esta ventana y vuelve a ejecutar este script desde PWSH 7." -ForegroundColor Green
    exit
}

# Recarga el PATH desde el registro para que los binarios instalados por winget
# en este mismo script (oh-my-posh, fd, fzf...) se puedan invocar sin reabrir la sesión.
function Update-SessionPath {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path", "User")
}

# 2. Lista de herramientas esenciales para que el perfil funcione
$apps = @(
    @{ id = "JanDeDobbeleer.OhMyPosh"; name = "Oh My Posh"; cmd = "oh-my-posh" },
    @{ id = "ajeetdsouza.zoxide";     name = "Zoxide";       cmd = "zoxide" },
    @{ id = "eza.eza";                 name = "Eza (ls alternativo)"; cmd = "eza" }
)

Write-Host "`n📦 Comprobando e instalando dependencias del sistema..." -ForegroundColor Yellow
foreach ($app in $apps) {
    if (-not (Get-Command $app.cmd -ErrorAction SilentlyContinue)) {
        Write-Host "📥 Instalando $($app.name)..." -ForegroundColor Blue
        winget install --id $app.id --source winget --silent --accept-source-agreements --accept-package-agreements | Out-Null
    } else {
        Write-Host "✅ $($app.name) ya está instalado." -ForegroundColor Green
    }
}

Update-SessionPath

# 3. Instalación de la fuente tipográfica obligatoria (Nerd Font para iconos)
Write-Host "`n🎨 Instalando CaskaydiaCove Nerd Font (Requerida para iconos de la terminal)..." -ForegroundColor Yellow
winget install --id Git.Git --source winget --silent --accept-source-agreements --accept-package-agreements | Out-Null # Asegurar Git por si acaso
oh-my-posh font install cascadiacode | Out-Null

# 4. Módulos de PowerShell usados por el perfil
$modules = @("Terminal-Icons", "posh-git", "PSFzf", "PSScriptAnalyzer", "z")
Write-Host "`n📦 Comprobando e instalando módulos de PowerShell..." -ForegroundColor Yellow
if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser | Out-Null
}
foreach ($module in $modules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Write-Host "📥 Instalando módulo $module..." -ForegroundColor Blue
        Install-Module -Name $module -Repository PSGallery -Scope CurrentUser -Force
    } else {
        Write-Host "✅ Módulo $module ya está instalado." -ForegroundColor Green
    }
}

# 5. fd.exe (usado por las funciones fd/ff del perfil) — comprobar con extensión,
#    "fd" a secas resuelve a la función del perfil, no al binario.
Write-Host "`n📦 Comprobando fd.exe..." -ForegroundColor Yellow
if (-not (Get-Command fd.exe -ErrorAction SilentlyContinue)) {
    Write-Host "📥 Instalando fd (sharkdp.fd)..." -ForegroundColor Blue
    winget install --id sharkdp.fd --source winget --silent --accept-source-agreements --accept-package-agreements | Out-Null
} else {
    Write-Host "✅ fd.exe ya está instalado." -ForegroundColor Green
}

# 6. fzf.exe (binario requerido por el módulo PSFzf, no lo trae el módulo en sí)
Write-Host "`n📦 Comprobando fzf.exe..." -ForegroundColor Yellow
if (-not (Get-Command fzf.exe -ErrorAction SilentlyContinue)) {
    Write-Host "📥 Instalando fzf (junegunn.fzf)..." -ForegroundColor Blue
    winget install --id junegunn.fzf --source winget --silent --accept-source-agreements --accept-package-agreements | Out-Null
} else {
    Write-Host "✅ fzf.exe ya está instalado." -ForegroundColor Green
}

Update-SessionPath

# 7. Node.js / npm (requerido para instalar y ejecutar Claude Code)
Write-Host "`n📦 Comprobando Node.js / npm..." -ForegroundColor Yellow
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Host "📥 Instalando Node.js LTS..." -ForegroundColor Blue
    winget install --id OpenJS.NodeJS.LTS --source winget --silent --accept-source-agreements --accept-package-agreements | Out-Null
    Update-SessionPath
} else {
    Write-Host "✅ npm ya está instalado." -ForegroundColor Green
}

# 8. Claude Code CLI (usado por el wrapper `claude` de CTTcustom.ps1)
Write-Host "`n📦 Comprobando Claude Code CLI..." -ForegroundColor Yellow
$claudeExe = Join-Path $env:APPDATA "npm\node_modules\@anthropic-ai\claude-code\bin\claude.exe"
if (-not (Test-Path $claudeExe)) {
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        Write-Host "📥 Instalando @anthropic-ai/claude-code..." -ForegroundColor Blue
        npm install -g @anthropic-ai/claude-code | Out-Null
    } else {
        Write-Warning "npm no disponible, no se puede instalar Claude Code. Revisa el paso de Node.js."
    }
} else {
    Write-Host "✅ Claude Code ya está instalado." -ForegroundColor Green
}

# 9. Python (versión estable) + pip
Write-Host "`n📦 Comprobando Python..." -ForegroundColor Yellow
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "📥 Instalando Python (versión estable)..." -ForegroundColor Blue
    winget install --id Python.Python.3.13 --source winget --silent --accept-source-agreements --accept-package-agreements | Out-Null
    Update-SessionPath
} else {
    Write-Host "✅ Python ya está instalado." -ForegroundColor Green
}
if ((Get-Command python -ErrorAction SilentlyContinue) -and -not (Get-Command pip -ErrorAction SilentlyContinue)) {
    Write-Host "📥 Instalando pip..." -ForegroundColor Blue
    python -m ensurepip --upgrade | Out-Null
    Update-SessionPath
} else {
    Write-Host "✅ pip ya está instalado." -ForegroundColor Green
}

Update-SessionPath

Write-Host "`n✨ ¡Ecosistema base configurado con éxito!" -ForegroundColor Green
Write-Host "💡 RECUERDA: Configura tu Terminal de Windows para usar la fuente 'CaskaydiaCove Nerd Font' para ver los iconos correctamente." -ForegroundColor Magenta
