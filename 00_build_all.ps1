# 00_build_all.ps1 – Teljes WinPE build folyamat (01–04)

# 🔓 Script futtatási korlátozás átmeneti feloldása
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# 📁 Scriptnevek és sorrend
$scripts = @(
    "01_install_adk.ps1",
    "02_prepare_folders.ps1",
    "03_build_winpe.ps1",
    "04_make_iso.ps1"
)

# 📍 Aktuális mappa
$basePath = $PSScriptRoot

Write-Host "🚀 Teljes WinPE build folyamat indul..."

foreach ($script in $scripts) {
    $fullPath = Join-Path $basePath $script
    if (!(Test-Path $fullPath)) {
        Write-Host "❌ HIBA: Hiányzó script: $script"
        exit 1
    }

    Write-Host "`n▶️ Futtatás: $script"
    try {
        & $fullPath
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ HIBA: $script hibával tért vissza (exit code: $LASTEXITCODE)"
            exit $LASTEXITCODE
        }
    } catch {
        Write-Host "❌ HIBA: $script futtatása közben hiba történt: $_"
        exit 1
    }
}

Write-Host "`n✅ Teljes WinPE build sikeresen lefutott"