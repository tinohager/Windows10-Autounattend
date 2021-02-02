# Install Nuget Package Provider
Install-PackageProvider -Name NuGet -RequiredVersion 2.8.5.201 -Confirm:$false -Force

# Install check pending reboot module
Install-Module PendingReboot -Confirm:$false -Force

# Import check pending reboot module
Import-Module PendingReboot

# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Required Chocolatey packages
$requiredPackages = @("notepadplusplus", "googlechrome", "firefox", "7zip.install", "sql-server-express", "sql-server-management-studio")
$installedPackages = New-Object Collections.Generic.List[String]

$installedPackagesPath = Join-Path -Path $PSScriptRoot -ChildPath "installedPackages.txt"
if (Test-Path $installedPackagesPath -PathType Leaf) {
    $installedPackages.AddRange([string[]](Get-Content $installedPackagesPath))
}

# Calculate missing packages
$missingPackages = $requiredPackages | Where-Object { $installedPackages -NotContains $_ }

foreach ($package in $missingPackages) {
    if ((Test-PendingReboot).IsRebootPending) {
        Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name 'UnattendInstall' -Value "%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy bypass -file $PSCommandPath"
        Restart-Computer -Force
        return
    }

    $installedPackages.Add($package)
    $installedPackages | Out-File $installedPackagesPath

    choco install $package -y
}


