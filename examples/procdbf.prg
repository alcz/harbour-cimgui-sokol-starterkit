#include "hbimenum.ch"
#include "hbthread.ch"

REQUEST HB_CODEPAGE_UTF8EX

PROCEDURE MAIN

   hb_cdpSelect("UTF8EX")

   IF ! hb_mtvm()
      Alert("please build with hbmk2 -mt")
      QUIT
   ENDIF

   hb_sokol_imguiNoDefaultFont( .T. )
   sapp_run_default( "Data processing", 800, 600 )

#ifdef __PLATFORM__WEB
   IF ImFrame() # NIL /* dummy calls for emscripten, to be removed when those functions are properly requested from .c code */
      ImInit()
   ENDIF
#endif
   RETURN

PROCEDURE ImInit
   LOCAL cFontBuf
#pragma __binarystreaminclude "OpenSans-Regular.ttf"|cFontBuf := %s
   hb_igAddFontFromMemoryTTF( cFontBuf, 18.0, ,{} , .T., .F. )

   hb_sokol_imguiFont2Texture()
   RETURN

PROCEDURE ImFrame
   igSetNextWindowPos( {10,10}, ImGuiCond_Once, {0,0} )
   igSetNextWindowSize( {650, 350}, ImGuiCond_Once )

   igBegin( "Listing", 0, ImGuiWindowFlags_None )

   GoingOn()

   igEnd()

   RETURN

STATIC FUNCTION GoingOn()
   STATIC lHaveJob := .F., nProgress, nProgText, lTurbo := .F.

   STATIC cFirst, cLast, cZip
   STATIC pPlotAge

   IF ! lHaveJob
      igText("nothing to do")
      IF igButton("do something")
         lHaveJob := .T.
         Act( { ||
            USE test
            pPlotAge := hb_igFloats(, RecCount() )
            DO WHILE ! EoF()
               nProgText := HB_NtoS( RecNo() ) + "/" + HB_NtoS( RecCount() )
               nProgress := RecNo() / RecCount()
               hb_igFloatsPush( pPlotAge, TEST->AGE, .T. )
               /* pretend our database is two oceans away */
               hb_idleSleep( 0.1 / IIF( lTurbo, 10, 1 ) )
               cFirst := RTrim( TEST->FIRST )
               cLast  := RTrim( TEST->LAST )
               cZip   := RTrim( TEST->ZIP )
               DBSkip()
            ENDDO
            CLOSE
            lHaveJob := .F.
         } )
      ENDIF
   ELSE
      igText("doing something heavy")
      igCheckBox("turbo mode", @lTurbo)
      igProgressBar( nProgress,, nProgText )
   ENDIF

   IF ! Empty( cZip )
      /* built-in labels are on the right */
      igInputText( "Name",  @cFirst )
      igInputText( "First", @cLast )
      igInputText( "Code",  @cZip )
      IF ! lHaveJob
         IF igButton("i'm done")
            cZip := NIL
            pPlotAge := NIL
         ENDIF
      ENDIF
   ENDIF

   IF pPlotAge # NIL
      hb_igPlotLinesFloat( "age scale", pPlotAge,,,,,, {,100} )
   ENDIF

   RETURN

STATIC PROCEDURE Act( b, ... )
   hb_threadDetach( hb_threadStart( HB_THREAD_INHERIT_PUBLIC, b, ... ) )
   RETURN
