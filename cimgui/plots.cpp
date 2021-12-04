/*
    cimgui/plots.cpp   -- hand-(re)written plotting wrappers

    license is MIT, see ../LICENSE

    Copyright (c) 2021 Aleksander Czajczynski
*/

#include "hbapi.h"

#include "./imgui/imgui.h"
#include "./imgui/imgui_internal.h"
#include "cimgui.h"

#include "hbimgui.h"

/* void igPlotLinesFloatPtr(const char* label,const float* values,int values_count,int values_offset,const char* overlay_text,float scale_min,float scale_max,ImVec2 graph_size,int stride) */
HB_FUNC( HB_IGPLOTLINESFLOAT )
{
   const char* label = hb_parcx( 1 );
   PHB_IG_FLOATS pFloats = hb_ig_floats_par( 2 );
   const float* values = ( pFloats ? pFloats->pBuf : NULL );
   int values_count = hb_parni( 3 );
   int values_offset = hb_parni( 4 );
   const char* overlay_text = hb_parcx( 5 );
   float scale_min = ( float ) hb_parnd( 6 );
   float scale_max = ( float ) hb_parnd( 7 );
   PHB_ITEM pgraph_size = hb_param( 8, HB_IT_ARRAY );
   ImVec2 graph_size = ImVec2{ _paf( pgraph_size, 1 ), _paf( pgraph_size, 2 ) };
   int stride = sizeof( float ); /* hb_parnidef( 9, sizeof( float ) ); */
   if( scale_min == 0.00 && scale_max == 0.00 )
      scale_min = scale_max = FLT_MAX;  /* avoid casting FLT_MAX from double(?) */
   if( ! values_count || ( HB_SIZE ) values_count > pFloats->nSize )
      values_count = pFloats->nSize;
   igPlotLinesFloatPtr(label,values,values_count,values_offset,overlay_text,scale_min,scale_max,graph_size,stride);
}

/* void igPlotHistogramFloatPtr(const char* label,const float* values,int values_count,int values_offset,const char* overlay_text,float scale_min,float scale_max,ImVec2 graph_size,int stride) */
HB_FUNC( HB_IGPLOTHISTOGRAMFLOAT )
{
   const char* label = hb_parcx( 1 );
   PHB_IG_FLOATS pFloats = hb_ig_floats_par( 2 );
   const float* values = ( pFloats ? pFloats->pBuf : NULL );
   int values_count = hb_parni( 3 );
   int values_offset = hb_parni( 4 );
   const char* overlay_text = hb_parcx( 5 );
   float scale_min = ( float ) hb_parnd( 6 );
   float scale_max = ( float ) hb_parnd( 7 );
   PHB_ITEM pgraph_size = hb_param( 8, HB_IT_ARRAY );
   ImVec2 graph_size = ImVec2{ _paf( pgraph_size, 1 ), _paf( pgraph_size, 2 ) };
   int stride = sizeof( float ); /* hb_parnidef( 9, sizeof( float ) ); */
   if( scale_min == 0.00 && scale_max == 0.00 )
      scale_min = scale_max = FLT_MAX; /* avoid casting FLT_MAX from double(?) */
   if( ! values_count || ( HB_SIZE ) values_count > pFloats->nSize )
      values_count = pFloats->nSize;
   igPlotHistogramFloatPtr(label,values,values_count,values_offset,overlay_text,scale_min,scale_max,graph_size,stride);
}
