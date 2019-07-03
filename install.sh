#!/bin/bash

set -e
set -u

BASEURL=https://www.vigibot.com/vigiclient
BASEDIR=/usr/local/vigiclient

if [[ $EUID -ne 0 ]]
then
 echo "This script must be run as root" 1>&2
 exit 1
fi

fgrep bcm2835-v4l2 /etc/modules || echo bcm2835-v4l2 >> /etc/modules

apt update
apt install -y nodejs npm ffmpeg

rm -rf $BASEDIR
mkdir -p $BASEDIR
cd $BASEDIR

wget $BASEURL/clientrobotpi.js
wget $BASEURL/trame.js
wget $BASEURL/vigiupdate.sh
chmod +x vigiupdate.sh

wget $BASEURL/robot.json -P /boot -N
wget $BASEURL/vigiclient.service -P /etc/systemd/system -N
wget $BASEURL/vigicron -P /etc/cron.d -N

ln -s /bin/cat processdiffusion
ln -s $(which ffmpeg || echo ffmpegnotfound) processdiffaudio

wget $BASEURL/package.json
#npm install
#raspi-config nonint do_camera 1
#raspi-config nonint do_spi 1
cat << EOF >> /boot/config.txt
dtparam=i2c_arm=on
start_x=1
gpu_mem=128
EOF

systemctl enable vigiclient
