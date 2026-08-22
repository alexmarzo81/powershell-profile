@echo off
setlocal

REM ==============================================================================
REM Restaurar-PowerShell.cmd
REM Doble clic para restaurar el entorno de PowerShell 7 de Alex tras
REM reinstalar Windows. Debe estar en la MISMA carpeta que
REM Restore-PowerShellProfile.ps1 (por ejemplo, dentro de tus Descargas).
REM ==============================================================================

echo ============================================================
echo   Restauracion del entorno PowerShell 7
echo ============================================================
echo.

where pwsh >nul 2>nul
if %errorlevel% neq 0 (
    echo PowerShell 7 no esta instalado todavia. Instalando via winget...
    winget install --id Microsoft.PowerShell --source winget --accept-source-agreements --accept-package-agreements
    echo.
    echo Vuelve a hacer doble clic en este archivo ahora que PowerShell 7 esta instalado.
    pause
    exit /b 0
)

pwsh -NoLogo -ExecutionPolicy Bypass -File "%~dp0Restore-PowerShellProfile.ps1"

echo.
echo Pulsa una tecla para cerrar esta ventana.
pause >nul
