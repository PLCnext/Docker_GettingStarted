#!/bin/bash
if [ ! -d "./build" ]; then
    mkdir ./build
fi
./makeself.sh --needroot --notemp ./archive ./build/axcf2152-docker-$VERSION.sh "Docker $VERSION-ce for AXC F 2152" ./setup.sh
