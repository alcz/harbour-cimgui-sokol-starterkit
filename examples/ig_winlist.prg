/*******
*
*  ig_winlist.prg by Aleksander Czajczyñski
*
*  Microframework for keeping up with multiple windows of the same type
*
*  license is MIT, see ../LICENSE
*
********/

THREAD STATIC s_hWinRefsNum, s_hWinRefsKey

THREAD STATIC s_cCurrentKey, s_nCurrentNum

THREAD STATIC s_nWinNum

#define _IG_WID    1
#define _IG_WNAME  2
#define _IG_WFUNC  3
#define _IG_WDATA  4 // BYREF clone of _IG_WORIG used for passing "permanent" parameters
#define _IG_WORIG  5

PROCEDURE IG_MultiWin_Init()
   s_hWinRefsNum := { => }
   s_hWinRefsKey := { => }
   s_nWinNum := 0
   RETURN

PROCEDURE IG_MultiWin()
   LOCAL a
   FOR EACH a IN s_hWinRefsKey
      s_cCurrentKey := a:__enumKey
      s_nCurrentNum := a[ _IG_WID ]
      a[ _IG_WFUNC ]:Exec( hb_arrayToParams( a[ _IG_WDATA ] ) )
   NEXT
   s_cCurrentKey := s_nCurrentNum := NIL
   RETURN

FUNCTION IG_WinKeyCurrent()
   RETURN s_cCurrentKey

FUNCTION IG_WinNumCurrent()
   RETURN s_nCurrentNum

FUNCTION IG_WinName( nId )
   IF ! HB_IsNumeric( nId )
      nId := s_nCurrentNum
   ENDIF
   IF ! nId == NIL
      RETURN HB_ValToExp( s_hWinRefsNum[ nId ][ _IG_WFUNC ] )
   ENDIF
   RETURN ""

/*
   IG_WinCreate( @WIG_*(), "document:1234", { oDok, "foo" } )
   or
   IG_WinCreate( @WIG_*(), "document:1234", NIL, oDok, "foo" )
 */
FUNCTION IG_WinCreate( symFunc, cKey, aData, nElements, lCloneData )
   IF aData == NIL 
      IF PCount() > 3
         aData := Array( PCount () - 3 )
         ACopy( HB_AParams(), aData, 4 )
      ENDIF
   ELSE
      IF HB_IsLogical( lCloneData ) .AND. lCloneData
         aData := AClone( aData )
      ENDIF
      IF ! HB_IsNumeric( nElements )
         nElements := Len( aData )
      ELSE
         ASize( aData, nElements )
      ENDIF
   ENDIF

   IF Empty( cKey )
      cKey := HB_ValToExp( symFunc )
   ENDIF

   s_nWinNum++
   IF aData == NIL
      s_hWinRefsNum[ s_nWinNum ] := s_hWinRefsKey[ cKey ] := { s_nWinNum, cKey, symFunc, { }, NIL }
   ELSE
      s_hWinRefsNum[ s_nWinNum ] := s_hWinRefsKey[ cKey ] := { s_nWinNum, cKey, symFunc, ARef( aData ), aData }
   ENDIF
   RETURN s_nWinNum

FUNCTION IG_WinDestroy( xKey )
   LOCAL aWin
   IF PCount() == 0
      xKey := s_nCurrentNum
   ENDIF
   aWin := HB_HGetDef( s_hWinRefsNum, xKey, aWin )
   aWin := HB_HGetDef( s_hWinRefsKey, xKey, aWin )
   IF HB_IsArray( aWin )
      HB_HDel( s_hWinRefsNum, aWin[ _IG_WID ] )
      HB_HDel( s_hWinRefsKey, aWin[ _IG_WNAME ] )
      RETURN .T.
   ENDIF
   RETURN .F.

