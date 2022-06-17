#!/bin/bash

## Create personal token
## https://freeswitch.org/confluence/display/FREESWITCH/HOWTO+Create+a+SignalWire+Personal+Access+Token

if [ -z "$1" ]; then
    echo "Token Arguments Empty"
    exit
else
    TOKEN=$1
fi

current_folder=$PWD

apt-get update && apt-get install -y gnupg2 wget lsb-release
 
wget --http-user=signalwire --http-password=$TOKEN -O /usr/share/keyrings/signalwire-freeswitch-repo.gpg https://freeswitch.signalwire.com/repo/deb/debian-release/signalwire-freeswitch-repo.gpg
 
echo "machine freeswitch.signalwire.com login signalwire password $TOKEN" > /etc/apt/auth.conf
echo "deb [signed-by=/usr/share/keyrings/signalwire-freeswitch-repo.gpg] https://freeswitch.signalwire.com/repo/deb/debian-release/ `lsb_release -sc` main" > /etc/apt/sources.list.d/freeswitch.list
echo "deb-src [signed-by=/usr/share/keyrings/signalwire-freeswitch-repo.gpg] https://freeswitch.signalwire.com/repo/deb/debian-release/ `lsb_release -sc` main" >> /etc/apt/sources.list.d/freeswitch.list
 
# you may want to populate /etc/freeswitch at this point.
# if /etc/freeswitch does not exist, the standard vanilla configuration is deployed
apt-get update && apt-get install -y freeswitch-meta-all


# edit internal.xml external rtp and sip ip
cp /etc/freeswitch/sip_profiles/internal.xml /etc/freeswitch/sip_profiles/internal.xml.ori
sed -i 's/external_rtp_ip/local_ip_v4/g' /etc/freeswitch/sip_profiles/internal.xml
sed -i 's/external_sip_ip/local_ip_v4/g' /etc/freeswitch/sip_profiles/internal.xml

# add mod_vosk and mod_amqp
cp /etc/freeswitch/autoload_configs/modules.conf.xml /etc/freeswitch/autoload_configs/modules.conf.xml.ori
cp modules.conf.xml /etc/freeswitch/autoload_configs/modules.conf.xml

# prepare rabbitmq client
# copy mod_amqp.so and configure amqp.conf.xml
#cp rabbitmq/mod_amqp.so /usr/lib/freeswitch/mod
cp /etc/freeswitch/autoload_configs/amqp.conf.xml /etc/freeswitch/autoload_configs/amqp.conf.xml.ori
cp modules/rabbitmq/amqp.conf.xml /etc/freeswitch/autoload_configs/amqp.conf.xml


# prepare vosk client
# copy mod_vosk.so, dialplan and configuration files
#cp vosk/mod_vosk.so /usr/lib/freeswitch/mod
# copy dialplan
cp modules/vosk/to_vosk_lua.xml /etc/freeswitch/dialplan/default/to_vosk_lua.xml
# copy vosk config
cp modules/vosk/vosk.conf.xml /etc/freeswitch/autoload_configs/vosk.conf.xml
# change lua script and copy
sed -i "s/joker/$USER/g" modules/vosk/vosk.lua
cp modules/vosk/vosk.lua /usr/share/freeswitch/scripts/vosk.lua


systemctl start freeswitch
