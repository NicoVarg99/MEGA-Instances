# MEGA-Instances
This script will help you running multiple MEGA (megasync) instances on Linux.
Make sure megasync is installed before your first use of this script.
Dependencies:
  - megasync
  - zenity

## Images
![System tray](img/tray.png?raw=true "System tray")
![File manager](img/file-manager.png?raw=true "File manager")

## Installation
```bash
sudo wget -O /usr/bin/megasync-instances https://raw.githubusercontent.com/NicoVarg99/MEGA-Instances/master/mega_instances.sh
sudo chmod 755 /usr/bin/megasync-instances
megasync-instances
```
Arch Linux users can install the package directly from AUR ([megasync-instances](https://aur.archlinux.org/packages/megasync-instances))

## Uninstallation
#### Close all instances
```bash
killall megasync
```
#### Remove script
```bash
rm ~/.config/autostart/mega_instances.desktop
rm ~/.config/megasync-instances/status
sudo rm /usr/bin/megasync-instances
```
#### Remove all instances
```bash
rm -rf ~/MEGA/*
```
