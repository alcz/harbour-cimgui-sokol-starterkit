OPATH="$(pwd)"
cd /home/$USER/emsdk
. ./emsdk_env.sh --build=Release
cd $OPATH

export HB_PLATFORM=wasm
export HB_COMPILER=emcc
export HB_BUILD_3RDEXT=no
export HB_HOST_BIN=/home/$USER/harbour/bin/linux/gcc/
export LLVM_ROOT=/home/$USER/emsdk/upstream/bin

# currently silences sigaltstack undefined symbol (why?)
# export HB_USER_LDFLAGS="-s ERROR_ON_UNDEFINED_SYMBOLS=0"

$HB_HOST_BIN/hbmk2 -gtnul $* -ldflag="--shell-file ../../sokol/shell.html -sASSERTIONS=0 -sMALLOC=emmalloc --closure 1"
