Write-Host "FirstLogonCommands Script"

New-Item -Path "C:\" -Name "Temp" -ItemType "directory"
New-Item -Path "C:\Temp" -Name "Unattend" -ItemType "directory"
Add-Content "C:\Temp\Unattend\autounattend.log" "Github Powershell executed"

$Installer7Zip = $env:TEMP + "C:\Temp\Unattend\7z1900-x64.msi"; 
Invoke-WebRequest "https://www.7-zip.org/a/7z1900-x64.msi" -OutFile $Installer7Zip; 
msiexec /i $Installer7Zip /qb; 
Remove-Item $Installer7Zip;
