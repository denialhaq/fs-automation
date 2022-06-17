#!/bin/bash

current_folder=$PWD

apt install -y git subversion build-essential autoconf automake libtool libncurses5 libncurses5-dev make libjpeg-dev libtool libtool-bin libsqlite3-dev libpcre3-dev libspeexdsp-dev libldns-dev libedit-dev yasm liblua5.2-dev libopus-dev cmake
apt install -y libcurl4-openssl-dev libexpat1-dev libgnutls28-dev libtiff5-dev libx11-dev unixodbc-dev libssl-dev python-dev zlib1g-dev libasound2-dev libogg-dev libvorbis-dev libperl-dev libgdbm-dev libdb-dev uuid-dev libsndfile1 librabbitmq-dev
#apt install -y libavformat-dev  libswscale-dev libpq-dev

git clone https://github.com/signalwire/libks.git
cd libks
cmake .
make
make install

cd /usr/src
git clone https://github.com/alphacep/freeswitch.git
cd freeswitch

./bootstrap.sh
./configure

cp $folder_loc/modules/modules.conf modules.conf

make
make install

#Copy mod_vosk.so from directory /usr/local/freeswitch/mod into current freeswitch module directory /usr/lib/freeswitch/mod

