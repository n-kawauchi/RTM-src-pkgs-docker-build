#!/bin/bash

TARGET=openrtp

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
cp -r packages ../openrtp/

VERSION=`dpkg-parsechangelog --file packages/deb/debian/changelog --show-field Version | cut -b 1-5`
SHORT_VER=`echo $VERSION | cut -b 1-3 | sed 's/\.//g'`

cd -
rm -rf OpenRTP-aist

# build in docker environment
echo "${password}" | sudo -S docker build \
 --build-arg TARGET=${TARGET} \
 -t ${TARGET}${SHORT_VER} \
 -f Dockerfile-${TARGET}-deb .
echo "${password}" | sudo -S docker create --name ${TARGET}${SHORT_VER} ${TARGET}${SHORT_VER}
echo "${password}" | sudo -S docker cp ${TARGET}${SHORT_VER}:/root/${TARGET}-deb-pkgs .
echo "${password}" | sudo -S docker rm ${TARGET}${SHORT_VER}
