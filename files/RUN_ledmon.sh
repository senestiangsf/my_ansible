#!/bin/bash

    NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"` #Blue
    NUMBER=`echo "\033[33m"` #yellow
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
    ENTER_LINE=`echo "\033[33m"`



for drive in /dev/sd[a-z] /dev/sd[a-z][a-z]; do
        echo "";
	echo -e "Disk: ${ENTER_LINE} $drive ${RED_TEXT} ${NORMAL}"
	echo -e "Sit LED aan\n";
	ledctl locate=$drive;
        read -n 1 -s -r -p "Press any key to continue"
	echo "Sit LED af"
	ledctl locate_off=$drive;
	clear;
done;
