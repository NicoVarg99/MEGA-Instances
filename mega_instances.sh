#!/bin/bash

#Some useful variables
MEGADIR="$HOME/MEGA-Instances"
PATH_TO_SCRIPT="$(readlink -f "$0")"
VERSION="0.0.1"

HELP_MENU=$(cat <<HELP
usage: $(basename $0) [options]

options:
  -h | --help
  -v | --verbose                print additional info to the terminal
  -m | --megadir PATH_TO_DIR    overrides path to instances
                                  defaults to ~/MEGA-Instances

  -a | --add-more               add more instances to an already configured path
  -t | --toggle-autostart       instances based on above --megadir location
  -k | --killall                instances based on above --megadir location
  -i | --install-for-me         moves this script under ~/bin, creating and
                                  prepending it to the PATH variable if necessary
  -u | --uninstall
HELP
)

main() {
  check_deps zenity megasync
  parse_args "$@"

  if [ -v SHOW_HELP ]
  then
    echo "$HELP_MENU"
  elif [ -v ADD_MORE_INSTANCES ]
  then
    add_instances
  elif [ -v TOGGLE_AUTOSTART ]
  then
    toggle_autostart
  elif [ -v KILL_ALL ]
  then
    kill_all
  elif [ -v INSTALL ]
  then
    install
  elif [ -v UNINSTALL ]
  then
    uninstall
  elif [ -f "$MEGADIR/.configured" ]
  then
    launch_instances
  else
    configure_instances
  fi
}

parse_args() {
  local -a unknown_flags
  while [ $# -gt 0 ]
  do
    case "$1" in
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

      (-i|--install-for-me)
        INSTALL=1
      ;;

      (-u|--uninstall)
        UNINSTALL=1
      ;;

      (*)
        unknown_flags+=("$1")
      ;;
    esac

    shift
  done

  if [ ${#unknown_flags[@]} -gt 0 ]
  then
    echo "UNKNOWN FLAGS: ${unknown_flags[@]}"
    exit 1
  fi
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
      local err=1
    fi
    shift
  done

  if [ -v err ]
  then
    >&2 echo "Error: Install all required dependencies before running MEGA-Instances"
    exit 1
  fi
}

get_depath() {
  printf "$HOME/.config/autostart/mega_instances_at${MEGADIR////_}.desktop"
}

#Function that creates a Desktop Entry and sets it up for autostart at the login
add_desktop_entry () {
  mkdir -p "$HOME/.config/autostart"

  cat <<ENTRY > "$1"
[Desktop Entry]
Type=Application
Exec=$PATH_TO_SCRIPT --megadir "$MEGADIR"
Name=megasync_instances
Comment=Open all your MEGA instances configured at "$MEGADIR"
ENTRY

  chmod +x $1
  echo "created $1"
}

rm_desktop_entry() {
  rm "$1"
  echo "deleted $1"
}

toggle_autostart() {
  local depath=$(get_depath)
  if [ -f "$depath" ]
  then
    rm_desktop_entry "$depath"
  else
    add_desktop_entry "$depath"
  fi
}

configure_instances () {
  debug "${MEGADIR} is not configured."

  add_instances

  if zenity --question --text="Do you want to autostart these instances?"
  then
    add_desktop_entry $(get_depath)
  fi

  touch "$MEGADIR/.configured"
}

add_instances() {
  debug "Adding instances..."

  local inst_num=$(($(find "$MEGADIR" -mindepth 1 -maxdepth 1 -type d | wc -l) + 1))
  local inst inst_dir name

  while true
  do
    inst="instance-${inst_num}"
    name="$(zenity --title="Add new instance" \
      --entry --entry-text="$inst" \
      --text="Set the name of instance, then configure and close it.")"

    if [ -z "$name" ]
    then
      name="$inst"
    fi
    inst_dir="$MEGADIR/$name"

    if [ -d "$inst_dir" ]
    then
      zenity --error --title="name collision" --text="$name already exists in $MEGADIR, pick another name!"
      continue
    fi

    debug "Creating $inst_dir"
    mkdir -p "$inst_dir"

    HOME="$inst_dir" megasync 2> /dev/null &

    if ! zenity --question --text="Do you need another instance?"
    then
      break
    fi
    ((inst_num++))
  done
}

launch_instances () {
  debug "$MEGADIR seems to be populated already, launching all instances."

  if [ -f "$MEGADIR/.env" ]
  then
    source "$MEGADIR/.env"
  fi

  local instance
  for instance in "$MEGADIR"/*/
  do
    (
      if [ -f "$instance.env" ]
      then
        source "$instance.env"
      fi

      debug "Launching $instance"
      HOME="$instance" megasync 2> /dev/null &
    )
  done
}

kill_all() {
  debug "Killing all instances of $MEGADIR"

  local pid
  for pid in $(pgrep megasync); do
    if tr '\0' '\n' < /proc/$pid/environ | grep -q "HOME=$MEGADIR/"; then
      kill $pid &
    fi
  done
}

install() {
  debug "Installing script under ~/bin"

  if [ ! -d ~/bin ]
  then
    mkdir -p ~/bin
  fi

  if ! echo ":$PATH:" | grep -q ":$HOME/bin:"
  then
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
  fi

  mv "$PATH_TO_SCRIPT" ~/bin/
}

uninstall() {
  local depath=$(get_depath)
  if [ -f "$depath" ]
  then
    rm_desktop_entry "$depath"
  fi

  if zenity --question --title="Deleting synced files" --text="Do you want to remove '$MEGADIR'?"
  then
    debug "removing $MEGADIR"
    rm -rf "$MEGADIR"
  fi

  if zenity --question --title="Deleting script" --text="Do you want to delete the script, too?"
  then
    debug "deleting script"
    if [[ "$PATH_TO_SCRIPT" == /usr/bin/* ]]
    then
      sudo pacman -Rscn megasync-instances
    elif [[ "$PATH_TO_SCRIPT" == /usr/local/bin/* ]]
    then
      sudo rm "$PATH_TO_SCRIPT"
    else
      rm "$PATH_TO_SCRIPT"
    fi
  fi
}

main "$@"
