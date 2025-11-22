#!/usr/bin/env fish

argparse 'llvm=' 'ocaml=' 'targets=' 'alive' -- $argv
or return 1

set -q _flag_llvm;    and set LLVM_VER $_flag_llvm;        or set LLVM_VER "20.1.1"
set -q _flag_ocaml;   and set OCAML_VER $_flag_ocaml;      or set OCAML_VER "5.2.0"
set -q _flag_targets; and set LLVM_TARGETS $_flag_targets; or set LLVM_TARGETS "X86;WebAssembly"
set -q _flag_alive;   and set ALIVE_OPTS "ON";             or set ALIVE_OPTS "OFF"

set CMAKE_PREFIX "/usr/local" 
set STAGING_DIR "$PWD/staging"
set ARCHIVE_NAME "llvm-$LLVM_VER-ocaml-$OCAML_VER-linux-x86_64.tar.gz"

# Configure OCAML environment
opam switch create $OCAML_VER $OCAML_VER
opam switch set $OCAML_VER
eval (opam env --switch=$OCAML_VER --set-switch)
ocaml -version | grep $OCAML_VER
if test $status -ne 0
  echo "opam switch failed"
end
opam install -y ocamlfind ctypes ctypes-foreign
which ocamlfind

if not test -d llvm-project
  echo "Cloning LLVM..."
  # Note: Ensure tag 'llvmorg-$LLVM_VER' exists, or change to 'main'
  git clone --depth 1 --branch llvmorg-$LLVM_VER https://github.com/llvm/llvm-project.git
end

rm -rf build
# Alive requires RTTI to be enabled
cmake -S llvm-project/llvm -B build -G Ninja \
		-DLLVM_ENABLE_PROJECTS="llvm;lld;clang" \
		-DCMAKE_BUILD_TYPE=Release \
		-DLLVM_TARGETS_TO_BUILD=$LLVM_TARGETS \
    -DLLVM_OCAML_INSTALL_PATH="lib/llvm" \
		-DLLVM_ENABLE_BINDINGS=ON \
    -DCMAKE_INSTALL_PREFIX=$CMAKE_PREFIX \
		-DLLVM_ENABLE_RTTI=$ALIVE_OPTS \
    -DLLVM_ENABLE_ZSTD=OFF \
		-DLLVM_ENABLE_ASSERTIONS=ON \
		-DLLVM_ENABLE_SPHINX=OFF \
		-DLLVM_ENABLE_DOXYGEN=OFF \
		-DLLVM_ENABLE_OCAMLDOC=OFF \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DLLVM_INCLUDE_EXAMPLES=OFF \
    -DLLVM_INCLUDE_BENCHMARKS=OFF
env DESTDIR=$STAGING_DIR cmake --build build --target install 

set META_DIR "$STAGING_DIR$CMAKE_PREFIX/lib/llvm"
if test -f "$META_DIR/META.llvm"
  echo "OCaml binding successfully generated"
else
  echo "OCaml binding not generated!"
  return 1
end

echo "Packaging $ARCHIVE_NAME..."
pushd "$STAGING_DIR$CMAKE_PREFIX"
tar -czvf "$PWD/../../../$ARCHIVE_NAME" .
popd

echo "Build Complete: $ARCHIVE_NAME"

