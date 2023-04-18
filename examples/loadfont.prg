/*
    loadfont.prg    -- example of font loading facilities

    license is MIT, see ../LICENSE
*/

#include "hbimenum.ch"

REQUEST HB_CODEPAGE_PL852
REQUEST HB_CODEPAGE_EL737
REQUEST HB_CODEPAGE_UTF8EX

PROCEDURE MAIN

   hb_cdpSelect("UTF8EX")

#ifndef __PLATFORM__WEB
   IF ! File( "OpenSans-Regular.ttf" )
      Alert("can't find my font")
   ENDIF
#endif
   hb_sokol_imguiNoDefaultFont( .T. )
   sapp_run_default( "Custom Font Example", 800, 600 )

#ifdef __PLATFORM__WEB
   IF ImFrame() # NIL /* dummy calls for emscripten, to be removed when those functions are properly requested from .c code */
      ImInit()
   ENDIF
#endif
   RETURN

PROCEDURE ImInit
#ifdef __PLATFORM__WEB
   LOCAL cFontBuf
#pragma __binarystreaminclude "OpenSans-Regular.ttf"|cFontBuf := %s
   hb_igAddFontFromMemoryTTF( cFontBuf, 18.0, , { "EL737", "PL852" }, .T., .F. )
#else
   hb_igAddFontFromFileTTF( "OpenSans-Regular.ttf", 18.0, , { "EL737", "PL852" }, .T., .F. )
#endif

   hb_sokol_imguiFont2Texture()

#ifdef ImGuiConfigFlags_DockingEnable
   hb_igConfigFlagsAdd( ImGuiConfigFlags_DockingEnable )
#endif

   RETURN

PROCEDURE ImFrame
   STATIC counter := 0, s, c, d, a

#ifdef ImGuiConfigFlags_DockingEnable
   igDockSpaceOverViewPort()
#endif

   igSetNextWindowPos( {10,10}, ImGuiCond_Once, {0,0} )
   igSetNextWindowSize( {650, 350}, ImGuiCond_Once )
   igBegin( "Hello Dear ImGui!", 0, ImGuiWindowFlags_None )

   igText("Viel Glück! α Ω")

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
