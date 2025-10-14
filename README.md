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

- **either** place it in your personal `~/bin` folder

  ```bash
  ./megasync-instances --install-for-me
  ```

- **or expose it systemwide** for all users
  ```bash
  sudo mv megasync-instances /usr/local/bin/
  ```

Arch Linux users can install the package directly from AUR ([megasync-instances](https://aur.archlinux.org/packages/megasync-instances))

## Tweaks

Each configured path, and all of their instances can have a `.env` in their root directory, which will be sourced before getting started up.

The below 2 `.env` files

```bash
# ~/MEGA-Instances/.env:
export INST_VAR_ALL="present in all instances"

# ~/MEGA-Instances/instance-1/.env:
export INST_VAR1="present only in instance-1"

# ~/MEGA-Instances/instance-2/.env does not exist
```

result in

```bash
# instance-1 having access to:
INST_VAR_ALL="present in all instances"
INST_VAR1="present only in instance-1"

# instance-2 having access to:
INST_VAR_ALL="present in all instances"
```

## Uninstallation

```bash
megasync-instances --uninstall
```
