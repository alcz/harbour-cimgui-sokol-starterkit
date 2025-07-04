/*                                                                                                    ^
    ebrowse.prg    -- yet another database utility, table editor

    license is MIT, see ../LICENSE
*/

/* example uses ImGui:: pseudo namespace */

#include "fonts/IconsFontAwesome6.ch"
#include "hbimenum.ch"
#include "hbimstru.ch"

STATIC s_lEnterAdvances := .T.
STATIC s_lMemoEditIsCombo := .F.

PROCEDURE EBrowser( lFit, nGoTo )
   STATIC nTableFlags := ImGuiTableFlags_BordersV + ImGuiTableFlags_BordersOuterH + ;
                         ImGuiTableFlags_Resizable + ImGuiTableFlags_RowBg + ;
                         ImGuiTableFlags_NoBordersInBody + ImGuiTableFlags_ScrollX + ;
                         ImGuiTableFlags_ScrollY + ImGuiTableFlags_SizingFixedFit + ;
                         ImGuiTableFlags_Reorderable

   STATIC nTextBHeight := NIL
   STATIC nCharWidth := 0

   STATIC a, aColor

   LOCAL pClip, i, nF, x, nOldRec := RecNo(), lIgnoreFocus := .F.

   LOCAL nFieldValue, fFieldValue, cFieldValue, lFieldValue

   /* CHECKME do we need to move these statics to aWA, it's rather impossible to have a collision/race condition here */
   STATIC aNewFocus := NIL, cMemoEditOpenKey := NIL, cDatePickerOpenKey := NIL, aPickerState := { NIL }, dFieldValue
   STATIC cMemoEdit := "", nMemoBuf := 0

   IF nTextBHeight == NIL
      ImGui::CalcTextSize( @nTextBHeight, "A" ) // -> {x,y}
      nCharWidth := nTextBHeight[ 1 ]
      nTextBHeight := nTextBHeight[ 2 ]
      a := { 0, 0 }
   ENDIF

   IF lFit
      ImGui::GetContentRegionAvail( @a )
   ELSE
      a[1] := 0
      a[2] := nTextBHeight * 12 /* 12 rows should be shown */
   ENDIF

   IF ImGui::BeginTable( "wa##" + Alias(), FCount() + 1 /* recno() pseudocolumn */, ;
                         nTableFlags, a /* widget size */ )

      pClip := ImGuiListClipper_ImGuiListClipper()
#ifndef FIRST_COLUMN_TITLE
#define FIRST_COLUMN_TITLE "  RECNO()"
#endif
      ImGui::TableSetupColumn( FIRST_COLUMN_TITLE )

      FOR i := 1 TO FCount()
         ImGui::TableSetupColumn( FieldName( i ) )
      NEXT

      ImGui::TableSetupScrollFreeze( 1, 1 /* "regular" header row needs a freeze! */ )
      ImGui::TableHeadersRow()

      ImGuiListClipper( pClip ):Begin( RecCount() )
#ifdef RECCOUNT_TRANSLATION
#xtranslate RecCount( => RECCOUNT_TRANSLATION
#endif
/* depending on underlying RDD OrdKeyCount() implementation can be too heavy to call on every loop iteration */

      IF nGoTo > 0
         ImGuiListClipper( pClip ):IncludeItemsByIndex( nGoTo - 1, nGoTo )
         aNewFocus := { nGoTo, 1 }
      ENDIF

      DO WHILE ImGuiListClipper( pClip ):Step()

         FOR i := ImGuiListClipper( pClip ):DisplayStart + 1 ;
               TO ImGuiListClipper( pClip ):DisplayEnd

            DBGoTo( i )

            IF EoF()
               EXIT
            ENDIF

            ImGui::TableNextRow( ImGuiTableRowFlags_None /*, row_min_height */ )

            ImGui::TableNextColumn()

#ifndef FIRST_COLUMN_EXPR
#define FIRST_COLUMN_EXPR Str( RecNo() )
#endif
            IF i == nOldRec .AND. nGoTo == 0
               aColor := hb_igGetStyleColorVec4( @aColor, ImGuiCol_PlotHistogram )
               ImGui::PushStyleColorVec4( ImGuiCol_Text, aColor )
               ImGui::Text( ICON_FA_CARET_RIGHT )
               ImGui::SameLine( 10 )
               ImGui::Text( FIRST_COLUMN_EXPR )
               ImGui::PopStyleColor()
            ELSE
               ImGui::Dummy()
               ImGui::SameLine( 10 )
               ImGui::Text( FIRST_COLUMN_EXPR )
            ENDIF

