/*
    cimplot/implots.cpp   -- hand-(re)written plotting wrappers
                             fifty-fifty job, templates of the
                             functions were made by the generator.prg
                             but parameter handling was altered.


    license is MIT, see ../LICENSE

    Copyright (c) 2021 Aleksander Czajczynski
*/

#include "hbapi.h"
#include "hbapiitm.h"

#include "implot/implot.h"
#include "implot/implot_internal.h"
#include "cimplot.h"

#include "hbimgui.h"

static double _pad( PHB_ITEM p, HB_SIZE nIndex )
{
   if( p && nIndex > 0 && nIndex <= hb_arrayLen( p ) )
      return hb_arrayGetND( p, nIndex );

   return ( double ) 0.0;
}

/* void ImPlot_CalculateBins_FloatPtr(const float* values,int count,ImPlotBin meth,const ImPlotRange range,int* bins_out,double* width_out) */
HB_FUNC( HB_IMPLOTCALCULATEBINSFLOAT )
{
   PHB_IG_FLOATS pFloats = hb_ig_floats_par( 1 );
   const float* values = ( pFloats ? pFloats->pBuf : NULL );
   int count = hb_parni( 2 );
   ImPlotBin meth = ( ImPlotBin ) hb_parni( 3 );
   const ImPlotRange range;
   int /* @ */ _bins_out = hb_parni( 5 );
   int * bins_out = &_bins_out;
   double /* @ */ _width_out = hb_parnd( 6 );
   double * width_out = &_width_out;
   ImPlot_CalculateBins_FloatPtr(values,count,meth,range,bins_out,width_out);
   hb_itemPutNI( hb_paramError( 5 ), _bins_out );
   hb_itemPutND( hb_paramError( 6 ), _width_out );
}

/* float ImPlot_ImMaxArray_FloatPtr(const float* values,int count) */
HB_FUNC( HB_IMPLOTIMMAXARRAYFLOAT )
{
   PHB_IG_FLOATS pFloats = hb_ig_floats_par( 1 );
   const float* values = ( pFloats ? pFloats->pBuf : NULL );
   int count = hb_parni( 2 );
   if( ! count || ( HB_SIZE ) count > pFloats->nSize )
      count = pFloats->nSize;
   float ret = ImPlot_ImMaxArray_FloatPtr(values,count);
   hb_retnd( ( double ) ret );
}

/* double ImPlot_ImMean_FloatPtr(const float* values,int count) */
HB_FUNC( HB_IMPLOTIMMEANFLOAT )
{
   PHB_IG_FLOATS pFloats = hb_ig_floats_par( 1 );
   const float* values = ( pFloats ? pFloats->pBuf : NULL );
   int count = hb_parni( 2 );
   if( ! count || ( HB_SIZE ) count > pFloats->nSize )
      count = pFloats->nSize;
   double ret = ImPlot_ImMean_FloatPtr(values,count);
   hb_retnd( ret );
}

/* float ImPlot_ImMinArray_FloatPtr(const float* values,int count) */
HB_FUNC( HB_IMPLOTIMMINARRAYFLOAT )
{
   PHB_IG_FLOATS pFloats = hb_ig_floats_par( 1 );
   const float* values = ( pFloats ? pFloats->pBuf : NULL );
   int count = hb_parni( 2 );
   if( ! count || ( HB_SIZE ) count > pFloats->nSize )
      count = pFloats->nSize;
   float ret = ImPlot_ImMinArray_FloatPtr(values,count);
   hb_retnd( ( double ) ret );
}

HB_FUNC( HB_IMPLOTIMMINMAXARRAYFLOAT )
{
   PHB_IG_FLOATS pFloats = hb_ig_floats_par( 1 );
   const float* values = ( pFloats ? pFloats->pBuf : NULL );
   int count = hb_parni( 2 );
   float /* @ */ _min_out = ( float ) hb_parnd( 3 );
   float * min_out = &_min_out;
   float /* @ */ _max_out = ( float ) hb_parnd( 4 );
   float * max_out = &_max_out;
   if( ! count || ( HB_SIZE ) count > pFloats->nSize )
      count = pFloats->nSize;
   ImPlot_ImMinMaxArray_FloatPtr(values,count,min_out,max_out);
   hb_itemPutND( hb_paramError( 3 ), ( double ) _min_out );
   hb_itemPutND( hb_paramError( 4 ), ( double ) _max_out );
}

