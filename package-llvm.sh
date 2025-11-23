#!/usr/bin/env fish

set -l BUILT $argv[1]

# check if the directory exists
test -e $BUILT
or exit 1
test -d $BUILT
or exit 1

echo "Packaging $BUILT for OPAM"
pushd $BUILT/lib

# `dune build` searches LLVM libraries in `switch-prefix/lib/llvm` via `ocamlfind`
# but the libraries are installed in `switch-prefix/lib`.
# To aid the dune's build system via `ocamlfind`, we create symlinks.
for llvmLib in libLLVM*.a
  pushd llvm/
  ln -sf ../$llvmLib .
  popd
end

popd

tar -czvf "llvm-20.1.1-ocaml-5.2.0.tar.gz" $BUILT