/*          something like this could be desirable too,
            to reposition by clicking near caret, but... the code below is not enough
            IF ImGui::IsItemClicked()
               aNewFocus := { RecNo(), 1 }
            ENDIF
*/

            IF nGoTo == i
               nGoTo := 0
               ImGui::SetScrollHereY( 0.5 )
            ENDIF

            FOR nF := 1 TO FCount()
               ImGui::TableNextColumn()
               x := FieldGet(nF)

               IF FieldLen() > 48
                  ImGui::PushItemWidth( ImGui::GetColumnWidth() )
               ELSEIF ValType( x ) == "N"
                  ImGui::PushItemWidth( Max( nCharWidth * ( FieldLen( nF ) + 8 ), ImGui::GetColumnWidth() ) )
               ELSEIF ValType( x ) == "D"
                  ImGui::PushItemWidth( Max( nCharWidth * 12, ImGui::GetColumnWidth() ) )
               ELSE
                  ImGui::PushItemWidth( Max( nCharWidth * ( FieldLen( nF ) + 2 ), ImGui::GetColumnWidth() ) )
               ENDIF

               IF ! aNewFocus == NIL .AND. RecNo() == aNewFocus[ 1 ] .AND. nF == aNewFocus[ 2 ]
                  IF ImGui::IsWindowFocused()
                     ImGui::SetKeyboardFocusHere()
                  ENDIF
                  nOldRec := RecNo()
                  aNewFocus := NIL
               ENDIF

#define WIDGET_KEY "##" + hb_NtoS( RecNo() ) + Alias() + FieldName( nF )

               SWITCH ValType( x )
                  CASE "N"
                     IF FieldDec( nF ) > 0
                        fFieldValue := x
                        cFormat := "%." + hb_NtoS( FieldDec( nF ) ) + "f" /* adjust precision */
                        IF ImGui::InputDouble( WIDGET_KEY, @fFieldValue, 0.0, 0.0, cFormat, ImGuiInputTextFlags_EnterReturnsTrue )
                           __Commit( nF, fFieldValue ) /* commit change */
                           __AdvanceOnEnter( nF, @aNewFocus, @nOldRec, @nGoto )
                        ELSEIF ImGui::IsItemDeactivated() /* AfterEdit() */ .AND. ImGui::IsKeyDown( ImGuiIO( igGetIO() ):KeyMap[ ImGuiKey_Enter + 1 /* offset BUG */ ] )
                           /* these do not return .T. on unchanged (confirmed) value, unlike plain InputText(), which does @ 1.86 */
                           __AdvanceOnEnter( nF, @aNewFocus, @nOldRec, @nGoto )
                        ENDIF
                     ELSE
                        nFieldValue := x
                        IF ImGui::InputInt( WIDGET_KEY, @nFieldValue, 0, 0, ImGuiInputTextFlags_EnterReturnsTrue )
                           __Commit( nF, nFieldValue ) /* commit change */
                           __AdvanceOnEnter( nF, @aNewFocus, @nOldRec, @nGoto )
                        ELSEIF ImGui::IsItemDeactivated() /* AfterEdit() */ .AND. ImGui::IsKeyDown( ImGuiIO( igGetIO() ):KeyMap[ ImGuiKey_Enter + 1 /* offset BUG */ ] )
                           /* these do not return .T. on unchanged (confirmed) value, unlike plain InputText(), which does @ 1.86 */
                           __AdvanceOnEnter( nF, @aNewFocus, @nOldRec, @nGoto )
                        ENDIF
                     ENDIF
                     EXIT
                  CASE "C"
                     cFieldValue := x
                     IF cMemoEditOpenKey == WIDGET_KEY
                        IF s_lMemoEditIsCombo .AND. ;
                           ImGui::BeginCombo( "Popup" + WIDGET_KEY, Left( cFieldValue, 4 ) + "...", ImGuiComboFlags_HeightLargest )

                           IF ImGui::InputTextMultiline( WIDGET_KEY + "_MEMO", @cMemoEdit, @nMemoBuf, { 320, 100 }, ImGuiInputTextFlags_CallbackResize )
                              __Commit( nF, cMemoEdit ) /* commit change */
                           ENDIF

                           ImGui::EndCombo()
                        ELSE
                           ImGui::GetCursorScreenPos( @a )
                           ImGui::SetNextWindowPos( a ) /* see BeginPopupEx( ImGui::GetIDStr( "Popup" ), ) to make it resizable */
                           IF ImGui::BeginPopup( "Popup" + WIDGET_KEY, ImGuiWindowFlags_NoMove )

                              ImGui::SetKeyboardFocusHere()
                              IF ImGui::InputTextMultiline( WIDGET_KEY + "_MEMO", @cMemoEdit, @nMemoBuf, { 320, 100 }, ImGuiInputTextFlags_CallbackResize + ;
                                                                                                                       ImGuiInputTextFlags_EnterReturnsTrue )
                                 ImGui::CloseCurrentPopup()
                              ELSEIF ImGui::IsKeyPressed( ImGuiIO( igGetIO() ):KeyMap[ ImGuiKey_Escape + 1 /* offset BUG */ ] )
                                 cMemoEditOpenKey := NIL
                              ENDIF
                              /*
                                 IF ImGui::Button("Edit in a window")
                                    // just an idea
                                 ENDIF
                              */
                              ImGui::EndPopup()
                           ELSE
                              __Commit( nF, cMemoEdit ) /* commit change */
                              cMemoEditOpenKey := NIL
                           ENDIF
                        ENDIF
                     ELSEIF ImGui::InputText( WIDGET_KEY, @cFieldValue,, ImGuiInputTextFlags_EnterReturnsTrue )
                        /* NOTE: this widget does not have resizable buffer, to extend a memo/varchar length
                                 double-click to open a popup, or patch the code to use cMemoEdit */
                        __Commit( nF, cFieldValue ) /* commit change */
                        IF FieldType( nF ) $ "MVQ" .AND. ImGuiIO( igGetIO() ):KeyCtrl /* Ctrl-Enter to open popup */
                           ImGui::OpenPopup( "Popup" + WIDGET_KEY )
                           cMemoEditOpenKey := WIDGET_KEY
                           cMemoEdit := cFieldValue
                           nMemoBuf := Len( cMemoEdit )
                        ELSE
                           __AdvanceOnEnter( nF, @aNewFocus, @nOldRec, @nGoto )
                        ENDIF
                     ELSEIF FieldType( nF ) $ "MVQ"
                        IF ImGui::IsItemHovered()
                           ImGui::SetToolTip("this is a MEMO or variable length field" + HB_EoL() + ;
                                             "double-click to fully edit or extend it's size")
                        ENDIF
                     ENDIF
                     IF ImGui::IsItemHovered() .AND. ImGui::IsMouseDoubleClicked( 0 ) .AND. FieldType( nF ) $ "MVQ"
                        IF ! cMemoEditOpenKey == WIDGET_KEY
                           ImGui::OpenPopup( "Popup" + WIDGET_KEY )
                           cMemoEditOpenKey := WIDGET_KEY
                           cMemoEdit := cFieldValue
                           nMemoBuf := Len( cMemoEdit )
                        ENDIF
                     ENDIF

                     EXIT
                     /* add a popup for multiline memos in similar fashion to date picker */
                  CASE "L"
                     IF ( lFieldValue := x )
                        cFieldValue := "T"
                     ELSE
                        cFieldValue := "F"
                     ENDIF
