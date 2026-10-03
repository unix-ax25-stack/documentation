#!/bin/bash

# 10/03/26 


# Purpose: This script is to help users compile the new Alpha stage Linux unix-ax25-stack userland 
#          AX.25 / NETROM stack from Thomas Osterried dl9sau
#
#          https://github.com/unix-ax25-stack


# Status
#-------
# Functional


# Known issues:
# -------------
#   - No distro packaging support yet for .deb (Debian), RPM (Redhat, Suse, etc), etc.


#Errata
#------
# 10/03/26 - KI6ZHD - added the documentation repo just to be complete
# 10/02/26 - KI6ZHD - updated ax25netd path defaults; added early sudo check to cache credentials sooner
# 09/27/26 - KI6ZHD - Add error checking; re-arranged some items; added more user variables
# 09/20/26 - KI6ZHD - Compiles and installs on a Raspberry Pi running Raspberry Pi OS Trixie 64bit Lite
# 09/20/26 - KI6ZHD - initial script



#-----------------------------------------
# Variables

# Change this variable to where you want code to be stored and built
BUILDDIR="/usr/src/archive/Rpi-scratch"

#STOP or CONINTUE the script on error?  y or n
CONTINUEONFAIL="n"

#Enable if you need debugging output
DEBUG=0


#-----------------------------------------
# Functions

