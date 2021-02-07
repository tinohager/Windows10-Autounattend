# Windows10 Autounattend

This project is optimized for installation via an USB stick. All available Windows updates are installed and manufacturer specific drivers for Lenovo are installed automatically. Also various software packages can be installed automatically via chocolatey. 

## Process Flow
- Check if an Internet connection is available
- Download the `firststart.ps1` script
- Execute the `firststart.ps1` script
- Install Windows Updates
- Install Hardware Manufacturer Updates
- Install Chocolatey Software Packages
- Check is a customize script available 

## Error Handling

If the error dialog is displayed after the installation and the computer hangs in a loop after confirming, this can be fixed with this trick.
1. When message appears, press `SHIFT` + `F10` to open `CMD`
1. Type: `regedit.exe`
1. Browse to `HKLM/SYSTEM/SETUP/STATUS/ChildCompletion` in `setup.exe`, change the value from 1 to 3.
1. Close the regedit window and confirm the error message dialog
1. Windows will now reboot to the OS but will bypass your answer file.

## Windows-International-Core

| Setting  | Description |
| ------------- | ------------- |
| **SystemLocale**  | Specifies the language for non-Unicode programs |
| **InputLocale** | Specifies the system input locale and the keyboard layout |
| **UILanguage** | Specifies the system default user interface (UI) language |
| **UserLocale** | Specifies the per-user settings used for formatting dates, times, currency, and numbers |

## Configuration Passes

| Step  | Pass | Description |
| ------------- | ------------- | ------------- |
| 1 | windowsPE | The Windows image is copied to the destination computer
| 2 | offlineServicing | After copy the image and before the computer reboots (not used in my project)
| 3 | specialize | Set language configuration, set hostname
| 4 | oobeSystem | Before Windows Welcome starts (Create User, Start Powershell Setup Script)

## Create an USB Boot Device

To create a bootable USB stick I recommend one of the following tools. Ventoy has the advantage that several ISOs are available at the same time on a USB stick.

- Use [Ventoy](https://github.com/ventoy/Ventoy) with the `Auto Installation Plugin`
- Use this [Powershell script](https://github.com/vmware-samples/euc-samples/tree/master/Windows-Samples/Tools%20%26%20Utilities/Windows%2010%20Automated%20Setup%20Media) from VMware

### Ventoy

You should have this files in your program directory.

    .
    ├── ventoy                                     # Base folder for ventoy configuration
    ├── ventoy/ventoy.json                         # Vento Configuration
    ├── ventoy/script/windows_autounattend1.xml    # Windows Auto Unattend Configuration
    ├── ISO                                        # Base folder for all ISO files
    ├── ISO/Windows.iso                            # The Windows ISO
