#!/bin/bash

UBUNTU_VER=2204
TARGET=cnoid-openrtm-py
CHOREONOID_VER=2.4.0

printf "sudo password: "
stty -echo
read password
stty echo

#----- OpenRTMPythonPlugin 
echo "${password}" | sudo -S rm -rf ${TARGET}-*
rm -rf OpenRTMPythonPlugin 
git clone https://github.com/Nobu19800/OpenRTMPythonPlugin 

#----- Copy ChoreonoidCorbaBuildFunctions.cmake
wget https://github.com/choreonoid/choreonoid/archive/refs/tags/v${CHOREONOID_VER}.tar.gz
tar xf v${CHOREONOID_VER}.tar.gz
mkdir -p OpenRTMPythonPlugin/cmake
cp choreonoid-${CHOREONOID_VER}/cmake/ChoreonoidCorbaBuildFunctions.cmake OpenRTMPythonPlugin/cmake/
rm -rf v${CHOREONOID_VER}.tar.gz choreonoid-${CHOREONOID_VER}

VERSION=`dpkg-parsechangelog --file OpenRTMPythonPlugin/packages/deb/debian/changelog --show-field Version | cut -b 1-5`
SHORT_VER=`echo $VERSION | cut -b 1-5 | sed 's/\.//g'`

# build in docker environment
echo "${password}" | sudo -S docker build \
 -t ${TARGET}${SHORT_VER} \
 -f OpenRTMPythonPlugin/scripts/ubuntu_${UBUNTU_VER}/Dockerfile.package .
echo "${password}" | sudo -S docker create --name ${TARGET}${SHORT_VER} ${TARGET}${SHORT_VER}
echo "${password}" | sudo -S docker cp ${TARGET}${SHORT_VER}:/root/${TARGET}-deb-pkgs .
echo "${password}" | sudo -S docker rm ${TARGET}${SHORT_VER}
USER_NAME=$(whoami)
echo "${password}" | sudo -S chown -R ${USER_NAME}:${USER_NAME} ${TARGET}-deb-pkgs
