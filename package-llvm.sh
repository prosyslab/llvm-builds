#!/usr/bin/env fish

set -l BUILT $argv[1]

# check if the directory exists
test -e $BUILT
or exit 1
test -d $BUILT
or exit 1

echo "Packaging $BUILT for OPAM"

tar -czvf "llvm-20.1.1-ocaml-5.2.0.tar.gz" $BUILT
