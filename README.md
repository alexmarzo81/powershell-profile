# 💻 Mi Entorno de PowerShell 7 & Dotfiles

Este repositorio contiene mis scripts de automatización, optimizaciones y la configuración personalizada de mi terminal de Windows basada en **PowerShell 7**, utilizando **Oh My Posh**, **Zoxide** y **Eza**.

## 🛠️ Herramientas Incluidas en el Kit
* **Oh My Posh:** Prompts estéticos con el tema personalizado Cobalt2.
* **Zoxide (`z`):** Navegador inteligente de directorios basado en frecuencia de uso.
* **Eza (`ls`, `ll`, `la`, `lt`):** Reemplazo moderno y colorido para listar archivos con iconos de desarrollo.
* **Gestión de paquetes:** Automatizaciones avanzadas cruzadas usando `WinGet` y `Chocolatey`.

---

## 🚀 Instalación desde cero (Post-Formateo rápido)

Si acabo de formatear el equipo, el proceso para recuperar todo mi entorno en menos de 5 minutos es el siguiente:

### Paso 1: Instalar PowerShell 7
Abre la consola nativa de Windows (PowerShell clásico) y ejecuta este comando:
---> winget install --id Microsoft.PowerShell --source winget

### Paso 2: Descargar tus Dotfiles
Una vez abierto PowerShell 7 (la nueva consola), viaja a tu carpeta de perfiles y clona este repositorio directamente ahí dentro:
---> cd (Split-Path $PROFILE)
---> git clone <URL_DE_TU_REPOSITORIO_DE_GITHUB> .

### Paso 3: Ejecutar el instalador automático
Corre el script de despliegue para instalar dependencias (oh-my-posh, eza, zoxide y la tipografía con iconos):
---> ./install.ps1

### Paso 4: Toque final de la Terminal
Abre la configuración de Windows Terminal (Ctrl + ,), ve a los perfiles de PowerShell, entra en Apariencia y cambia la fuente a "CaskaydiaCove Nerd Font". ¡Listo!

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