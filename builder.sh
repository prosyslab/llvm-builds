#!/usr/bin/env bash

# build LLVM producing OCaml bindings in a Docker container

set -l LLVM_VER 20.1.1

set -e
docker build -t llvm-builder --build-arg LLVM_VER=$LLVM_VER .
docker create --name extract-llvm llvm-builder
docker cp extract-llvm:/home/llvm-$LLVM_VER ./
docker rm extract-llvm

