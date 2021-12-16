/*
    hello.prg   -- Hello Harbour logo

    license is MIT, see ../LICENSE
*/

#include "hbimenum.ch"
REQUEST HB_CODEPAGE_UTF8EX

STATIC s_iTextureHarbour, s_iTextureButton
STATIC s_nWidth, s_nHeight /* image button size */

PROCEDURE MAIN

   hb_cdpSelect("UTF8EX")

   sapp_run_default( "Hello Harbour", 800, 600 )

#ifdef __PLATFORM__WEB
   IF ImFrame() # NIL /* dummy calls for emscripten, to be removed when those functions are properly requested from .c code */
      ImInit()
   ENDIF
#endif
   RETURN

PROCEDURE ImFrame
   STATIC nStartCpu := 0
   STATIC nTotalFrames := 0
   STATIC nCounter := 0
   STATIC aTintClr := {1, 1, 1, 1}
   STATIC aBorderClr := {1, 1, 1, 0.5}
   STATIC cToolTip

   IF nStartCpu == 0
      nStartCpu := hb_secondsCPU()

#pragma __cstream|cToolTip := %s
Harbour is the open/free software implementation
of a cross-platform, multi-threading, object-oriented,
scriptable programming language, backwards compatible
with xBase languages. Harbour consists of a compiler
and runtime libraries with multiple UI, database and
I/O backends, its own build system and a collection
of libraries and bindings for popular APIs. With Harbour,
you can build apps running on GNU/Linux, Windows, macOS,
iOS, Android, *BSD, *nix, and more
#pragma __endtext

   ENDIF

   igSetNextWindowPos( {10,10}, ImGuiCond_Once, {0,0} )
   igSetNextWindowSize( {650, 400}, ImGuiCond_Once )
   igBegin( "Dear imgui drawing Harbour logo", 0, ImGuiWindowFlags_None )

   igText("Texture #1 " + hb_NtoS( s_iTextureHarbour ) )
   igText("Texture #2 " + hb_NtoS( s_iTextureButton ) + " " + hb_valToExp( { s_nWidth, s_nHeight } ) )

   hb_sokol_igImage( s_iTextureHarbour, {64, 64}, {0, 0}, {1, 1}, aTintClr, aBorderClr )
   IF igIsItemHovered( )
      igBeginTooltip()
      igPushTextWrapPos( igGetFontSize() * 35 )
      igTextUnformatted( cToolTip )
      igPopTextWrapPos( cToolTip )
      igEndTooltip()
   ENDIF

   IF hb_sokol_igImageButton( s_iTextureButton, { s_nWidth, s_nHeight }, {0, 0}, {1, 1}, 1, {0, 0, 0, 1}, aTintClr )
      nCounter++
   ENDIF

   IF nCounter > 0
      igBulletText("core meltdown detected, warning level " + hb_NtoS( nCounter ) )
   ENDIF

   igText("Application average " + hb_NtoS( hb_igFps( 1 ) ) + " ms/frame (" + HB_NtoS( hb_igFps() ) + " FPS)")
   igText("CPU usage per frame " + hb_NtoS( ( ( hb_secondsCPU() - nStartCpu ) * 1000 ) / ++nTotalFrames ) + " ms" )

   igEnd()

   RETURN

PROCEDURE ImInit
   LOCAL cButtonBuf, cHarbourBuf

#pragma __binarystreaminclude "harbour-2016-64x64.png"|cHarbourBuf := %s
#pragma __binarystreaminclude "harbour-button.png"|cButtonBuf := %s

   s_iTextureHarbour := hb_sokol_img2TextureRGBA32( cHarbourBuf )
   s_iTextureButton  := hb_sokol_img2TextureRGBA32( cButtonBuf, @s_nWidth, @s_nHeight )

   RETURN