/* double ImPlot_ImStdDev_FloatPtr(const float* values,int count) */
HB_FUNC( HB_IMPLOTIMSTDDEVFLOAT )
{
   PHB_IG_FLOATS pFloats = hb_ig_floats_par( 1 );
   const float* values = ( pFloats ? pFloats->pBuf : NULL );
   int count = hb_parni( 2 );
   if( ! count || ( HB_SIZE ) count > pFloats->nSize )
      count = pFloats->nSize;
   double ret = ImPlot_ImStdDev_FloatPtr(values,count);
   hb_retnd( ret );
}

/* float ImPlot_ImSum_FloatPtr(const float* values,int count) */
HB_FUNC( HB_IMPLOTIMSUMFLOAT )
{
   PHB_IG_FLOATS pFloats = hb_ig_floats_par( 1 );
   const float* values = ( pFloats ? pFloats->pBuf : NULL );
   int count = hb_parni( 2 );
   if( ! count || ( HB_SIZE ) count > pFloats->nSize )
      count = pFloats->nSize;
   float ret = ImPlot_ImSum_FloatPtr(values,count);
   hb_retnd( ( double ) ret );
}

/* void ImPlot_PlotBars_FloatPtrInt(const char* label_id,const float* values,int count,double width,double shift,int offset,int stride) */
HB_FUNC( HB_IMPLOTBARSFLOAT )
{
   const char* label_id = hb_parcx( 1 );
   PHB_IG_FLOATS pFloats = hb_ig_floats_par( 2 );
   const float* values = ( pFloats ? pFloats->pBuf : NULL );
   int count = hb_parni( 3 );
   double width = hb_parnd( 4 );
   double shift = hb_parnd( 5 );
   int offset = hb_parni( 6 );
   int stride = sizeof( float );
   if( ! count || ( HB_SIZE ) count > pFloats->nSize )
      count = pFloats->nSize;
   ImPlot_PlotBars_FloatPtrInt(label_id,values,count,width,shift,offset,stride);
}

/* void ImPlot_PlotBars_FloatPtrFloatPtr(const char* label_id,const float* xs,const float* ys,int count,double width,int offset,int stride) */
HB_FUNC( HB_IMPLOTBARSFLOAT2 )
{
   const char* label_id = hb_parcx( 1 );
   PHB_IG_FLOATS pFloatsx = hb_ig_floats_par( 2 );
   const float* xs = ( pFloatsx ? pFloatsx->pBuf : NULL );
   PHB_IG_FLOATS pFloatsy = hb_ig_floats_par( 3 );
   const float* ys = ( pFloatsy ? pFloatsy->pBuf : NULL );
   int count = hb_parni( 4 );
   double width = hb_parnd( 5 );
   int offset = hb_parni( 6 );
   int stride = sizeof( float );
   if( ! count || ( HB_SIZE ) count > pFloatsx->nSize )
      count = pFloatsx->nSize;
   if( ( HB_SIZE ) count > pFloatsy->nSize )
      count = pFloatsy->nSize;
   ImPlot_PlotBars_FloatPtrFloatPtr(label_id,xs,ys,count,width,offset,stride);
}

/* void ImPlot_PlotBarsH_FloatPtrInt(const char* label_id,const float* values,int count,double height,double shift,int offset,int stride) */
HB_FUNC( HB_IMPLOTBARSHFLOAT )
{
   const char* label_id = hb_parcx( 1 );
   PHB_IG_FLOATS pFloats = hb_ig_floats_par( 2 );
   const float* values = ( pFloats ? pFloats->pBuf : NULL );
   int count = hb_parni( 3 );
   double height = hb_parnd( 4 );
   double shift = hb_parnd( 5 );
   int offset = hb_parni( 6 );
   int stride = sizeof( float );
   if( ! count || ( HB_SIZE ) count > pFloats->nSize )
      count = pFloats->nSize;
   ImPlot_PlotBarsH_FloatPtrInt(label_id,values,count,height,shift,offset,stride);
}

