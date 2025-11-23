#!/usr/bin/env fish

# must be used in a docker container for building
argparse 'llvm=' 'ocaml=' 'targets=' 'alive' -- $argv
or return 1

test (pwd -P) = "/home"
or exit 1

set -q _flag_llvm;    and set LLVM_VER $_flag_llvm;       or set LLVM_VER "20.1.1"
set -q _flag_ocaml;   and set OCAML_VER $_flag_ocaml;     or set OCAML_VER "5.2.0"
set -q _flag_targets; and set LLVM_TARGETS $_flag_targets; or set LLVM_TARGETS "X86;WebAssembly"

# if set -q _flag_alive
set ALIVE_OPTS "ON"
set CONFIG_MSG "Enabled (RTTI + Assertions)"
# else
#     set ALIVE_OPTS "OFF"
#     set CONFIG_MSG "Disabled"
# end

set CMAKE_PREFIX "/usr/local"
set STAGING_DIR "$PWD/staging"
set ARCHIVE_NAME "llvm-$LLVM_VER-ocaml-$OCAML_VER-linux-x86_64.tar.gz"

eval (opam env)

# --- 3. Clone Source ---
if not test -d llvm-project
    echo "Cloning LLVM $LLVM_VER..."
    git clone --depth 1 --branch llvmorg-$LLVM_VER https://github.com/llvm/llvm-project.git
end

# --- 4. Configure & Build ---
rm -rf build $STAGING_DIR

# We use "lib/llvm" for OCaml bindings to separate them from C++ libs.
cmake -S llvm-project/llvm -B build -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$CMAKE_PREFIX" \
    -DLLVM_TARGETS_TO_BUILD="$LLVM_TARGETS" \
    -DLLVM_ENABLE_PROJECTS="clang;lld" \
    -DLLVM_ENABLE_BINDINGS=ON \
    -DLLVM_BINDINGS_LIST="ocaml" \
    -DLLVM_OCAML_INSTALL_PATH="lib/llvm" \
    -DLLVM_ENABLE_ZSTD=OFF \
    -DLLVM_ENABLE_RTTI=$ALIVE_OPTS \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DLLVM_INCLUDE_EXAMPLES=OFF \
    -DLLVM_INCLUDE_BENCHMARKS=OFF \
    -DLLVM_ENABLE_ASSERTIONS=$ALIVE_OPTS \
    -DLLVM_ENABLE_SPHINX=OFF \
    -DLLVM_ENABLE_DOXYGEN=OFF \
    -DLLVM_ENABLE_OCAMLDOC=OFF

echo "Building and Installing to Staging..."
env DESTDIR=$STAGING_DIR cmake --build build --target install

echo "Build Complete: $STAGING_DIR"

