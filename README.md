# 💻 Mi Entorno de PowerShell 7 & Dotfiles

Este repositorio contiene mis scripts de automatización, optimizaciones y la configuración personalizada de mi terminal de Windows basada en **PowerShell 7**, utilizando **Oh My Posh**, **Zoxide** y **Eza**.

## 🛠️ Herramientas Incluidas en el Kit
* **Oh My Posh:** Prompts estéticos con el tema personalizado Cobalt2 (`cobalt2.omp.json`, vive en este mismo repo).
* **Zoxide (`z`):** Navegador inteligente de directorios basado en frecuencia de uso.
* **Eza (`ls`, `ll`, `la`, `lt`):** Reemplazo moderno y colorido para listar archivos con iconos de desarrollo.
* **fd / ff:** Búsqueda ultra rápida de carpetas y archivos en todos los discos (binario `fd.exe`, de `sharkdp/fd`).
* **Terminal-Icons, posh-git, PSFzf, PSScriptAnalyzer, z (módulo):** Módulos de PowerShell instalados automáticamente por `install.ps1`. `PSFzf` además necesita el binario `fzf.exe` (`junegunn/fzf`), que también instala `install.ps1`.
* **Gestión de paquetes:** Automatizaciones avanzadas cruzadas usando `WinGet` y `Chocolatey`.

---

## 🚀 Instalación desde cero (Post-Formateo rápido)

Si acabo de formatear el equipo, el proceso para recuperar todo mi entorno es el siguiente:

### Paso 1: Instalar PowerShell 7
Abre la consola nativa de Windows (PowerShell clásico) y ejecuta este comando:
---> winget install --id Microsoft.PowerShell --source winget

### Paso 2: Descargar tus Dotfiles en una ruta fija
**No uses `cd (Split-Path $PROFILE)` para clonar.** Justo después de formatear, OneDrive puede tardar en redirigir la carpeta "Documentos", y en ese caso `$PROFILE` apunta temporalmente a un sitio distinto — clonar ahí deja el repo tirado en el lugar equivocado. Clona siempre en la ruta fija dentro de OneDrive:
---> git clone <URL_DE_TU_REPOSITORIO_DE_GITHUB> "$env:OneDrive\Dokumente\PowerShell"

Comprueba que `$PROFILE` ya apunta ahí:
---> $PROFILE

Si `Test-Path $PROFILE` da `False`, o apunta a otra carpeta (p. ej. `Documents\PowerShell` porque OneDrive aún no ha terminado de sincronizar), crea el archivo a mano con este contenido — es un "puente" que carga el perfil real desde la ruta fija:
---> if (-not (Test-Path (Split-Path $PROFILE))) { New-Item -ItemType Directory -Path (Split-Path $PROFILE) -Force }
---> ". `"$env:OneDrive\Dokumente\PowerShell\Microsoft.PowerShell_profile.ps1`"" | Set-Content $PROFILE
---> . $PROFILE

### Paso 3: Ejecutar el instalador automático
Corre el script de despliegue para instalar todas las dependencias (oh-my-posh, eza, zoxide, fd, fzf, la tipografía con iconos, y los módulos de PowerShell: Terminal-Icons, posh-git, PSFzf, PSScriptAnalyzer, z):
---> cd "$env:OneDrive\Dokumente\PowerShell"
---> ./install.ps1

### Paso 4: Toque final de la Terminal
Abre la configuración de Windows Terminal (Ctrl + ,), ve a los perfiles de PowerShell, entra en Apariencia y cambia la fuente a "CaskaydiaCove Nerd Font". Fija también PowerShell 7 como perfil predeterminado. ¡Listo!

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