/* void ImPlot_PlotBarsH_FloatPtrFloatPtr(const char* label_id,const float* xs,const float* ys,int count,double height,int offset,int stride) */
HB_FUNC( HB_IMPLOTBARSHFLOAT2 )
{
   const char* label_id = hb_parcx( 1 );
   PHB_IG_FLOATS pFloatsx = hb_ig_floats_par( 2 );
   const float* xs = ( pFloatsx ? pFloatsx->pBuf : NULL );
   PHB_IG_FLOATS pFloatsy = hb_ig_floats_par( 3 );
   const float* ys = ( pFloatsy ? pFloatsy->pBuf : NULL );
   int count = hb_parni( 4 );
   double height = hb_parnd( 5 );
   int offset = hb_parni( 6 );
   int stride = sizeof( float );
   if( ! count || ( HB_SIZE ) count > pFloatsx->nSize )
      count = pFloatsx->nSize;
   if( ( HB_SIZE ) count > pFloatsy->nSize )
      count = pFloatsy->nSize;
   ImPlot_PlotBarsH_FloatPtrFloatPtr(label_id,xs,ys,count,height,offset,stride);
}

/* void ImPlot_PlotDigital_FloatPtr(const char* label_id,const float* xs,const float* ys,int count,int offset,int stride) */
HB_FUNC( HB_IMPLOTDIGITALFLOAT )
{
   const char* label_id = hb_parcx( 1 );
   PHB_IG_FLOATS pFloatsx = hb_ig_floats_par( 2 );
   const float* xs = ( pFloatsx ? pFloatsx->pBuf : NULL );
   PHB_IG_FLOATS pFloatsy = hb_ig_floats_par( 3 );
   const float* ys = ( pFloatsy ? pFloatsy->pBuf : NULL );
   int count = hb_parni( 4 );
   int offset = hb_parni( 5 );
   int stride = sizeof( float );
   if( ! count || ( HB_SIZE ) count > pFloatsx->nSize )
      count = pFloatsx->nSize;
   if( ( HB_SIZE ) count > pFloatsy->nSize )
      count = pFloatsy->nSize;
   ImPlot_PlotDigital_FloatPtr(label_id,xs,ys,count,offset,stride);
}

/* void ImPlot_PlotErrorBars_FloatPtrFloatPtrFloatPtrInt(const char* label_id,const float* xs,const float* ys,const float* err,int count,int offset,int stride) */
HB_FUNC( HB_IMPLOTERRORBARSFLOAT3 )
{
   const char* label_id = hb_parcx( 1 );
   PHB_IG_FLOATS pFloatsx = hb_ig_floats_par( 2 );
   const float* xs = ( pFloatsx ? pFloatsx->pBuf : NULL );
   PHB_IG_FLOATS pFloatsy = hb_ig_floats_par( 3 );
   const float* ys = ( pFloatsy ? pFloatsy->pBuf : NULL );
   PHB_IG_FLOATS pFloatse = hb_ig_floats_par( 4 );
   const float* err = ( pFloatse ? pFloatse->pBuf : NULL );
   int count = hb_parni( 5 );
   int offset = hb_parni( 6 );
   int stride = sizeof( float );
   if( ! count || ( HB_SIZE ) count > pFloatsx->nSize )
      count = pFloatsx->nSize;
   if( ( HB_SIZE ) count > pFloatsy->nSize )
      count = pFloatsy->nSize;
   if( ( HB_SIZE ) count > pFloatse->nSize )
      count = pFloatse->nSize;
   ImPlot_PlotErrorBars_FloatPtrFloatPtrFloatPtrInt(label_id,xs,ys,err,count,offset,stride);
}

/* void ImPlot_PlotErrorBars_FloatPtrFloatPtrFloatPtrFloatPtr(const char* label_id,const float* xs,const float* ys,const float* neg,const float* pos,int count,int offset,int stride) */
HB_FUNC( HB_IMPLOTERRORBARSFLOAT4 )
{
   const char* label_id = hb_parcx( 1 );
   PHB_IG_FLOATS pFloatsx = hb_ig_floats_par( 2 );
   const float* xs = ( pFloatsx ? pFloatsx->pBuf : NULL );
   PHB_IG_FLOATS pFloatsy = hb_ig_floats_par( 3 );
   const float* ys = ( pFloatsy ? pFloatsy->pBuf : NULL );
   PHB_IG_FLOATS pFloatsn = hb_ig_floats_par( 4 );
   const float* neg = ( pFloatsn ? pFloatsn->pBuf : NULL );
   PHB_IG_FLOATS pFloatsp = hb_ig_floats_par( 4 );
   const float* pos = ( pFloatsp ? pFloatsp->pBuf : NULL );
   int count = hb_parni( 6 );
   int offset = hb_parni( 7 );
   int stride = sizeof( float );
   if( ! count || ( HB_SIZE ) count > pFloatsx->nSize )
      count = pFloatsx->nSize;
   if( ( HB_SIZE ) count > pFloatsy->nSize )
      count = pFloatsy->nSize;
   if( ( HB_SIZE ) count > pFloatsn->nSize )
      count = pFloatsn->nSize;
   if( ( HB_SIZE ) count > pFloatsp->nSize )
      count = pFloatsp->nSize;
   ImPlot_PlotErrorBars_FloatPtrFloatPtrFloatPtrFloatPtr(label_id,xs,ys,neg,pos,count,offset,stride);
}

