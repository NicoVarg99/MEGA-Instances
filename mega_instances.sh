#!/bin/bash

#Some useful variables
REALHOME=$HOME
MEGADIR="MEGA"
FILE=$REALHOME/$MEGADIR/.ok
echo "REALHOME = $REALHOME"

#Function that creates a Desktop Entry and sets it up for autostart at the login
function generateDesktopEntry
{
	mkdir -p /home/$USER/.config/autostart
	echo "[Desktop Entry]" > $REALHOME/.config/autostart/mega_instances.desktop
	echo "Type=Application" >> $REALHOME/.config/autostart/mega_instances.desktop
	echo "Exec=/home/$USER/MEGA/mega_instances.sh" >> $REALHOME/.config/autostart/mega_instances.desktop
	echo "Name=megasync_instances" >> $REALHOME/.config/autostart/mega_instances.desktop
	echo "Comment=Open all your MEGA instances"  >> $REALHOME/.config/autostart/mega_instances.desktop
	chmod +x $REALHOME/.config/autostart/mega_instances.desktop
}

function finstall
{
	ERR=0

	if [[ `whereis zenity` == "zenity:" ]];
	then
		echo "Dependency 'zenity' seems to be missing"
		ERR=1
	fi

	if [[ `whereis megasync` == "megasync:" ]];
	then
		echo "Dependency 'megasync' seems to be missing"
		ERR=1
	fi

	if [[ $ERR -ne 0 ]]; then
		echo "Error: Install all required dependencies before running MEGA-Instances"
		exit 1
	fi

	generateDesktopEntry
	frun
}

function frun
{
	FILE=$REALHOME/$MEGADIR/.ok

	if [ -f $FILE ];
	then
		echo "MEGA-Instances is already configured. Will now launch the instances."

		for d in $REALHOME/$MEGADIR/*/ ; do
			echo "$d"
			HOME=$d
			megasync 2> /dev/null &
		done

	else
	  	echo "MEGA-Instances is not configured. Will now start the configuration."

			INSTNUM=`zenity --entry --text="How many MEGA instances do you need?"`
			mkdir -p $REALHOME/$MEGADIR

			for (( i=1; i<=INSTNUM; i++ ))
			do
				NAME=`zenity --entry --text="Insert the name for instance $i/$INSTNUM"`
				ARRAY[$i]=$NAME
				mkdir -p $REALHOME/$MEGADIR/$NAME
			done

			for (( i=1; i<=INSTNUM; i++ ))
			do
				zenity --warning --text="Instance ${ARRAY[i]} ($i/$INSTNUM). Close it after the configuration."
				HOME=$REALHOME/$MEGADIR/${ARRAY[$i]}
				megasync
			done

			generateDesktopEntry

			zenity --warning --text="Will now launch all the instances. They will also start at every startup."
			HOME=$REALHOME
			touch $REALHOME/$MEGADIR/.ok #Mark as configured
			cp $0 $REALHOME/$MEGADIR/mega_instances.sh
			chmod +x $REALHOME/$MEGADIR/mega_instances.sh
			bash $REALHOME/$MEGADIR/mega_instances.sh
	fi
}

finstall
