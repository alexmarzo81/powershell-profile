# 💻 Mi Entorno de PowerShell 7 & Dotfiles

Este repositorio contiene mis scripts de automatización, optimizaciones y la configuración personalizada de mi terminal de Windows basada en **PowerShell 7**, utilizando **Oh My Posh**, **Zoxide** y **Eza**.

## 🛠️ Herramientas Incluidas en el Kit
* **Oh My Posh:** Prompts estéticos con el tema personalizado Cobalt2 (`cobalt2.omp.json`, vive en este mismo repo).
* **Zoxide (`z`):** Navegador inteligente de directorios basado en frecuencia de uso.
* **Eza (`ls`, `ll`, `la`, `lt`):** Reemplazo moderno y colorido para listar archivos con iconos de desarrollo.
* **fd / ff:** Búsqueda ultra rápida de carpetas y archivos en todos los discos (binario `fd.exe`, de `sharkdp/fd`).
* **Terminal-Icons, posh-git, PSFzf, PSScriptAnalyzer, z (módulo):** Módulos de PowerShell instalados automáticamente por `install.ps1`. `PSFzf` además necesita el binario `fzf.exe` (`junegunn/fzf`), que también instala `install.ps1`.
* **Node.js / npm + Claude Code:** Instalados automáticamente por `install.ps1`. `claude` (definido en `CTTcustom.ps1`) es un wrapper que llama al Claude Code real instalado por npm, siempre con `--dangerously-skip-permissions`.
* **Python (versión estable) + pip:** Instalados automáticamente por `install.ps1`.
* **Gestión de paquetes:** Automatizaciones avanzadas cruzadas usando `WinGet` y `Chocolatey`.

---

## 🚀 Instalación desde cero (Post-Formateo)

### Opción rápida: un solo script

1. Instala PowerShell 7 si no lo tienes:
   ---> winget install --id Microsoft.PowerShell --source winget
2. Descarga (o copia desde un USB/otro disco) `Restore-PowerShellProfile.ps1` y `Restaurar-PowerShell.cmd` — por ejemplo a `Descargas`, da igual la carpeta, el script no depende de dónde se ejecute.
3. Doble clic en `Restaurar-PowerShell.cmd` (o `pwsh -ExecutionPolicy Bypass -File Restore-PowerShellProfile.ps1`).

Ese único script:
- Clona (o actualiza con `git pull`) el repo **siempre** en la ruta fija `$env:OneDrive\Dokumente\PowerShell`, sin importar desde qué carpeta se lanzó el script — evita el bug de que `$PROFILE` apunte a otro sitio mientras OneDrive todavía está redirigiendo "Documentos" tras el formateo.
- Crea cualquier carpeta que falte por el camino.
- Ejecuta `install.ps1`: oh-my-posh, zoxide, eza, fd, fzf, tipografía, módulos de PowerShell (Terminal-Icons, posh-git, PSFzf, PSScriptAnalyzer, z), Node.js/npm, Claude Code, Python + pip.
- Deja un "puente" en `$PROFILE` si hiciera falta (si `$PROFILE` no resuelve todavía a la carpeta fija).
- Instala VS Code si falta.
- Configura Windows Terminal: fuente `CaskaydiaCove Nerd Font` en el perfil de PowerShell y lo fija como perfil por defecto (hace copia de seguridad de `settings.json` antes de tocarlo).

Nota de diseño: el tema de Oh My Posh se resuelve dinámicamente desde la carpeta del propio repo (`$PSScriptRoot/cobalt2.omp.json`) — a propósito **no** se fija `$env:POSH_THEME` de forma permanente, para que el tema no se rompa si algún día mueves o reclonas el repo en otra ruta.

### Opción manual, paso a paso (si algo del script automático falla)

**Paso 1 — PowerShell 7:**
---> winget install --id Microsoft.PowerShell --source winget

**Paso 2 — Clonar en ruta fija.** No uses `cd (Split-Path $PROFILE)`: justo después de formatear, `$PROFILE` puede apuntar temporalmente a otro sitio mientras OneDrive redirige "Documentos".
---> git clone <URL_DE_TU_REPOSITORIO_DE_GITHUB> "$env:OneDrive\Dokumente\PowerShell"

Comprueba que `$PROFILE` ya apunta ahí:
---> $PROFILE

Si `Test-Path $PROFILE` da `False`, o apunta a otra carpeta, crea el "puente" a mano:
---> if (-not (Test-Path (Split-Path $PROFILE))) { New-Item -ItemType Directory -Path (Split-Path $PROFILE) -Force }
---> ". `"$env:OneDrive\Dokumente\PowerShell\Microsoft.PowerShell_profile.ps1`"" | Set-Content $PROFILE
---> . $PROFILE

**Paso 3 — Instalador de dependencias:**
---> cd "$env:OneDrive\Dokumente\PowerShell"
---> ./install.ps1

**Paso 4 — Windows Terminal a mano:** Ctrl + , > perfil PowerShell > Apariencia > fuente "CaskaydiaCove Nerd Font". Fija PowerShell 7 como perfil predeterminado. ¡Listo!

---

## 📋 Comandos Rápidos Personalizados

| Comando | Acción |
| :--- | :--- |
| update | Menú interactivo inteligente para actualizar apps (WinGet/Choco) y el propio PWSH 7. |
| lazyg "msg" | Add, commit y push estricto del proyecto Git en el que estés parado. |
| lazyp "msg" | Copia de seguridad automática de estos Dotfiles a GitHub (con confirmación de seguridad). |
| perfil | Abre toda esta carpeta de configuración directamente en VS Code. |
| myip | Muestra de forma limpia tu IP de red local y tu IP pública. |
| admin | Lanza una pestaña nueva de la terminal con permisos de Administrador de golpe. |
| claude | Wrapper de Claude Code, siempre con `--dangerously-skip-permissions` (definido en `CTTcustom.ps1`). |