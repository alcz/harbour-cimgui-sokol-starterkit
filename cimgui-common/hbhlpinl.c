/*
    cimgui/hbhlpinl.c    -- static inline kind of ugly helpers

    license is MIT, see ../LICENSE

    Copyright (c) 2021-2022 Aleksander Czajczynski
*/

static inline void _fixa( PHB_ITEM p, HB_SIZE nSize )
{
   if( ! HB_IS_ARRAY( p ) )
      hb_arrayNew( p, nSize );
   else if( hb_arrayLen( p ) < nSize )
      hb_arraySize( p, nSize );
}

static inline void _ImVec2toA( const ImVec2* s, PHB_ITEM p )
{
   _fixa( p, 2 );
   hb_arraySetND( p, 1, ( double ) s->x );
   hb_arraySetND( p, 2, ( double ) s->y );
   hb_itemReturn( p );
}

static inline void _ImVec4toA( const ImVec4* s, PHB_ITEM p )
{
   _fixa( p, 4 );
   hb_arraySetND( p, 1, ( double ) s->x );
   hb_arraySetND( p, 2, ( double ) s->y );
   hb_arraySetND( p, 3, ( double ) s->z );
   hb_arraySetND( p, 4, ( double ) s->w );
   hb_itemReturn( p );
}

static inline void _ImRecttoA( const ImRect* s, PHB_ITEM p )
{
   _fixa( p, 4 );
   hb_arraySetND( p, 1, ( double ) s->Min.x );
   hb_arraySetND( p, 2, ( double ) s->Min.y );
   hb_arraySetND( p, 3, ( double ) s->Max.x );
   hb_arraySetND( p, 4, ( double ) s->Max.y );
   hb_itemReturn( p );
}
