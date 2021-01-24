# Windows10-Autounattend

## Error Handling

If the error dialog is displayed after the installation and the computer hangs in a loop after confirming, this can be fixed with this trick.
1. When message appears, press `SHIFT` + `F10` to open `CMD`
1. Type: `regedit.exe`
1. Browse to `HKLM/SYSTEM/SETUP/STATUS/ChildCompletion` in `setup.exe`, change the value from 1 to 3.
1. Close the regedit window and confirm the error message dialog
1. Windows will now reboot to the OS but will bypass your answer file.
