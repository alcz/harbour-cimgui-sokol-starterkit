/*
    cimgui/hbfunc_.prg    -- support functions exposed to Harbour

                          hb_igAddFontFromFileTTF()
                          hb_igAddFontFromMemoryTTF()
                          hb_igCdpRange()

    license is MIT, see ../LICENSE

    Copyright (c) 2021-2025 Aleksander Czajczynski
*/


/*
   <xCdpList> - crucial functionality to support font glyph ranges outside
   of default ASCII / Latin-1 ( <lDefaultRange> == .T. )
   Dear imgui does not use generate textures for whole font, it's preferred to specify
   string or array parameter listing Harbour codepages { "PL852", "DE850" }
*/

FUNCTION hb_igAddFontFromFileTTF( cFile, nSizePx, xConfig, xCdpList, lDefaultRange, lMerge )

   IF ! File( cFile )
      RETURN .F.
   ENDIF

   IF ! HB_IsNumeric( nSizePx )
      nSizePx := 10
   ENDIF

   IF xCdpList == NIL
      xCdpList := "EN"
   ENDIF

   RETURN __igAddFont( .F., cFile, nSizePx, xConfig, hb_igCdpRange( xCdpList ), lDefaultRange, lMerge )

FUNCTION hb_igAddFontFromMemoryTTF( cBuffer, nSizePx, xConfig, xCdpList, lDefaultRange, lMerge )

   IF Empty( cBuffer )
      RETURN .F.
   ENDIF

   IF ! HB_IsNumeric( nSizePx )
      nSizePx := 10
   ENDIF

   IF xCdpList == NIL
      xCdpList := "EN"
   ENDIF

   RETURN __igAddFont( .T., cBuffer, nSizePx, xConfig, hb_igCdpRange( xCdpList ), lDefaultRange, lMerge )

FUNCTION hb_igCdpRange( xCdpList )
   LOCAL cCdp, cCdpVM, hRet := { => }, aRet, x, i

   IF hb_isHash( xCdpList )
      IF AScan( hb_HValues( xCdpList ), { |x| hb_isNumeric( x ) } ) > 0
         aRet := Array( Len( xCdpList ) * 2 + 1 )
         i := 0 /* convert { 0xaaaa => 0xaaff, ... } ranges to { 0xaaaa, 0xaaff, ..., 0 } */
         FOR EACH x IN xCdpList
            IF hb_isNumeric( x:__enumKey )
               IF hb_isNumeric( x )
                  aRet[ ++i ] := x:__enumKey
                  aRet[ ++i ] := x
               ELSE /* 0xaaaa => NIL will go as repeated { 0xaaaa, 0xaaaa, ..., 0 } in range mode */
                  aRet[ ++i ] := aRet[ ++i ] := x:__enumKey
               ENDIF
            ENDIF
         NEXT
         ASize( aRet, ++i )
         aRet[ Len( aRet ) ] := 0
         RETURN aRet /* TODO: amalgamation passthru if "CP123" => key is found */
      ENDIF
      RETURN hb_HKeys( xCdpList )
   ELSEIF hb_isArray( xCdpList ) .AND. Len( xCdpList ) > 0 .AND. hb_IsNumeric( xCdpList[ 1 ] )
      RETURN xCdpList
   ENDIF

   cCdpVM := hb_cdpSelect()

   IF HB_IsString( xCdpList )
      xCdpList := { xCdpList }
   ENDIF

   FOR EACH cCdp IN xCdpList
      IF hb_cdpExists( cCdp )
         hb_cdpSelect( cCdp )
         FOR i := 128 TO 255
            hRet[ hb_UCode( hb_BChar( i ) ) ] := NIL
         NEXT
      ENDIF
   NEXT

   hb_cdpSelect( cCdpVM )

   RETURN hb_HKeys( hRet )

REQUEST __IGFONTHIDPI
