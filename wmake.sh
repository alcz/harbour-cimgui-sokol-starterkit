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

if [$(IMGUI_DOCKING) -ne '']
then
   $HB_HOST_BIN/hbmk2 $* meta-rebuild-docking.hbp
else
   $HB_HOST_BIN/hbmk2 $* meta-rebuild.hbp
fi

$HB_HOST_BIN/hbmk2 $* -gtnul hbdemo.hbp -ohbdemo2.html -ldflag="--shell-file ./sokol/shell.html -sASSERTIONS=0 -sMALLOC=emmalloc --closure 1"
$HB_HOST_BIN/hbmk2 $* -gtnul cdemo.hbp -ocdemo.html -ldflag="--shell-file ./sokol/shell.html -sASSERTIONS=0 -sMALLOC=emmalloc --closure 1"