/* void ImPlot_PlotErrorBarsH_FloatPtrFloatPtrFloatPtrInt(const char* label_id,const float* xs,const float* ys,const float* err,int count,int offset,int stride) */
HB_FUNC( HB_IMPLOTERRORBARSHFLOAT3 )
{
   const char* label_id = hb_parcx( 1 );
   PHB_IG_FLOATS pFloatsx = hb_ig_floats_par( 2 );
   const float* xs = ( pFloatsx ? pFloatsx->pBuf : NULL );
   PHB_IG_FLOATS pFloatsy = hb_ig_floats_par( 3 );
   const float* ys = ( pFloatsy ? pFloatsy->pBuf : NULL );
   PHB_IG_FLOATS pFloatse = hb_ig_floats_par( 4 );
   const float* err = ( pFloatse ? pFloatse->pBuf : NULL );
   int count = hb_parni( 5 );
   int offset = hb_parni( 6 );
   int stride = sizeof( float );
   if( ! count || ( HB_SIZE ) count > pFloatsx->nSize )
      count = pFloatsx->nSize;
   if( ( HB_SIZE ) count > pFloatsy->nSize )
      count = pFloatsy->nSize;
   if( ( HB_SIZE ) count > pFloatse->nSize )
      count = pFloatse->nSize;
   ImPlot_PlotErrorBarsH_FloatPtrFloatPtrFloatPtrInt(label_id,xs,ys,err,count,offset,stride);
}

/* void ImPlot_PlotErrorBarsH_FloatPtrFloatPtrFloatPtrFloatPtr(const char* label_id,const float* xs,const float* ys,const float* neg,const float* pos,int count,int offset,int stride) */
HB_FUNC( HB_IMPLOTERRORBARSHFLOAT4 )
{
   const char* label_id = hb_parcx( 1 );
   PHB_IG_FLOATS pFloatsx = hb_ig_floats_par( 2 );
   const float* xs = ( pFloatsx ? pFloatsx->pBuf : NULL );
   PHB_IG_FLOATS pFloatsy = hb_ig_floats_par( 3 );
   const float* ys = ( pFloatsy ? pFloatsy->pBuf : NULL );
   PHB_IG_FLOATS pFloatsn = hb_ig_floats_par( 4 );
   const float* neg = ( pFloatsn ? pFloatsn->pBuf : NULL );
   PHB_IG_FLOATS pFloatsp = hb_ig_floats_par( 4 );
   const float* pos = ( pFloatsp ? pFloatsp->pBuf : NULL );
   int count = hb_parni( 6 );
   int offset = hb_parni( 7 );
   int stride = sizeof( float );
   if( ! count || ( HB_SIZE ) count > pFloatsx->nSize )
      count = pFloatsx->nSize;
   if( ( HB_SIZE ) count > pFloatsy->nSize )
      count = pFloatsy->nSize;
   if( ( HB_SIZE ) count > pFloatsn->nSize )
      count = pFloatsn->nSize;
   if( ( HB_SIZE ) count > pFloatsp->nSize )
      count = pFloatsp->nSize;
   ImPlot_PlotErrorBarsH_FloatPtrFloatPtrFloatPtrFloatPtr(label_id,xs,ys,neg,pos,count,offset,stride);
}

/* void ImPlot_PlotHLines_FloatPtr(const char* label_id,const float* ys,int count,int offset,int stride) */
HB_FUNC( HB_IMPLOTHLINESFLOAT )
{
   const char* label_id = hb_parcx( 1 );
   PHB_IG_FLOATS pFloatsy = hb_ig_floats_par( 2 );
   const float* ys = ( pFloatsy ? pFloatsy->pBuf : NULL );
   int count = hb_parni( 3 );
   int offset = hb_parni( 4 );
   int stride = sizeof( float );
   if( ! count || ( HB_SIZE ) count > pFloatsy->nSize )
      count = pFloatsy->nSize;
   ImPlot_PlotHLines_FloatPtr(label_id,ys,count,offset,stride);
}

