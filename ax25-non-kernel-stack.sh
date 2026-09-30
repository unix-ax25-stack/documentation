#!/bin/bash

#09/26/26

# Purpose:  This is a basic script to connect a native Linux application through the new ax25netd 
#           Unix sockets to AGW software-TNC for AX.25 connections


# Todo: 
#           - Add start/stop stanzas


#Errata
#09/26/26 - dranch - initial version of the start up script


#---------------------------------------------------------------------------------------------

#Variables
#---------

#Log file of all direwolf statup and decodes of heard packets
#  If you do not want to store this detail (it can get very big over time), 
#  you can either tune what is logged via the '-q ' options or change the output 
#  filename to use: /dev/null
#
DIREWOLFRUNLOG="/var/tmp/direwolf.log"

#Log for ax25netd
AX25NETDLOG="/var/tmp/ax25netd.log"


#Enable script debugging if wanted
DEBUG=0


#---------------------------------------------------------------------------------------------

# Functions
# ---------

function CHKERR {
   ERR=$?
   if [ "$DEBUG" == "y" ]; then
      echo -e "CHKRERR: in function"
   fi
   if [ $ERR -ne 0 ]; then
      echo -en "\nERROR: the last command failed"
      if [ "$CONTINUEONFAIL" == "n" ]; then
         echo -e " - CONTINUEONFAIL is set to 'n' so we are aborting"
         exit 1
        else
         echo -e " - CONTINUEONFAIL is set to 'y' so we are continuing"
      fi
     else
      if [ "$DEBUG" == "y" ]; then
         echo -e "CHKRERR: No failure found"
      fi
   fi
}




#---------------------------------------------------------------------------------------------

# Main script
#------------

echo -e "\nTest of DL9SAU Linux non-kernel packew radio suite - scenario#!"

if [ -n "`lsmod | grep -e mkiss -e ax25 -e netrom -e rose`" ]; then
   echo -e "\nERROR: linux in-kernel AX.25 stack modules loaded"
   echo -e   "       shutdown the in-kernel ax.25 stack and try again"
   echo -e   "\nAborting"
   CHKERR
fi

if [ "$UIDi" == "0" ]; then
   echo -e "\nERROR: do not run this script as root"
   echo -e   "       Run this script as a regular user that has all required permissions"
   CHKERR
fi


cd /etc/ax25
CHKERR

#Direwolf can also be started via systemd but we need to ensure it is actually running - tbd
echo -e "Starting direwolf:  Logs in $LOG"
direwolf -c /etc/ax25/direwolf.conf -da -t0 2>&1 >> $DIREWOLFRUNLOG &
CHKERR

#check this exists as it's required for ax25netd
if [ ! -d /var/ax25/ ]; then
   sudo mkdir -m 1777 /var/ax25
   CHKERR
   sudo mkdir -m 777 /var/ax25/mheard/
   CHKERR
fi

echo -e "Starting ax25netd (translates libax25 calls to AGW connections)"
echo -e "   - local AGW server loop/proxy port: 8100"
echo -e "   - Mheard station gathering enabled"
#echo -e "DEBUG: running in foreground : not as a daemon"
#ax25netd -c /etc/ax25/agwpe.conf -f
ax25netd -c /etc/ax25/agwpe.conf 2>&1 >> $AX25NETDLOG
CHKERR

echo -e "\nScript complete\n"

