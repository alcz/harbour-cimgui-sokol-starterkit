OPATH="$(pwd)"
cd /home/$USER/emsdk
. ./emsdk_env.sh --build=Release
cd $OPATH

export HB_PLATFORM=wasm
export HB_COMPILER=emcc
export HB_BUILD_3RDEXT=no
export HB_HOST_BIN=/home/$USER/harbour/bin/linux/gcc/
export LLVM_ROOT=/home/$USER/emsdk/upstream/bin

# export HB_USER_LDFLAGS="-s ERROR_ON_UNDEFINED_SYMBOLS=0"

# NOTE: wmake.sh uses a different --shell-file, closure, (no) exported FS
# TODO: move these flags to .hbp
# NOTE: with emscripten > 2.12.x withStackSave is no longer needed to be manually listed in EXPORTED_RUNTIME_METHODS
$HB_HOST_BIN/hbmk2 -gtnul -l runner.hbp -ldflag="--shell-file html/runner.html -sASSERTIONS=0 -sMALLOC=emmalloc --closure 0 -sEXPORTED_RUNTIME_METHODS=['FS','withStackSave'] -sALLOW_MEMORY_GROWTH=1" -orunner.html