/* void ImPlot_PlotHeatmap_FloatPtr(const char* label_id,const float* values,int rows,int cols,double scale_min,double scale_max,const char* label_fmt,const ImPlotPoint bounds_min,const ImPlotPoint bounds_max) */
HB_FUNC( HB_IMPLOTHEATMAPFLOAT )
{
   const char* label_id = hb_parcx( 1 );
   PHB_IG_FLOATS pFloats = hb_ig_floats_par( 2 );
   const float* values = ( pFloats ? pFloats->pBuf : NULL );
   int rows = hb_parni( 3 );
   int cols = hb_parni( 4 );
   double scale_min = hb_parnd( 5 );
   double scale_max = hb_parnd( 6 );
   const char* label_fmt = hb_parcx( 7 );
   PHB_ITEM pbounds_min = hb_param( 8, HB_IT_ARRAY );
   const ImPlotPoint bounds_min = ImPlotPoint{ _pad( pbounds_min, 1 ), _pad( pbounds_min, 2 ) };
   PHB_ITEM pbounds_max = hb_param( 9, HB_IT_ARRAY );
   const ImPlotPoint bounds_max = ImPlotPoint{ _pad( pbounds_max, 1 ), _pad( pbounds_max, 2 ) };
   /* TOFIX: no bounds checking rows, cols vs values */
   ImPlot_PlotHeatmap_FloatPtr(label_id,values,rows,cols,scale_min,scale_max,label_fmt,bounds_min,bounds_max);
}

/* double ImPlot_PlotHistogram_FloatPtr(const char* label_id,const float* values,int count,int bins,bool cumulative,bool density,ImPlotRange range,bool outliers,double bar_scale) */
HB_FUNC( HB_IMPLOTHISTOGRAMFLOAT )
{
   const char* label_id = hb_parcx( 1 );
   PHB_IG_FLOATS pFloats = hb_ig_floats_par( 2 );
   const float* values = ( pFloats ? pFloats->pBuf : NULL );
   int count = hb_parni( 3 );
   int bins = hb_parni( 4 );
   bool cumulative = hb_parldef( 5, 0 );
   bool density = hb_parldef( 6, 0 );
   PHB_ITEM prange = hb_param( 7, HB_IT_ARRAY );
   ImPlotRange range = ImPlotRange{ _pad( prange, 1 ), _pad( prange, 2 ) };
   bool outliers = hb_parldef( 8, 1 );
   double bar_scale = hb_parnd( 9 );
   double ret = ImPlot_PlotHistogram_FloatPtr(label_id,values,count,bins,cumulative,density,range,outliers,bar_scale);
   if( ! count || ( HB_SIZE ) count > pFloats->nSize )
      count = pFloats->nSize;
   hb_retnd( ret );
}

/* double ImPlot_PlotHistogram2D_FloatPtr(const char* label_id,const float* xs,const float* ys,int count,int x_bins,int y_bins,bool density,ImPlotLimits range,bool outliers) */
HB_FUNC( HB_IMPLOTHISTOGRAM2DFLOAT )
{
   const char* label_id = hb_parcx( 1 );
   PHB_IG_FLOATS pFloatsx = hb_ig_floats_par( 2 );
   const float* xs = ( pFloatsx ? pFloatsx->pBuf : NULL );
   PHB_IG_FLOATS pFloatsy = hb_ig_floats_par( 3 );
   const float* ys = ( pFloatsy ? pFloatsy->pBuf : NULL );
   int count = hb_parni( 4 );
   int x_bins = hb_parni( 5 );
   int y_bins = hb_parni( 6 );
   bool density = hb_parldef( 7, 0 );
   PHB_ITEM prange = hb_param( 8, HB_IT_ARRAY );
   ImPlotLimits range = ImPlotLimits{ _pad( prange, 1 ), _pad( prange, 2 ), _pad( prange, 3 ), _pad( prange, 4 ) };
   bool outliers = hb_parldef( 9, 1 );
   double ret = ImPlot_PlotHistogram2D_FloatPtr(label_id,xs,ys,count,x_bins,y_bins,density,range,outliers);
   if( ! count || ( HB_SIZE ) count > pFloatsx->nSize )
      count = pFloatsx->nSize;
   if( ( HB_SIZE ) count > pFloatsy->nSize )
      count = pFloatsy->nSize;
   hb_retnd( ret );
}

