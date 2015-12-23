#!/bin/bash

function finstall
{
	wget https://mega.nz/linux/MEGAsync/xUbuntu_15.10/amd64/megasync-xUbuntu_15.10_amd64.deb
	sudo dpkg -i megasync-xUbuntu_15.10_amd64.deb
	sudo rm megasync-xUbuntu_15.10_amd64.deb
	sudo apt-get -y --force-yes -f install
	frun
}

function frun
{
	FILE=/home/$USER/MEGA/.ok

	if [ -f $FILE ];
	then
		echo "File $FILE exists. Will now launch the instances."

		for d in /home/$USER/MEGA/*/ ; do
			echo "$d"
			HOME=$d
			megasync 2> /dev/null &
		done

	else
	  	echo "File $FILE does not exist. Will now start the configuration."

		INSTNUM=`zenity --entry --text="How many MEGA instances do you need?"`
		mkdir /home/$USER/MEGA


		for (( i=1; i<=INSTNUM; i++ ))
		do
			NAME=`zenity --entry --text="Insert the name for instance $i/$INSTNUM"`
			ARRAY[$i]=$NAME	
			mkdir /home/$USER/MEGA/$NAME
		done

		for (( i=1; i<=INSTNUM; i++ ))
		do
			zenity --warning --text="Instance ${ARRAY[i]} ($i/$INSTNUM). Close it after the configuration."
			HOME=/home/$USER/MEGA/${ARRAY[$i]}
			megasync
		done
		
		
		
		
		mkdir /home/$USER/.config/autostart
		
		
		
		echo "[Desktop Entry]" > .config/autostart/mega_instances.desktop
		echo "Type=Application" >> .config/autostart/mega_instances.desktop
		echo "Exec=/home/$USER/MEGA/mega_instances.sh" >> .config/autostart/mega_instances.desktop
		echo "Name=megasync_instances" >> .config/autostart/mega_instances.desktop
		echo "Comment=Open all the MEGA instances"  >> .config/autostart/mega_instances.desktop
		chmod +x .config/autostart/mega_instances.desktop

		
		
		
		zenity --warning --text="Will now launch all the instances. They will also start at every startup."
		touch /home/$USER/MEGA/.ok
		cp $0 /home/$USER/MEGA/mega_instances.sh
		chmod +x /home/$USER/MEGA/mega_instances.sh
		bash /home/$USER/MEGA/mega_instances.sh
	fi
}


if [ -f /usr/bin/megasync ];
then
	frun
else
	finstall
fi
