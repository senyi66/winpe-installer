# winpe-installer
PowerShell-alapú WinPE építő rendszer és ISO generáláshoz.

# 🧭 WinPE Audit Pendrive – Teljes Rendszerleírás HwSwInfo-hoz

## 🎯 Cél

Olyan bootolható WinPE pendrive készítése, amely automatikusan:

- 🖥️ kiolvassa a hardver/szoftver adatokat
- 🌐 hálózatra csatlakozik (DHCP, DNS)
- 📤 REST API-n keresztül feltölti az adatokat
- 🧩 modulárisan bővíthető, konfiguráció-vezérelt

---
## 🛠️ Technikai követelmények

| Tulajdonság | Részletezés |
|-------------|-------------|
| **Futtatás** | Rendszergazdai PowerShell (Run as Administrator) |
| **Kódolás** | Minden `.ps1` fájl: **UTF-8 BOM** |
| **OS** | Windows 10/11 |
| **ADK verzió** | 10.1.28000.1 (vagy konfigurálhatóan régebbi) |
| **Hálózat** | DHCP, internet elérés REST API-hoz |
| **Pendrive** | ISO kiírása Rufus/Ventoy/diskpart segítségével |

---

## 📁 Könyvtárszerkezet

```
\Install\
├── Audit\                  # Audit script és startnet.cmd
│   ├── audit.ps1
│   ├── startnet.cmd
│   └── tools\              # Opcionális binárisok (pl. hwinfo.exe)
├── ISO\
│   ├── winpe\              # WinPE build mappa
│   │   ├── media\
│   │   │   └── Windows\System32\startnet.cmd
│   │   ├── bootbins\       # etfsboot.com, efisys.bin
│   │   └── mount\          # boot.wim mountolása
├── winpe_config.psd1       # Konfigurációs fájl
├── 00_build_all.ps1        # Master script
├── 01_install_adk.ps1      # ADK + WinPE telepítés
├── 02_prepare_folders.ps1  # Könyvtárak + boot fájlok
├── 03_build_winpe.ps1      # boot.wim másolás + mount + testreszabás
├── 04_make_iso.ps1         # ISO generálás oscdimg.exe-vel
```
---

## 🧾 Fájlok és szerepük

| Fájl | Funkció |
|------|---------|
| `winpe_config.psd1` | Konfigurációs fájl: verziók, elérési utak, install mód |
| `00_build_all.ps1` | Master script: sorban futtatja a 01–04 scripteket |
| `01_install_adk.ps1` | ADK és WinPE telepítése, verzióellenőrzés, csendes/interaktív mód |
| `02_prepare_folders.ps1` | Könyvtárak létrehozása, boot fájlok bemásolása |
| `03_build_winpe.ps1` | boot.wim másolása, mountolása, audit fájlok beépítése |
| `04_make_iso.ps1` | ISO generálása oscdimg.exe segítségével |
| `audit.ps1` | HW/SW adatgyűjtés, REST API feltöltés |
| `startnet.cmd` | Automatikusan elindítja `audit.ps1`-t boot után |

---

## ⚙️ Konfigurációs fájl – `winpe_config.psd1`

```powershell
@{
    AdkVersion        = '10.1.28000.1'
    AdkDownloadUrl    = 'https://go.microsoft.com/fwlink/?linkid=2337875'
    WinPEDownloadUrl  = 'https://go.microsoft.com/fwlink/?linkid=2337681'

    ADKRoot           = 'C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit'
    OscdimgExe        = 'C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe'

    WinPERoot         = 'E:\Install\ISO\winpe'
    WinPEMedia        = 'E:\Install\ISO\winpe\media'
    BootBinPath       = 'E:\Install\ISO\winpe\bootbins'
    OutputIso         = 'E:\Install\ISO\WinPE.iso'

    WinPEWimSource    = 'C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\en-us\winpe.wim'
    MountPath         = 'E:\Install\ISO\mount'

    UseQuietInstall   = $true  # vagy $false
}
```
---

## 🧠 Script működés sorrendje

1. **`00_build_all.ps1`** elindul
2. **`01_install_adk.ps1`**: ellenőrzi, telepíti az ADK-t és WinPE-t
3. **`02_prepare_folders.ps1`**: létrehozza a mappákat, bemásolja a boot fájlokat
4. **`03_build_winpe.ps1`**:
   - másolja a `winpe.wim`-et → `media\sources\boot.wim`
   - mountolja → `mount`
   - bemásolja az `audit.ps1`-t és `startnet.cmd`-t
   - lementi a `boot.wim`-et
5. **`04_make_iso.ps1`**: oscdimg.exe segítségével ISO-t generál

---

## 🧪 Bootolás után – WinPE viselkedés

- `wpeinit` elindul → hálózat felépül
- `startnet.cmd` automatikusan fut → elindítja `audit.ps1`-t
- `audit.ps1`:
  - kiolvassa a hardver/szoftver adatokat
  - JSON-be csomagolja
  - REST API-n keresztül feltölti

---

## 📤 REST API példa PowerShell-ből

```powershell
Invoke-RestMethod -Uri "https://your.api/endpoint" -Method POST -Body $json -ContentType "application/json"
```

---

## 🧯 Hibaelhárítás

| Hiba | Megoldás |
|------|----------|
| `etfsboot.com` hiányzik | Ellenőrizd, hogy `02_prepare_folders.ps1` bemásolta-e |
| ISO nem jön létre | Ellenőrizd az `oscdimg.exe` elérhetőségét |
| Script nem indul boot után | Ellenőrizd a `startnet.cmd` helyét és tartalmát |
| REST API nem elérhető | Teszteld `Invoke-RestMethod`-dal WinPE alatt |

---

## 🧳 Pendrive készítés

1. ISO kiírása Rufus/Ventoy segítségével
2. Bootolás BIOS/UEFI módban
3. Script automatikusan fut → adatgyűjtés és feltöltés

---

### ⚙️ Ha interaktív a telepítés winpe_config.psd1 ben a UseQuietInstall   = $false  
## ✅ Szükséges komponensek WinPE + HWSW információhoz

| Komponens | Szükséges? | Megjegyzés |
|-----------|------------|------------|
| **Deployment Tools** | ✔️ Kötelező | Ez tartalmazza a `copype.cmd` és `MakeWinPEMedia` parancsokat |
| **Windows Preinstallation Environment (WinPE)** | ✔️ Kötelező | Ez külön add-onként települ, nem látszik a képen |
| **Windows Performance Toolkit** | ✔️ Ajánlott | Rendszerteljesítmény elemzéshez, pl. `xperf` |
| **User State Migration Tool (USMT)** | ❌ Nem szükséges | Felhasználói profilok migrálásához |
| **Application Compatibility Tools** | ❌ Nem szükséges | Régi alkalmazások kompatibilitásához |
| **Imaging and Configuration Designer (ICD)** | ❌ Nem szükséges | Mobil eszköz konfigurálásához |
| **Volume Activation Management Tool (VAMT)** | ❌ Nem szükséges | Licenceléshez |
| **UE-V Template / App-V Sequencer** | ❌ Nem szükséges | Virtualizált alkalmazásokhoz |
| **Supply Chain Trust Tools / Assessment Services** | ❌ Nem szükséges | Haladó biztonsági és tesztelési célokra

---

## 📦 Összefoglaló: Minimálisan válaszd ki

- ✅ **Deployment Tools**
- ✅ **Windows Performance Toolkit**
- ➕ A **WinPE Add-on** telepítése külön szükséges (külön letöltés)

