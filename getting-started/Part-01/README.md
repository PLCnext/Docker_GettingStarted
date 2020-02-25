# Part 1 - Installation of Balena Engine

This is part of a [series of articles](https://github.com/PLCnext/docker_gettingstarted) that demonstrate how to install Balena-engine on PLCnext controller and work with OCI containers.

In this article, we will install the Balena-engine and start OCI containers.

## Installation

### Establish the Connections

1. Connect the AXC F 2152 controller to Internet-Provider and Linux OS via LAN-cable.
2. Start the terminal on Linux OS and establisch the SSH-Connection to PLC via commandline "ssh admin@192.168.1.10".
3. Change to root via "su -" (root password have to be setup)
4. Make sure your Internet connection is intact, via command-line "ping 8.8.8.8".

### Download the Project to the controller

```bash
root@axcf2152:/opt/plcnext/# git clone <MyProject>
root@axcf2152:/opt/plcnext/# cd <MyProject>
```

### Install Balena

Setup needs as parameter the `<VERSION>` of Balena to be installed, e.g. `v.18.9.13`.

```bash
root@axcf2152:~# chmod +x setup.sh
root@axcf2152:~# ./setup.sh <VERSION>
```

### Start and stop the daemon

Start the balena-engine-daemon manually.

```bash
root@axcf2152:~# /etc/init.d/balena start
```

Stop the balena-engine-daemon manually.

```bash
root@axcf2152:~# /etc/init.d/balena stop
```

Open the new terminal and show the status of OCI container

```bash
root@axcf2152:~# balena-engine ps
Result:
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
```

## Work with containers

All OCI compatible images can be used in combination with balena, especially docker images.  
For images see: https://hub.docker.com/

### Download an image to the controller

`Pull` loads an image from a repository and stores it locally. if no complete domain is given, the images on https://hub.docker.com/ are searched automatically.

```bash
root@axcf2152:~# balena-engine pull armhf/debian
```

### Start an image on the controller

`Start` creates a container from an image available on the local computer

```bash
root@axcf2152:~# balena-engine start armhf/debian
```

### Run an image

The `run` command combines `pull` and `start`

```bash
root@axcf2152:~# balena-engine run armhf/debian
```

### Start an image and get access into the container

The command `-it` (interactive with tty) creates a new process in a container. The entry point must also be specified. In the example `/bin/bash`

```bash
root@axcf2152:~# balena-engine run -it debian /bin/bash
# Result: If a container is successfully started
root@9bc6dd4527e0:/#
```

### Test the internet access inside docker container

```bash
root@9bc6dd4527e0:/# ping 8.8.8.8
# Result:
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=55 time=14.6 ms
```

### Exit the running container

When closing and restarting containers the runtime data (data that is not part of the image) is lost. If this data is to be retained, it must be stored persistently. See volumes.

```bash
root@9bc6dd4527e0:/# exit
# Result:
root@axcf2152:~#
```

### Working with Volumes

Mounting host volumes into the container and test it. A host volume is one way to persist data from a container.

```bash
# Create a project folder on the host e.g. /opt/plcnext/test and mount it in the container as /home/test/
root@axcf2152:~# mkdir /opt/plcnext/test
root@axcf2152:~# balena-engine run -it -v /opt/plcnext/test:/home/test/ debian bash
```

Alternative to host volumes, you can use container volumes on your host.
There are also other methods to persistently store data from containers, for which various drivers are provided. Besides volumes and folders, central network storage, such as NFS, is often used.

```bash
# For use a container volume you need a name instead of directory. Example:
balena-engine run -it -v test:/home/test/ debian bash
# will be create a volume.

# The volumes can be viewed by:
root@axcf2152:~# balena-engine volume ls

# The content of the volume can be inspected via ls on the host system
root@axcf2152:~# ls /media/rfs/rw/var/lib/docker/volumes/test/_data
```

### Show all OCI container

You can see an example output on the console.

```bash
root@axcf2152:~# balena-engine ps -a
Result:
CONTAINER ID        IMAGE                 COMMAND                  CREATED             STATUS                       PORTS                                            NAMES
4401cdaf0fee        armhf/debian          "bash"                   7 minutes ago       Exited (130) 8 seconds ago                                                    cranky_mayer
df194ad3f89d        debian                "bash"                   22 minutes ago      Exited (0) 21 minutes ago                                                     agitated_austin
092fe03508aa        nginx                 "nginx -g 'daemon of…"   33 minutes ago      Exited (0) 31 minutes ago                                                     magical_antonelli
0dd0b4d84759        registry:2            "/entrypoint.sh /etc…"   About an hour ago   Up About an hour             5000/tcp, 0.0.0.0:5000->5000/tcp                 registry_name
2c71de9f0555        portainer/portainer   "/portainer"             About an hour ago   Up About an hour             0.0.0.0:18000->8000/tcp, 0.0.0.0:19000->9000/tcp frosty_mclean
```

### Remove container

You can see an example output on the console.

```bash
root@axcf2152:~# balena-engine rm 44 (a part of ID-Number: 4401cdaf0fee)
root@axcf2152:~# balena-engine ps -a
Result:
CONTAINER ID        IMAGE                 COMMAND                  CREATED             STATUS                       PORTS                                            NAMES
df194ad3f89d        debian                "bash"                   22 minutes ago      Exited (0) 21 minutes ago                                                     agitated_austin
092fe03508aa        nginx                 "nginx -g 'daemon of…"   33 minutes ago      Exited (0) 31 minutes ago                                                     magical_antonelli
0dd0b4d84759        registry:2            "/entrypoint.sh /etc…"   About an hour ago   Up About an hour             5000/tcp, 0.0.0.0:5000->5000/tcp                 registry_name
2c71de9f0555        portainer/portainer   "/portainer"             About an hour ago   Up About an hour             0.0.0.0:18000->8000/tcp, 0.0.0.0:19000->9000/tcp frosty_mclean
```

## Examples

Examples of interesting projects.

### Run a local registry

See following Usecase: https://docs.docker.com/registry/deploying/

```bash
root@axcf2152:~# balena-engine run -d -p 5000:5000 --name registry_name registry:2
```

### Run a local webserver nginx

Find more information under: https://hub.docker.com/_/nginx

```bash
root@axcf2152:~# balena-engine run -d nginx
```

### Deploy and start Portainer (user interface for container runtimes)

See Portainer Quick-Start: https://portainer.readthedocs.io/en/stable/deployment.html#quick-start  
Result: Open Webbrowser and login into Portainer Docker-Management-Tool (http://192.168.1.10:9000/#/home)

```bash
balena-engine run -d -p 8000:8000 -p 9000:9000 -v /var/run/balena-engine.sock:/var/run/balena-engine.sock -v portainer_data_name:/data portainer/portainer
```

Copyright © 2019 Phoenix Contact Electronics GmbH

All rights reserved. This program and the accompanying materials are made available under the terms of the [MIT License](http://opensource.org/licenses/MIT) which accompanies this distribution.
