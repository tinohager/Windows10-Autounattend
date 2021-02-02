Write-Host "Windows10-Autounattend"

# Install Nuget PackageProvider
if (-Not (Get-PackageProvider -Name NuGet)) {
    Write-Host "Install Nuget PackageProvider"
    Install-PackageProvider -Name NuGet -Confirm:$false -Force
}

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

# Install available Windows Updates
if ((Get-WindowsUpdate).Count -gt 0) {
    Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name 'UnattendInstall!' -Value "cmd /c powershell -ExecutionPolicy ByPass -File $PSCommandPath"
    Install-WindowsUpdate -NotKBArticleID "KB4598242" -AcceptAll -Confirm:$false -AutoReboot
    Restart-Computer -Force
    return
}

# Install Chocolatey
if (-Not (Test-Path "$($env:ProgramData)\chocolatey\choco.exe")) {
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Required Chocolatey packages
$requiredPackages = @("notepadplusplus", "googlechrome", "firefox", "7zip.install", "sql-server-express", "sql-server-management-studio")
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
