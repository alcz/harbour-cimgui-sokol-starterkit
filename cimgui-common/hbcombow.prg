/*
    cimgui/hbcombow.prg   -- combo widgets

                          hb_igComboText()

    license is MIT, see ../LICENSE

    Copyright (c) 2023-2025 Aleksander Czajczynski
*/

#include "hbimenum.ch"

#ifdef IMGUI_1_89_OR_GREATER

/* based on C++ snippet by @ocornut */
PROCEDURE hb_igComboText( cName, cVar, nLen, aComplete, lAll, nFlags, cHint )
   THREAD STATIC a1 := {0,0}, a2 := {0,0}
   LOCAL lEnterPressed := IIF( HB_IsString( cHint ), ;
                               igInputText( cName, @cVar, @nLen, HB_BitOr( IIF( nFlags == NIL, 0, nFlags ), ImGuiInputTextFlags_EnterReturnsTrue ), ), ;
                               igInputTextWithHint( cName, cHint, @cVar, @nLen, HB_BitOr( IIF( nFlags == NIL, 0, nFlags ), ImGuiInputTextFlags_EnterReturnsTrue ), ) )
   LOCAL lActive := igIsItemActive()
   LOCAL lActivated := igIsItemActivated()

   IF lActivated
      igOpenPopup("##popupcombo" + cName )
   ENDIF

   igGetItemRectMin( @a1 )
   igGetItemRectMax( @a2 )
   igSetNextWindowPos( { a1[1], a2[2] } )

   IF igBeginPopup( "##popupcombo" + cName, ImGuiWindowFlags_NoTitleBar + ImGuiWindowFlags_NoMove + ImGuiWindowFlags_NoResize + ImGuiWindowFlags_Tooltip )

       lAll := lAll .OR. ( Len( AllTrim( cVar ) ) == 0 )

       FOR i := 1 TO Len( aComplete )
          IF ! lAll .AND. At( AllTrim( cVar ), aComplete[ i ] ) == 0
             LOOP
          ENDIF
          IF igSelectableBool( aComplete[ i ], .F. )
             igClearActiveID()
             cVar := aComplete[ i ]
          ENDIF
       NEXT

      IF lEnterPressed .OR. ( ! lActive .AND. ! igIsWindowFocused() )
         igCloseCurrentPopup()
      ENDIF 

      igEndPopup()
   ENDIF

   RETURN

#else

/* based on C++ snippet by @rokups */
PROCEDURE hb_igComboText( cName, cVar, nLen, aComplete, lAll, nFlags, cHint, lOpen )
   LOCAL lIsFocused, i
   THREAD STATIC a1 := {0,0}, a2 := {0,0}

   /* keyboard navigation does not work on the suggestions :-( */

   /* return value is possible here, .T. after the text is modified, but incompatible with later version... */
   IF HB_IsString( cHint )
      igInputTextWithHint( cName, cHint, @cVar, @nLen, nFlags )
   ELSE
      igInputText( cName, @cVar, @nLen, nFlags )
   ENDIF
// igSameLine()

   IF ! HB_IsLogical( lOpen )
      lOpen := .F.
   ENDIF

   IF ! HB_IsLogical( lAll )
      lAll := .F.
   ENDIF

   lIsFocused := igIsItemFocused()
   lOpen := ( lOpen .OR. igIsItemActive() )

   IF lOpen
      igGetItemRectMin( @a1 )
      igGetItemRectMax( @a2 )
      igSetNextWindowPos( { a1[1], a2[2] } )
      igGetItemRectSize( @a2 )
      igSetNextWindowSize( { a2[1], 0 } )
      IF igBegin( "##popupcombo", @lOpen, ImGuiWindowFlags_NoTitleBar + ImGuiWindowFlags_NoMove + ImGuiWindowFlags_NoResize + ImGuiWindowFlags_Tooltip )

         igBringWindowToDisplayFront( igGetCurrentWindow() )
         lIsFocused := ( lIsFocused .OR. igIsWindowFocused() )

         lAll := lAll .OR. ( Len( AllTrim( cVar ) ) == 0 )

         FOR i := 1 TO Len( aComplete )
            IF ! lAll .AND. At( AllTrim( cVar ), aComplete[ i ] ) == 0
               LOOP
            ENDIF
            IF igSelectableBool( aComplete[ i ], .F. ) .OR. ( igIsItemFocused() .AND. igIsKeyPressedMap( ImGuiKey_Enter ) )
               cVar := aComplete[ i ]
               lOpen := .F.
            ENDIF
         NEXT
      ENDIF
      igEnd()
   ENDIF

   lOpen := ( lOpen .AND. lIsFocused )

   RETURN

#endif
