/*
    cimgui/hbctcalw.prg   -- calendar widgets

                          hb_igDatePicker()

    license is MIT, see ../LICENSE

    Copyright (c) 2022 Aleksander Czajczynski
*/

#include "hbimenum.ch"

FUNCTION hb_igDatePicker( cLabel, dDate, nWidth, nStartOfWeek, aState )
   THREAD STATIC s_hState
   LOCAL aPreRet := Array( 2 )
   LOCAL dNew, i, j, a, nWeekRows, lRet := .F.
   LOCAL bSelector 

   IF ! hb_isDate( dDate )
      RETURN .F.
   ENDIF

   IF ! hb_isArray( aState )
      IF ! hb_isHash( s_hState )
         s_hState := { => }
         s_hState[ cLabel ] := aState := Array( 1 )
      ELSEIF ( aState := hb_HGetDef( s_hState, cLabel, NIL ) ) == NIL
         s_hState[ cLabel ] := aState := Array( 1 )
      ENDIF
   ENDIF

   igPushIdStr( cLabel )
   aPreRet[ 1 ] := { || igPopId() }
   IF HB_IsNumeric( nWidth ) .AND. nWidth > 0 
      igPushItemWidth( nWidth )
      aPreRet[ 2 ] := { || igPopItemWidth() }
   ENDIF

#define _Y_BTN_SIZE { 25, 25 }

   IF igBeginCombo( cLabel + "##Combo", DtoC( dDate ), ImGuiComboFlags_HeightLargest )

      igAlignTextToFramePadding()

      // ROW
      IF igButton( "<##" + cLabel + "year", _Y_BTN_SIZE )
         dNew := hb_date( Year( dDate ) - 1, Month( dDate ), Day( dDate ) )
         IF ! Empty( dNew )
            // stick to end-of-month
            IF Month( dDate ) == 2 .AND. dDate == EoM( dDate )
               dNew := EoM( dNew )
            ENDIF
            dDate := dNew
         ELSEIF Month( dDate ) == 2
            // tolerate 28/29th of Feb
            dNew := hb_date( Year( dDate ) - 1, 2, 1 )
            IF ! Empty( dNew )
               dDate := EoM( dNew )
            ENDIF
         ENDIF
      ENDIF
      igSameLine()
      IF igButton( ">##" + cLabel + "year", _Y_BTN_SIZE )
         dNew := hb_date( Year( dDate ) + 1, Month( dDate ), Day( dDate ) )
         IF ! Empty( dNew )
            // stick to end-of-month
            IF Month( dDate ) == 2 .AND. dDate == EoM( dDate )
               dNew := EoM( dNew )
            ENDIF
            dDate := dNew
         ELSEIF Month( dDate ) == 2
            // tolerate 28/29th of Feb
            dNew := hb_date( Year( dDate ) + 1, 2, 1 )
            IF ! Empty( dNew )
               dDate := EoM( dNew )
            ENDIF
         ENDIF
      ENDIF
      igSameLine( 75.00 )
      igText( hb_NtoS( Year( dDate ) ) )

      // ROW
      IF igButton( "<##" + cLabel + "month", _Y_BTN_SIZE )
         dNew := hb_date( Year( dDate ), Month( dDate ) - 1, Day( dDate ) )
         IF ! Empty( dNew )
            // stick to end-of-month
            IF dDate == EoM( dDate )
               dNew := EoM( dNew )
            ENDIF
            dDate := dNew
         ELSEIF Month( dDate ) > 1
            dNew := hb_date( Year( dDate ), Month( dDate ) - 1, 1 )
            IF ! Empty( dNew )
               dDate := EoM( dNew )
            ENDIF
         ELSE
            dNew := hb_date( Year( dDate ) - 1, 12, Day( dDate ) )
            IF ! Empty( dNew )
               dDate := dNew
            ENDIF
         ENDIF
      ENDIF
      igSameLine()
      IF igButton( ">##" + cLabel + "month", _Y_BTN_SIZE )
         dNew := hb_date( Year( dDate ), Month( dDate ) + 1, Day( dDate ) )
         IF ! Empty( dNew )
            // stick to end-of-month
            IF dDate == EoM( dDate )
               dNew := EoM( dNew )
            ENDIF
            dDate := dNew
         ELSEIF Month( dDate ) < 12
            dNew := hb_date( Year( dDate ), Month( dDate ) + 1, 1 )
            IF ! Empty( dNew )
               dDate := EoM( dNew )
            ENDIF
         ELSE
            dNew := hb_date( Year( dDate ) + 1, 1, Day( dDate ) )
            IF ! Empty( dNew )
               dDate := dNew
            ENDIF
         ENDIF
      ENDIF
      igSameLine( 75.00 )
      igText( CMonth( dDate ) )

      IF igBeginTable( "##" + cLabel + "day", 7, ImGuiTableFlags_Borders + ImGuiTableFlags_SizingStretchSame )
         IF ! HB_IsNumeric( nStartOfWeek ) .OR. nStartOfWeek <= 1
            FOR i := 1 TO 7
               igTableSetupColumn( Left( hb_cday( i ), 3 ) )
            NEXT
         ELSE
            FOR i := nStartOfWeek TO 7
               igTableSetupColumn( Left( hb_cday( i ), 3 ) )
            NEXT
            FOR i := 1 TO Min( nStartOfWeek - 1, 7 )
               igTableSetupColumn( Left( hb_cday( i ), 3 ) )
            NEXT
         ENDIF
         igTableHeadersRow()

         IF Len( aState ) = 0 .OR. dDate # aState[ 1 ]
            aState[ 1 ] := dDate
            
            IF Empty( nStartOfWeek )
               nStartOfWeek := 1
            ELSE
               nStartOfWeek := Min( nStartOfWeek, 7 )
            ENDIF

            dNew := BoM( dDate ) - ( DoW( BoM( dDate ) ) - nStartOfWeek )
            IF Month( dDate ) == Month( dNew ) .AND. Day( dNew ) > 1
               dNew -= 7
            ENDIF

            nWeekRows := 1   
            DO WHILE dNew <= EoM( dDate )
               a := Array( 7 )
               IF ! HB_IsNumeric( nStartOfWeek ) .OR. nStartOfWeek <= 1
                  FOR i := 1 TO 7
                     a[ i ] := __igDatePickerSelector( Day( dNew ), dNew, dNew++ == dDate, dDate )
                  NEXT
               ELSE
                  i := 1
                  FOR j := nStartOfWeek TO 7
                     a[ i++ ] := __igDatePickerSelector( Day( dNew ), dNew, dNew++ == dDate, dDate )
                  NEXT
                  FOR j := 1 TO Min( nStartOfWeek - 1, 7 )
                     a[ i++ ] := __igDatePickerSelector( Day( dNew ), dNew, dNew++ == dDate, dDate )
                  NEXT
               ENDIF
               IF Len( aState ) >= nWeekRows + 1
                  aState[ nWeekRows + 1 ] := a
               ELSE
                  AAdd( aState, a )
               ENDIF
               nWeekRows++
            ENDDO
            ASize( aState, nWeekRows )
         ENDIF
      ENDIF

      FOR i := 2 TO Len( aState )
         igTableNextRow( ImGuiTableRowFlags_None )
         FOR EACH bSelector IN aState[ i ]
            igTableNextColumn()
            IF ( dNew := Eval( bSelector ) ) # NIL
               dDate := dNew
               lRet := .T.
            ENDIF
         NEXT
      NEXT

      igEndTable()

      igEndCombo()
   ENDIF

   AEval( aPreRet, { |x| IIF( HB_IsBlock( x ), Eval( x ), NIL ) } )

   RETURN lRet

