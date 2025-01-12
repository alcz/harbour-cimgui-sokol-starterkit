/*
    plotfloat.prg    -- Basic Dear ImGui's plotting

    license is MIT, see ../LICENSE
*/

#include "hbimenum.ch"

REQUEST HB_CODEPAGE_UTF8EX

PROCEDURE MAIN

   hb_cdpSelect("UTF8EX")

   sapp_run_default( "Plotting", 800, 600 )

#ifdef __PLATFORM__WASM
   ImFrame() /* dummy call for emscripten, to be removed when those functions are properly requested from .c code */
#endif
   RETURN

PROCEDURE ImFrame
   STATIC pPlot, pPlot2, pPlot3
   STATIC nSec, n
   STATIC nStartCpu := 0
   STATIC nTotalFrames := 0

   IF nStartCpu == 0
      nStartCpu := hb_secondsCPU()
   ENDIF

   igSetNextWindowPos( {10,10}, ImGuiCond_Once, {0,0} )
   igSetNextWindowSize( {650, 400}, ImGuiCond_Once )
   igBegin( "Hello Dear ImGui plots!", 0, ImGuiWindowFlags_None )

   IF pPlot == NIL
      pPlot  := hb_igFloats( { 1.0, 1.5, 5, 2, 10 } )
      pPlot2 := hb_igFloats( Array( 100 ) )
      pPlot3 := hb_igFloats(, 100 ) /* cursor will be at 0 */
      nSec   := Seconds()
   ELSEIF Seconds() - nSec > 0.1
      n := hb_Random( 1, 10 )
      hb_igFloatsPush( pPlot2, n )
      hb_igFloatsPush( pPlot3, n, .T. /* use cursor */ )
      nSec := Seconds()
   ENDIF

   igDragFloat4("drag me", pPlot,, 1, 10, "%.1f" )

   hb_igPlotLinesFloat( "hello plot", pPlot )

   hb_igPlotHistogramFloat( "histogram", pPlot,,,,,, {,50} )

   hb_igPlotLinesFloat( "random", pPlot2,,,,,, {,100} )

   hb_igPlotLinesFloat( "cursor", pPlot3,,,,,, {,100} )

   igText("Application average " + HB_NtoS( hb_igFps( 1 ) ) + " ms/frame (" + HB_NtoS( hb_igFps() ) + " FPS)")
   igText("CPU usage per frame " + HB_NtoS( ( ( hb_secondsCPU() - nStartCpu ) * 1000 ) / ++nTotalFrames ) + " ms" )

   igEnd()

   RETURN