//                     IF ImGui::Checkbox( WIDGET_KEY, @lFieldValue ) -- not using checkbox widget, it's not friendly for fast keyboard navigation
                     IF ImGui::InputText( WIDGET_KEY, @cFieldValue, 1, ImGuiInputTextFlags_EnterReturnsTrue )
                        lFieldValue := ( Upper( cFieldValue ) == "T" .OR. Upper( cFieldValue ) == "Y" .OR. IsAffirm( cFieldValue ) )
                        __Commit( nF, lFieldValue ) /* commit change */
                        __AdvanceOnEnter( nF, @aNewFocus, @nOldRec, @nGoto )
                     ENDIF
                     EXIT
                  CASE "D"
                     cFieldValue := DtoC( x )
                     IF cDatePickerOpenKey == WIDGET_KEY
                        hb_igDatePicker( cDatePickerOpenKey, @dFieldValue, nCharWidth * 12, , @aPickerState )
                        IF dFieldValue <> x
                           __Commit( nF, dFieldValue ) /* commit change */
                        ENDIF
                     ELSEIF ImGui::InputText( WIDGET_KEY, @cFieldValue,, ImGuiInputTextFlags_EnterReturnsTrue + ImGuiInputTextFlags_AlwaysOverwrite )
                        __Commit( nF, CtoD( cFieldValue ) ) /* commit change */
                        __AdvanceOnEnter( nF, @aNewFocus, @nOldRec, @nGoto )
                     ENDIF
                     IF ImGui::IsItemHovered() .AND. ImGui::IsMouseDoubleClicked( 0 )
                        IF ! cDatePickerOpenKey == WIDGET_KEY
                           cDatePickerOpenKey := WIDGET_KEY
                           dFieldValue := x
                        ENDIF
                     ENDIF
                     EXIT
                  CASE "T" /* case based on ValType() */
                  /* CASE "@" */
                  /* CASE "=" */
                     cFieldValue := HB_TtoC( x )
                     IF ImGui::InputText( WIDGET_KEY, @cFieldValue,, ImGuiInputTextFlags_EnterReturnsTrue + ImGuiInputTextFlags_AlwaysOverwrite )
                        /* lazy try to prevent malformed input from emptying previous value */
                        IF Empty( cFieldValue ) .OR. ! Empty( HB_CtoT( cFieldValue ) )
                           __Commit( nF, HB_CtoT( cFieldValue ) ) /* commit change */
                        ENDIF
                        __AdvanceOnEnter( nF, @aNewFocus, @nOldRec, @nGoto )
                     ENDIF
                     EXIT
                  /* TODO: DateTime picker */
               ENDSWITCH
               IF ! cDatePickerOpenKey == NIL
                  IF ! cDatePickerOpenKey == WIDGET_KEY
                     IF ImGui::IsItemHovered()
                        cDatePickerOpenKey := NIL
                     ENDIF
                  ENDIF
               ELSEIF ! cMemoEditOpenKey == NIL
                  IF ! cMemoEditOpenKey == WIDGET_KEY
                     IF ImGui::IsItemHovered()
                        cMemoEditOpenKey := NIL
                     ENDIF
                  ENDIF
               ENDIF
               __EditInFocus( @aNewFocus, nF, pClip )
               ImGui::PopItemWidth()
               IF ImGui::IsItemFocused()
                  nOldRec := RecNo()
               ENDIF
            NEXT

         NEXT
      ENDDO

      IF nGoTo == -1 /* page up */
         nGoTo := ImGuiListClipper( pClip ):DisplayStart - 1
         IF nGoTo < 0 .OR. nGoTo > RecCount()
            nGoTo := 0
         ENDIF
      ELSEIF nGoTo == -2 /* page down */
         nGoTo := ImGuiListClipper( pClip ):DisplayEnd + 1
         IF nGoTo < 0 .OR. nGoTo > RecCount()
            nGoTo := 0
         ENDIF
      ENDIF

      ImGuiListClipper( pClip ):destroy() /* TODO: GC collectible pointer */