STATIC FUNCTION __igDatePickerSelector( n, dDate, lSel, dMaster )
   STATIC aColorToday
   IF aColorToday == NIL
      aColorToday := hb_igGetStyleColorVec4( @aColorToday, ImGuiCol_PlotHistogram )
   ENDIF
   IF dDate == Date()
      RETURN __igDatePickerSelectorColor( n, dDate, lSel, aColorToday )
   ELSEIF Month( dDate ) # Month( dMaster )
      RETURN __igDatePickerSelectorGray( n, dDate, lSel )
   ENDIF
   RETURN { || IIF( igSelectableBool( hb_ntos( n ) + "##" + DToS( dDate ), lSel ), dDate, NIL ) }

STATIC FUNCTION __igDatePickerSelectorGray( n, dDate, lSel )
   RETURN { || igPushStyleColorVec4( ImGuiCol_Text, { 0.5, 0.5, 0.5, 1 } ), IIF( igSelectableBool( hb_ntos( n ) + "##" + DToS( dDate ), lSel ), ( igPopStyleColor( 1 ), dDate ), ( igPopStyleColor( 1 ), NIL ) ) }

STATIC FUNCTION __igDatePickerSelectorColor( n, dDate, lSel, aColor )
   RETURN { || igPushStyleColorVec4( ImGuiCol_Text, aColor ), IIF( igSelectableBool( hb_ntos( n ) + "##" + DToS( dDate ), lSel ), ( igPopStyleColor( 1 ), dDate ), ( igPopStyleColor( 1 ), NIL ) ) }
