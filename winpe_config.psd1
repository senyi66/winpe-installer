@{
    AdkVersion        = '10.1.28000.1'
		
	AdkDownloadUrl    = 'https://go.microsoft.com/fwlink/?linkid=2337875'
	WinPEDownloadUrl  = 'https://go.microsoft.com/fwlink/?linkid=2337681'
	
	AdkVersion_old        = '10.1.25398.1'
	AdkDownloadUrl_old    = 'https://go.microsoft.com/fwlink/?linkid=2243390'
	WinPEDownloadUrl_old  = 'https://go.microsoft.com/fwlink/?linkid=2243391'

    ADKRoot           = 'C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit'
    OscdimgExe        = 'C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe'
	
	UseQuietInstall   = $false  # vagy $true, ha csendes telepítés - $false, ha interaktív telepítést szeretnél
	
    WinPERoot         = 'E:\Install\ISO\winpe'
    WinPEMedia        = 'E:\Install\ISO\winpe\media'
    BootBinPath       = 'E:\Install\ISO\winpe\bootbins'
    OutputIso         = 'E:\Install\ISO\winpe\WinPE.iso'

    WinPEWimSource    = 'C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\en-us\winpe.wim'
    MountPath         = 'E:\Install\ISO\mount'
}