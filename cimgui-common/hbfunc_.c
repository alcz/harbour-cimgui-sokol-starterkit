/*
    cimgui/hbfunc_.c    -- support functions exposed to Harbour

                           __igAddFont()
                           hb_igFps()

    license is MIT, see ../LICENSE

    Copyright (c) 2021-2025 Aleksander Czajczynski
*/


#define CIMGUI_DEFINE_ENUMS_AND_STRUCTS
#include "cimgui.h"
#include "hbapi.h"
#include "hbapiitm.h"
#include "hbvm.h"
#include "exstyles.h"

static ImFontConfig * s_pCfg = NULL;

ImFont * hb_igFontAdd( HB_BOOL bMem, const char * szFont, float fSizePx, PHB_ITEM pChars, HB_BOOL bDefRange, HB_BOOL bMergeMode, ImFontConfig * pCfg )
{
   ImGuiIO * io = igGetIO();
   ImFontGlyphRangesBuilder * builder = ImFontGlyphRangesBuilder_ImFontGlyphRangesBuilder();
   ImVector_ImWchar * ranges = ImVector_ImWchar_create();

   ImFont * pRet;
   
   if( bDefRange )
      ImFontGlyphRangesBuilder_AddRanges( builder, ImFontAtlas_GetGlyphRangesDefault( io->Fonts ) );

   if( pChars )
   {
      HB_SIZE i;
      HB_SIZE nChars = hb_arrayLen( pChars );

      if( hb_arrayGetNI( pChars, hb_arrayLen( pChars ) ) == 0 )
      {
         ImWchar ranges_a[] = { 0, 0, 0 };
         ImWchar * ranges_p = ( ImWchar * ) &ranges_a;
         for( i = 1; i <= ( HB_SIZE ) nChars; i += 2 )
         {
            if( hb_arrayGetNI( pChars, i ) == 0 )
               break;
            ranges_a[ 0 ] = hb_arrayGetNI( pChars, i );
            ranges_a[ 1 ] = hb_arrayGetNI( pChars, i + 1 );
            ImFontGlyphRangesBuilder_AddRanges( builder, ranges_p );
         }
      }
      else
      {
         for( i = 1; i <= ( HB_SIZE ) nChars; i++ )
            ImFontGlyphRangesBuilder_AddChar( builder, hb_arrayGetNI( pChars, i ) );
      }
   }

   ImFontGlyphRangesBuilder_BuildRanges( builder, ranges );

   if( ! pCfg )
   {
      if( ! s_pCfg )
         s_pCfg = pCfg = ImFontConfig_ImFontConfig();
      else
         pCfg = s_pCfg;

      pCfg->SizePixels = fSizePx; /* ( for HiDPI x-multiply ?) * SCALE; */
      pCfg->MergeMode  = bMergeMode;
   }

   if( bMem )
   {
      char * szFontBuf = ( char * ) hb_xmemdup( ( void * ) szFont, hb_parclen( 2 ) );
      pCfg->FontDataOwnedByAtlas = false; /* mark ownership - when added from memory, region shouldn't be ever freed by imgui! */

      if( ! ( pRet = ImFontAtlas_AddFontFromMemoryTTF( io->Fonts, szFontBuf, hb_parclen( 2 ), fSizePx, pCfg, ranges->Data ) ) )
         hb_xfree( szFontBuf );
   }
   else
      pRet = ImFontAtlas_AddFontFromFileTTF( io->Fonts, szFont, fSizePx, pCfg, ranges->Data );

   /* TODO: return font handle as GC-item, destroy own ImFontConfig, *Builder, they're not on stack */

   return pRet;
}

HB_FUNC( __IGFONTHIDPI )
{
   if( ! s_pCfg )
      s_pCfg = ImFontConfig_ImFontConfig();

   s_pCfg->OversampleH = 2;
   s_pCfg->OversampleV = 2;
   s_pCfg->RasterizerMultiply = 1.5;
}

HB_FUNC( __IGFONTHIDPITEST )
{
   if( s_pCfg )
      hb_retnd( s_pCfg->RasterizerMultiply );
}

HB_FUNC( __IGADDFONT )
{
   HB_BOOL bMem        = hb_parldef( 1, HB_FALSE );
   const char * szFont = hb_parc( 2 );
   float fSizePx       = ( float ) hb_parnd( 3 );
   PHB_ITEM pChars     = hb_param( 5, HB_IT_ARRAY );
   HB_BOOL bDefRange   = hb_parldef( 6, HB_TRUE );
   HB_BOOL bMergeMode  = hb_parldef( 7, HB_FALSE );
   ImGuiIO * io        = igGetIO();
   ImFont * pRet;

   pRet = hb_igFontAdd( bMem, szFont, fSizePx, pChars, bDefRange, bMergeMode, NULL );

   /* NOTE: doesn't seem to be required in current ImGui */
   ImFontAtlas_Build( io->Fonts );

   hb_retptr( ( void * ) pRet );
}

HB_FUNC( HB_IGFPS )
{
   ImGuiIO *io   = igGetIO();
   PHB_ITEM pMs  = hb_param( 1, HB_IT_ANY );
   PHB_ITEM pFps = hb_param( 2, HB_IT_ANY );

   if( hb_parnidef( 1, 0 ) )
      hb_retnd( ( double ) 1000.0f / io->Framerate );
   else /* this is the default - when 0 is passed */
      hb_retnd( ( double ) io->Framerate );

   if( pMs && HB_ISBYREF( 1 ) )
      hb_itemPutND( pMs, ( double ) 1000.0f / io->Framerate );

   if( pFps && HB_ISBYREF( 2 ) )
      hb_itemPutND( pFps, ( double ) io->Framerate );
}

HB_FUNC( HB_IGCONFIGFLAGSADD )
{
   int iFlags       = hb_parnidef( 1, 0 );
   ImGuiIO *io      = igGetIO();
   hb_retni( io->ConfigFlags );
   io->ConfigFlags |= iFlags;
}

HB_FUNC( HB_IGCONFIGFLAGSDEL )
{
   int iFlags       = hb_parnidef( 1, 0 );
   ImGuiIO *io      = igGetIO();
   hb_retni( io->ConfigFlags );
   io->ConfigFlags &= iFlags;
}

#include "hbhlpinl.c"

/* returns to array that is passed by reference as 1st param
   unlike igGetStyleColorVec4 which returns a pointer to a struct
 */
HB_FUNC( HB_IGGETSTYLECOLORVEC4 )
{
   PHB_ITEM pOutItem = hb_param( 1, HB_IT_ANY );
   ImGuiCol idx = ( ImGuiCol ) hb_parni( 2 );
   const ImVec4* ret = igGetStyleColorVec4(idx);
   _ImVec4toA( ret, pOutItem );
}
