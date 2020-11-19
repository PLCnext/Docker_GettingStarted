#!/bin/sh

# Read inut from cmd for control
read -p " Please choose your container runtime:
Install balenaEngine(recommend): 1
Install Docker: 2
" RUNTIME

while read -p "Version xx.xx.xx (let empty for default balenaEngine 18.9.7, Docker 19.03.8): " VERSION; do
    if [ $VERSION ]; then
      break;
    elif [ -z $VERSION ]; then
      if [ $RUNTIME = "1" ]; then 
	    VERSION="18.9.7"
		break;
	  else 
	    VERSION="19.03.8"
		break;
      fi
    fi
  done

# VERSION=$(echo "$VERSION" | sed 's|+|.|g')

machine=$(uname -m)

case "$machine" in
#	"armv5"*)
#		arch="armv5"
#		;;
#	"armv6"*)
#		arch="armv6"
#		;;
	"armv7"*)
		arch="armv7"
		;;
#	"armv8"*)
#		arch="aarch64"
#		;;
#	"aarch64"*)
#		arch="aarch64"
#		;;
#	"i386")
#		arch="i386"
#		;;
#	"i686")
#		arch="i386"
#		;;
	"x86_64")
		arch="x86_64"
		;;
	*)
		echo "Unknown machine type: $machine"
		exit 1
esac

### Set user rights to archive
chown -R root:root ./archive
chmod -R 755 ./archive

case "$RUNTIME" in 
### Install balenaEngine
   1)
		### Download and unzip balenaEngine
		BALENA_URL="https://github.com/balena-os/balena-engine/releases/download/v${VERSION}/balena-engine-v${VERSION}-${arch}.tar.gz"
		wget "$BALENA_URL"
        tar xzv -C /usr/bin --strip-components=1 -f balena-engine-v${VERSION}-${arch}.tar.gz
		rm balena-engine-v${VERSION}-${arch}.tar.gz
		#### Copy configs and add group
		cp -a ./archive/balena/etc/. /etc/
		cp -a ./archive/balena/usr/. /usr/
		groupadd balena
		usermod -a -G balena admin
		usermod -a -G balena plcnext_firmware
		### Add alias for balena-engine
		echo "alias docker=\"/usr/bin/balena-engine\"" >> /opt/plcnext/.bashrc
		echo "alias balena=\"/usr/bin/balena-engine\"" >> /opt/plcnext/.bashrc
		update-rc.d -s balena defaults
		## Install docker-compose
		mkdir /usr/local/bin
		curl -L --fail https://github.com/docker/compose/releases/download/1.27.0/run.sh -o /usr/local/bin/docker-compose
		sed -i 's/docker.sock/balena-engine.sock/g' /usr/local/bin/docker-compose
		sed -i 's/exec docker/exec balena-engine/g' /usr/local/bin/docker-compose
		case "$arch" in 
			"armv7")
				sed -i 's/docker\/compose/apptower\/docker-compose/g' /usr/local/bin/docker-compose
			;;
			"armhf")
				sed -i 's/docker\/compose/apptower\/docker-compose/g' /usr/local/bin/docker-compose
			;;
		esac
		sed -i 's/$DOCKER_HOST:$DOCKER_HOST/$DOCKER_HOST:\/var\/run\/docker.sock/g' /usr/localbin/docker-compose
		chgrp balena /usr/local/bin/docker-compose
		chmod g+x /usr/local/bin/docker-compose
		

cat <<EOF


   		Installation successful!
		 _           _
		| |__   __ _| | ___ _ __   __ _
		| '_ \\ / _\` | |/ _ \\ '_ \ / _\` |
		| |_) | (_| | |  __/ | | | (_| |
		|_.__/ \__,_|_|\___|_| |_|\__,_|

		the container engine for the IoT
EOF
   		
	;;
   
   2)
		### Download Docker
		if [ $arch = "armv7" ]; then
		  arch="armhf"
		fi
		DOCKER_URL="https://download.docker.com/linux/static/stable/${arch}/docker-$VERSION.tgz"
		wget "$DOCKER_URL" 
		tar xzv -C /usr/bin --strip-components=1 -f docker-$VERSION.tgz
		rm docker-$VERSION.tgz
		## Copy configs and add group
		cp -a ./archive/docker/etc/. /etc/
		cp -a ./archive/docker/usr/. /usr/
		groupadd docker
		usermod -a -G docker admin
		usermod -a -G docker plcnext_firmware
		update-rc.d -s docker defaults
		## Install docker-compose
		mkdir /usr/local/bin
		curl -L --fail https://github.com/docker/compose/releases/download/1.27.0/run.sh -o /usr/local/bin/docker-compose
		case "$arch" in 
			"armv7")
				sed -i 's/docker\/compose/apptower\/docker-compose/g' /usr/local/bin/docker-compose
			;;
			"armhf")
				sed -i 's/docker\/compose/apptower\/docker-compose/g' /usr/local/bin/docker-compose
			;;
		esac
		chgrp docker /usr/local/bin/docker-compose
		chmod g+x /usr/local/bin/docker-compose

cat <<EOF
		Docker installation successful!
EOF
		;;
esac

### copy iptables  

case "$arch" in 
	"armv7")
		cp -a ./archive/iptables/armv7/usr/. /usr/
	;;
	"armhf")
		cp -a ./archive/iptables/armv7/usr/. /usr/
	;;
	"x86_64")
		cp -a ./archive/iptables/x86_64/usr/. /usr/
	;;
esac

### create symlinks for iptables
ln -s /usr/sbin/xtables-nft-multi /usr/sbin/iptables
ln -s /usr/sbin/xtables-nft-multi /usr/sbin/arptables
ln -s /usr/sbin/xtables-nft-multi /usr/sbin/ip6tables
ln -s /usr/sbin/xtables-nft-multi /usr/sbin/ebtables
ln -s /usr/lib/libip4tc.so.2.0.0 /usr/lib/libip4tc.so.2
ln -s /usr/lib/libip6tc.so.2.0.0 /usr/lib/libip6tc.so.2
ln -s /usr/lib/libxtables.so.12.2.0 /usr/lib/libxtables.so.12

cat <<EOF
		Ready - It is time for container :). 
EOF
