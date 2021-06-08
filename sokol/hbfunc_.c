/*
    sokol/hbfunc_.c    -- support functions exposed to Harbour

                          hb_sokol_imguiFont2Texture()
                          - generate font textures inside sokol lib structures
                            after adding font to Dear imgui FontAtlas

    license is MIT, see ../LICENSE

    Copyright (c) 2021 Aleksander Czajczynski
*/


#include "sokol_app.h"
#include "sokol_gfx.h"
#include "sokol_time.h"
#include "sokol_glue.h"
#define CIMGUI_DEFINE_ENUMS_AND_STRUCTS
#include "cimgui.h"
#include "sokol_imgui.h"
#include "hbapi.h"

HB_FUNC( HB_SOKOL_IMGUIFONT2TEXTURE )
{
   ImGuiIO    *io = igGetIO();
   unsigned char* font_pixels; 
   int font_width, font_height; 
   int bytes_per_pixel;

   /* create font texture for the custom font */

   ImFontAtlas_GetTexDataAsRGBA32( io->Fonts, &font_pixels, &font_width, &font_height, &bytes_per_pixel );
   sg_image_desc img_desc = { }; 
   img_desc.width = font_width; 
   img_desc.height = font_height; 
   img_desc.pixel_format = SG_PIXELFORMAT_RGBA8; 
   img_desc.wrap_u = SG_WRAP_CLAMP_TO_EDGE; 
   img_desc.wrap_v = SG_WRAP_CLAMP_TO_EDGE; 
   img_desc.min_filter = SG_FILTER_LINEAR; 
   img_desc.mag_filter = SG_FILTER_LINEAR; 
   img_desc.data.subimage[0][0].ptr = font_pixels; 
   img_desc.data.subimage[0][0].size = font_width * font_height * 4; 
   io->Fonts->TexID = ( ImTextureID )( uintptr_t ) sg_make_image( &img_desc ).id; 
}
