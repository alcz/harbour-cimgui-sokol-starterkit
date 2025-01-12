/*
    line.prg   -- ImPlot's and Harbour first example

    license is MIT, see ../LICENSE
*/

#include "hbimenum.ch"
#include "hbimplot.ch"

REQUEST HB_CODEPAGE_UTF8EX

PROCEDURE MAIN

   hb_cdpSelect("UTF8EX")

   sapp_run_default( "Plotting with ImPlot", 800, 600 )

#ifdef __PLATFORM__WASM
   IF ImFrame() # NIL /* dummy calls for emscripten, to be removed when those functions are properly requested from .c code */
      ImInit()
   ENDIF
#endif
   RETURN

PROCEDURE ImFrame
   STATIC pPlotX, pPlotY
   STATIC nSec, n
   STATIC nStartCpu := 0
   STATIC nTotalFrames := 0

   IF nStartCpu == 0
      nStartCpu := hb_secondsCPU()
   ENDIF

   igSetNextWindowPos( {10,10}, ImGuiCond_Once, {0,0} )
   igSetNextWindowSize( {650, 400}, ImGuiCond_Once )
   igBegin( "Hello Dear ImGui plots!", NIL, ImGuiWindowFlags_None )

   IF pPlotX == NIL
      pPlotX := hb_igFloats( { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 } )
      pPlotY := hb_igFloats( { 1, 2, 3, 4, 5, 5, 4, 3, 2, 1  } )
   ENDIF

   IF ImPlot_BeginPlot( "Line Plot", "x", "y" )
      ImPlot_SetNextMarkerStyle( ImPlotMarker_Circle )
      hb_imPlotLineFloat2( "test", pPlotX, pPlotY )
      ImPlot_EndPlot()
   ENDIF

   igText("Application average " + HB_NtoS( hb_igFps( 1 ) ) + " ms/frame (" + HB_NtoS( hb_igFps() ) + " FPS)")
   igText("CPU usage per frame " + HB_NtoS( ( ( hb_secondsCPU() - nStartCpu ) * 1000 ) / ++nTotalFrames ) + " ms" )

   igEnd()

   RETURN

PROCEDURE ImInit

   /* creating ImPlot context is neccesary */

   ImPlot_CreateContext()

   /*
      also multiple contexts can be created:

      p := ImPlot_CreateContext()
      ImPlot_SetCurrentContext( p )
   */

   RETURN
