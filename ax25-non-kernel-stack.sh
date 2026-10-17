#!/bin/bash

#10/08/26

# Purpose:  This is a basic script to connect a native Linux application through the new ax25netd 
#           Unix sockets to AGW software-TNC for AX.25 connections


# Todo: 
#           - Add start/stop stanzas


#Errata
#10/08/26 - KI6ZHD - added restoring audio device levels
#10/04/26 - KI6ZHD - disable Direwolf APRS packet decoding by default
#10/02/26 - KI6ZHD - Added ax25netd socket directory prep; added start/stop syntax
#09/26/26 - KI6ZHD - initial version of the start up script


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

if [ "$UID" == "0" ]; then
   echo -e "\nERROR: do not run this script as root"
   echo -e   "       Run this script as a regular user that has all required permissions"
   CHKERR
fi

if [ "$1" != "start" ] || [ "$1" != "stop" ]; then 
   echo -e "\nERROR:  USAGE: You must specify 'start' or 'stop'
   echo -e "Aborting\n"
   exit 1
fi

if [ "$1" == "start "]; then
   cd /etc/ax25
   CHKERR

   #Restoring previous saved audio levels - you MUST have previously tuned and saved your levels
   sudo alsactl restore
   CHKERR

   #Direwolf can also be started via systemd but we need to ensure it is actually running - tbd
   echo -e "Starting direwolf:  Logs in $LOG"
   # APRS decoding disabled by default - if you want this decoing logged, remove the -qd option
   direwolf -c /etc/ax25/direwolf.conf -da -qd -t0 2>&1 >> $DIREWOLFRUNLOG &
   CHKERR

   #check this exists as it's required for ax25netd socket support
   if [ ! -d /var/run/ax25/sockets/ ]; then
      echo -e "\nCreating ax25netd socket directory"
      sudo mkdir -p /var/run/ax25/sockets/
      sudo chmod 755 /var/run/ax25
      sudo chmod 777 /var/run/ax25/sockets/
   fi

   #check this exists as it's required for ax25netd
   echo -e "\nPreping ax25netd mheard directory"
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
   ax25netd -c /etc/ax25/ax25netd_agwpe.conf 2>&1 >> $AX25NETDLOG
   CHKERR

   #End of startup section


  elif [ "$1" == "stop "]; then
   #Future WAMPES stop

   echo -e "\nStopping ax25netd"
   killall ax25netd

   echo -e "\nStopping Direwolf"
   killall direwolf

   #End of shutdown section
fi

echo -e "\nScript complete\n"

