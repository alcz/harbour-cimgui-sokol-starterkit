/*
    cimgui/hbimca.prg   -- caching displayed expressions
                           in case they are too expensive
                           to run repeatedly at 60 fps

    license is MIT, see ../LICENSE

    Copyright (c) 2023 Aleksander Czajczynski
*/

FUNCTION hb_igLineCache( aImLineCache, nLine, nElement, xStored )
   LOCAL a
   IF Len( aImLineCache ) < nLine
      ASize( aImLineCache, nLine )
   ENDIF
   IF nElement == 0
      aImLineCache[ nLine ] := xStored
   ELSE
      IF ! HB_IsArray( a := aImLineCache[ nLine ] )
         aImLineCache[ nLine ] := Array( nElement )
      ELSEIF Len( a ) < nElement
         ASize( a, nElement )
      ENDIF
      a[ nElement ] := xStored
   ENDIF
   RETURN xStored
