# Windows10-Autounattend

## Error Handling

If the error dialog is displayed after the installation and the computer hangs in a loop after confirming, this can be fixed with this trick.
1. When message appears, press `SHIFT` + `F10` to open `CMD`
1. Type: `regedit.exe`
1. Browse to `HKLM/SYSTEM/SETUP/STATUS/ChildCompletion` in `setup.exe`, change the value from 1 to 3.
1. Close the regedit window and confirm the error message dialog
1. Windows will now reboot to the OS but will bypass your answer file.

## Create an USB Boot Device

To create a bootable USB stick I recommend one of the following tools. Ventoy has the advantage that several ISOs are available at the same time on a USB stick.

- Use [Ventoy](https://github.com/ventoy/Ventoy) with the `Auto Installation Plugin`
- Use this [Powershell script](https://github.com/vmware-samples/euc-samples/tree/master/Windows-Samples/Tools%20%26%20Utilities/Windows%2010%20Automated%20Setup%20Media) from VMware
