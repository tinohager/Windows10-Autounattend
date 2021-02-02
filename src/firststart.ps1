# Install Nuget Package Provider
if (-Not (Get-PackageProvider -Name NuGet)) {
    Install-PackageProvider -Name NuGet -RequiredVersion 2.8.5.201 -Confirm:$false -Force
}

# Install check pending reboot module
if (-Not (Get-Module -ListAvailable -Name PendingReboot)) {
    Install-Module PendingReboot -Confirm:$false -Force
}

# Import check pending reboot module
Import-Module PendingReboot

# Install Windows Updates
if (-Not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    Install-Module PSWindowsUpdate -Confirm:$false -Force
}

if ((Get-WindowsUpdate).Count -gt 0) {
    Install-WindowsUpdate -AcceptAll
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
Start-Sleep -s 60
