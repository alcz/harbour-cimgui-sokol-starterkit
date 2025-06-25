# harbour-cimgui-sokol-starterkit

A minimal cross-platform starter-kit to write creative Harbour + Dear ImGui programs for Windows, Linux, macOS or any modern Web browser, with option to step down to C at will.

This repository contains what could be called auto-generated Harbour wrapper to Dear ImGui, probably connecting table-oriented dynamic xbase-like programming language for the first time (and the results around the regions of immediate approach are intresting).

forked from cimgui-sokol-starterkit at https://github.com/floooh/cimgui-sokol-starterkit

[WASM version](https://os.allcom.pl/hbv3/#!UFJPQ0VEVVJFIE1haW4KICAgaWdUZXh0KCAiRGVhciBJbUd1aSAiICsgaWdHZXRWZXJzaW9uKCkgKyAiLCBIZWxsbyBXb3JsZCEiICkKICAgICAg) that supports entering code examples live (see below for build instructions)
[Some more coding examples](https://os.allcom.pl/p/1VcPUlPk_3/imgui.html)
## Clone:

```bash
> git clone https://github.com/alcz/harbour-cimgui-sokol-starterkit
> cd harbour-cimgui-sokol-starterkit
```

## Build:

Make sure you have installed current Harbour developement version 3.2 from:
https://github.com/harbour/core or
https://github.com/alcz/harbour and ```hbmk2``` tool is in path

In a checked out directory invoke either:
```bash
> hbmk2 meta-rebuild.hbp
```
or
```bash
> hbmk2 meta-rebuild-docking.hbp
```
NOTE: keeping more branches of Dear ImGui (like regular, docking, custom, tui) under single directory tree is not currently supported.

To build an example application  Release version on Windows with the VisualStudio toolchain:

```bash
> cd examples
> export IMGUI_DOCKING=y # if applicable (set IMGUI_DOCKING=y on Windows)
> hbmk2 [sample].prg # loadfont.prg, browse1.prg, procdbf.prg
> hbmk2 [sampleproject.hbp] # yadbu.hbp
```

NOTE: on Linux you'll also need to install the 'usual' dev-packages needed for X11+GL development.

## Run:

On Linux and macOS:
```bash
> ./sample # ./loadfont ./browse ./procdbf ./yadbu etc...
```

On Windows you can proceed with Visual Studio, MinGW, clang toolchains, the exe is likewise in original subdirectory:
```bash
> examples\demo.exe
```

## Build and Run WASM/HTML version via Emscripten (Linux, macOS)

emscripten SDK release 2.0.32 is recommended as tested one, newer also should do, but emscripten introduces many symbol linking issues in C code, so be prepared to be a debugging kind of person. Older releases will break file drag and drop support  in the browsers.

Setup the emscripten SDK as described here:

https://emscripten.org/docs/getting_started/downloads.html#installation-instructions

Don't forget to run ```source ./emsdk_env.sh``` after activating the SDK.

And then in the ```harbour-cimgui-sokol-starterkit``` directory:

```bash
> ./wmake.sh
```

Please refer to ```wmake.sh``` helper script, which contains example setup of emsdk in your ```$HOME``` directory of a UNIX system 

```
OPATH="$(pwd)"
cd /home/$USER/emsdk
. ./emsdk_env.sh --build=Release
cd $OPATH

export HB_PLATFORM=wasm
export HB_COMPILER=emcc
export HB_BUILD_3RDEXT=no
export HB_HOST_BIN=/home/$USER/harbour/bin/linux/gcc/
export LLVM_ROOT=/home/$USER/emsdk/upstream/bin

if [$(IMGUI_DOCKING) -ne '']
then
   $HB_HOST_BIN/hbmk2 $* meta-rebuild-docking.hbp
else
   $HB_HOST_BIN/hbmk2 $* meta-rebuild.hbp
fi

$HB_HOST_BIN/hbmk2 $* -gtnul hbdemo.hbp -ohbdemo2.html -ldflag="--shell-file ./sokol/shell.html -sASSERTIONS=0 -sMALLOC=emmalloc --closure 1"
$HB_HOST_BIN/hbmk2 $* -gtnul cdemo.hbp -ocdemo.html -ldflag="--shell-file ./sokol/shell.html -sASSERTIONS=0 -sMALLOC=emmalloc --closure 1"

```

To run the compilation result in the system web browser:

```
> emrun cdemo.html
> emrun hbdemo2.html
```

...which should look like [this](https://os.allcom.pl/hb/wasm/hbdemo2.html), but better (very outdated build).

(please contribute Windows build instructions if you use emscripten under this environment)

## Notes:

The repository contains snapshots of the following libraries:

- [Dear ImGui](https://github.com/ocornut/imgui)
- [cimgui](https://github.com/cimgui/cimgui) (C bindings for Dear ImGui)
- [Sokol Headers](https://github.com/floooh/sokol) (only what's needed)

Dear ImGui version stored here is not the newest one, but the one that was thorougly tested at my developement pace.

Hopefully project build files ```*.hbp``` ```*.hbc``` ```*.hbm``` are kept as simple as possible (unfortunately cross-platform differences needs attention).

Advanced users may study and compare original ```CMakeLists.txt``` to Harbour Build System (hbmk2) files step by step by checking out ```cdemo.c + *.hbp```, ```hbdemo2.prg + *.hbp```, ```examples/hbmk2.hbm```.

Enjoy!

## **Work in progress**

### Current focus in this project:
- ImGui revisions 1.87-1.89 introduced many interesting changes in the areas of keyboard mapping system, sokol at the same time introduced changing mouse pointer cursors. They will be upgraded stepping throught versions to accomodate them consciously.
- Introduce idling feature / power saving mode, that do not redraw (constantly at 60fps or so) with no input events, similar to https://github.com/pthom/hello_imgui (we may as well at some point repackage whole hello_imgui as an alternative platform handler)
- Make error handler: ErrorBlock() that will not disrupt display on runtime errors, but will manage back the window/control/tree stack of ImGui without assertion failures.
- Evaluate database client/server kind of example code.
- wire Harbour's memory allocator into sokol and ImGui
- due to vast amount of autogenerated code in the wrappers, currently NOT focusing on fixing every C/C++ compiler warning

## **Screenshots**

![Playground](/img/playground.png?raw=true "Playground")
![Playground coding](/img/playground-code.png?raw=true "Playground coding")
![yadbu Win64](/img/yadbu-win64.png?raw=true "yadbu on Windows 64-bit")
![yadbu Firefox](/img/yadbu-firefox.png?raw=true "yadbu WebAssembly in Firefox")
![yadbu Debian](/img/yadbu-debian.png?raw=true "yadbu running on Debian")

## **Bonus chatter**

### **1. understanding the Build System Differences, when migrating from cmake to hbmk2**
- **CMake**:
  - Uses `CMakeLists.txt` to define build rules, dependencies, and compiler options.
  - Organizes source files, header directories, and external libraries using commands like `add_executable()`, `target_include_directories()`, and `target_link_libraries()`.

- **hbmk2**:
  - Uses `.hbp` files for build project definitions and `.hbc` to reference any dependencies/libraries used.
  - `.hbp` files reference `.hbc` files, which include compiler settings, for further dependencies, and link options.

### **2. Translating Build Targets from CMakeLists.txt to `.hbp`**
Each `CMakeLists.txt` directive corresponds to an equivalent `.hbp` setup in `hbmk2`.

#### **Example CMakeLists.txt**
```
cmake_minimum_required(VERSION 3.10)
project(MyProject)

set(SOURCES main.c utils.c)
set(INCLUDES include/)

add_executable(MyProject ${SOURCES})
target_include_directories(MyProject PRIVATE ${INCLUDES})

if (CMAKE_SYSTEM_NAME STREQUAL Linux)
   target_link_libraries(MyProject PRIVATE m)
endif
```

#### **Equivalent `hbmk2` `.hbp` File**
```
main.c
utils.c
anylibraryused.hbc
-Iinclude
{linux}-lm
```

#### **If you're making a library not an application refer to sokol build files (`sokol.hbp sokol.hbc`)**

[sokol.hbp](https://github.com/alcz/harbour-cimgui-sokol-starterkit/blob/master/sokol/sokol.hbp)
[sokol.hbc](https://github.com/alcz/harbour-cimgui-sokol-starterkit/blob/master/sokol/sokol.hbc)


#### **Key Translations**
| **CMake Command**                    | **hbmk2 Equivalent**                 |
|--------------------------------------|--------------------------------------|
| `set(SOURCES main.c utils.c)`       | List source files directly in `.hbp` |
| `set(INCLUDES include/)`            | `-Iinclude` (in `.hbp`, generally not needed for Harbour projects) |
| `add_executable(MyProject ${SOURCES})` | No explicit command neededhbmk2 builds executables automatically, optionally ```-o[execname]``` |
| `target_include_directories(MyProject PRIVATE ${INCLUDES})` | Handled in `.hbc` using `libpath=<path>` |
| `target_link_libraries(MyProject PRIVATE m)` | `libs=m` (Linking math library, defined in `.hbc`) |

### **3. Handling Dependencies**
- CMake uses `find_package()` or `target_link_libraries()`.
- `hbmk2` handles dependencies via `.hbc` configuration files.
- `.hbp` files reference `.hbc` rather than listing individual flags.

#### **Example: Dependency Management**
##### **CMakeLists.txt**
```
target_link_libraries(MyProject PRIVATE imgui sokol)
```

##### **hbmk2 Setup**
- **Project file (`MyProject.hbp`)**
  ```
  main.prg
  utils.prg
  cimgui.hbc
  sokol.hbc
  ```

