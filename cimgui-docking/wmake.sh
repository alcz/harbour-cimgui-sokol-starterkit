OPATH="$(pwd)"
cd /home/$USER/emsdk
. ./emsdk_env.sh --build=Release
cd $OPATH

export HB_PLATFORM=wasm
export HB_COMPILER=emcc
export HB_BUILD_3RDEXT=no
export HB_HOST_BIN=/home/$USER/harbour/bin/linux/gcc/
export LLVM_ROOT=/home/$USER/emsdk/upstream/bin

$HB_HOST_BIN/hbmk2 cimgui.hbp
