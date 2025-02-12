/*
    loadfont.prg    -- example of font loading facilities

    license is MIT, see ../LICENSE
*/

#include "hbimenum.ch"
#include "hbimstru.ch"
#include "fonts/IconsFontAwesome6.ch"

REQUEST HB_CODEPAGE_PL852
REQUEST HB_CODEPAGE_EL737
REQUEST HB_CODEPAGE_UTF8EX

PROCEDURE MAIN( cHiDpi )

   hb_cdpSelect("UTF8EX")

#ifndef __PLATFORM__WASM
   IF ! File( "OpenSans-Regular.ttf" )
      Alert("can't find my font")
   ENDIF
#endif
   hb_sokol_imguiNoDefaultFont( .T. )
   sapp_run_default( "Custom Font Example", 800, 600, .T., IIF( cHiDpi == "-hidpi", .T., .F. ) )

#ifdef __PLATFORM__WASM
   IF ImFrame() # NIL /* dummy calls for emscripten, to be removed when those functions are properly requested from .c code */
      ImInit()
   ENDIF
#endif
   RETURN

PROCEDURE ImInit
#ifdef __PLATFORM__WASM
   LOCAL cFontBuf, cFontABuf
#pragma __binarystreaminclude "OpenSans-Regular.ttf"|cFontBuf := %s
   hb_igAddFontFromMemoryTTF( cFontBuf, 18.0, , { "EL737", "PL852" }, .T., .F. )
#pragma __binarystreaminclude "fonts/fa-solid-900.ttf"|cFontABuf := %s
   hb_igAddFontFromMemoryTTF( cFontABuf, 18.0 * ( 3 / 4 ), , { 0xf4e3, 0xf72f }, .F., .T. )
#else
   hb_igAddFontFromFileTTF( "OpenSans-Regular.ttf", 18.0, , { "EL737", "PL852" }, .T., .F. )
   hb_igAddFontFromFileTTF( "fonts/fa-solid-900.ttf", 18.0 * ( 3 / 4 ), , { 0xf4e3, 0xf72f }, .F., .T. )
   // if you want to make all icons available try following... note that the range pairs
   // keep 0 as the last element to distinct from character list
   // hb_igAddFontFromFileTTF( "fonts/fa-solid-900.ttf", 18.0 * ( 3 / 4 ), , { ICON_MIN_FA, ICON_MAX_FA, 0 }, .F., .T. )
#endif

   hb_sokol_imguiFont2Texture()

#ifdef ImGuiConfigFlags_DockingEnable
   hb_igConfigFlagsAdd( ImGuiConfigFlags_DockingEnable )
#endif

   ImGuiIO( igGetIO() ):ConfigInputTextCursorBlink := .T.

   RETURN

PROCEDURE ImFrame
   STATIC counter := 0, s, c, d, a

#ifdef ImGuiConfigFlags_DockingEnable
   igDockSpaceOverViewPort()
#endif

   igSetNextWindowPos( {10,10}, ImGuiCond_Once, {0,0} )
   igSetNextWindowSize( {650, 350}, ImGuiCond_Once )
   igBegin( "Hello Dear ImGui!", 0, ImGuiWindowFlags_None )

   igText("Viel Glück! α Ω " + ICON_FA_WINE_BOTTLE + " " + ICON_FA_WINE_GLASS )

   IF IgButton( "dupa.8 dópą.8" )
      counter++
   ENDIF

   igSameLine(0.0, -1.0)
   igText("counter " + hb_NtoS( counter ) )

   igSliderFloat("float", @s, 0.0, 1.0, "%.2f", 0)
   igText("slider updates Harbour variable -> " + hb_NtoS( s ) )

   IF c == NIL
      c := ""
   ENDIF

   igInputTextWithHint("input text (w/ hint)", "enter text here", @c, 200 );

   igText("UPPER() by Harbour -> " + Upper( c ) )

   IF d == NIL
      d := Date()
   ENDIF

   hb_igDatePicker( "Pick a date", @d )
   hb_igDatePicker( "or if Monday starts your week", @d,, 2 )

   hb_igButtonRounded("i'm different")

#include "hbimstru.ch"

   IF ImGuiIO( igGetIO() ):KeyAlt
      igText("ALT is pressed")
   ENDIF

#ifdef ImGuiIO_AppFocusLost
   IF ImGuiIO( igGetIO() ):AppFocusLost
      /* sokol does not seem to support it */
      igText("Window not in focus")
   ENDIF
#endif

   IF ( a := ImGuiIO( igGetIO() ):MouseClickedPos[ 1 ] ) <> NIL
      igText( "Last left click @ " + hb_valToExp( a ) )
   ENDIF

   IF ( a := ImGuiIO( igGetIO() ):MouseClickedPos[ 2 ] ) <> NIL
      igText( "Last right click @ " + hb_valToExp( a ) )
   ENDIF

   igEnd()

   RETURN
