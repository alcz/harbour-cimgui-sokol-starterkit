/*
    cdemo.prg    -- C test build entering via Harbour MAIN procedure
                    building using hbmk2 instead of CMake

    license is MIT, see ./LICENSE
*/

PROCEDURE Main
   sapp_run()
   RETURN

#pragma BEGINDUMP

#include "hbapi.h"
#include "sokol_app.h"
#include "sokol_glue.h"

sapp_desc hb_sokol_main();

HB_FUNC( SAPP_RUN )
{
   sapp_desc s = hb_sokol_main();
   sapp_run( &s );
}
