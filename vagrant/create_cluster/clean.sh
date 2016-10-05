#!/bin/bash

############
# GET OPTS #
############

function usage {
  echo "-c <number> - Specifies how many clients to clean up"
  exit
}

while getopts ":c:" opt; do
  case $opt in
    c)
      PXE_COUNT=$OPTARG
      ;;
   *)
      echo "Invalid option: -$OPTARG" >&2
      usage
      ;;
  esac
done


######################
# DEPLOY PXE CLIENTS #
######################
if [ $PXE_COUNT ]
  then
    for (( i=1; i <= $PXE_COUNT; i++ ))
      do
        vmName="boot-$i"

        if $remove ; then
            VBoxManage controlvm $vmName poweroff
            VBoxManage unregistervm $vmName --delete 
        fi
      done
fi
