#!/bin/bash

#Some useful variables
REALHOME=$HOME
MEGADIR="$REALHOME/MEGA-Instances"
ERR=0
VERSION="0.0.1"
echo "REALHOME = $REALHOME"

ORIGINAL_ARGS=("$@")

while [ $# -gt 0 ]
do
	case $1 in 
		(-h|--help)
			SHOW_HELP=1
		;;

		(-v|--verbose)
			VERBOSE=1
		;;

	esac

	shift
done

if [ -v SHOW_HELP ]
then
	cat <<-HELP
		usage: $(basename $0) [options]

		options:
			-h | --help
			-m | --megadir		set MEGADIR, defaults to ~/MEGA-Instances
	HELP
	exit 0
fi

debug() {
	if [ -v VERBOSE ]
	then
		echo "$@"
	fi
}

zenity () {
	/usr/bin/zenity "$@" 2>/dev/null
}

checkDep () {
	if [[ `whereis $1` == "$1:" ]]
	then
		>&2 echo "Dependency '$1' seems to be missing"
		ERR=1
	fi
}

#Function that creates a Desktop Entry and sets it up for autostart at the login
generateDesktopEntry () {
	DEPATH=$REALHOME/.config/autostart/mega_instances.desktop
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

finstall () {
	checkDep "zenity"
	checkDep "megasync"

	if [[ $ERR -ne 0 ]]
	then
		>&2 echo "Error: Install all required dependencies before running MEGA-Instances"
		exit 1
	fi

	frun
}

addInstances() {
	local INST_NUM=1 INST INST_DIR NAME

	while true
	do
		INST="instance-${INST_NUM}"
		NAME="$(zenity --entry --text="Name this instance, then configure and close it.")"

		if [ -z "$NAME" ]
		then
			NAME="$INST"
		fi
		INST_DIR="$MEGADIR/$NAME"
		mkdir -p "$INST_DIR"

		HOME="$INST_DIR" megasync
		
		if ! zenity --question --text="Do you need another instance?"
		then
			break
		fi
		((INST_NUM++))
	done
}

frun () {
	if [ -f "$MEGADIR/.configured" ]
	then
		echo "$MEGADIR seems to be populated already, launching all instances."
		for d in $MEGADIR/*/
		do
			HOME="$d" megasync 2> /dev/null &
		done
	else
		echo "${MEGADIR} is not configured."

		addInstances

		if zenity --question --text="Launching all instances. Do you want to also autostart them?"
		then
			generateDesktopEntry
		fi

		touch "$MEGADIR/.configured"
		bash $0 &
		sleep 1
	fi
}

finstall
