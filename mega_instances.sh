#!/bin/bash

#Some useful variables
REALHOME=$HOME
MEGADIR="MEGA"
echo "REALHOME = $REALHOME"

#Function that creates a Desktop Entry and sets it up for autostart at the login
function generateDesktopEntry
{
	FILE=$REALHOME/$MEGADIR/launch_all_megasync.sh

	if [ -f $FILE ]; then
		echo "Launch file exist."
	else
cat > /home/$USER/MEGA/launch_all_megasync.sh << EOF1
#!/bin/bash

#Some useful variables
REALHOME=$HOME
MEGADIR="MEGA"
echo "REALHOME = $REALHOME"
echo "launching megasync the instances."

for d in $REALHOME/$MEGADIR/*/ ; do
	echo "\$d"
	HOME=\$d
	megasync 2> /dev/null &
done
EOF1

cat > $REALHOME/.config/autostart/launch_all_megasync.desktop << EOF1
[Desktop Entry]
Type=Application
Exec=/home/$USER/MEGA/launch_all_megasync.sh
Name=launch_all_megasync
Comment=Open all your MEGA instances
EOF1
chmod +x $REALHOME/.config/autostart/launch_all_megasync.desktop

	fi
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
	mkdir -p $REALHOME/$MEGADIR
	NAME=`zenity --entry --text="Insert the name for megasync instance"`
	NAMESIZE=${#NAME}

	if [[ $NAMESIZE -gt 1 ]]; then
		mkdir -p $REALHOME/$MEGADIR/$NAME
		HOME=$REALHOME/$MEGADIR/$NAME
		megasync
	else
		echo "you must provide a name."
	fi
}

finstall
