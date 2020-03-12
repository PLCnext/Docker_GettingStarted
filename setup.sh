#!/bin/sh

tag="$1"
tag=$(echo "$tag" | sed 's|+|.|g')

if [ -z "$1" ]
then tag="v17.12.0"
fi

machine=$(uname -m)

case "$machine" in
	"armv5"*)
		arch="armv5"
		;;
	"armv6"*)
		arch="armv6"
		;;
	"armv7"*)
		arch="armv7"
		;;
	"armv8"*)
		arch="aarch64"
		;;
	"aarch64"*)
		arch="aarch64"
		;;
	"i386")
		arch="i386"
		;;
	"i686")
		arch="i386"
		;;
	"x86_64")
		arch="x86_64"
		;;
	*)
		echo "Unknown machine type: $machine"
		exit 1
esac

url="https://github.com/balena-os/balena-engine/releases/download/${tag}/balena-engine-${tag}-${arch}.tar.gz"

curl -sL "$url" | tar xzv -C /usr/bin --strip-components=1

echo "Installing files..."

chown -R root:root ./archive
chmod -R 755 ./archive
cp -a ./archive/etc/init.d/. /etc/init.d/
cp -a ./archive/etc/balena-engine/. /etc/balena-engine/

groupadd balena
usermod -a -G balena admin

update-rc.d -s balena defaults

cat <<EOF


   Installation successful!
 _           _
| |__   __ _| | ___ _ __   __ _
| '_ \\ / _\` | |/ _ \\ '_ \ / _\` |
| |_) | (_| | |  __/ | | | (_| |
|_.__/ \__,_|_|\___|_| |_|\__,_|

the container engine for the IoT
EOF
