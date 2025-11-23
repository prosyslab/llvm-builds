FROM ubuntu:24.04

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y cmake ninja-build opam git python3.12 fish 
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential pkg-config ca-certificates
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y libffi-dev

WORKDIR /home/
RUN opam init --disable-sandboxing -y --compiler=5.2.0 && opam install -y ocamlfind ctypes ctypes-foreign
COPY ./build-llvm.fish .
RUN chmod +x build-llvm.fish
RUN ./build-llvm.fish --alive

