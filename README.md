```sh
opam repo add prosyslab git@github.com:prosyslab/llvm-builds.git
opam install llvm-prosys
```

```sh
./builder.sh # this produces built LLVM and its OCaml bindings to ./llvm-20.1.1
./package-llvm.sh llvm-20.1.1
./release.sh
```
