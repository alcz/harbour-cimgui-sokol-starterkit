/*
    edit1.prg    -- database editor reusing ImGui table

    license is MIT, see ../LICENSE
*/

/* example uses ImGui:: pseudo namespace */

#include "hbimenum.ch"
#include "hbimstru.ch"

REQUEST HB_CODEPAGE_UTF8EX
REQUEST HB_MEMIO

PROCEDURE MAIN

#ifdef __PLATFORM__WASM
   LOCAL cDBF
#pragma __binarystreaminclude "test.dbf"|cDBF := %s
   hb_memoWrit( "mem:test.dbf", cDBF )
#else
   hb_vfCopyFile( "test.dbf", "mem:test.dbf" )
   USE test ALIAS test SHARED
#endif

   USE mem:test ALIAS testmem EXCLUSIVE NEW

#ifdef __PLATFORM__WASM
    DBSelectArea("TESTMEM")
#else
    DBSelectArea("TEST")
#endif

   hb_cdpSelect("UTF8EX")

   SET CENTURY ON

   sapp_run_default( "Simple dbeditor", 800, 600 )

#ifdef __PLATFORM__WASM
   ImFrame()  /* dummy calls for emscripten, to be removed when those */
   HB_MEMIO() /* functions are properly requested from .c code        */
   DBFNTX()
#endif
   RETURN

/* uncomment to have additional keyboard navigation in the table
PROCEDURE ImInit
   hb_igConfigFlagsAdd( ImGuiConfigFlags_NavEnableKeyboard )
   RETURN
*/

PROCEDURE ImFrame
   STATIC lMem := .F., lFit := .T.
   LOCAL lAppend := .F.

   ImGui::SetNextWindowPos( {10,10}, ImGuiCond_Once, {0,0} )
   ImGui::SetNextWindowSize( {650, 350}, ImGuiCond_Once )
   ImGui::Begin( ".dbf edit", 0, ImGuiWindowFlags_None )

#ifndef __PLATFORM__WASM
   IF ImGui::CheckBox("use in-memory .dbf", @lMem )
      IF lMem
         DBSelectArea("TESTMEM")
      ELSE
         DBSelectArea("TEST")
      ENDIF
   ENDIF
#endif

   ImGui::SameLine( 200 )
   ImGui::Text("When table is focused:")
   ImGui::SameLine( 370 )
   ImGui::Text("Up and Down arrows changes records")
   ImGui::CheckBox("fit rows to window", @lFit )
   ImGui::SameLine( 200 )
   IF ImGui::Button("Append rec")
      DBAppend()
      lAppend := .T.
   ENDIF
   ImGui::SameLine( 370 )
   ImGui::Text("Tab and Shift-Tab jumps visible columns")

   DBEditor( lFit, lAppend )

   ImGui::End()

   RETURN

/* this editor feels a bit like a spreadsheet, always rendering textedit controls in the grid */
STATIC PROCEDURE DBEditor( lFit, lAppend )
   STATIC nTableFlags := ImGuiTableFlags_BordersV + ImGuiTableFlags_BordersOuterH + ;
                         ImGuiTableFlags_Resizable + ImGuiTableFlags_RowBg + ;
                         ImGuiTableFlags_NoBordersInBody + ImGuiTableFlags_ScrollX + ;
                         ImGuiTableFlags_ScrollY + ImGuiTableFlags_SizingFixedFit + ;
                         ImGuiTableFlags_Reorderable

   STATIC nTextBHeight := NIL
   STATIC nCharWidth := 0

   STATIC a

   LOCAL pClip, i, nF, x

   LOCAL nFieldValue, fFieldValue, cFieldValue, lFieldValue

   STATIC aNewFocus := NIL, cDatePickerOpenKey := NIL, aPickerState := { NIL }, dFieldValue

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

   IF lAppend
      aNewFocus := { RecCount(), 1 }
   ENDIF

   IF ImGui::BeginTable( "table_easy", FCount() + 1 /* recno() pseudocolumn */, ;
                         nTableFlags, a /* widget size */ )

      pClip := ImGuiListClipper_ImGuiListClipper()

      ImGui::TableSetupColumn( "RECNO()" )

      FOR i := 1 TO FCount()
         ImGui::TableSetupColumn( FieldName( i ) )
      NEXT

      ImGui::TableSetupScrollFreeze( 1, 1 /* "regular" header row needs a freeze! */ )
      ImGui::TableHeadersRow()

      ImGuiListClipper( pClip ):Begin( RecCount() )

      DO WHILE ImGuiListClipper( pClip ):Step()

         FOR i := ImGuiListClipper( pClip ):DisplayStart + 1 ;
               TO ImGuiListClipper( pClip ):DisplayEnd

            DBGoTo( i )

            IF EoF()
               EXIT
            ENDIF

            ImGui::TableNextRow( ImGuiTableRowFlags_None /*, row_min_height */ )

            ImGui::TableNextColumn()

            ImGui::Text( Str( RecNo() ) )

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
                  ImGui::SetKeyboardFocusHere()
                  aNewFocus := NIL
               ENDIF

