docker build -t llvm-builder .
docker create --name extract-llvm llvm-builder
docker cp extract-llvm:/home/llvm-20.1.1-ocaml-5.2.0-linux-x86_64.tar.gz ./
docker rm extract-llvm

