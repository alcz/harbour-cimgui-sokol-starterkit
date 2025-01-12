/*
    treetable.prg    -- example filesystem structure presented
                        with Dear Imgui's tree+table

    license is MIT, see ../LICENSE
*/

#include "hbimenum.ch"

REQUEST HB_CODEPAGE_PL852
REQUEST HB_CODEPAGE_HU852
REQUEST HB_CODEPAGE_UTF8EX

PROCEDURE MAIN

   hb_cdpSelect("UTF8EX")

#ifndef __PLATFORM__WASM
   IF ! File( "OpenSans-Regular.ttf" )
      Alert("can't find my font")
   ENDIF
#endif
   hb_sokol_imguiNoDefaultFont( .T. )
   sapp_run_default( "Tree table", 800, 600 )

#ifdef __PLATFORM__WASM
   IF ImFrame() # NIL /* dummy calls for emscripten, to be removed when those functions are properly requested from .c code */
      ImInit()
   ENDIF
#endif
   RETURN

PROCEDURE ImInit
#ifdef __PLATFORM__WASM
   LOCAL cFontBuf
#pragma __binarystreaminclude "OpenSans-Regular.ttf"|cFontBuf := %s
   hb_igAddFontFromMemoryTTF( cFontBuf, 18.0, , { "HU852", "PL852" }, .T., .F. )
#else
   hb_igAddFontFromFileTTF( "OpenSans-Regular.ttf", 18.0, , { "HU852", "PL852" }, .T., .F. )
#endif

   hb_sokol_imguiFont2Texture()
   RETURN

PROCEDURE ImFrame
   STATIC a
   STATIC aFiles := ;
      { { "Root",                         "Folder",       -1,       1, 3    },; // 0
        { "Music",                        "Folder",       -1,       4, 2    },; // 1
        { "Textures",                     "Folder",       -1,       6, 3    },; // 2
        { "desktop.ini",                  "System file",  1024,    -1,-1    },; // 3
        { "File1_a.wav",                  "Audio file",   123000,  -1,-1    },; // 4
        { "File1_b.wav",                  "Audio file",   456000,  -1,-1    },; // 5
        { "Image001.png",                 "Image file",   203128,  -1,-1    },; // 6
        { "Copy of Image001.png",         "Image file",   203256,  -1,-1    },; // 7
        { "Copy of Image001 (Final2).png","Image file",   203512,  -1,-1    } } // 8

   igSetNextWindowPos( {10,10}, ImGuiCond_Once, {0,0} )
   igSetNextWindowSize( {650, 350}, ImGuiCond_Once )
   igBegin( "Filesystem structure", 0, ImGuiWindowFlags_None )

   igCalcTextSize( @a, "A" )
   igText("size of a letter " + hb_valToExp( a ) )

   igGetWindowPos( @a )
   igText("window pos " + hb_valToExp( a ) )

   TreeTable( aFiles )

   igEnd()

   RETURN

STATIC FUNCTION TreeTable( a )
   STATIC nTableFlags := ImGuiTableFlags_BordersV + ImGuiTableFlags_BordersOuterH + ;
                         ImGuiTableFlags_Resizable + ImGuiTableFlags_RowBg + ;
                         ImGuiTableFlags_NoBordersInBody

   STATIC nTextBWidth := NIL

   STATIC b := NIL

   IF nTextBWidth == NIL
      igCalcTextSize( @nTextBWidth,"A" ) // -> {x,y}
      nTextBWidth := nTextBWidth[ 1 ]
   ENDIF

   IF igBeginTable( "3ways", 3, nTableFlags )

      // The first column will use the default _WidthStretch when ScrollX is Off and _WidthFixed when ScrollX is On
      igTableSetupColumn( "Name", ImGuiTableColumnFlags_NoHide )
      igTableSetupColumn( "Size", ImGuiTableColumnFlags_WidthFixed, nTextBWidth * 12.0 )
      igTableSetupColumn( "Type", ImGuiTableColumnFlags_WidthFixed, nTextBWidth * 18.0 )
      igTableHeadersRow()

      IF b == NIL
         b := { |x|
                 LOCAL cName := x[ 1 ]
                 LOCAL cType := x[ 2 ]
                 LOCAL nSize := x[ 3 ]
                 LOCAL nChildIdx   := x[ 4 ]
                 LOCAL nChildCount := x[ 5 ]
                 LOCAL lOpen

                 igTableNextRow()
                 igTableNextColumn()

                 IF nChildCount > 0 /* is_folder */
                    lOpen := igTreeNodeExStr( cName, ImGuiTreeNodeFlags_SpanFullWidth )
                    igTableNextColumn()
                    igTextDisabled( "--" )
                    igTableNextColumn()
                    igTextUnformatted( cType )
                    IF lOpen
                       AEval( a, b, nChildIdx + 1, nChildCount )
                       igTreePop()
                    ENDIF
                 ELSE
                    igTreeNodeExStr( cName, ImGuiTreeNodeFlags_Leaf + ;
                                            ImGuiTreeNodeFlags_Bullet + ;
                                            ImGuiTreeNodeFlags_NoTreePushOnOpen + ;
                                            ImGuiTreeNodeFlags_SpanFullWidth )
                    igTableNextColumn()
                    igTextUnformatted( hb_NtoS( nSize ) )
                    igTableNextColumn()
                    igTextUnformatted( cType )
                 ENDIF
              }
      ENDIF

      AEval( a, b, 1, 1 )

      igEndTable()

   ENDIF
