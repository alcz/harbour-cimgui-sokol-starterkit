/*
    sokol/hbsokol.c    -- default application structure, used by examples/

    license is MIT, see ../LICENSE

    Copyright (c) 2021-2025 Aleksander Czajczynski
*/


#include "sokol_app.h"
#include "sokol_gfx.h"
#include "sokol_time.h"
#include "sokol_glue.h"
#define CIMGUI_DEFINE_ENUMS_AND_STRUCTS
#include "cimgui.h"
#include "sokol_imgui.h"
#include "hbapi.h"
#include "hbvm.h"

static HB_BOOL s_bNoDefaultFont = HB_FALSE;

static struct {
    uint64_t laptime;
    sg_pass_action pass_action;
} state;

static void init(void) {
    PHB_DYNS pDynSym = NULL;

    sg_setup(&(sg_desc){
        .context = sapp_sgcontext()
    });
    stm_setup();
    simgui_setup(&(simgui_desc_t){ .no_default_font = s_bNoDefaultFont });

    if( ( pDynSym = hb_dynsymFindName( "IMINIT" ) ) )
    {
       hb_vmPushDynSym( pDynSym );
       hb_vmPushNil();
       hb_vmProc( 0 );
    }

    // initial clear color
    state.pass_action = (sg_pass_action) {
        .colors[0] = { .action = SG_ACTION_CLEAR, .value = { 0.0f, 0.5f, 1.0f, 1.0 } }
    };
}

static void frame(void) {
    static PHB_DYNS pDynSym = NULL;
    const int width = sapp_width();
    const int height = sapp_height();

    simgui_new_frame(&(simgui_frame_desc_t){
        .width = width,
        .height = height,
        .delta_time = sapp_frame_duration(),
        .dpi_scale = sapp_dpi_scale()
    });

    if( ! pDynSym )
       pDynSym = hb_dynsymFindName( "IMFRAME" );

    /*=== UI CODE STARTS HERE === */

    if( pDynSym )
    {
       hb_vmPushDynSym( pDynSym );
       hb_vmPushNil();
       hb_vmProc( 0 );
    }

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
    if( ev->type == SAPP_EVENTTYPE_QUIT_REQUESTED )
    {
       PHB_DYNS pDynSym = NULL;
       if( ( pDynSym = hb_dynsymFindName( "IMQUIT" ) ) )
       {
          hb_vmPushDynSym( pDynSym );
          hb_vmPushNil();
          hb_vmProc( 0 );
       }
    }
    simgui_handle_event(ev);
}

static sapp_desc hb_sokol_main( const char * pszCaption, int width, int height, HB_BOOL bClipboard, HB_BOOL bHiDPI ) {
    return (sapp_desc){
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = event,
        .window_title = pszCaption,
        .width = width,
        .height = height,
        .high_dpi = bHiDPI,
        .enable_clipboard = bClipboard
    };
}

HB_FUNC( HB_SOKOL_IMGUINODEFAULTFONT )
{ 
   HB_BOOL bRet = s_bNoDefaultFont;

   s_bNoDefaultFont = hb_parl( 1 );
   hb_retl( bRet );
}

HB_FUNC( HB_SOKOL_HWND )
{
   hb_retptr( HB_UNCONST( sapp_win32_get_hwnd() ) );
}

HB_FUNC( SAPP_QUIT )
{
   sapp_quit();
}

HB_FUNC( SAPP_REQUEST_QUIT )
{
   sapp_request_quit();
}

HB_FUNC( SAPP_CANCEL_QUIT )
{
   sapp_cancel_quit();
}

HB_FUNC( SAPP_DPI_SCALE )
{
   hb_retnd( sapp_dpi_scale() );
}

HB_FUNC( SAPP_RUN_DEFAULT )
{ 
   sapp_desc s = hb_sokol_main( hb_parcx( 1 ), hb_parnidef( 2, 800 ), hb_parnidef( 3, 600 ), hb_parldef( 4, HB_TRUE ), hb_parldef( 5, HB_FALSE ) );
   sapp_run( &s );
}
