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

# NOTE: wmake.sh uses a different --shell-file, closure, (no) exported FS
# TODO: move these flags to .hbp
$HB_HOST_BIN/hbmk2 -gtnul runner.hbp -ldflag="--shell-file html/runner.html -sASSERTIONS=0 -sMALLOC=emmalloc --closure 0 -sEXPORTED_RUNTIME_METHODS=['FS']" -orunner.html
