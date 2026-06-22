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

# 2. Lista de herramientas esenciales para que el perfil funcione
$apps = @(
    @{ id = "JanDeDobbeleer.OhMyPosh"; name = "Oh My Posh" },
    @{ id = "ajeetdsouza.zoxide";     name = "Zoxide" },
    @{ id = "eza.eza";                 name = "Eza (ls alternativo)" }
)

Write-Host "`n📦 Comprobando e instalando dependencias del sistema..." -ForegroundColor Yellow
foreach ($app in $apps) {
    if (-not (Get-Command $app.id.Split('.')[-1] -ErrorAction SilentlyContinue)) {
        Write-Host "📥 Instalando $($app.name)..." -ForegroundColor Blue
        winget install --id $app.id --source winget --silent --accept-source-agreements --accept-package-agreements | Out-Null
    } else {
        Write-Host "✅ $($app.name) ya está instalado." -ForegroundColor Green
    }
}

# 3. Instalación de la fuente tipográfica obligatoria (Nerd Font para iconos)
Write-Host "`n🎨 Instalando CaskaydiaCove Nerd Font (Requerida para iconos de la terminal)..." -ForegroundColor Yellow
winget install --id Git.Git --source winget --silent --accept-source-agreements --accept-package-agreements | Out-Null # Asegurar Git por si acaso
oh-my-posh font install cascadiacode --non-interactive | Out-Null

# 4. Clonar el tema de Oh My Posh si no existe
$themePath = Join-Path $Home 'cobalt2.omp.json'
if (-not (Test-Path $themePath)) {
    Write-Host "🎨 Descargando tema Cobalt2 de Oh My Posh..." -ForegroundColor Blue
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/wesbos/cobalt2-custom/master/cobalt2.omp.json" -OutFile $themePath -UseBasicParsing | Out-Null
}

Write-Host "`n✨ ¡Ecosistema base configurado con éxito!" -ForegroundColor Green
Write-Host "💡 RECUERDA: Configura tu Terminal de Windows para usar la fuente 'CaskaydiaCove Nerd Font' para ver los iconos correctamente." -ForegroundColor Magenta