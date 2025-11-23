FROM ubuntu:24.04

ARG LLVM_VER=20.1.1
ARG OCAML_VER=5.2.0
ENV LLVM_VER=$LLVM_VER
ENV OCAML_VER=$OCAML_VER

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y cmake ninja-build opam git python3.12 fish 
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential pkg-config ca-certificates
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y libffi-dev

WORKDIR /home/
RUN git clone --depth 1 --branch llvmorg-$LLVM_VER https://github.com/llvm/llvm-project.git
RUN opam init --disable-sandboxing -y --compiler=$OCAML_VER && opam install -y ocamlfind ctypes ctypes-foreign
COPY ./build-llvm.fish .
RUN chmod +x build-llvm.fish
RUN ./build-llvm.fish --alive

