/*
    sokol/hbemfile.c    -- async file receiving via WebAssembly/emscripten

    license is MIT, see ../LICENSE

    Copyright (c) 2025 Aleksander Czajczynski
*/

#include "sokol_app.h"
#include "hbapi.h"
#include "hbapiitm.h"
#include "hbvm.h"

static void fetch_cb( const sapp_html5_fetch_response * response )
{
   PHB_DYNS pDynSym;

   if( response->succeeded )
   {
      HB_SIZE  nBytes  = ( HB_SIZE ) response->data.size;
      char   * pszBuf  = ( char * ) response->data.ptr;
      PHB_ITEM pBuffer = hb_itemPutCLPtr( NULL, pszBuf, nBytes );

      /* user supplied handler function/block should check if first parameter
         type is string (buffer), otherwise numeric parameter indicates error */

      if( response->user_data
          && HB_IS_EVALITEM( ( PHB_ITEM ) response->user_data )
          && hb_vmRequestReenter() )
      {
         hb_vmPushEvalSym();
         hb_vmPush( ( PHB_ITEM ) response->user_data );
         hb_vmPush( pBuffer );
         hb_vmPushInteger( response->file_index + 1 );
         hb_vmDo( 2 );
         hb_vmRequestRestore();
      }
      else if( ( pDynSym = hb_dynsymFindName( "IMASYNCFILE" ) ) && hb_vmRequestReenter() )
      {
         hb_vmPushDynSym( pDynSym );
         hb_vmPushNil();
         hb_vmPush( pBuffer );
         hb_vmPushInteger( response->file_index + 1 );

         if( response->user_data )
         {
            hb_vmPush( ( PHB_ITEM ) response->user_data );
            hb_vmDo( 3 );
         }
         else
            hb_vmDo( 2 );

         hb_vmRequestRestore();
      }

      hb_itemRelease( pBuffer );
   }
   else
   {
      if( response->user_data
          && HB_IS_EVALITEM( ( PHB_ITEM ) response->user_data )
          && hb_vmRequestReenter() )
      {
         hb_vmPushEvalSym();
         hb_vmPush( ( PHB_ITEM ) response->user_data );
         hb_vmPushInteger( ( int ) response->error_code );
         hb_vmPushInteger( response->file_index + 1 );
         hb_vmDo( 2 );

         hb_vmRequestRestore();
      }
      else if( ( pDynSym = hb_dynsymFindName( "IMASYNCERROR" ) ) && hb_vmRequestReenter() )
      {
         hb_vmPushDynSym( pDynSym );
         hb_vmPushNil();
         hb_vmPushInteger( ( int ) response->error_code );
         hb_vmPushInteger( response->file_index + 1 );
         if( response->user_data )
         {
            hb_vmPush( ( PHB_ITEM ) response->user_data );
            hb_vmDo( 3 );
         }
         else
            hb_vmDo( 2 );

         hb_vmRequestRestore();
      }

      hb_xfree( ( void * ) response->data.ptr );
   }

   if( response->user_data )
      hb_itemRelease( ( PHB_ITEM ) response->user_data );
}

HB_FUNC( HB_SOKOL_WASM_DROPPEDFILELOAD )
{
   int      nFileId      = hb_parnidef( 1, 1 );
   HB_SIZE  nFileBufSize = ( HB_SIZE ) hb_parns( 2 );
   PHB_ITEM pKey         = hb_param( 3, HB_IT_ANY );
   PHB_ITEM pKeyCpy;
   char   * pszBuf;

   if( --nFileId < 0 )
   {
      hb_retl( HB_FALSE );
      return;
   }

   if( ! nFileBufSize )
      nFileBufSize = sapp_html5_get_dropped_file_size( nFileId );

   if( ! nFileBufSize )
   {
      hb_retl( HB_FALSE );
      return;
   }

   pszBuf = ( char * ) hb_xgrab( nFileBufSize );
   if( ! pszBuf )
   {
      /* alloc failure can be fatal error */
      hb_retl( HB_FALSE );
      return;
   }

   if( pKey )
      pKeyCpy = hb_itemClone( pKey );
   else
      pKeyCpy = NULL;

   sapp_html5_fetch_dropped_file( &( sapp_html5_fetch_request ) {
      .dropped_file_index = nFileId,
      .callback = fetch_cb,
      .buffer = {
         .ptr = ( void * ) pszBuf,
         .size = ( uint32_t ) nFileBufSize
      },
      .user_data = ( void * ) pKeyCpy
   } );

   hb_retl( HB_TRUE );
}

HB_FUNC( HB_SOKOL_WASM_DROPPEDFILESIZE )
{
    hb_retns( ( HB_SIZE ) sapp_html5_get_dropped_file_size( hb_parnidef( 1, 1 ) - 1 ) );
}