/* void ImPlot_PlotLine_FloatPtrInt(const char* label_id,const float* values,int count,double xscale,double x0,int offset,int stride) */
HB_FUNC( HB_IMPLOTLINEFLOAT )
{
   const char* label_id = hb_parcx( 1 );
   PHB_IG_FLOATS pFloats = hb_ig_floats_par( 2 );
   const float* values = ( pFloats ? pFloats->pBuf : NULL );
   int count = hb_parni( 3 );
   double xscale = hb_parnd( 4 );
   double x0 = hb_parnd( 5 );
   int offset = hb_parni( 6 );
   int stride = sizeof( float );
   if( ! count || ( HB_SIZE ) count > pFloats->nSize )
      count = pFloats->nSize;
   ImPlot_PlotLine_FloatPtrInt(label_id,values,count,xscale,x0,offset,stride);
}

/* void ImPlot_PlotLine_FloatPtrFloatPtr(const char* label_id,const float* xs,const float* ys,int count,int offset,int stride) */
HB_FUNC( HB_IMPLOTLINEFLOAT2 )
{
   const char* label_id = hb_parcx( 1 );
   PHB_IG_FLOATS pFloatsx = hb_ig_floats_par( 2 );
   const float* xs = ( pFloatsx ? pFloatsx->pBuf : NULL );
   PHB_IG_FLOATS pFloatsy = hb_ig_floats_par( 3 );
   const float* ys = ( pFloatsy ? pFloatsy->pBuf : NULL );
   int count = hb_parni( 4 );
   int offset = hb_parni( 5 );
   int stride = sizeof( float );
   if( ! count || ( HB_SIZE ) count > pFloatsx->nSize )
      count = pFloatsx->nSize;
   if( ( HB_SIZE ) count > pFloatsy->nSize )
      count = pFloatsy->nSize;
   ImPlot_PlotLine_FloatPtrFloatPtr(label_id,xs,ys,count,offset,stride);
}

/* void ImPlot_PlotPieChart_FloatPtr(const char* const label_ids[],const float* values,int count,double x,double y,double radius,bool normalize,const char* label_fmt,double angle0) */
HB_FUNC( HB_IMPLOTPIECHARTFLOAT )
{
   const char* const label_ids[] = { 0 };
   PHB_IG_FLOATS pFloats = hb_ig_floats_par( 2 );
   const float* values = ( pFloats ? pFloats->pBuf : NULL );
   int count = hb_parni( 3 );
   double x = hb_parnd( 4 );
   double y = hb_parnd( 5 );
   double radius = hb_parnd( 6 );
   bool normalize = hb_parldef( 7, 0 );
   const char* label_fmt = hb_parcx( 8 );
   double angle0 = hb_parnd( 9 );
   if( ! count || ( HB_SIZE ) count > pFloats->nSize )
      count = pFloats->nSize;
   ImPlot_PlotPieChart_FloatPtr(label_ids,values,count,x,y,radius,normalize,label_fmt,angle0);
}

/* void ImPlot_PlotScatter_FloatPtrInt(const char* label_id,const float* values,int count,double xscale,double x0,int offset,int stride) */
HB_FUNC( HB_IMPLOTSCATTERFLOAT )
{
   const char* label_id = hb_parcx( 1 );
   PHB_IG_FLOATS pFloats = hb_ig_floats_par( 2 );
   const float* values = ( pFloats ? pFloats->pBuf : NULL );
   int count = hb_parni( 3 );
   double xscale = hb_parnd( 4 );
   double x0 = hb_parnd( 5 );
   int offset = hb_parni( 6 );
   int stride = sizeof( float );
   if( ! count || ( HB_SIZE ) count > pFloats->nSize )
      count = pFloats->nSize;
   ImPlot_PlotScatter_FloatPtrInt(label_id,values,count,xscale,x0,offset,stride);
}

/* void ImPlot_PlotScatter_FloatPtrFloatPtr(const char* label_id,const float* xs,const float* ys,int count,int offset,int stride) */
HB_FUNC( HB_IMPLOTSCATTERFLOAT2 )
{
   const char* label_id = hb_parcx( 1 );
   PHB_IG_FLOATS pFloatsx = hb_ig_floats_par( 2 );
   const float* xs = ( pFloatsx ? pFloatsx->pBuf : NULL );
   PHB_IG_FLOATS pFloatsy = hb_ig_floats_par( 3 );
   const float* ys = ( pFloatsy ? pFloatsy->pBuf : NULL );
   int count = hb_parni( 4 );
   int offset = hb_parni( 5 );
   int stride = sizeof( float );
   ImPlot_PlotScatter_FloatPtrFloatPtr(label_id,xs,ys,count,offset,stride);
}

