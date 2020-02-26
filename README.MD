# PLCnext Technology - Docker and Balena Engine

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Web](https://img.shields.io/badge/PLCnext-Website-blue.svg)](https://www.phoenixcontact.com/plcnext)
[![Community](https://img.shields.io/badge/PLCnext-Community-blue.svg)](https://www.plcnext-community.net)

## Guide details

|Description   | Value      |
|--------------|------------|
|Created       | 18.02.2020 |
|Last modified | 18.02.2020 |
|Controller    | AXC F 2152 |
|Firmware      | 2020.0 LTS |

Hardware requirements:

- PLC AXC F 2152 - (Order number 2404267)

Host machine software requirements:

- Linux operating system.

## Introduction

The multi-part tutorial provides an introduction to Balena-Engine an IoT focused Docker like container technology on a PLCnext control.

For more Information about Balena-Engine visit the [website](https://www.balena.io/engine/).

## Roadmap

- With PLCnext Technology **Firmware 2020.0** the AXC controller are **Docker Ready**, this includes a basic set of kernel flags.
- With Firmware 2020.3 there will follow some advanced settings like additional kernel flags and cgroup mounts.
- With Firmware 2020.6 it is planned to have balena-engine, a docker compatible container engine, as firmware component implemented.

> The solution for containerization in this tutorial is only for testing and development purposes.
> With Firmware 2020.6 there will be no more need to install an engine manually and the firmware
> update could interfere with this solution. Please make sure to backup your images before updating to Firmware 2020.6.

## Before getting started

Please note that the introduction in this series of articles uses:

- Internet-Connection

## Getting Started

In the following series of technical articles, you will install Balena Engine for PLCnext Control and run [OCI container](https://www.opencontainers.org/) on a PLCnext Control.

|\#| Topic | Objectives |
| --- | ------ | ------ |
|[01](getting-started/Part-01/README.md)| [Installation](getting-started/Part-01/README.md)| Install the Balena Engine and run the Balena Container on a PLCnext Control.|
|[02](getting-started/Part-02/README.md)| [Firewall Configuration](getting-started/Part-02/README.md)| How to configure the device firewall for the network access of the container.|
|| [Explore unlimited possibilities ...](getting-started/Part-99/README.md)| Get ideas for other interesting features you can implement in your own PLCnext datalogger application.|

## How to get support or provide suggestion and ideas

You can get support or provide suggestion and ideas in the forum of the [PLCnext Community](www.plcnext-community.net).

## License

Copyright (c) Phoenix Contact Gmbh & Co KG. All rights reserved.

Licensed under the [MIT](LICENSE) License.
