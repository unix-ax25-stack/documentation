#!/bin/bash

# 2026-09-20 - David Ranch KI6ZHD


# Purpose: This script is to help users compile the new Alpha stage Linux unix-ax25-stack userland 
#          AX.25 / NETROM stack from Thomas Osterried dl9sau
#
#          https://github.com/unix-ax25-stack


# Status
#-------
#  2026-09-20 - dranch - Compiles and installs on a Raspberry Pi running Raspberry Pi OS Trixie 64bit Lite


# Known issues:
# -------------
#   - No distro packaging support including Debain


#Errata
#------
# 2026-09-20 - dranch - initial script



#-----------------------------------------


echo -e "\nPrep the build environment"

#Change this to something else if you wish to
#
if [ ! -d /usr/src/archive/Rpi-scratch ]; then
   mkdir /usr/src/archive/Rpi-scratch
fi

cd /usr/src/archive/Rpi-scratch

if [ ! -d unix-ax25-stack ]; then 
   mkdir unix-ax25-stack
fi

cd unix-ax25-stack

# -----------------------------------------------------------

echo -e "\nCreate or update all unix-ax25-stack git repos"

echo -e "\nwampes:"
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

if [ -d libax25 ]; then
   echo -e "\nlibax25:"
   echo -e "-------------------------------------------------"
   echo -e "updating libax25 repo"
   cd libax25
   git pull
   cd ..
  else
   echo -e "Creating and downloading: libax25 repo"
   git clone https://github.com/unix-ax25-stack/libax25
fi

if [ -d ax25-apps ]; then
   echo -e "\nax25-apps:"
   echo -e "-------------------------------------------------"
   echo -e "updating ax25-apps repo"
   cd ax25-apps
   git pull
   cd ..
  else
   echo -e "Creating and downloading: ax25-apps repo"
   git clone https://github.com/unix-ax25-stack/ax25-apps
fi

if [ -d ax25-tools ]; then
   echo -e "\nax25-tools:"
   echo -e "-------------------------------------------------"
   echo -e "updating ax25-tools repo"
   cd ax25-tools
   git pull
   cd ..
  else
   echo -e "Creating and downloading: ax25-toolss repo"
   git clone https://github.com/unix-ax25-stack/ax25-tools
fi

# -----------------------------------------------------------

echo -e "\nCheck dependencies: "
echo -e "-------------------------------------------------"

# unix-ax25-stack requirements
for I in "libgdbm-compat-dev libgdbm-dev libncurses-dev"; do
   dpkg -l | grep $I
   if [ $? -ne 0 ]; then
      echo -e "Installing $I"
      sudo apt install $I
   fi
done

#Debian packaging
for I in "checkinstall"; do
   dpkg -l | grep $I
   if [ $? -ne 0 ]; then
      echo -e "Installing $I"
      sudo apt install $I
   fi
done

# -----------------------------------------------------------

echo -e "\nStart compiling:"

#--------------------------------------------------------------------------------------------------------------
echo -e "\nwampes:"
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

echo -e "Last resort 'make; make install' workaround"
NUMCPUS=`lscpu | grep ^CPU\(s\): | awk '{print $2}'`
make -j$NUMCPUS
sudo make install


#--------------------------------------------------------------------------------------------------------------
echo -e "\nlibax25:"
echo -e "-------------------------------------------------"

echo -e " "
cd ../libax25
autoreconf --install --force
#./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --enable-userspace-ax25
./configure --enable-userspace-ax25  --prefix=/usr --sysconfdir=/etc --localstatedir=/var --mandir=/usr/share/man;

# no debian/ dir is present so we cannot build and package the debian way
#
#checkinstall is broken as is targeted installation dir support


NUMCPUS=`lscpu | grep ^CPU\(s\): | awk '{print $2}'`

#echo -e "Compiling on $NUMCPUS CPUs concurrently\n"
#debuild -us -uc -j$NUMCPUS
##CHKERR
#sudo dpkg -i ../libax25_*_*.deb ../libax25-dev_*_*.deb

echo -e "Last resort 'make; make install' workaround"
make clean
make -j$NUMCPUS
sudo make install
sudo make installconf


#--------------------------------------------------------------------------------------------------------------
echo -e "\nax25-apps"
echo -e "-------------------------------------------------"

echo -e " "
cd ../ax25-apps
autoreconf --install --force
#./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --enable-userspace-ax25
./configure --enable-userspace-ax25  --prefix=/usr --sysconfdir=/etc --localstatedir=/var --mandir=/usr/share/man;

# no debian/ dir is present so we cannot build and package the debian way
#
#checkinstall is broken as is targeted installation dir support


#NUMCPUS=`lscpu | grep ^CPU\(s\): | awk '{print $2}'`
#echo -e "Compiling on $NUMCPUS CPUs concurrently\n"
#debuild -us -uc -j$NUMCPUS
##CHKERR
#sudo dpkg -i ../libax25_*_*.deb ../libax25-dev_*_*.deb

echo -e "Last resort 'make; make install' workaround"
make clean
NUMCPUS=`lscpu | grep ^CPU\(s\): | awk '{print $2}'`
make -j$NUMCPUS
sudo make install
sudo make installconf


#--------------------------------------------------------------------------------------------------------------
echo -e "\nax25-tools"
echo -e "-------------------------------------------------"

echo -e " "
cd ../ax25-tools
autoreconf --install --force
#./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --enable-userspace-ax25
./configure --enable-userspace-ax25  --prefix=/usr --sysconfdir=/etc --localstatedir=/var --mandir=/usr/share/man;

# no debian/ dir is present so we cannot build and package the debian way
#
#checkinstall is broken as is targeted installation dir support


#NUMCPUS=`lscpu | grep ^CPU\(s\): | awk '{print $2}'`
#echo -e "Compiling on $NUMCPUS CPUs concurrently\n"
#debuild -us -uc -j$NUMCPUS
##CHKERR
#sudo dpkg -i ../libax25_*_*.deb ../libax25-dev_*_*.deb

echo -e "Last resort 'make; make install' workaround"
make clean
NUMCPUS=`lscpu | grep ^CPU\(s\): | awk '{print $2}'`
make -j$NUMCPUS
sudo make install
echo Execute  sudo make installconf  by hand, else it may overwwrite your current configuration.



echo -e "\nScript complete.  You now need to configure the stack.  WIP"

