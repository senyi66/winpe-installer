# 01_install_adk.ps1 – ADK és WinPE Add-on telepítése

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# 📥 Konfiguráció betöltése
$cfgPath = Join-Path $PSScriptRoot 'winpe_config.psd1'
if (!(Test-Path $cfgPath)) {
    Write-Host "❌ HIBA: Konfigurációs fájl nem található: $cfgPath"
    exit 1
}

try {
    $cfg = Import-PowerShellDataFile $cfgPath
    Write-Host "✅ Konfiguráció betöltve: $cfgPath"
} catch {
    Write-Host "❌ HIBA: winpe_config.psd1 betöltése sikertelen: $_"
    exit 1
}

chcp 65001 | Out-Null
Write-Host "🔍 ADK telepítés ellenőrzése..."

$adkInstalled = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*", "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -like "Windows Assessment and Deployment Kit*" }

if ($adkInstalled) {
    $installedVersion = $adkInstalled[0].DisplayVersion
    Write-Host "📦 Telepített ADK verzió: $installedVersion"
} else {
    Write-Host "⚠️ ADK nincs telepítve – letöltés indul..."
}

# 📥 Letöltés
$adkExe = "$env:TEMP\adksetup.exe"
$winpeExe = "$env:TEMP\adkwinpesetup.exe"

try {
    Start-BitsTransfer -Source $cfg.AdkDownloadUrl -Destination $adkExe
    Start-BitsTransfer -Source $cfg.WinPEDownloadUrl -Destination $winpeExe
    Write-Host "✅ Telepítők letöltve"
} catch {
    Write-Host "❌ HIBA: Letöltés sikertelen: $_"
    exit 1
}

# 🔍 Letöltött verziók kiírása
if (Test-Path $adkExe) {
    $adkVersion = (Get-Item $adkExe).VersionInfo.ProductVersion
    Write-Host "📦 Letöltött ADK telepítő verzió: $adkVersion"
}
if (Test-Path $winpeExe) {
    $winpeVersion = (Get-Item $winpeExe).VersionInfo.ProductVersion
    Write-Host "📦 Letöltött WinPE Add-on verzió: $winpeVersion"
}

# ⚖️ Verzió összehasonlítás
if ($installedVersion -and $adkVersion -and ($installedVersion -ne $adkVersion)) {
    Write-Host "⚠️ FIGYELEM: A telepített ADK verzió eltér a letöltött verziótól!"
}

# 📦 ADK telepítése (ha nem volt telepítve)
if (-not $adkInstalled) {
    Write-Host "📦 ADK telepítése – ez eltarthat néhány percig..."
    try {
        $adkArgs = if ($cfg.UseQuietInstall) {
            '/Features OptionId.DeploymentTools /norestart /quiet /ceip off'
        } else {
            '/Features OptionId.DeploymentTools /norestart'
        }
        Start-Process $adkExe -Wait -ArgumentList $adkArgs
        Write-Host "✅ ADK telepítve"
    } catch {
        Write-Host "❌ HIBA: ADK telepítése sikertelen: $_"
        exit 1
    }

    Write-Host "📦 WinPE Add-on telepítése – kérlek várj..."
    try {
        $winpeArgs = if ($cfg.UseQuietInstall) {
            '/features + /quiet'
        } else {
            '/features +'
        }
        Start-Process $winpeExe -Wait -ArgumentList $winpeArgs
        Write-Host "✅ WinPE Add-on telepítve"
    } catch {
        Write-Host "❌ HIBA: WinPE Add-on telepítése sikertelen: $_"
        exit 1
    }

    # 🔍 Ellenőrzés: létrejött-e az oscdimg.exe
    if (!(Test-Path $cfg.OscdimgExe)) {
        Write-Host "❌ HIBA: ADK telepítés után nem található az oscdimg.exe: $($cfg.OscdimgExe)"
        exit 1
    }
}

Write-Host "🏁 Kész – ADK és WinPE sikeresen telepítve vagy már telepítve volt"