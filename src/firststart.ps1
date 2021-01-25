Write-Host "hello"

Add-Content $Env:Temp\autounattend.log "Github Powershell executed"
Add-Content C:\Temp\autounattend1.log "Github Powershell executed"
New-Item -Path "C:\" -Name "Github" -ItemType "directory"

$Installer7Zip = $env:TEMP + "\7z1900-x64.msi"; 
Invoke-WebRequest "https://www.7-zip.org/a/7z1900-x64.msi" -OutFile 
$Installer7Zip; 
msiexec /i $Installer7Zip /qb; 
Remove-Item $Installer7Zip;
