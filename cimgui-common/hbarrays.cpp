/*
    cimgui/hbarrays.cpp   -- garbage collected
                             float and int C arrays

    license is MIT, see ../LICENSE

    Copyright (c) 2021 Aleksander Czajczynski
*/

#include "hbapi.h"
#include "hbapierr.h"
#include "hbapiitm.h"

#include "imgui.h"
#include "imgui_internal.h"
#include "cimgui.h"

#include "hbimgui.h"

static HB_GARBAGE_FUNC( floats_release )
{
   void ** ph = ( void ** ) Cargo;

   if( ph && *ph )
   {
      PHB_IG_FLOATS p = ( PHB_IG_FLOATS ) *ph;
      if( p->pBuf )
      {
         hb_xfree( p->pBuf );
         p->pBuf = NULL;
      }
      hb_xfree( p );

      *ph = NULL;
   }
}

static const HB_GC_FUNCS s_gcFloatFuncs =
{
   floats_release,
   hb_gcDummyMark
};

void hb_ig_floats_ret( PHB_IG_FLOATS p )
{
   if( p )
   {
      void ** ph = ( void ** ) hb_gcAllocate( sizeof( PHB_IG_FLOATS ), &s_gcFloatFuncs );

      *ph = p;

      hb_retptrGC( ph );
   }
   else
      hb_retptr( NULL );
}

PHB_IG_FLOATS hb_ig_floats_par( int iParam )
{
   void ** ph = ( void ** ) hb_parptrGC( &s_gcFloatFuncs, iParam );

   return ph ? ( PHB_IG_FLOATS ) *ph : NULL;
}

HB_FUNC( HB_IGFLOATS )
{
   PHB_ITEM pArray = hb_param( 1, HB_IT_ARRAY );
   int iLen = hb_parni( 2 );
   HB_SIZE nLen = ( iLen > 0 ? ( HB_SIZE ) iLen : hb_arrayLen( pArray ) );

   if( nLen )
   {
      HB_SIZE i;
      PHB_IG_FLOATS pFloats = ( PHB_IG_FLOATS ) hb_xgrab( sizeof( HB_IG_FLOATS ) );
      float * pBuf;

      pFloats->nSize = nLen;

      if( pArray )
      {
         pFloats->nCursor = hb_arrayLen( pArray );
         pBuf = pFloats->pBuf = ( float * ) hb_xgrab( sizeof( float ) * nLen );
         for( i = 0; i < ( HB_SIZE ) nLen; i++ )
            pBuf[ i ] = ( float ) hb_arrayGetND( pArray, i + 1 );
      }
      else
      {
         pFloats->nCursor = 0;
         pFloats->pBuf = ( float * ) hb_xgrabz( sizeof( float ) * nLen );
      }

      hb_ig_floats_ret( pFloats );
   }

}

HB_FUNC( HB_IGFLOATSPUSH )
{
   PHB_IG_FLOATS pFloats = hb_ig_floats_par( 1 );
   float * values = ( pFloats ? pFloats->pBuf : NULL );
   float value = ( float ) hb_parnd( 2 );
   HB_BOOL bUseCursor = hb_parl( 3 );

   if( values )
   {
      if( pFloats->nSize > 1 )
      {
         /*
          * TOFIX: use different memmove that supports overlapping blocks
          * or different schema like working on oversized region,
          * which won't need to reallocate on every push
          *
          * memmove( values, values + sizeof( float ), sizeof( float ) * ( pFloats->nSize - 1 ) );
          * will likely not do okay on overlapping blocks
          */

         HB_SIZE n;
         if( ! bUseCursor || pFloats->nCursor == pFloats->nSize )
         {
            for( n = 0; n < ( HB_SIZE ) pFloats->nSize; n++ )
               values[ n ] = values[ n + 1 ];

            values[ pFloats->nSize - 1 ] = value;
         }
         else
            values[ pFloats->nCursor++ ] = value;
      }
      else
         values[ 0 ] = value;
   }
}

static HB_GARBAGE_FUNC( ints_release )
{
   void ** ph = ( void ** ) Cargo;

   if( ph && *ph )
   {
      PHB_IG_INTS p = ( PHB_IG_INTS ) *ph;
      if( p->pBuf )
      {
         hb_xfree( p->pBuf );
         p->pBuf = NULL;
      }
      hb_xfree( p );

      *ph = NULL;
   }
}

static const HB_GC_FUNCS s_gcIntFuncs =
{
   ints_release,
   hb_gcDummyMark
};

void hb_ig_ints_ret( PHB_IG_INTS p )
{
   if( p )
   {
      void ** ph = ( void ** ) hb_gcAllocate( sizeof( PHB_IG_INTS ), &s_gcIntFuncs );

      *ph = p;

      hb_retptrGC( ph );
   }
   else
      hb_retptr( NULL );
}

PHB_IG_INTS hb_ig_ints_par( int iParam )
{
   void ** ph = ( void ** ) hb_parptrGC( &s_gcIntFuncs, iParam );

   return ph ? ( PHB_IG_INTS ) *ph : NULL;
}

HB_FUNC( HB_IGINTS )
{
   PHB_ITEM pArray = hb_param( 1, HB_IT_ARRAY );
   int iLen = hb_parni( 2 );
   HB_SIZE nLen = ( iLen > 0 ? ( HB_SIZE ) iLen : hb_arrayLen( pArray ) );

   if( nLen )
   {
      HB_SIZE i;
      PHB_IG_INTS pInts = ( PHB_IG_INTS ) hb_xgrab( sizeof( HB_IG_INTS ) );
      int * pBuf;

      pInts->nSize = nLen;

      if( pArray )
      {
         pInts->nCursor = hb_arrayLen( pArray );
         pBuf = pInts->pBuf = ( int * ) hb_xgrab( sizeof( int ) * nLen );
         for( i = 0; i < ( HB_SIZE ) nLen; i++ )
            pBuf[ i ] = ( int ) hb_arrayGetNI( pArray, i + 1 );
      }
      else
      {
         pInts->nCursor = 0;
         pInts->pBuf = ( int * ) hb_xgrabz( sizeof( int ) * nLen );
      }

      hb_ig_ints_ret( pInts );
   }

}

HB_FUNC( HB_IGINTSPUSH )
{
   PHB_IG_INTS pInts = hb_ig_ints_par( 1 );
   int * values = ( pInts ? pInts->pBuf : NULL );
   int value = hb_parni( 2 );
   HB_BOOL bUseCursor = hb_parl( 3 );

   if( values )
   {
      if( pInts->nSize > 1 )
      {
         HB_SIZE n;
         if( ! bUseCursor || pInts->nCursor == pInts->nSize )
         {
            for( n = 0; n < ( HB_SIZE ) pInts->nSize; n++ )
               values[ n ] = values[ n + 1 ];

            values[ pInts->nSize - 1 ] = value;
         }
         else
            values[ pInts->nCursor++ ] = value;

      }
      values[ pInts->nSize - 1 ] = value;
   }
}
