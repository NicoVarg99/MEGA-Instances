#!/bin/bash

FILE=./.ok

if [ -f $FILE ];
then
	echo "File $FILE exists. Will now launch the instances."

	for d in $(xdg-user-dir)/MEGA/*/ ; do
		echo "$d"
		HOME=$d
		megasync 2> /dev/null &
	done

else
  	echo "File $FILE does not exist. Will now start the configuration."

	INSTNUM=`zenity --entry --text="How many MEGA instances do you need?"`
	mkdir $(xdg-user-dir)/MEGA


	for (( i=1; i<=INSTNUM; i++ ))
	do
		NAME=`zenity --entry --text="Insert the name for instance $i/$INSTNUM"`
		ARRAY[$i]=$NAME	
		mkdir $(xdg-user-dir)/MEGA/$NAME
	done

	for (( i=1; i<=INSTNUM; i++ ))
	do
		zenity --warning --text="Instance $ARRAY[$i] ($i/$INSTNUM). Close it after the configuration."
		HOME=$(xdg-user-dir)/MEGA/$ARRAY[$i]
		megasync
	done

	zenity --warning --text="Will now launch all the instances. They also will start ed every startup."
	touch $(xdg-user-dir)/MEGA/.ok
	cp $0 $(xdg-user-dir)/MEGA/mega_instances.sh
	bash $(xdg-user-dir)/MEGA/mega_instances.sh
fi


