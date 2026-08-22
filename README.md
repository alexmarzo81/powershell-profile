```
╔══════════════════════════════════════════════════════════════════════╗
║   A L E X . D O T F I L E S   ::   POWERSHELL 7 EDITION               ║
╚══════════════════════════════════════════════════════════════════════╝
```

```
$ whoami
alex@win11 :: powershell 7 dotfiles

$ cat status.txt
[ok] entorno reproducible desde cero tras un formateo
[ok] tema, prompt, atajos y modulos versionados en git
[ok] un solo script de restauracion post-formateo
```

Repositorio con mis scripts de automatización, optimizaciones y la configuración
personalizada de mi terminal de Windows, basada en **PowerShell 7** + **Oh My Posh**
+ **Zoxide** + **Eza**. Objetivo: si mañana formateo, reconstruyo el entorno entero
con un doble clic.

---

## [ ARSENAL ]

```
oh-my-posh     prompt con tema personalizado Cobalt2 (cobalt2.omp.json, en este repo)
zoxide  (z)    navegador inteligente de directorios por frecuencia de uso
eza            reemplazo moderno de ls/ll/la/lt con iconos
fd / ff        busqueda ultra rapida de archivos y carpetas en todos los discos
                 -> binario fd.exe (sharkdp/fd)
```

* **Módulos de PowerShell** (instalados automáticamente por `install.ps1`):
  `Terminal-Icons`, `posh-git`, `PSFzf`, `PSScriptAnalyzer`, `z`.
  `PSFzf` además necesita el binario `fzf.exe` (`junegunn/fzf`), también instalado por `install.ps1`.
* **Node.js / npm + Claude Code:** instalados por `install.ps1`. `claude` (definido en
  `CTTcustom.ps1`) es un wrapper que llama al Claude Code real, siempre con `--dangerously-skip-permissions`.
* **Python (versión estable) + pip:** instalados por `install.ps1`.
* **Gestión de paquetes:** automatizaciones cruzadas usando `WinGet` y `Chocolatey`.

---

## [ DEPLOY :: INSTALACIÓN DESDE CERO (POST-FORMATEO) ]

### >> opción rápida — un solo script

```
1. winget install --id Microsoft.PowerShell --source winget
2. copia Restore-PowerShellProfile.ps1 + Restaurar-PowerShell.cmd a cualquier carpeta
   (Descargas, USB... da igual, el script no depende de donde se ejecute)
3. doble clic en Restaurar-PowerShell.cmd
   (o: pwsh -ExecutionPolicy Bypass -File Restore-PowerShellProfile.ps1)
```

Ese único script:

- Clona (o actualiza con `git pull`) el repo **siempre** en la ruta fija
  `$env:OneDrive\Dokumente\PowerShell`, sin importar desde qué carpeta se lanzó —
  evita que `$PROFILE` apunte a otro sitio mientras OneDrive aún redirige "Documentos" tras formatear.
- Crea cualquier carpeta que falte por el camino.
- Ejecuta `install.ps1`: oh-my-posh, zoxide, eza, fd, fzf, tipografía, módulos de
  PowerShell (Terminal-Icons, posh-git, PSFzf, PSScriptAnalyzer, z), Node.js/npm,
  Claude Code, Python + pip.
- Deja un "puente" en `$PROFILE` si hiciera falta (si `$PROFILE` no resuelve todavía a la carpeta fija).
- Instala VS Code si falta.
- Configura Windows Terminal: fuente `CaskaydiaCove Nerd Font` en el perfil de
  PowerShell y lo fija como perfil por defecto (con copia de seguridad de `settings.json` antes de tocarlo).

> **Nota de diseño:** el tema de Oh My Posh se resuelve dinámicamente desde la
> carpeta del propio repo (`$PSScriptRoot/cobalt2.omp.json`) — a propósito **no**
> se fija `$env:POSH_THEME` de forma permanente, para que el tema no se rompa si
> algún día mueves o reclonas el repo en otra ruta.

### >> opción manual, paso a paso (si algo del script automático falla)

