/*
    cimgui/hbhlp.c    -- callbacks from Dear imgui library are (or will be)
                         handled here

    license is MIT, see ../LICENSE

    Copyright (c) 2021 Aleksander Czajczynski
*/


typedef struct _HB_IG_TEXT_DATA
{
    char * pNewBuf;
    int    nBufSize;
} HB_IG_TEXT_DATA, * PHB_IG_TEXT_DATA;

float _paf( PHB_ITEM p, HB_SIZE nIndex )
{
   if( p && nIndex > 0 && nIndex <= hb_arrayLen( p ) )
      return ( float ) hb_arrayGetND( p, nIndex );

   return ( float ) 0.0;
}

static inline void _fixa( PHB_ITEM p, HB_SIZE nSize )
{
   if( ! HB_IS_ARRAY( p ) )
      hb_arrayNew( p, nSize );
   else if( hb_arrayLen( p ) < nSize )
      hb_arraySize( p, nSize );
}

static inline void _ImVec2toA( ImVec2* s, PHB_ITEM p )
{
   _fixa( p, 2 );
   hb_arraySetND( p, 1, (double) s->x );
   hb_arraySetND( p, 2, (double) s->y );
}

static inline void _ImVec4toA( ImVec4* s, PHB_ITEM p )
{
   _fixa( p, 4 );
   hb_arraySetND( p, 1, (double) s->x );
   hb_arraySetND( p, 2, (double) s->y );
   hb_arraySetND( p, 3, (double) s->z );
   hb_arraySetND( p, 4, (double) s->w );
}

static inline void _ImRecttoA( ImRect* s, PHB_ITEM p )
{
   _fixa( p, 4 );
   hb_arraySetND( p, 1, (double) s->Min.x );
   hb_arraySetND( p, 2, (double) s->Min.y );
   hb_arraySetND( p, 3, (double) s->Max.x );
   hb_arraySetND( p, 4, (double) s->Max.y );
}

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
