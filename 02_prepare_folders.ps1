# 02_prepare_folders.ps1 – WinPE build könyvtárak létrehozása és boot fájlok másolása

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

# 📁 Könyvtárak létrehozása
Write-Host "📁 Könyvtárak létrehozása indul..."

$paths = @($cfg.WinPERoot, $cfg.WinPEMedia, $cfg.BootBinPath, $cfg.MountPath)
foreach ($p in $paths) {
    if (!(Test-Path $p)) {
        try {
            New-Item -ItemType Directory -Path $p -Force | Out-Null
            Write-Host "✅ Létrehozva: $p"
        } catch {
            Write-Host "❌ HIBA: Nem sikerült létrehozni: $p – $_"
            exit 1
        }
    } else {
        Write-Host "ℹ️ Már létezik: $p"
    }
}

# 🔄 Boot szektor fájlok másolása
Write-Host "📄 Boot fájlok másolása: etfsboot.com, efisys.bin"

$srcBoot = Join-Path $cfg.ADKRoot 'Deployment Tools\amd64\Oscdimg'
$dstBoot = $cfg.BootBinPath

$bootFiles = @('etfsboot.com', 'efisys.bin')
foreach ($file in $bootFiles) {
    $src = Join-Path $srcBoot $file
    $dst = Join-Path $dstBoot $file
    if (Test-Path $src) {
        Copy-Item $src -Destination $dst -Force
        Write-Host "✅ Boot fájl másolva: $file"
    } else {
        Write-Host "❌ HIBA: Nem található: $src"
        exit 1
    }
}

Write-Host "🏁 Könyvtárak és boot fájlok előkészítése kész"