/*    anoter solution to scroll bottom without knowing the record number 
      IF lAppend
         ImGui::SetScrollHereY( 1.0 )
         lAppend := .F.
      ENDIF
*/
      ImGui::EndTable()

   ENDIF

   DBGoTo( nOldRec )

   RETURN

STATIC PROCEDURE __EditInFocus( aNewFocus, nF, pClip )
   LOCAL a
   /* FIXME: keymap shouldn't be offset */
   IF ImGui::IsItemFocused()
      IF ImGui::IsKeyPressed( ImGuiIO( igGetIO() ):KeyMap[ ImGuiKey_UpArrow + 1 /* offset BUG */ ] ) .AND. RecNo() > 1
         aNewFocus := { RecNo() - 1, nF }
         IF ImGuiListClipper( pClip ):DisplayStart + 1 == RecNo()
            ImGui::GetWindowPos( @a )
            ImGui::SetScrollFromPosYFloat( ;
                                           ( ImGuiListClipper( pClip ):StartPosY + ;
                                             ImGuiListClipper( pClip ):ItemsHeight * ( RecNo() - 1.5 ) ;
                                           ) - a[ 2 ] ;
                                         )
         ENDIF

      ENDIF
      IF ImGui::IsKeyPressed( ImGuiIO( igGetIO() ):KeyMap[ ImGuiKey_DownArrow + 1 /* offset BUG */ ] )
         IF RecNo() < RecCount()
            aNewFocus := { RecNo() + 1, nF }
         ENDIF
         IF ImGuiListClipper( pClip ):DisplayEnd == RecNo()
            ImGui::SetScrollHereY( 1.0 )
         ENDIF
      ENDIF
   ENDIF
   RETURN

STATIC PROCEDURE __Commit( nF, x )
   /* real/responsive app should collect pending operations waiting for lock */
   BEGIN SEQUENCE WITH { || Break() }
      /* stock inputInt, inputDouble widgets do not have min/max params, data width error possible */
      IF RLock()
         FieldPut( nF, x )
         DBUnlock()
      ENDIF
   RECOVER
      DBUnlock()
   END SEQUENCE
   RETURN

#ifdef NEED_SCROLL_AFTER_EDIT
STATIC PROCEDURE __AdvanceOnEnter( nF, aNewFocus, nOldRec, nGoTo )
   NEED_SCROLL_AFTER_EDIT
#else
STATIC PROCEDURE __AdvanceOnEnter( nF, aNewFocus )
#endif
   IF ! s_lEnterAdvances
      RETURN
   ENDIF
   IF nF == FCount()
      IF RecNo() < RecCount()
         aNewFocus := { RecNo() + 1, 1 }
      ENDIF
   ELSE
      aNewFocus := { RecNo(), nF + 1 }
   ENDIF
   RETURN

FUNCTION ToggleEBrowserEnter( l )
   RETURN s_lEnterAdvances := l
