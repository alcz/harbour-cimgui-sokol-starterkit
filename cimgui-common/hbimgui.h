/*
    cimgui/hbimgui.h   -- definitions used across the library


    license is MIT, see ../LICENSE

    Copyright (c) 2021-2022 Aleksander Czajczynski
*/

#ifdef __cplusplus
extern "C" {
#endif

/* hbhlp.c - the following used in array to ImVec* conversions */
float _paf( PHB_ITEM p, HB_SIZE nIndex );

/* hbfunc_.c - font tools, etc. */
ImFont * hb_igFontAdd( HB_BOOL bMem, const char * szFont, float fSizePx, PHB_ITEM pChars, HB_BOOL bDefRange, HB_BOOL bMergeMode, ImFontConfig * pCfg );

/* hbarrays.cpp - special kind of arrays/sets used with plotting */

typedef struct _HB_IG_FLOATS
{
    float * pBuf;
    HB_SIZE nSize;
    HB_SIZE nCursor;
} HB_IG_FLOATS, * PHB_IG_FLOATS;

typedef struct _HB_IG_INTS
{
    int * pBuf;
    HB_SIZE nSize;
    HB_SIZE nCursor;
} HB_IG_INTS, * PHB_IG_INTS;

void hb_ig_floats_ret( PHB_IG_FLOATS p );
PHB_IG_FLOATS hb_ig_floats_par( int iParam );

void hb_ig_ints_ret( PHB_IG_INTS p );
PHB_IG_INTS hb_ig_ints_par( int iParam );

#ifdef __cplusplus
}
#endif
