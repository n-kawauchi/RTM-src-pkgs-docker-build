#!/bin/bash

UBUNTU_VER=2204
TARGET=cnoid-corba
CHOREONOID_VER=2.4.0

printf "sudo password: "
stty -echo
read password
stty echo

#----- ChoreonoidCORBAPluginBuildFiles 
echo "${password}" | sudo -S rm -rf ${TARGET}-*
rm -rf ChoreonoidCORBAPluginBuildFiles 
git clone https://github.com/Nobu19800/ChoreonoidCORBAPluginBuildFiles 

#----- Copy Corba and CorbaPlugin from Choreonoid
wget https://github.com/choreonoid/choreonoid/archive/refs/tags/v${CHOREONOID_VER}.tar.gz
tar xf v${CHOREONOID_VER}.tar.gz
cp -r choreonoid-${CHOREONOID_VER}/src/Corba ChoreonoidCORBAPluginBuildFiles/src/
cp -r choreonoid-${CHOREONOID_VER}/src/CorbaPlugin ChoreonoidCORBAPluginBuildFiles/src/
#----- Copy ChoreonoidCorbaBuildFunctions.cmake
mkdir -p ChoreonoidCORBAPluginBuildFiles/cmake
cp choreonoid-${CHOREONOID_VER}/cmake/ChoreonoidCorbaBuildFunctions.cmake ChoreonoidCORBAPluginBuildFiles/cmake/
rm -rf v${CHOREONOID_VER}.tar.gz choreonoid-${CHOREONOID_VER}

VERSION=`dpkg-parsechangelog --file ChoreonoidCORBAPluginBuildFiles/packages/deb/debian/changelog --show-field Version | cut -b 1-5`
SHORT_VER=`echo $VERSION | cut -b 1-5 | sed 's/\.//g'`

# build in docker environment
echo "${password}" | sudo -S docker build \
 --build-arg CODE_NAME=${CODE_NAME} \
 --build-arg TARGET=${TARGET} \
 --build-arg VERSION=${VERSION} \
 -t ${TARGET}${SHORT_VER} \
 -f ChoreonoidCORBAPluginBuildFiles/scripts/ubuntu_${UBUNTU_VER}/Dockerfile.package .
echo "${password}" | sudo -S docker create --name ${TARGET}${SHORT_VER} ${TARGET}${SHORT_VER}
echo "${password}" | sudo -S docker cp ${TARGET}${SHORT_VER}:/root/${TARGET}-deb-pkgs .
echo "${password}" | sudo -S docker rm ${TARGET}${SHORT_VER}