#define WIDGET_KEY "##" + Alias() + FieldName( nF ) + hb_NtoS( RecNo() )

               SWITCH ValType( x )
                  CASE "N"
                     IF FieldDec( nF ) > 0
                        fFieldValue := x
                        cFormat := "%." + hb_NtoS( FieldDec( nF ) ) + "f" /* adjust precision */
                        IF ImGui::InputDouble( WIDGET_KEY, @fFieldValue, 0.01, 1.0, cFormat )
                           __Commit( nF, fFieldValue ) /* commit change */
                        ENDIF
                     ELSE
                        nFieldValue := x
                        IF ImGui::InputInt( WIDGET_KEY, @nFieldValue )
                           __Commit( nF, nFieldValue ) /* commit change */
                        ENDIF
                     ENDIF
                     EXIT
                  CASE "C"
                     cFieldValue := x
                     IF ImGui::InputText( WIDGET_KEY, @cFieldValue )
                        __Commit( nF, cFieldValue ) /* commit change */
                     ENDIF
                     EXIT
                  CASE "L"
                     lFieldValue := x
                     IF ImGui::Checkbox( WIDGET_KEY, @lFieldValue )
                        __Commit( nF, lFieldValue ) /* commit change */
                     ENDIF
                     EXIT
                  CASE "D"
                     cFieldValue := DtoC( x )
                     IF cDatePickerOpenKey == WIDGET_KEY
                        hb_igDatePicker( cDatePickerOpenKey, @dFieldValue, nCharWidth * 12, , @aPickerState )
                        IF dFieldValue <> x
                           __Commit( nF, dFieldValue ) /* commit change */
                        ENDIF
                     ELSEIF ImGui::InputText( WIDGET_KEY, @cFieldValue )
                        __Commit( nF, CtoD( cFieldValue ) ) /* commit change */
                     ENDIF
                     IF ImGui::IsItemHovered() .AND. ImGui::IsMouseDoubleClicked( 0 )
                        IF ! cDatePickerOpenKey == WIDGET_KEY
                           cDatePickerOpenKey := WIDGET_KEY
                           dFieldValue := x
                        ENDIF
                     ENDIF
                     EXIT
               ENDSWITCH
               IF ! cDatePickerOpenKey == NIL
                  IF ! cDatePickerOpenKey == WIDGET_KEY
                     IF ImGui::IsItemHovered()
                        cDatePickerOpenKey := NIL
                     ENDIF
                  ENDIF
               ENDIF
               __EditInFocus( @aNewFocus, nF, pClip )
               ImGui::PopItemWidth()
            NEXT

         NEXT
      ENDDO

      ImGuiListClipper( pClip ):destroy() /* TODO: GC collectible pointer */

      IF lAppend
         ImGui::SetScrollHereY( 1.0 )
      ENDIF

      ImGui::EndTable()

   ENDIF

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
