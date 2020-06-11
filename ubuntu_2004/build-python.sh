#!/bin/bash

CODE_NAME=focal
TARGET=python
VERSION=1.2.2
BRANCH=svn/RELENG_1_2
SHORT_VER=`echo $VERSION | cut -b 1-3 | sed 's/\.//g'`
#REPO=openrtm.org
REPO=150.29.99.185

printf "sudo password: "
stty -echo
read password
stty echo

#----- OpenRTM-aist-Python 
echo "${password}" | sudo -S rm -rf ${TARGET}-*
rm -rf OpenRTM-aist-Python

git clone https://github.com/OpenRTM/OpenRTM-aist-Python
cd OpenRTM-aist-Python
git checkout ${BRANCH} 
cd -

# build in docker environment
echo "${password}" | sudo -S docker build \
 --build-arg CODE_NAME=${CODE_NAME} \
 --build-arg TARGET=${TARGET} \
 --build-arg VERSION=${VERSION} \
 --build-arg REPO=${REPO} \
 -t ${TARGET}${SHORT_VER} \
 -f Dockerfile-${TARGET}-${SHORT_VER}-deb .
echo "${password}" | sudo -S docker create --name ${TARGET}${SHORT_VER} ${TARGET}${SHORT_VER}
echo "${password}" | sudo -S docker cp ${TARGET}${SHORT_VER}:/root/${TARGET}-src-pkgs .
echo "${password}" | sudo -S docker cp ${TARGET}${SHORT_VER}:/root/${TARGET}-deb-pkgs .
echo "${password}" | sudo -S docker rm ${TARGET}${SHORT_VER}