/* void ImPlot_PlotShaded_FloatPtrInt(const char* label_id,const float* values,int count,double y_ref,double xscale,double x0,int offset,int stride) */
HB_FUNC( HB_IMPLOTSHADEDFLOAT )
{
   const char* label_id = hb_parcx( 1 );
   PHB_IG_FLOATS pFloats = hb_ig_floats_par( 2 );
   const float* values = ( pFloats ? pFloats->pBuf : NULL );
   int count = hb_parni( 3 );
   double y_ref = hb_parnd( 4 );
   double xscale = hb_parnd( 5 );
   double x0 = hb_parnd( 6 );
   int offset = hb_parni( 7 );
   int stride = sizeof( float );
   if( ! count || ( HB_SIZE ) count > pFloats->nSize )
      count = pFloats->nSize;
   ImPlot_PlotShaded_FloatPtrInt(label_id,values,count,y_ref,xscale,x0,offset,stride);
}

/* void ImPlot_PlotShaded_FloatPtrFloatPtrInt(const char* label_id,const float* xs,const float* ys,int count,double y_ref,int offset,int stride) */
HB_FUNC( HB_IMPLOTSHADEDFLOAT2 )
{
   const char* label_id = hb_parcx( 1 );
   PHB_IG_FLOATS pFloatsx = hb_ig_floats_par( 2 );
   const float* xs = ( pFloatsx ? pFloatsx->pBuf : NULL );
   PHB_IG_FLOATS pFloatsy = hb_ig_floats_par( 3 );
   const float* ys = ( pFloatsy ? pFloatsy->pBuf : NULL );
   int count = hb_parni( 4 );
   double y_ref = hb_parnd( 5 );
   int offset = hb_parni( 6 );
   int stride = sizeof( float );
   if( ! count || ( HB_SIZE ) count > pFloatsx->nSize )
      count = pFloatsx->nSize;
   if( ( HB_SIZE ) count > pFloatsy->nSize )
      count = pFloatsy->nSize;
   ImPlot_PlotShaded_FloatPtrFloatPtrInt(label_id,xs,ys,count,y_ref,offset,stride);
}

/* void ImPlot_PlotShaded_FloatPtrFloatPtrFloatPtr(const char* label_id,const float* xs,const float* ys1,const float* ys2,int count,int offset,int stride) */
HB_FUNC( HB_IMPLOTSHADED_FLOAT3 )
{
   const char* label_id = hb_parcx( 1 );
   PHB_IG_FLOATS pFloatsx = hb_ig_floats_par( 2 );
   const float* xs = ( pFloatsx ? pFloatsx->pBuf : NULL );
   PHB_IG_FLOATS pFloatsy = hb_ig_floats_par( 3 );
   const float* ys1 = ( pFloatsy ? pFloatsy->pBuf : NULL );
   PHB_IG_FLOATS pFloatsy2 = hb_ig_floats_par( 4 );
   const float* ys2 = ( pFloatsy2 ? pFloatsy2->pBuf : NULL );
   int count = hb_parni( 5 );
   int offset = hb_parni( 6 );
   int stride = sizeof( float );
   if( ! count || ( HB_SIZE ) count > pFloatsx->nSize )
      count = pFloatsx->nSize;
   if( ( HB_SIZE ) count > pFloatsy->nSize )
      count = pFloatsy->nSize;
   if( ( HB_SIZE ) count > pFloatsy2->nSize )
      count = pFloatsy2->nSize;
   ImPlot_PlotShaded_FloatPtrFloatPtrFloatPtr(label_id,xs,ys1,ys2,count,offset,stride);
}

