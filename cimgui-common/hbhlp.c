/*
    cimgui/hbhlp.c    -- callbacks from Dear imgui library are (or will be)
                         handled here

    license is MIT, see ../LICENSE

    Copyright (c) 2021 Aleksander Czajczynski
*/

#include "hbimgui.h"

/* don't use ever misleading "AlwaysInsertMode", also it will be removed
   from future versions of Dear imgui */
#ifndef ImGuiInputTextFlags_AlwaysOverwrite
#define ImGuiInputTextFlags_AlwaysOverwrite ImGuiInputTextFlags_AlwaysInsertMode
#endif

typedef struct _HB_IG_TEXT_DATA
{
    char * pNewBuf;
    int    nBufSize;
} HB_IG_TEXT_DATA, * PHB_IG_TEXT_DATA;

float _paf( PHB_ITEM p, HB_SIZE nIndex )
{
   if( p )
      return ( float ) hb_arrayGetND( p, nIndex );

   return ( float ) 0.0;
}

#include "hbhlpinl.c"

// bool(*)(void* data,int idx,const char** out_text) items_getter;

bool hb_ig_items_getter( void* data,int idx,const char** out_text )
{
   out_text = NULL;
   return 0;
}

// float(*)(void* data,int idx) values_getter;

float hb_ig_values_getter( void* data,int idx )
{
   return 0.0;
}

//   void*(*)(size_t sz,void* user_data) alloc_func;

void * hb_ig_alloc_func( size_t sz,void* user_data )
{
   return NULL;
}

//   void(*)(void* ptr,void* user_data) free_func;

void hb_ig_free_func( void* ptr,void* user_data )
{
}

//    int(*compare_func)(void const*,void const*));
int hb_ig_compare_func( const void* ptr, const void* ptr2 )
{
   return 0;
}

int hb_ig_text_cb( ImGuiInputTextCallbackData * data )
{
   char * buf_old;
   HB_SIZE buf_size;
   PHB_IG_TEXT_DATA user_data = ( PHB_IG_TEXT_DATA ) data->UserData;

   switch ( data->EventFlag )
   {
      case ImGuiInputTextFlags_CallbackCharFilter:
         break;
      case ImGuiInputTextFlags_CallbackResize:
         buf_old = data->Buf;
         if( data->BufTextLen + 1 > user_data->nBufSize &&
             ( data->Buf = ( char * ) hb_xrealloc( ( void * ) data->Buf, user_data->nBufSize * 2 ) ) )
         {
            user_data->pNewBuf = data->Buf; /* notify Harbour code, the buffer has new location */
            data->BufSize = user_data->nBufSize *= 2;
         }
         else 
            data->Buf = buf_old;
         break;
      case ImGuiInputTextFlags_CallbackHistory:
         break;
      case ImGuiInputTextFlags_CallbackCompletion:
         break;
      default:
         break;
   }

   return 0;
}

/*

- this is a right place for executing PICTURE-like formating on text input
- considering UTF-8, buffer sizing should be independent from limiting length of text
  although we could prealloc buffer that is [max-text-len * 2]

ImGuiInputTextCallBackData follows:

struct {
    ImGuiInputTextFlags EventFlag;
    ImGuiInputTextFlags Flags;
    void* UserData;
    ImWchar EventChar;
    ImGuiKey EventKey;
    char* Buf;
    int BufTextLen;
    int BufSize;
    bool BufDirty;
    int CursorPos;
    int SelectionStart;
    int SelectionEnd;
};

*/