```
# 1. PowerShell 7
winget install --id Microsoft.PowerShell --source winget

# 2. clonar en ruta fija -- NO uses cd (Split-Path $PROFILE):
#    justo tras formatear, $PROFILE puede apuntar temporalmente a otro sitio
#    mientras OneDrive redirige "Documentos"
git clone <URL_DE_TU_REPOSITORIO_DE_GITHUB> "$env:OneDrive\Dokumente\PowerShell"

# comprueba que $PROFILE ya apunta ahi
$PROFILE

# si Test-Path $PROFILE da False, o apunta a otra carpeta, crea el "puente" a mano:
if (-not (Test-Path (Split-Path $PROFILE))) { New-Item -ItemType Directory -Path (Split-Path $PROFILE) -Force }
". `"$env:OneDrive\Dokumente\PowerShell\Microsoft.PowerShell_profile.ps1`"" | Set-Content $PROFILE
. $PROFILE

# 3. instalador de dependencias
cd "$env:OneDrive\Dokumente\PowerShell"
./install.ps1
```

**Paso 4 — Windows Terminal a mano:** `Ctrl + ,` > perfil PowerShell > Apariencia >
fuente `CaskaydiaCove Nerd Font`. Fija PowerShell 7 como perfil predeterminado. Listo.

---

## [ TROUBLESHOOTING ]

### >> incidente: ninguna consola abre (cmd.exe incluido) — 22/08/2026, resuelto

```
[!] sintoma   : tras probar el paso de Windows Terminal de Restore-PowerShellProfile.ps1,
                dejaron de abrir TODAS las consolas -- Windows Terminal Y cmd.exe.
[i] descartado: el diff aplicado a settings.json (solo anade el campo font,
                defaultProfile no cambia) -- JSON valido, perfil de PowerShell
                cargaba sin error en pwsh -NoProfile.
[x] causa real: paquete Appx Microsoft.WindowsTerminal danado
                (HRESULT 0x80073D02, "in use"), combinado con que Windows
                delegaba TODAS las consolas a ese motor via
                "Aplicacion de terminal predeterminada"
                (HKCU\Console\%%Startup\DelegationConsole / DelegationTerminal).
```

**Fix que funcionó:**

```
1. Abre cmd.exe (si Windows Terminal no abre nada, cmd normalmente sí).
2. Repara el paquete Appx desde ahí:

   pwsh -NoProfile -Command "Get-AppxPackage *WindowsTerminal* | ForEach-Object { Add-AppxPackage -DisableDevelopmentMode -Register (\"$($_.InstallLocation)\AppXManifest.xml\") }"

3. Configuración de Windows > "Aplicación de terminal predeterminada":
   alterna el motor (Windows Terminal <-> Host de consola de Windows) una o
   dos veces hasta que las consolas vuelvan a abrir con normalidad.
```

**Regla de oro:** si tras una restauración las consolas dejan de abrir, el primer
sospechoso es la config de "aplicación de terminal predeterminada" de Windows
(paquete Appx `Microsoft.WindowsTerminal`) — **no** el perfil ni este repo.
`Restore-PowerShellProfile.ps1` ya imprime un aviso de esto justo después de tocar
`settings.json`.

---

## [ COMANDOS ]

| Comando | Acción |
| :--- | :--- |
| `update` | Menú interactivo inteligente para actualizar apps (WinGet/Choco) y el propio PWSH 7. |
| `lazyg "msg"` | Add, commit y push estricto del proyecto Git en el que estés parado. |
| `lazyp "msg"` | Copia de seguridad automática de estos Dotfiles a GitHub (con confirmación de seguridad). |
| `perfil` | Abre toda esta carpeta de configuración directamente en VS Code. |
| `myip` | Muestra de forma limpia tu IP de red local y tu IP pública. |
| `admin` | Lanza una pestaña nueva de la terminal con permisos de Administrador de golpe. |
| `claude` | Wrapper de Claude Code, siempre con `--dangerously-skip-permissions` (definido en `CTTcustom.ps1`). |

```
$ echo "EOF"
EOF
```