/* void ImPlot_PlotStairs_FloatPtrInt(const char* label_id,const float* values,int count,double xscale,double x0,int offset,int stride) */
HB_FUNC( HB_IMPLOTSTAIRSFLOAT )
{
   const char* label_id = hb_parcx( 1 );
   PHB_IG_FLOATS pFloats = hb_ig_floats_par( 2 );
   const float* values = ( pFloats ? pFloats->pBuf : NULL );
   int count = hb_parni( 3 );
   double xscale = hb_parnd( 4 );
   double x0 = hb_parnd( 5 );
   int offset = hb_parni( 6 );
   int stride = sizeof( float );
   if( ! count || ( HB_SIZE ) count > pFloats->nSize )
      count = pFloats->nSize;
   ImPlot_PlotStairs_FloatPtrInt(label_id,values,count,xscale,x0,offset,stride);
}

/* void ImPlot_PlotStairs_FloatPtrFloatPtr(const char* label_id,const float* xs,const float* ys,int count,int offset,int stride) */
HB_FUNC( HB_IMPLOTSTAIRSFLOAT2 )
{
   const char* label_id = hb_parcx( 1 );
   PHB_IG_FLOATS pFloatsx = hb_ig_floats_par( 2 );
   const float* xs = ( pFloatsx ? pFloatsx->pBuf : NULL );
   PHB_IG_FLOATS pFloatsy = hb_ig_floats_par( 3 );
   const float* ys = ( pFloatsy ? pFloatsy->pBuf : NULL );
   int count = hb_parni( 4 );
   int offset = hb_parni( 5 );
   int stride = sizeof( float );
   if( ! count || ( HB_SIZE ) count > pFloatsx->nSize )
      count = pFloatsx->nSize;
   if( ( HB_SIZE ) count > pFloatsy->nSize )
      count = pFloatsy->nSize;
   ImPlot_PlotStairs_FloatPtrFloatPtr(label_id,xs,ys,count,offset,stride);
}

/* void ImPlot_PlotStems_FloatPtrInt(const char* label_id,const float* values,int count,double y_ref,double xscale,double x0,int offset,int stride) */
HB_FUNC( HB_IMPLOTSTEMSFLOAT )
{
   const char* label_id = hb_parcx( 1 );
   PHB_IG_FLOATS pFloats = hb_ig_floats_par( 2 );
   const float* values = ( pFloats ? pFloats->pBuf : NULL );
   int count = hb_parni( 3 );
   double y_ref = hb_parnd( 4 );
   double xscale = hb_parnd( 5 );
   double x0 = hb_parnd( 6 );
   int offset = hb_parni( 7 );
   int stride = sizeof( float );
   if( ! count || ( HB_SIZE ) count > pFloats->nSize )
      count = pFloats->nSize;
   ImPlot_PlotStems_FloatPtrInt(label_id,values,count,y_ref,xscale,x0,offset,stride);
}

/* void ImPlot_PlotStems_FloatPtrFloatPtr(const char* label_id,const float* xs,const float* ys,int count,double y_ref,int offset,int stride) */
HB_FUNC( HB_IMPLOTSTEMSFLOAT2 )
{
   const char* label_id = hb_parcx( 1 );
   PHB_IG_FLOATS pFloatsx = hb_ig_floats_par( 2 );
   const float* xs = ( pFloatsx ? pFloatsx->pBuf : NULL );
   PHB_IG_FLOATS pFloatsy = hb_ig_floats_par( 3 );
   const float* ys = ( pFloatsy ? pFloatsy->pBuf : NULL );
   int count = hb_parni( 4 );
   double y_ref = hb_parnd( 5 );
   int offset = hb_parni( 6 );
   int stride = sizeof( float );
   if( ! count || ( HB_SIZE ) count > pFloatsx->nSize )
      count = pFloatsx->nSize;
   if( ( HB_SIZE ) count > pFloatsy->nSize )
      count = pFloatsy->nSize;
   ImPlot_PlotStems_FloatPtrFloatPtr(label_id,xs,ys,count,y_ref,offset,stride);
}

/* void ImPlot_PlotVLines_FloatPtr(const char* label_id,const float* xs,int count,int offset,int stride) */
HB_FUNC( HB_IMPLOTVLINESFLOAT )
{
   const char* label_id = hb_parcx( 1 );
   PHB_IG_FLOATS pFloatsx = hb_ig_floats_par( 2 );
   const float* xs = ( pFloatsx ? pFloatsx->pBuf : NULL );
   int count = hb_parni( 3 );
   int offset = hb_parni( 4 );
   int stride = sizeof( float );
   if( ! count || ( HB_SIZE ) count > pFloatsx->nSize )
      count = pFloatsx->nSize;
   ImPlot_PlotVLines_FloatPtr(label_id,xs,count,offset,stride);
}
