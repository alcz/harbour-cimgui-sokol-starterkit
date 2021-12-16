/*
    sokol/hbimgwrap.cpp    -- sokol compatible wrappers
                              to Dear imgui texture based
                              functions:
                              hb_sokol_igImage()
                              hb_sokol_igImageButton()
                              hb_sokol_igImageButtonEx()

    license is MIT, see ../LICENSE

    Copyright (c) 2021 Aleksander Czajczynski
*/

#include "sokol_app.h"
#include "sokol_gfx.h"
#include "sokol_time.h"
#include "sokol_glue.h"
#include "hbapi.h"
#include "hbapiitm.h"

#define CIMGUI_DEFINE_ENUMS_AND_STRUCTS
#include "cimgui.h"
#include "sokol_imgui.h"

float _paf( PHB_ITEM p, HB_SIZE nIndex );

/* these wrappers make sokol compatible ImTextureID parameter from hb_parni()
   Comparing hb_sokol_igImage() to plain igImage(), etc. is that those plain
   require pointer argument. ImTextureID is custom structure not defined by
   Dear imgui at all - we call such things Cargo in Harbour codebase */

/* void igImage(ImTextureID user_texture_id,const ImVec2 size,const ImVec2 uv0,const ImVec2 uv1,const ImVec4 tint_col,const ImVec4 border_col) */
HB_FUNC( HB_SOKOL_IGIMAGE )
{
   uintptr_t user_texture_id = ( uintptr_t ) hb_parni( 1 );
   if( user_texture_id )
   {
      PHB_ITEM psize = hb_param( 2, HB_IT_ARRAY );
      const ImVec2 size = ImVec2{ _paf( psize, 1 ), _paf( psize, 2 ) };
      PHB_ITEM puv0 = hb_param( 3, HB_IT_ARRAY );
      const ImVec2 uv0 = ImVec2{ _paf( puv0, 1 ), _paf( puv0, 2 ) };
      PHB_ITEM puv1 = hb_param( 4, HB_IT_ARRAY );
      const ImVec2 uv1 = ImVec2{ _paf( puv1, 1 ), _paf( puv1, 2 ) };
      PHB_ITEM ptint_col = hb_param( 5, HB_IT_ARRAY );
      const ImVec4 tint_col = ImVec4{ _paf( ptint_col, 1 ), _paf( ptint_col, 2 ), _paf( ptint_col, 3 ), _paf( ptint_col, 4 ) };
      PHB_ITEM pborder_col = hb_param( 6, HB_IT_ARRAY );
      const ImVec4 border_col = ImVec4{ _paf( pborder_col, 1 ), _paf( pborder_col, 2 ), _paf( pborder_col, 3 ), _paf( pborder_col, 4 ) };
      igImage( ( ImTextureID ) user_texture_id,size,uv0,uv1,tint_col,border_col );
   }
}

/* bool igImageButton(ImTextureID user_texture_id,const ImVec2 size,const ImVec2 uv0,const ImVec2 uv1,int frame_padding,const ImVec4 bg_col,const ImVec4 tint_col) */
HB_FUNC( HB_SOKOL_IGIMAGEBUTTON )
{
   uintptr_t user_texture_id = ( uintptr_t ) hb_parni( 1 );
   if( user_texture_id )
   {
      PHB_ITEM psize = hb_param( 2, HB_IT_ARRAY );
      const ImVec2 size = ImVec2{ _paf( psize, 1 ), _paf( psize, 2 ) };
      PHB_ITEM puv0 = hb_param( 3, HB_IT_ARRAY );
      const ImVec2 uv0 = ImVec2{ _paf( puv0, 1 ), _paf( puv0, 2 ) };
      PHB_ITEM puv1 = hb_param( 4, HB_IT_ARRAY );
      const ImVec2 uv1 = ImVec2{ _paf( puv1, 1 ), _paf( puv1, 2 ) };
      int frame_padding = hb_parni( 5 );
      PHB_ITEM pbg_col = hb_param( 6, HB_IT_ARRAY );
      const ImVec4 bg_col = ImVec4{ _paf( pbg_col, 1 ), _paf( pbg_col, 2 ), _paf( pbg_col, 3 ), _paf( pbg_col, 4 ) };
      PHB_ITEM ptint_col = hb_param( 7, HB_IT_ARRAY );
      const ImVec4 tint_col = ImVec4{ _paf( ptint_col, 1 ), _paf( ptint_col, 2 ), _paf( ptint_col, 3 ), _paf( ptint_col, 4 ) };
      hb_retl( igImageButton( ( ImTextureID ) user_texture_id,size,uv0,uv1,frame_padding,bg_col,tint_col ) );
   }
   else
      hb_retl( HB_FALSE );
}

/* bool igImageButtonEx(ImGuiID id,ImTextureID texture_id,const ImVec2 size,const ImVec2 uv0,const ImVec2 uv1,const ImVec2 padding,const ImVec4 bg_col,const ImVec4 tint_col) */
HB_FUNC( HB_SOKOL_IGIMAGEBUTTONEX )
{
   ImGuiID id = ( ImGuiID ) hb_parni( 1 );
   uintptr_t texture_id = ( uintptr_t ) hb_parni( 2 );
   if( id && texture_id )
   {
      PHB_ITEM psize = hb_param( 3, HB_IT_ARRAY );
      const ImVec2 size = ImVec2{ _paf( psize, 1 ), _paf( psize, 2 ) };
      PHB_ITEM puv0 = hb_param( 4, HB_IT_ARRAY );
      const ImVec2 uv0 = ImVec2{ _paf( puv0, 1 ), _paf( puv0, 2 ) };
      PHB_ITEM puv1 = hb_param( 5, HB_IT_ARRAY );
      const ImVec2 uv1 = ImVec2{ _paf( puv1, 1 ), _paf( puv1, 2 ) };
      PHB_ITEM ppadding = hb_param( 6, HB_IT_ARRAY );
      const ImVec2 padding = ImVec2{ _paf( ppadding, 1 ), _paf( ppadding, 2 ) };
      PHB_ITEM pbg_col = hb_param( 7, HB_IT_ARRAY );
      const ImVec4 bg_col = ImVec4{ _paf( pbg_col, 1 ), _paf( pbg_col, 2 ), _paf( pbg_col, 3 ), _paf( pbg_col, 4 ) };
      PHB_ITEM ptint_col = hb_param( 8, HB_IT_ARRAY );
      const ImVec4 tint_col = ImVec4{ _paf( ptint_col, 1 ), _paf( ptint_col, 2 ), _paf( ptint_col, 3 ), _paf( ptint_col, 4 ) };
      hb_retl( igImageButtonEx( id, ( ImTextureID ) texture_id,size,uv0,uv1,padding,bg_col,tint_col ) );
   }
   else
      hb_retl( HB_FALSE );
}
