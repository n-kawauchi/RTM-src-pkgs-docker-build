#!/bin/bash

TARGET=openrtp
VERSION=1.2.2
BRANCH=RELENG_1_2
SHORT_VER=`echo $VERSION | cut -b 1-3 | sed 's/\.//g'`

#----- check all in one package
ret=`find . -name *ja-linux-gtk-x86_64.tar.gz`
if test "x${ret}" = "x"; then
	echo "Not found all-in-package.(eclipse*ja-linux-gtk-x86_64.tar.gz)"
	exit
fi

printf "sudo password: "
stty -echo
read password
stty echo
echo "${password}" | sudo -S rm -rf openrtp*

name=`find . -name *ja-linux-gtk-x86_64.tar.gz | xargs basename`
tar xvzf ${name}
mv eclipse openrtp

git clone https://github.com/OpenRTM/OpenRTP-aist
cd OpenRTP-aist
git checkout ${BRANCH} 
cp -r packages ../openrtp/
cd -
rm -rf OpenRTP-aist

# build in docker environment
echo "${password}" | sudo -S docker build --build-arg TARGET=${TARGET} -t ${TARGET}${SHORT_VER} -f Dockerfile-${TARGET}-${SHORT_VER}-deb .
echo "${password}" | sudo -S docker create --name ${TARGET}${SHORT_VER} ${TARGET}${SHORT_VER}
echo "${password}" | sudo -S docker cp ${TARGET}${SHORT_VER}:/root/${TARGET}-deb-pkgs .
echo "${password}" | sudo -S docker rm ${TARGET}${SHORT_VER}
