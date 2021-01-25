Write-Host "FirstLogonCommands Script"

$installPath = "C:\Temp\Unattend"

New-Item $installPath -ItemType Directory

# Install 7-Zip
$installer7Zip = Join-Path -Path $installPath -ChildPath "7z1900-x64.msi"
Invoke-WebRequest "https://www.7-zip.org/a/7z1900-x64.msi" -OutFile $installer7Zip
Start-Process "msiexec.exe" -Wait -NoNewWindow -ArgumentList "/i ""$($installer7Zip)"" /qb"

# Install Notepad++
$installerNotepadPlusPlus = Join-Path -Path $installPath -ChildPath "npp.7.9.2.Installer.x64.exe"
Invoke-WebRequest "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v7.9.2/npp.7.9.2.Installer.x64.exe" -OutFile $installerNotepadPlusPlus
Start-Process $installerNotepadPlusPlus -Wait -NoNewWindow -ArgumentList "/S"

$manufacturer = (Get-ComputerInfo | Select -expand CsManufacturer)
Add-Content "C:\Temp\Unattend\autounattend.log" $manufacturer