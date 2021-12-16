/*
    sokol/hbimg.c      -- support functions exposed to Harbour

                          hb_sokol_img2TextureRGBA32()
                          - generate textures from image files

    license is MIT, see ../LICENSE

    Copyright (c) 2021 Aleksander Czajczynski
*/

#include "sokol_app.h"
#include "sokol_gfx.h"
#include "sokol_time.h"
#include "sokol_glue.h"
#include "stb/stb_image.h"
#include "hbapi.h"
#include "hbapiitm.h"

/*
#define CIMGUI_DEFINE_ENUMS_AND_STRUCTS
#include "cimgui.h"
#include "sokol_imgui.h"
*/

HB_FUNC( HB_SOKOL_IMG2TEXTURERGBA32 )
{
   int iSize = ( int ) hb_parclen( 1 );
   stbi_uc * pBuf = ( stbi_uc * ) hb_parc( 1 );

   /* again based on sokol-samples, thanks Andre Weissflog */

   if( iSize && pBuf )
   {
      int width, height, num_channels;
      const int desired_channels = 4;

      stbi_uc* pixels = stbi_load_from_memory(
            pBuf,
            iSize,
            &width, &height,
            &num_channels, desired_channels);

      if( pixels )
      {
         sg_image img =
            sg_make_image( &(sg_image_desc){
               .width = width,
               .height = height,
               .pixel_format = SG_PIXELFORMAT_RGBA8,
               .min_filter = SG_FILTER_LINEAR,
               .mag_filter = SG_FILTER_LINEAR,
               .data.subimage[0][0] = {
                  .ptr = pixels,
                  .size = ( size_t )( width * height * 4 ),
               }
         });
         stbi_image_free( pixels );

         if( HB_ISBYREF( 2 ) )
            hb_itemPutNI( hb_param( 2, HB_IT_ANY ), width );
         if( HB_ISBYREF( 3 ) )
            hb_itemPutNI( hb_param( 3, HB_IT_ANY ), height );

         hb_retni( ( int ) img.id );
      }
   }
}

/* TODO: check if those resources can be safely garbage collected:
         Object or GC'ed variable may fall out of scope before
         things are drawn. Better idea may be to create a list
         of textures to destroy after drawing, rather than calling
         sg_destroy_image() right away */

HB_FUNC( HB_SOKOL_IMGDESTROY )
{
   int i = hb_parni( 1 );

   if( i )
   {
      sg_image img = { i };
      sg_destroy_image( img );
   }
}
