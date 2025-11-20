# 03_build_winpe.ps1 – WinPE build (copype nélkül)

# 🔓 Script futtatási korlátozás átmeneti feloldása
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

# 📄 Ellenőrzés: winpe.wim forrásfájl
if (!(Test-Path $cfg.WinPEWimSource)) {
    Write-Host "❌ HIBA: winpe.wim forrás nem található: $($cfg.WinPEWimSource)"
    exit 1
}

# 📁 Célmappa: sources
$sourcesDir = Join-Path $cfg.WinPEMedia "sources"
if (!(Test-Path $sourcesDir)) {
    New-Item -ItemType Directory -Path $sourcesDir -Force | Out-Null
    Write-Host "✅ Létrehozva: $sourcesDir"
}

# 📄 boot.wim másolása
$bootWimTarget = Join-Path $sourcesDir "boot.wim"
Write-Host "📄 Másolás: winpe.wim → $bootWimTarget"
try {
    Copy-Item -Path $cfg.WinPEWimSource -Destination $bootWimTarget -Force
    Write-Host "✅ boot.wim másolva"
} catch {
    Write-Host "❌ HIBA: boot.wim másolása sikertelen: $_"
    exit 1
}

# 🧩 boot.wim mountolása
Write-Host "🧩 boot.wim mountolása: $cfg.MountPath"
try {
    Mount-WindowsImage -ImagePath $bootWimTarget -Index 1 -Path $cfg.MountPath
    Write-Host "✅ boot.wim mountolva"
} catch {
    Write-Host "❌ HIBA: boot.wim mountolása sikertelen: $_"
    exit 1
}

# Itt jöhetne fájlmásolás, modulbeillesztés stb.
Write-Host "ℹ️ (Ide illeszthetők be a testreszabások: fájlok, modulok, registry stb.)"

# 🧼 boot.wim lezárása
Write-Host "🧼 boot.wim leválasztása és mentése..."
try {
    Dismount-WindowsImage -Path $cfg.MountPath -Save
    Write-Host "✅ boot.wim mentve és leválasztva"
} catch {
    Write-Host "❌ HIBA: boot.wim leválasztása sikertelen: $_"
    exit 1
}

Write-Host "🏁 WinPE build kész"