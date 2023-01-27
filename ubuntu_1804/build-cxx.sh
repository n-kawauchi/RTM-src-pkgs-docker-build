#!/bin/bash

UBUNTU_VER=1804
TARGET=cxx
VERSION=2.0.1
SHORT_VER=`echo $VERSION | cut -b 1-3 | sed 's/\.//g'`

printf "sudo password: "
stty -echo
read password
stty echo

#----- OpenRTM-aist 
echo "${password}" | sudo -S rm -rf ${TARGET}-*
rm -rf OpenRTM-aist

git clone https://github.com/OpenRTM/OpenRTM-aist

# build in docker environment
echo "${password}" | sudo -S docker build \
 -t ${TARGET}${SHORT_VER} \
 -f OpenRTM-aist/scripts/ubuntu_${UBUNTU_VER}/Dockerfile.package .
echo "${password}" | sudo -S docker create --name ${TARGET}${SHORT_VER} ${TARGET}${SHORT_VER}
echo "${password}" | sudo -S docker cp ${TARGET}${SHORT_VER}:/root/${TARGET}-deb-pkgs .
echo "${password}" | sudo -S docker rm ${TARGET}${SHORT_VER}
