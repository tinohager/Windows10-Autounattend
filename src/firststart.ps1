Write-Host "hello"

Add-Content $Env:Temp\autounattend.log "Github Powershell executed"
Add-Content C:\Temp\autounattend1.log "Github Powershell executed"
New-Item -Path "C:\" -Name "Github" -ItemType "directory"

sleep 600
