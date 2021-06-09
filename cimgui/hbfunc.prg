/*
    cimgui/hbfunc_.prg    -- support functions exposed to Harbour

                          hb_igAddFontFromFileTTF()
                          hb_igAddFontFromMemoryTTF()

    license is MIT, see ../LICENSE

    Copyright (c) 2021 Aleksander Czajczynski
*/


/*
   <xCdpList> - crucial functionality to support font glyph ranges outside
   of default ASCII / Latin-1 ( <lDefaultRange> == .T. )
   Dear imgui does not use generate textures for whole font, it's preferred to specify
   string or array parameter listing Harbour codepages { "PL852", "DE850" }
*/

FUNCTION hb_igAddFontFromFileTTF( cFile, nSizePx, xConfig, xCdpList, lDefaultRange, lMerge )
   LOCAL aCdpChars := __cdpRange( xCdpList )

   IF ! File( cFile )
      RETURN .F.
   ENDIF

   IF ! HB_IsNumeric( nSizePx )
      nSizePx := 10
   ENDIF

   RETURN __igAddFont( .F., cFile, nSizePx, xConfig, __cdpRange( xCdpList ), lDefaultRange, lMerge )

FUNCTION hb_igAddFontFromMemoryTTF( cBuffer, nSizePx, xConfig, xCdpList, lDefaultRange, lMerge )
   LOCAL aCdpChars := __cdpRange( xCdpList )

   IF Empty( cBuffer )
      RETURN .F.
   ENDIF

   IF ! HB_IsNumeric( nSizePx )
      nSizePx := 10
   ENDIF

   RETURN __igAddFont( .T., cBuffer, nSizePx, xConfig, __cdpRange( xCdpList ), lDefaultRange, lMerge )

STATIC FUNCTION __cdpRange( xCdpList )
   LOCAL cCdp, cCdpVM, hRet := { => }, i

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

