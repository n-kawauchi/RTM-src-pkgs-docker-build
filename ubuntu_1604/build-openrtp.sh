#!/bin/bash

TARGET=openrtp
VERSION=1.2.2
BRANCH=RELENG_1_2
SHORT_VER=`echo $VERSION | cut -b 1-3 | sed 's/\.//g'`

#----- check all in one package
ARCH=`arch`
if test "x${ARCH}" = "xx86_64"; then
	ret=`find . -name *ja-linux-gtk-x86_64.tar.gz`
	if test "x${ret}" = "x"; then
		echo "Not found all-in-package.(eclipse*ja-linux-gtk-x86_64.tar.gz)"
		exit
	fi
	eclipse_name=`find . -name *ja-linux-gtk-x86_64.tar.gz | xargs basename`
else
	ret=`find . -name *ja-linux-gtk.tar.gz`
	if test "x${ret}" = "x"; then
		echo "Not found all-in-package.(eclipse*ja-linux-gtk.tar.gz)"
		exit
	fi
	eclipse_name=`find . -name *ja-linux-gtk.tar.gz | xargs basename`
fi

printf "sudo password: "
stty -echo
read password
stty echo
echo "${password}" | sudo -S rm -rf openrtp*

tar xvzf ${eclipse_name}
mv eclipse openrtp

git clone https://github.com/OpenRTM/OpenRTP-aist
cd OpenRTP-aist
git checkout ${BRANCH} 
cp -r packages ../openrtp/
cd -
rm -rf OpenRTP-aist

# build in docker environment
echo "${password}" | sudo -S docker build \
 --build-arg TARGET=${TARGET} \
 --network=host \
 -t ${TARGET}${SHORT_VER} \
 -f Dockerfile-${TARGET}-${SHORT_VER}-deb .
echo "${password}" | sudo -S docker create --name ${TARGET}${SHORT_VER} ${TARGET}${SHORT_VER}
echo "${password}" | sudo -S docker cp ${TARGET}${SHORT_VER}:/root/${TARGET}-deb-pkgs .
echo "${password}" | sudo -S docker rm ${TARGET}${SHORT_VER}
