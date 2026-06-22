# ==============================================================================
# Script: update.ps1
# Descripción: Gestor dinámico de actualizaciones multiplataforma (WinGet + Chocolatey)
# ==============================================================================

function global:update {
    $forceChocoList = @("Apple.Bonjour", "CreativeTechnology.OpenAL")

    $chocoMapping = @{
        "Apple.Bonjour"             = "apple-bonjour"
        "CreativeTechnology.OpenAL" = "openal"
    }

    do {
        Clear-Host
        Write-Host "🔍 Sincronizando repositorios de WinGet y buscando actualizaciones..." -ForegroundColor Yellow
        winget source update | Out-Null 
        winget upgrade --include-unknown
        
        # --- COMPROBACIÓN DINÁMICA DE CHOCOLATEY ---
        $chocoInstalled = [bool](Get-Command choco -ErrorAction SilentlyContinue)
        $chocoOutdatedPackages = $false

        if ($chocoInstalled) {
            try {
                $chocoOutdated = Invoke-Expression "choco outdated" 2>$null
                
                if ($chocoOutdated -match "determined 0 package" -or $chocoOutdated -eq $null) {
                    Write-Host "✅ Chocolatey está completamente al día." -ForegroundColor Green
                } else {
                    Write-Host "🍫 Chocolatey tiene actualizaciones disponibles:" -ForegroundColor Yellow
                    
                    $chocoOutdated | Select-String -Pattern "\|" | ForEach-Object {
                        Write-Host "   • $($_.Line)" -ForegroundColor DarkYellow
                    }
                    Write-Host "" 
                    $chocoOutdatedPackages = $true
                }
            } catch {
                Write-Host "✅ Chocolatey está al día (comprobación silenciada)." -ForegroundColor Green
            }
        } else {
            Write-Host "⚠️ Nota: Chocolatey no está instalado." -ForegroundColor Gray
        }

        # --- COMPROBACIÓN DINÁMICA DE POWERSHELL 7 ---
        $pwshNeedUpdate = $false
        $latestRelease = $null
        $downloadAsset = $null
        try {
            $repoUri = "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"
            $latestRelease = Invoke-RestMethod -Uri $repoUri -UseBasicParsing
            $latestVersionString = $latestRelease.tag_name.TrimStart('v')
            if ([version]$latestVersionString -gt $PSVersionTable.PSVersion) {
                Write-Host "📢 ¡Nota: Hay una nueva versión de PowerShell 7 disponible! (GitHub: v$latestVersionString)" -ForegroundColor Magenta
                $downloadAsset = $latestRelease.assets | Where-Object { $_.name -like "*win-x64.msi" } | Select-Object -First 1
                $pwshNeedUpdate = $true
            } else {
                Write-Host "✅ PowerShell 7 está completamente al día." -ForegroundColor Green
            }
        } catch {}

        Write-Host "`n📋 ¿Cómo deseas proceder?" -ForegroundColor Cyan
        Write-Host "  [1] Actualizar TODO de golpe (Aceptando licencias)" -ForegroundColor Green
        Write-Host "  [2] Actualizar una aplicación específica por su ID" -ForegroundColor Green
        
        if ($pwshNeedUpdate) {
            Write-Host "  [3] Descargar instalador (.msi) de la nueva versión de PowerShell" -ForegroundColor Magenta
            Write-Host "  [4] Desinstalar una aplicación por su ID" -ForegroundColor Yellow
            Write-Host "  [5] Cancelar y salir" -ForegroundColor Red
            $maxOpcion = 5
        } else {
            Write-Host "  [3] Desinstalar una aplicación por su ID" -ForegroundColor Yellow
            Write-Host "  [4] Cancelar y salir" -ForegroundColor Red
            $maxOpcion = 4
        }
        
        $opcion = Read-Host "`nSelecciona una opción (1-$maxOpcion)"
        
        if (-not $pwshNeedUpdate) {
            if ($opcion -eq "3") { $opcion = "desinstalar" }
            if ($opcion -eq "4") { $opcion = "cancelar" }
        } else {
            if ($opcion -eq "3") { $opcion = "pwsh" }
            if ($opcion -eq "4") { $opcion = "desinstalar" }
            if ($opcion -eq "5") { $opcion = "cancelar" }
        }

        $pausarAlFinal = $true

        switch ($opcion) {
            "1" {
                Write-Host "`n🚀 Actualizando todo el sistema con WinGet..." -ForegroundColor Green
                winget upgrade --all --include-unknown --accept-package-agreements --accept-source-agreements
                
                # OPTIMIZACIÓN: Solo abre la pestaña Admin si realmente hay paquetes retenidos en Chocolatey
                if ($chocoInstalled -and $chocoOutdatedPackages) {
                    Write-Host "`n🔄 Forzando actualización masiva de Chocolatey en tu pestaña 'admin'..." -ForegroundColor Cyan
                    
                    $subCmd = "Write-Host '🍫 Ejecutando actualización masiva vía Chocolatey (Modo Admin)...' -ForegroundColor Cyan; choco upgrade all -y"
                    $bytes = [System.Text.Encoding]::Unicode.GetBytes($subCmd)
                    $encodedCmd = [Convert]::ToBase64String($bytes)
                    
                    $arguments = "nt -p `"PowerShell`" pwsh.exe -NoExit -EncodedCommand $encodedCmd"
                    Start-Process wt.exe -ArgumentList $arguments -Verb RunAs
                } elseif ($chocoInstalled) {
                    Write-Host "`n✅ Chocolatey ya estaba limpio. No se requiere elevación." -ForegroundColor Green
                }
            }
            "2" {
                $id = Read-Host "`nIntroduce el ID de la aplicación"
                if (-not [string]::IsNullOrWhiteSpace($id)) {
                    
                    $usarChocoNativo = $chocoInstalled -and ($forceChocoList -contains $id)

                    if (-not $usarChocoNativo) {
                        Write-Host "`n🚀 Intentando actualizar $id con WinGet..." -ForegroundColor Green
                        $process = Start-Process winget -ArgumentList "upgrade --id $id --accept-package-agreements --accept-source-agreements" -NoNewWindow -PassThru -Wait
                        $success = ($process.ExitCode -eq 0)
                    } else {
                        $success = $false
                    }

                    if (-not $success) {
                        if ($chocoInstalled) {
                            $chocoName = if ($chocoMapping.ContainsKey($id)) { $chocoMapping[$id] } else { $id.ToLower() }
                            Write-Host "`n🔄 WinGet falló o requiere rescate. Intentando con Chocolatey para '$chocoName'..." -ForegroundColor Cyan
                            
                            $subCmd = "Write-Host '🍫 Ejecutando actualización de rescate vía Chocolatey...' -ForegroundColor Cyan; choco upgrade $chocoName -y"
                            $bytes = [System.Text.Encoding]::Unicode.GetBytes($subCmd)
                            $encodedCmd = [Convert]::ToBase64String($bytes)
                            
                            $arguments = "nt -p `"PowerShell`" pwsh.exe -NoExit -EncodedCommand $encodedCmd"
                            Start-Process wt.exe -ArgumentList $arguments -Verb RunAs
                        } else {
                            Write-Host "`n⚠️ WinGet falló y Chocolatey no está disponible para rescate." -ForegroundColor Red
                        }
                    }
                } else {
                    Write-Host "❌ ID no válido." -ForegroundColor Red
                }
            }
            "pwsh" {
                if ($downloadAsset) {
                    $downloadsFolder = Join-Path $env:USERPROFILE "Downloads"
                    $destinationPath = Join-Path $downloadsFolder $downloadAsset.name
                    Write-Host "`n📥 Descargando PowerShell..." -ForegroundColor Cyan
                    Invoke-WebRequest -Uri $downloadAsset.browser_download_url -OutFile $destinationPath -UseBasicParsing
                    Write-Host "`n✨ Descarga completada en: $destinationPath" -ForegroundColor Green
                }
            }
            "desinstalar" {
                $id = Read-Host "`nIntroduce el ID de la aplicación a desinstalar"
                if (-not [string]::IsNullOrWhiteSpace($id)) {
                    Write-Host "`n🗑️ Eliminando con WinGet..." -ForegroundColor Yellow
                    Start-Process winget -ArgumentList "uninstall --id $id" -NoNewWindow -Wait
                    
                    if ($chocoInstalled) {
                        $chocoName = if ($chocoMapping.ContainsKey($id)) { $chocoMapping[$id] } else { $id.ToLower() }
                        Write-Host "🗑️ Asegurando eliminación en Chocolatey..." -ForegroundColor Cyan
                        Start-Process choco -ArgumentList "uninstall $chocoName -y" -NoNewWindow -Wait
                    }
                }
            }
            "cancelar" {
                Write-Host "`n❌ Saliendo..." -ForegroundColor Yellow
                $pausarAlFinal = $false
                return 
            }
            default {
                Write-Host "`n❌ Opción no válida." -ForegroundColor Red
            }
        }

        if ($pausarAlFinal) {
            Write-Host "`n👋 Presiona cualquier tecla para volver al menú..." -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }

    } while ($true)
}