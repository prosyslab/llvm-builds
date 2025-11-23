#!/usr/bin/env bash

# build LLVM producing OCaml bindings in a Docker container

set -e
docker build -t llvm-builder .
docker create --name extract-llvm llvm-builder
docker cp extract-llvm:/home/staging ./
docker rm extract-llvm

