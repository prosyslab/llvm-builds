#!/usr/bin/env fish

# build LLVM producing OCaml bindings in a Docker container

set -l LLVM_VER 20.1.1
set -l OCAML_VER 5.2.0

docker build -t llvm-builder --build-arg LLVM_VER=$LLVM_VER --build-arg OCAML_VER=$OCAML_VER .; or exit 1
docker create --name extract-llvm llvm-builder
docker cp extract-llvm:/home/llvm-$LLVM_VER ./
docker rm extract-llvm

