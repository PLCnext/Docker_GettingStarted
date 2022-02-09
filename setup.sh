#!/bin/sh

function validate_url() {
  if [[ `wget -S --spider $1  2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then
    return 0
  else
    return 1
  fi
}

function print_usage() {
  echo "Usage: "$execution_name" [balena-engine = 1 || docker = 2] [docker-compose = yes | no]";
  exit 1
}

##### Main Program #####
execution_name=$0;

if [ $# -ge 3 ]; then
        echo "error: wrong number of arguments" >&2;
		print_usage;
fi

if [ $# -eq 2 ]; then
# Read input from arguments
	    re='^[0-9]+$'
	    if ! [[ $1 =~ $re && $1 -lt 3 && $1 -gt 0 ]] ; then
	      echo "error in runtime argument" >&2; print_usage;
		else
	      RUNTIME=$1;
		fi
		if ! [[ $2 == "yes" || $2 == "no" ]]; then
	      echo "error in docker-compose argument" >&2; print_usage;
		else
	      COMPOSE=$2;
	    fi
else
# Read input from cmd for control
	  while true; do
				read -p " Please choose your container runtime:
	  Install balenaEngine(recommend): 1
	  Install Docker: 2
	  Cancel installation: [C]ancel
	  " RUNTIME
				case $RUNTIME in
						[1] ) break;;
						[2] ) break;;
						[Cc]* ) exit;;
						* ) echo "Please choose a valid value (1 or 2) or cancel the installation.";;
				esac
	  done

	  # Read input from cmd for control
	  while true; do
	  	read -p " Do you wish to install docker-compose?
	   " COMPOSE
	  	    case $COMPOSE in
	                  [Yy]* ) COMPOSE=yes; break;;
	                  [Nn]* ) COMPOSE=no; break;;
	                  [Cc]* ) exit;;
	                  * ) echo "Please answer yes/no or [c]ancel the installation.";;
	          esac
	  done
fi

### Version selection removed due to incompatiblity of new versions (systemd is required)
#while read -p "Version xx.xx.xx (let empty for default balenaEngine 18.9.7, Docker 19.03.12): " VERSION; do
#    if [ $VERSION ]; then
#      break;
#    elif [ -z $VERSION ]; then
      if [ $RUNTIME = "1" ]; then 
	    VERSION="18.9.7"
		break;
	  else 
	    VERSION="19.03.8"
		break;
      fi
#    fi
#  done

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
		echo "Starting Balena installation..."
		BALENA_URL="https://github.com/balena-os/balena-engine/releases/download/v${VERSION}/balena-engine-v${VERSION}-${arch}.tar.gz"
		### Check for the available fitting architecture
		case "$arch" in 
			"armv7")
				if validate_url $BALENA_URL; then
    			# Go on when File exists!
				break;
 				else
				 	echo "Balena Version is not available for $arch!"
				 	arch="armv7hf"
					BALENA_URL="https://github.com/balena-os/balena-engine/releases/download/v${VERSION}/balena-engine-v${VERSION}-${arch}.tar.gz"
				 	if validate_url $BALENA_URL; then
    				# Go on when File exists!
					break;
 					else
					 	echo "Balena Version is not available for $arch!"
						arch="armhf"
						BALENA_URL="https://github.com/balena-os/balena-engine/releases/download/v${VERSION}/balena-engine-v${VERSION}-${arch}.tar.gz"
				 		if validate_url $BALENA_URL; then
    					# Go on when File exists!
						break;
 						else
							echo "Balena Version is not available for $arch!"
							exit 1
						fi
					fi
				fi
			;;
			"x86_64")
				if validate_url $BALENA_URL; then
    			# Go on when File exists!
				break;
 				else
				 	echo "Balena Version is not available for $arch!"
					exit 1
				fi
			;;
		esac
		### Download and unzip balenaEngine
		wget "$BALENA_URL"
        tar xzv -C /usr/bin --strip-components=1 -f balena-engine-v${VERSION}-${arch}.tar.gz
		rm balena-engine-v${VERSION}-${arch}.tar.gz
		if [ -d /usr/bin/balena-engine ]; then
			mv /usr/bin/balena-engine /usr/bin/tmp
			mv /usr/bin/tmp/* /usr/bin/
			rmdir /usr/bin/tmp
		fi
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
	if [ $COMPOSE = "yes" ]; then
		echo "Starting docker-compose installation for Balena..."
		COMPOSE_URL="https://github.com/docker/compose/releases/download/1.29.2/run.sh"
		mkdir /usr/bin		
		if validate_url $COMPOSE_URL; then	
			curl --insecure -L --fail $COMPOSE_URL -o /usr/bin/docker-compose
			sed -i 's/docker.sock/balena-engine.sock/g' /usr/bin/docker-compose
			sed -i 's/exec docker/exec balena-engine/g' /usr/bin/docker-compose
			case "$arch" in 
				"armv7")
					sed -i 's/docker\/compose/apptower\/docker-compose/g' /usr/bin/docker-compose
				;;
				"armhf")
					sed -i 's/docker\/compose/apptower\/docker-compose/g' /usr/bin/docker-compose
				;;
				"armv7hf")
					sed -i 's/docker\/compose/apptower\/docker-compose/g' /usr/bin/docker-compose
				;;
			esac
			sed -i 's/$DOCKER_HOST:$DOCKER_HOST/$DOCKER_HOST:\/var\/run\/docker.sock/g' /usr/bin/docker-compose
			chgrp balena /usr/bin/docker-compose
			chmod g+x /usr/bin/docker-compose
			break;
 		else
			echo "Docker-Compose is not installed!"
		fi		
	fi
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
		echo "Starting Docker installation..."
		### Download Docker
		if [ $arch = "armv7" ]; then
		  arch="armhf"
		fi
		DOCKER_URL="https://download.docker.com/linux/static/stable/${arch}/docker-$VERSION.tgz"
		### Check for the available fitting architecture
		case "$arch" in 
			"armhf")
				if validate_url $DOCKER_URL; then
    			# Go on when File exists!
				break;
 				else
					echo "Docker Version is not available for $arch!"
					exit 1
				fi
			;;
			"x86_64")
				if validate_url $DOCKER_URL; then
    			# Go on when File exists!
				break;
 				else
				 	echo "Docker Version is not available for $arch!"
					exit 1
				fi
			;;
		esac
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
		if [ $COMPOSE = "yes" ]; then
			echo "Starting docker-compose installation..."
			
			if [ $arch == "x86_64" ]; then
				COMPOSE_URL="https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-linux-x86_64"
			else
				COMPOSE_URL="https://github.com/docker/compose/releases/download/1.29.2/run.sh"
			fi
			
			mkdir /usr/bin
			if validate_url $COMPOSE_URL; then	
				curl --insecure -L --fail $COMPOSE_URL -o /usr/bin/docker-compose
				
				if [ $arch != "x86_64" ]; then
					case "$arch" in 
						"armv7")
							sed -i 's/docker\/compose/apptower\/docker-compose/g' /usr/bin/docker-compose
						;;
						"armhf")
							sed -i 's/docker\/compose/apptower\/docker-compose/g' /usr/bin/docker-compose
						;;
						"armv7hf")
							sed -i 's/docker\/compose/apptower\/docker-compose/g' /usr/bin/docker-compose
						;;
					esac
				fi
				chgrp docker /usr/bin/docker-compose
				chmod g+x /usr/bin/docker-compose
				break;
			else
				echo "Docker-Compose is not installed!"
			fi
		fi
cat <<EOF
		Docker installation successful!
EOF
		;;
esac