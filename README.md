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

Follow the below steps on any distro:

- download the script from GitHub and make it executable

  ```bash
  curl -o megasync-instances https://raw.githubusercontent.com/NicoVarg99/MEGA-Instances/master/mega_instances.sh
  chmod 755 megasync-instances
  ```

- **either append it to your** `PATH` only

  ```bash
  echo 'export PATH='"$PWD"'/megasync-instances:'"$PATH" >> ~/.bashrc
  ```

- **or expose it systemwide** for all users
  ```bash
  sudo mv megasync-instances /usr/local/bin/
  ```

Arch Linux users can install the package directly from AUR ([megasync-instances](https://aur.archlinux.org/packages/megasync-instances))

## Uninstallation

```bash
megasync-instances --uninstall
```
