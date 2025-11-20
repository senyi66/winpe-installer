# 04_make_iso.ps1 – WinPE ISO generálás oscdimg.exe segítségével

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

# 📄 Boot szektor fájlok ellenőrzése
$biosBoot = Join-Path $cfg.BootBinPath "etfsboot.com"
$uefiBoot = Join-Path $cfg.BootBinPath "efisys.bin"

foreach ($file in @($cfg.OscdimgExe, $biosBoot, $uefiBoot, $cfg.WinPEMedia)) {
    if (!(Test-Path $file)) {
        Write-Host "❌ HIBA: Hiányzó fájl vagy mappa: $file"
        exit 1
    }
}

Write-Host "💿 ISO generálás indul oscdimg.exe segítségével..."

$cmd = "`"$($cfg.OscdimgExe)`" -m -o -u2 -udfver102 -bootdata:2#p0,e,b`"$biosBoot`"#pEF,e,b`"$uefiBoot`" `"$($cfg.WinPEMedia)`" `"$($cfg.OutputIso)`""
try {
    cmd.exe /c $cmd
    Write-Host "✅ ISO generálás parancs lefutott"
} catch {
    Write-Host "❌ HIBA: oscdimg.exe futtatása sikertelen: $_"
    exit 1
}

# 📦 Eredmény ellenőrzése
if (Test-Path $cfg.OutputIso) {
    Write-Host "✅ Sikeres ISO generálás: $($cfg.OutputIso)"
} else {
    Write-Host "❌ HIBA: ISO fájl nem jött létre"
    exit 1
}

Write-Host "🏁 ISO generálás kész"