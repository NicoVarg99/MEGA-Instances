# MEGA-Instances
This script will help you running multiple MEGA (megasync) instances on Linux.
Make sure megasync is installed before your first use of this script.
Dependencies:
  - megasync
  - zenity

## Images
![System tray](img/path/tray-png?raw=true "System tray")
![File manager](img/path/file-manager.png?raw=true "File manager")

## Installation
```bash
wget https://raw.githubusercontent.com/NicoVarg99/MEGA-Instances/master/mega_instances.sh && bash mega_instances.sh
```

## Uninstallation
#### Remove script
```bash
rm ~/.config/autostart/mega_instances.desktop
rm ~/MEGA/.ok
rm ~/MEGA/mega_instances.sh
```
#### Remove all instances
```bash
rm -rf ~/MEGA/*
```
