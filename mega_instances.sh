#!/bin/bash

#Some useful variables
REALHOME=$HOME
MEGADIR="$REALHOME/MEGA-Instances"
DEPATH=$REALHOME/.config/autostart/mega_instances.desktop
BIN=/usr/local/bin/megasync-instances
PATH_TO_SCRIPT="$(readlink -f "$0")"
VERSION="0.0.1"

parse_args() {
  while [ $# -gt 0 ]
  do
    case $1 in
      (-h|--help)
        SHOW_HELP=1
      ;;

      (-v|--verbose)
        VERBOSE=1
      ;;

      (-m|--megadir)
        MEGADIR="$(readlink -f "$2")"
        shift
      ;;

      (-a|--add-more)
        ADD_MORE_INSTANCES=1
      ;;

      (-t|--toggle-autostart)
        TOGGLE_AUTOSTART=1
      ;;

      (-k|--killall)
        KILL_ALL=1
      ;;

      (-u|--uninstall)
        UNINSTALL=1
      ;;
    esac

    shift
  done
}

show_help() {
  cat <<HELP
usage: $(basename $0) [options]

options:
  -h | --help
  -m | --megadir PATH_TO_DIR    overrides path to instances
                                  defaults to ~/MEGA-Instances

  -a | --add-more               add more instances to an already configured path
  -t | --toggle-autostart
  -k | --killall                instances based on above --megadir location
  -u | --uninstall
HELP
}

debug() {
  if [ -v VERBOSE ]
  then
    echo "$@"
  fi
}

zenity () {
  /usr/bin/zenity "$@" 2>/dev/null
}

check_deps () {
  while [ $# -gt 0 ]
  do
    if ! which $1 >/dev/null 2>&1
    then
      >&2 echo "Dependency '$1' seems to be missing"
      local ERR=1
    fi
    shift
  done

  if [ -v ERR ]
  then
    >&2 echo "Error: Install all required dependencies before running MEGA-Instances"
    exit 1
  fi
}

#Function that creates a Desktop Entry and sets it up for autostart at the login
generate_desktop_entry () {
  mkdir -p $REALHOME/.config/autostart

  cat <<ENTRY > "$DEPATH"
[Desktop Entry]
Type=Application
Exec=$PATH_TO_SCRIPT
Name=megasync_instances
Comment=Open all your MEGA instances
ENTRY

  chmod +x $DEPATH
}

toggle_autostart() {
  if [ -f "$DEPATH" ]
  then
    rm "$DEPATH"
    echo "deleted $DEPATH"
  else
    generate_desktop_entry
    echo "created $DEPATH"
  fi
}

configure_instances () {
  debug "${MEGADIR} is not configured."

  add_instances

  if zenity --question --text="Launching all instances. Do you want to also autostart them?"
  then
    generate_desktop_entry
  fi

  touch "$MEGADIR/.configured"

  launch_instances
}

add_instances() {
  local INST_NUM=$(($(find "$MEGADIR" -mindepth 1 -maxdepth 1 -type d | wc -l) + 1))
  local INST INST_DIR NAME
  debug "Adding instances..."

  while true
  do
    INST="instance-${INST_NUM}"
    NAME="$(zenity --title="Add new instance" \
      --entry --entry-text="$INST" \
      --text="Set the name of instance, then configure and close it.")"

    if [ -z "$NAME" ]
    then
      NAME="$INST"
    fi
    INST_DIR="$MEGADIR/$NAME"

    if [ -d "$INST_DIR" ]
    then
      zenity --error --title="name collision" --text="$NAME already exists in $MEGADIR, pick another name!"
      continue
    fi

    debug "Creating $INST_DIR"
    mkdir -p "$INST_DIR"

    HOME="$INST_DIR" megasync

    if ! zenity --question --text="Do you need another instance?"
    then
      break
    fi
    ((INST_NUM++))
  done
}

launch_instances () {
  debug "$MEGADIR seems to be populated already, launching all instances."
  for d in $MEGADIR/*/
  do
    debug "Launching $d"
    HOME="$d" megasync 2> /dev/null &
  done
}

kill_all() {
  for pid in $(pgrep megasync); do
    if tr '\0' '\n' < /proc/$pid/environ | grep -q 'HOME='"$MEGADIR"'/'; then
      kill $pid &
    fi
  done
}

uninstall() {
  rm "$DEPATH"
  rm -rf "$MEGADIR"
  echo "Deleting $BIN"
  sudo rm $BIN
}

check_deps zenity megasync
debug "REALHOME = $REALHOME"
parse_args $@

if [ -v SHOW_HELP ]
then
  show_help
elif [ -v KILL_ALL ]
then 
  kill_all
elif [ -v UNINSTALL ]
then
  uninstall
elif [ -f "$MEGADIR/.configured" ]
then
  if [ -v ADD_MORE_INSTANCES ]
  then
    add_instances
  fi

  if [ -v TOGGLE_AUTOSTART ]
  then
    toggle_autostart
  fi

  launch_instances
else
  configure_instances
fi
