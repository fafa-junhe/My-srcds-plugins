#!/bin/sh
cd /home/hlserver/tf2/tf/addons/sourcemod/scripting/ || exit
./spcomp trails.sp -o/tmp/tmp.smx
mv /tmp/tmp.smx ../plugins/trails.smx
