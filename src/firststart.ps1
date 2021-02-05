Write-Host "Windows10-Autounattend"

# Install Nuget PackageProvider
#if (-Not (Get-PackageProvider -Name NuGet)) {
    Write-Host "Install Nuget PackageProvider"
    Install-PackageProvider -Name NuGet -Confirm:$false -Force
#}

# Install PendingReboot Module
if (-Not (Get-Module -ListAvailable -Name PendingReboot)) {
    Write-Host "Install PendingReboot Module"
    Install-Module PendingReboot -Confirm:$false -Force
}

# Import PendingReboot Module
Import-Module PendingReboot

# Install WindowsUpdate Module
if (-Not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    Write-Host "Install WindowsUpdate Module"
    Install-Module PSWindowsUpdate -Confirm:$false -Force
}

# Check is busy
while ((Get-WUInstallerStatus).IsBusy) {
    Write-Host "Windows Update installer is busy, wait..."
    Start-Sleep -s 10
}

# Install available Windows Updates (less 1GB)
Write-Host "Start installation system updates"
if ((Get-WindowsUpdate -MaxSize 1073741824 -Verbose).Count -gt 0) {
    try {
        Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name 'UnattendInstall!' -Value "cmd /c powershell -ExecutionPolicy ByPass -File $PSCommandPath"
        $status = Get-WindowsUpdate -MaxSize 1073741824 -Install -AcceptAll -Confirm:$false -IgnoreReboot
        Write-Host ($status | Where Result -eq "Failed").Length
        if (($status | Where Result -eq "Installed").Length -gt 0)
        {
            Restart-Computer -Force
            return
        }
        
        if ((Test-PendingReboot).IsRebootPending) {
            Restart-Computer -Force
            return
        }
    } catch {
        Write-Host "Error:`r`n $_.Exception.Message"
        Restart-Computer -Force
    }
}

# Install Hardware Manufacturer Updates
Write-Host "Start installation manufacturers"
$manufacturer = (Get-ComputerInfo | Select -expand CsManufacturer)

if ($manufacturer -eq "Lenovo") {
    Write-Host "Lenovo detected"

    # Install PendingReboot Module
    if (-Not (Get-Module -ListAvailable -Name LSUClient)) {
        Write-Host "Install LSUClient Module"
        Install-Module LSUClient -Confirm:$false -Force
    }

    $updates = Get-LSUpdate
    $updates | Save-LSUpdate -ShowProgress
    $updates | Install-LSUpdate -Verbose
}

# Install Chocolatey
if (-Not (Test-Path "$($env:ProgramData)\chocolatey\choco.exe")) {
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Required Chocolatey packages
$requiredPackages = @("notepadplusplus", "7zip.install", "firefox", "googlechrome")
$installedPackages = New-Object Collections.Generic.List[String]

# Load installed packages
$installedPackagesPath = Join-Path -Path $PSScriptRoot -ChildPath "installedPackages.txt"
if (Test-Path $installedPackagesPath -PathType Leaf) {
    $installedPackages.AddRange([string[]](Get-Content $installedPackagesPath))
}

# Calculate missing packages
$missingPackages = $requiredPackages | Where-Object { $installedPackages -NotContains $_ }

foreach ($package in $missingPackages) {
    if ((Test-PendingReboot).IsRebootPending) {
        Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name 'UnattendInstall!' -Value "cmd /c powershell -ExecutionPolicy ByPass -File $PSCommandPath"
        Restart-Computer -Force
        return
    }

    $installedPackages.Add($package)
    $installedPackages | Out-File $installedPackagesPath

    choco install $package -y
}

Write-Host "Installation done"

$pathCustomizeScript = "C:\Temp\Unattended\customize.ps1"
if (Test-Path $pathCustomizeScript -PathType Leaf) {
    Write-Host "Found customize scirpt"
    & $pathCustomizeScript
}

Start-Sleep -s 60
