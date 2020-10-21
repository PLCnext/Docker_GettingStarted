# PLCnext Technology compatible container runtimes - Docker, Moby, balenaEngine

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Web](https://img.shields.io/badge/PLCnext-Website-blue.svg)](https://www.phoenixcontact.com/plcnext)
[![Community](https://img.shields.io/badge/PLCnext-Community-blue.svg)](https://www.plcnext-community.net)

## Project details

|Description   | Value      |
|--------------|------------|
|Created       | 18.02.2020 |
|Last modified | 21.10.2020 |
|Controller    | ALL        |
|Firmware      | 2020.6     |

Hardware requirements:

- AXC F 1152
- AXC F 2152
- AXC F 3152

## Changes for PLCnext firmware 2020.6

- The command "balena-engine exec -it <container> <execute>"  works now
- Integrate `iptables-nft` for automatic firewall configuration
- Publish as APP in [PLCnext Store](https://www.plcnextstore.com/)
- Added in the Setup Docker as selection for installation
- Added Docker-Compose

For the difference between Docker and balenaEngine, see [https://www.balena.io/engine/](https://www.balena.io/engine/)

Known bugs:

- If the firewall is activated in WBM or rules are changed here, the container runtime must be restarted.
- Docker-Compose does not work if the compose file is located directly in */opt/plcnext/*
- Factory reset does not remove application images and cache.

## Install on Target

For installation you need to be root user:

To change to root:

```sh
su
```

To set the password from root

```sh
sudo passwd root
```

For installation:

```sh
# Download the Project
git clone https://github.com/PLCnext/Docker_GettingStarted.git

# Execute Setup.sh in archive
cd Docker_GettingStarted
chmod +x setup.sh
./setup.sh
```

## Hotfix for FW2020.6

After a restart the firewall rules are set incorrectly. For development purposes, the PLCnext firewall can be removed from the autostart. This is adapted in Firmware 2021.0 LTS. 

```sh
update-rc.d -f firewall remove
```

## Workaround to fully remove images and cache before/after firmware reset

Login to the terminal, change to root and remove the folder manually

```sh
rm -rf /media/rfs/rw/var/lib/balena
```

## Introduction

The multi-part tutorial provides an introduction to Balena-Engine an IoT focused Docker like container technology on a PLCnext control.

For more Information about Balena-Engine visit the [website](https://www.balena.io/engine/) and the [GitHub project](https://github.com/balena-os/balena-engine).

## License

[balenaEngine](https://github.com/balena-os/balena-engine/blob/master/README.md), [Moby and Docker](https://github.com/moby/moby/blob/master/README.md) are licensed under the [Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0).

## Roadmap

- With PLCnext Technology **Firmware 2020.0** the AXC controller are **Docker Ready**, this includes a basic set of kernel flags.
- With Firmware 2020.3 there will follow some advanced settings like additional kernel flags and cgroup mounts.
- With Firmware 2021.0 xtables will be part of the image

> The solution for containerization in this tutorial is only for testing and development purposes.
> update could interfere with this solution. Please make sure to backup your images before updating to a new Firmware.

## Before getting started

Please note that the introduction in this series of articles uses:

- Internet-Connection

## Getting Started

In the following series of technical articles, you will install Balena Engine for PLCnext Control and run [OCI container](https://www.opencontainers.org/) on a PLCnext Control.

|\#| Topic | Objectives |
| --- | ------ | ------ |
|[01](getting-started/Part-01/README.md)| [Installation](getting-started/Part-01/README.md)| Install the Balena Engine and run the Balena Container on a PLCnext Control.|
|[02](getting-started/Part-02/README.md)| [Firewall Configuration](getting-started/Part-02/README.md)| How to configure the device firewall for the network access of the container.|
|| [Explore unlimited possibilities ...](getting-started/Part-99/README.md)| Get ideas for other interesting features you can implement in your own PLCnext docker application.|

## How to get support or provide suggestion and ideas

You can get support or provide suggestion and ideas in the forum of the [PLCnext Community](www.plcnext-community.net).

## License

Copyright (c) Phoenix Contact Gmbh & Co KG. All rights reserved.

Licensed under the [MIT](LICENSE) License.