function CHKERR {
   ERR=$?
   if [ "$DEBUG" == "y" ]; then
      echo -e "CHKERR: in function"
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


#-----------------------------------------
# Main

if [ "$UID" == "0" ]; then
   echo -e "\nYou cannot be root when running this script"
   echo -e "Aborting\n"
   exit 1
fi


echo -e "\nPrep the build environment"

echo -e "\nPlease enter in the sudo credentials now to void any delays later"
echo -en "Confirm UID is 0: "
sudo echo $UID

#Change this to something else if you wish to
#
if [ ! -d $BUILDDIR ]; then
   echo -e "Creating $BUILDDIR"
   mkdir $BUILDDIR
fi

cd $BUILDDIR

if [ ! -d unix-ax25-stack ]; then 
   echo -e "Creating unix-ax25-stack"
   mkdir unix-ax25-stack
fi

cd unix-ax25-stack


echo -e "\nCreate or update all unix-ax25-stack git repos"


echo -e "\nlibax25:"
echo -e "-------------------------------------------------"
if [ -d libax25 ]; then
   echo -e "updating libax25 repo"
   cd libax25
   git pull
   cd ..
  else
   echo -e "Creating and downloading: libax25 repo"
   git clone https://github.com/unix-ax25-stack/libax25
fi

echo -e "\nax25-apps:"
echo -e "-------------------------------------------------"
if [ -d ax25-apps ]; then
   echo -e "updating ax25-apps repo"
   cd ax25-apps
   git pull
   cd ..
  else
   echo -e "Creating and downloading: ax25-apps repo"
   git clone https://github.com/unix-ax25-stack/ax25-apps
fi

echo -e "\nax25-tools:"
echo -e "-------------------------------------------------"
if [ -d ax25-tools ]; then
   echo -e "updating ax25-tools repo"
   cd ax25-tools
   git pull
   cd ..
  else
   echo -e "Creating and downloading: ax25-toolss repo"
   git clone https://github.com/unix-ax25-stack/ax25-tools
fi

echo -e "\nwampes: the advanced ax25/netrom/inp3/etc stack"
echo -e "-------------------------------------------------"
if [ -d wampes ]; then
   echo -e "updating wampes repo"
   cd wampes
   git pull
   cd ..
  else
   echo -e "Creating and downloading: wampes repo"
   git clone https://github.com/unix-ax25-stack/wampes
fi

echo -e "\ndocumentation: grab various suplimental docs, user contributed scripts, etc."
echo -e "-------------------------------------------------"
if [ -d documentation ]; then
   echo -e "updating documentation repo"
   cd documentation
   git pull
   cd ..
  else
   echo -e "Creating and downloading: documentation repo"
   git clone https://github.com/unix-ax25-stack/documentation
fi

echo -e "\n-------------------------------------------------"
echo -e "Check Build time dependencies: "
echo -e   "-------------------------------------------------"

# unix-ax25-stack requirements
for I in "libgdbm-compat-dev libgdbm-dev libncurses-dev"; do
   dpkg -l | grep $I
   if [ $? -ne 0 ]; then
      echo -e "Installing $I"
      sudo apt install $I
   fi
done

#Debian packaging
#for I in "checkinstall"; do
#   dpkg -l | grep $I
#   if [ $? -ne 0 ]; then
#      echo -e "Installing $I"
#      sudo apt install $I
#   fi
#done


echo -e "\n-------------------------------------------------"
echo -e "Compiling Stage:"
echo -e "-------------------------------------------------"

echo -e "\n\n-------------------------------------------------"
echo -e "\nCompiling wampes:"
echo -e "-------------------------------------------------"

echo -e " "
cd wampes

# no debian/ dir is present so we cannot build and package the debian way
#
#checkinstall is broken as is targeted installation dir support
#  as in make install DESTDIR=/tmp/my-pkg
#
#sudo checkinstall --pkgname wampes--pkgversion 20260920 --pkgrelease 1 --pkggroup \
#                 hamradio --pkgsource https://github.com/unix-ax25-stack/wampes --maintainer \
#                 dl9sau@darc.de --provides "packet radio stack" --requires libgdbm6t64,libncurses6 \
#                 make install

echo -e "\nLast resort 'make; make install' workaround"
NUMCPUS=`lscpu | grep ^CPU\(s\): | awk '{print $2}'`
echo -e "\nCompiling.."
make -j$NUMCPUS
CHKERR
echo -e "\nInstalling.."
sudo make install
CHKERR

#This doesn't exist yet
#sudo make installconf


echo -e "\n\n-------------------------------------------------"
echo -e "Compiling libax25:"
echo -e "-------------------------------------------------"

echo -e " "
cd ../libax25
CHKERR

echo -e "\nAutoreconfig.."
autoreconf --install --force
CHKERR

echo -e "\nConfiguring.."
#./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --enable-userspace-ax25
./configure --enable-userspace-ax25  --prefix=/usr --sysconfdir=/etc --localstatedir=/var --mandir=/usr/share/man;
CHKERR

# no debian/ dir is present so we cannot build and package the debian way
#
#checkinstall is broken as is targeted installation dir support

NUMCPUS=`lscpu | grep ^CPU\(s\): | awk '{print $2}'`

#echo -e "Compiling on $NUMCPUS CPUs concurrently\n"
#debuild -us -uc -j$NUMCPUS
##CHKERR
#sudo dpkg -i ../libax25_*_*.deb ../libax25-dev_*_*.deb

echo -e "Last resort 'make; make install' workaround"
echo -e "\nMake cleaning.."
make clean
CHKERR

echo -e "\nCompiling.."
make -j$NUMCPUS
CHKERR

echo -e "\nMake installing.."
sudo make install
CHKERR

echo -e "\nMake installing conf files.."
sudo make installconf
CHKERR


echo -e "\n\n-------------------------------------------------"
echo -e "ax25-apps"
echo -e "-------------------------------------------------"

echo -e " "
cd ../ax25-apps
CHKERR

echo -e "\nAutoreconfig.."
autoreconf --install --force
CHKERR

echo -e "\nConfiguring.."
#./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --enable-userspace-ax25
./configure --enable-userspace-ax25  --prefix=/usr --sysconfdir=/etc --localstatedir=/var --mandir=/usr/share/man;
CHKERR


# no debian/ dir is present so we cannot build and package the debian way
#
#checkinstall is broken as is targeted installation dir support

#NUMCPUS=`lscpu | grep ^CPU\(s\): | awk '{print $2}'`
#echo -e "Compiling on $NUMCPUS CPUs concurrently\n"
#debuild -us -uc -j$NUMCPUS
##CHKERR
#sudo dpkg -i ../libax25_*_*.deb ../libax25-dev_*_*.deb

echo -e "Last resort 'make; make install' workaround"
echo -e "\nMake cleaning.."
make clean
CHKERR

NUMCPUS=`lscpu | grep ^CPU\(s\): | awk '{print $2}'`
echo -e "\nCompiling.."
make -j$NUMCPUS
CHKERR

echo -e "\nMake installing.."
sudo make install
CHKERR

echo -e "\nMake installing conf files.."
sudo make installconf
CHKERR


echo -e "\n\n-------------------------------------------------"
echo -e "ax25-tools"
echo -e "-------------------------------------------------"

echo -e " "
cd ../ax25-tools
CHKERR

echo -e "\nAutoreconfig.."
autoreconf --install --force
CHKERR

echo -e "\nConfiguring.."
#./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --enable-userspace-ax25
./configure --enable-userspace-ax25  --prefix=/usr --sysconfdir=/etc --localstatedir=/var --mandir=/usr/share/man;
CHKERR

# no debian/ dir is present so we cannot build and package the debian way
#
#checkinstall is broken as is targeted installation dir support


#NUMCPUS=`lscpu | grep ^CPU\(s\): | awk '{print $2}'`
#echo -e "Compiling on $NUMCPUS CPUs concurrently\n"
#debuild -us -uc -j$NUMCPUS
##CHKERR
#sudo dpkg -i ../libax25_*_*.deb ../libax25-dev_*_*.deb

echo -e "Last resort 'make; make install' workaround"
echo -e "\nMake cleaning.."
make clean
CHKERR

NUMCPUS=`lscpu | grep ^CPU\(s\): | awk '{print $2}'`
echo -e "\nCompiling.."
make -j$NUMCPUS
CHKERR

echo -e "\nMake installing.."
sudo make install
CHKERR

echo -e "\nMake installing conf files.."
sudo make installconf
CHKERR


echo -e "\nScript complete.  You now need to configure the userland stack in various /etc/ax25/*.conf files"
echo -e "See the various repo readme.md files and the files in the documentation repo\n"

