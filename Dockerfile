FROM ubuntu:24.04

RUN apt-get update

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y cmake ninja-build opam git python3.12 fish

WORKDIR /home/
RUN opam init --disable-sandboxing -y
COPY ./build-llvm.fish .
RUN chmod +x build-llvm
RUN ./build-llvm.fish