FUNCTION ARef( arr, nLimit )
   STATIC aCB

   IF nLimit == NIL
      nLimit := Min( Len( arr ), 16 )
   ELSE
      nLimit := Min( Len( arr ), nLimit )
   ENDIF

   IF aCB == NIL
      aCB := Array( 16 )
      aCB[ 1 ]  := {| a | { @a[ 1 ] } }
      aCB[ 2 ]  := {| a | { @a[ 1 ], @a[ 2 ], } }
      aCB[ 3 ]  := {| a | { @a[ 1 ], @a[ 2 ], @a[ 3 ] } }
      aCB[ 4 ]  := {| a | { @a[ 1 ], @a[ 2 ], @a[ 3 ], @a[ 4 ] } }
      aCB[ 5 ]  := {| a | { @a[ 1 ], @a[ 2 ], @a[ 3 ], @a[ 4 ], @a[ 5 ] } }
      aCB[ 6 ]  := {| a | { @a[ 1 ], @a[ 2 ], @a[ 3 ], @a[ 4 ], @a[ 5 ], @a[ 6 ] } }
      aCB[ 7 ]  := {| a | { @a[ 1 ], @a[ 2 ], @a[ 3 ], @a[ 4 ], @a[ 5 ], @a[ 6 ], @a[ 7 ] } }
      aCB[ 8 ]  := {| a | { @a[ 1 ], @a[ 2 ], @a[ 3 ], @a[ 4 ], @a[ 5 ], @a[ 6 ], @a[ 7 ], @a[ 8 ] } }
      aCB[ 9 ]  := {| a | { @a[ 1 ], @a[ 2 ], @a[ 3 ], @a[ 4 ], @a[ 5 ], @a[ 6 ], @a[ 7 ], @a[ 8 ], ;
                    @a[ 9 ] } }

      aCB[ 10 ] := {| a | { @a[ 1 ], @a[ 2 ], @a[ 3 ], @a[ 4 ], @a[ 5 ], @a[ 6 ], @a[ 7 ], @a[ 8 ], ;
                    @a[ 9 ], @a[ 10 ], @a[ 11 ] } }

      aCB[ 11 ] := {| a | { @a[ 1 ], @a[ 2 ], @a[ 3 ], @a[ 4 ], @a[ 5 ], @a[ 6 ], @a[ 7 ], @a[ 8 ], ;
                    @a[ 9 ], @a[ 10 ], @a[ 11 ] } }

      aCB[ 12 ] := {| a | { @a[ 1 ], @a[ 2 ], @a[ 3 ], @a[ 4 ], @a[ 5 ], @a[ 6 ], @a[ 7 ], @a[ 8 ], ;
                    @a[ 9 ], @a[ 10 ], @a[ 11 ], @a[ 12 ] } }

      aCB[ 13 ] := {| a | { @a[ 1 ], @a[ 2 ], @a[ 3 ], @a[ 4 ], @a[ 5 ], @a[ 6 ], @a[ 7 ], @a[ 8 ], ;
                    @a[ 9 ], @a[ 10 ], @a[ 11 ], @a[ 12 ], @a[ 13 ] } }

      aCB[ 14 ] := {| a | { @a[ 1 ], @a[ 2 ], @a[ 3 ], @a[ 4 ], @a[ 5 ], @a[ 6 ], @a[ 7 ], @a[ 8 ], ;
                     @a[ 9 ], @a[ 10 ], @a[ 11 ], @a[ 12 ], @a[ 13 ], @a[ 14 ] } }
 
      aCB[ 15 ] := {| a | { @a[ 1 ], @a[ 2 ], @a[ 3 ], @a[ 4 ], @a[ 5 ], @a[ 6 ], @a[ 7 ], @a[ 8 ], ;
                    @a[ 9 ], @a[ 10 ], @a[ 11 ], @a[ 12 ], @a[ 13 ], @a[ 15 ] } }

      aCB[ 16 ] := {| a | { @a[ 1 ], @a[ 2 ], @a[ 3 ], @a[ 4 ], @a[ 5 ], @a[ 6 ], @a[ 7 ], @a[ 8 ], ;
                    @a[ 9 ], @a[ 10 ], @a[ 11 ], @a[ 12 ], @a[ 13 ], @a[ 15 ], @a[ 16 ] } }
   ENDIF

   RETURN Eval( aCB[ nLimit ], arr )
