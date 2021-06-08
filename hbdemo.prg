/*
    hbdemo.prg    -- test build displaying few widgets from .prg code
                     picking up some data using static variables passed as reference
                     and updating them

    license is MIT, see ./LICENSE
*/

#include "hbimenum.ch"

PROCEDURE Main
   sapp_run( )
   RETURN

PROCEDURE ImFrame
   STATIC counter := 0
   STATIC s := 0.0
   STATIC c, c2, c3, nBuf

   igSetNextWindowPos( {10,10}, ImGuiCond_Once, {0,0} )
   igSetNextWindowSize( {650, 350}, ImGuiCond_Once )
   igBegin( "Hello Dear ImGui!", 0, ImGuiWindowFlags_None )

   IF igButton( "dupa.8" )
      counter++
   ENDIF

   igSameLine( 0.0, -1.0 )
   igText( "counter " + hb_NtoS( counter ) )

   igSliderFloat( "float", @s, 0.0, 1.0, "%.2f", 0 )
   igText( "slider updates Harbour variable -> " + hb_NtoS( s ) )

   IF c == NIL
      c := c2 := c3 := ""
      nBuf := 0
   ENDIF

   igText("Application average " + HB_NtoS( hb_igFps( 1 ) ) + " ms/frame (" + HB_NtoS( hb_igFps() ) + " FPS)")

   igInputTextWithHint("input text (w/ hint)", "enter text here", @c, 200 )
   igText("UPPER() by Harbour -> " + Upper( c ) )
   igInputText("two chars", @c2, 2 )
   igInputText("unlimited text len", @c3, @nBuf, ImGuiInputTextFlags_CallbackResize )
   igText( "buffer len " + hb_NtoS( nBuf ) )
   igInputTextMultiline("##the same", @c3, @nBuf, { 450, 100 }, ImGuiInputTextFlags_CallbackResize )

   igEnd()

   RETURN

#pragma BEGINDUMP 

#include "sokol_app.h"
#include "sokol_gfx.h"
#include "sokol_time.h"
#include "sokol_glue.h"
#define CIMGUI_DEFINE_ENUMS_AND_STRUCTS
#include "cimgui.h"
#include "sokol_imgui.h"
#include "hbapi.h"
#include "hbvm.h"

static struct {
    uint64_t laptime;
    sg_pass_action pass_action;
} state;

static void init(void) {
    sg_setup(&(sg_desc){
        .context = sapp_sgcontext()
    });
    stm_setup();
    simgui_setup(&(simgui_desc_t){ 0 });

    // initial clear color
    state.pass_action = (sg_pass_action) {
        .colors[0] = { .action = SG_ACTION_CLEAR, .value = { 0.0f, 0.5f, 1.0f, 1.0 } }
    };
}

static void frame(void) {
    static PHB_DYNS pDynSym = NULL;
    ImGuiIO *io = igGetIO();
    const int width = sapp_width();
    const int height = sapp_height();
    const double delta_time = stm_sec(stm_round_to_common_refresh_rate(stm_laptime(&state.laptime)));
    simgui_new_frame(width, height, delta_time);

    if( ! pDynSym )
       pDynSym = hb_dynsymFindName( "IMFRAME" );

    /*=== UI CODE STARTS HERE === */

    /* if you like, you may create widgets mixing .c and .prg code - see the color picker at the bottom
    igSetNextWindowPos((ImVec2){10,10}, ImGuiCond_Once, (ImVec2){0,0});
    igSetNextWindowSize((ImVec2){400, 200}, ImGuiCond_Once);
    igBegin("Hello Dear ImGui!", 0, ImGuiWindowFlags_None);
    */

    if( pDynSym )
    {
       hb_vmPushDynSym( pDynSym );
       hb_vmPushNil();
       hb_vmProc( 0 );
    }

    igSetNextWindowPos((ImVec2){10,450}, ImGuiCond_Once, (ImVec2){0,0});
    igBegin("Added from .c", 0, ImGuiWindowFlags_None);
    igColorEdit3("Background", &state.pass_action.colors[0].value.r, ImGuiColorEditFlags_None);
    igText("Application average %.3f ms/frame (%.1f FPS)", 1000.0f / io->Framerate, io->Framerate);
    igEnd();

    /*=== UI CODE ENDS HERE ===*/

    sg_begin_default_pass(&state.pass_action, width, height);
    simgui_render();
    sg_end_pass();
    sg_commit();
}

static void cleanup(void) {
    simgui_shutdown();
    sg_shutdown();
}

static void event(const sapp_event* ev) {
    simgui_handle_event(ev);
}

sapp_desc hb_sokol_main() {
    return (sapp_desc){
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = event,
        .window_title = "Hello Sokol + Dear ImGui + Harbour",
        .width = 800,
        .height = 600,
    };
}

HB_FUNC( SAPP_RUN )
{ 
   sapp_desc s = hb_sokol_main();
   sapp_run( &s );
}
