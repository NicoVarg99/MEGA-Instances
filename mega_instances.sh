#!/bin/bash

#Some useful variables
REALHOME=$HOME
MEGADIR="$REALHOME/MEGA-Instances"
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
				MEGADIR="$REALHOME/$2"
				shift
			;;

			(--add-more)
				ADD_MORE_INSTANCES=1
			;;

			(--toggle-autostart)
				TOGGLE_AUTOSTART=1
			;;
		esac

		shift
	done
}

show_help() {
	cat <<-HELP
		usage: $(basename $0) [options]

		options:
			-h | --help
			-m | --megadir	PATH_TO_DIR		overrides path to instances
												defaults to ~/MEGA-Instances

			     --add-more					add more instances to a configured path
				 --toggle-autostart				toggle autostart
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
		if ! which $1 2>/dev/null
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
	local DEPATH=$REALHOME/.config/autostart/mega_instances.desktop
	mkdir -p $REALHOME/.config/autostart
	
	cat <<-ENTRY > "$DEPATH"
	[Desktop Entry]
	Type=Application
	Exec=/usr/bin/megasync-instances
	Name=megasync_instances
	Comment=Open all your MEGA instances
	ENTRY

	chmod +x $DEPATH
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
		NAME="$(zenity --entry --text="Name this instance, then configure and close it.")"

		if [ -z "$NAME" ]
		then
			NAME="$INST"
		fi
		INST_DIR="$MEGADIR/$NAME"
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

check_deps zenity megasync
debug "REALHOME = $REALHOME"
parse_args

if [ -v SHOW_HELP ]
then
	show_help
elif [ -f "$MEGADIR/.configured" ]
then
	if [ -v ADD_MORE_INSTANCES ]
	then
		add_instances
	fi

	launch_instances
else
	configure_instances
fi
