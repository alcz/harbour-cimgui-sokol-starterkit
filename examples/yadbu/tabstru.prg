/*
    tabstru.prg    -- yet another database utility, table structure "designer"

    by Aleksander Czajczyski

    form design was outlined by Copilot in "think deeper" mode

    license is MIT, see ../../LICENSE
*/

#include "hbimenum.ch"
#include "fonts/IconsFontAwesome6.ch"

STATIC aDataTypes := { "Numeric", "Character", "Date", "Logical", "Memo", "Integer", ;
                       "B Double", "T Time", "Y Currency", "V Variant", "Q VarChar", ;
                       "@ DayTime", "+ AutoInc", "= ModTime", "^ RowVer" }


/* 
   Following poor-mans drawing was feed into Copilot to strike an idea:

   Fields:                 Field Struct:
   -----------------       -----------------------------------------------------
   | 1  |>example  |       | Data type | Numeric / Character / Date / Logical  |
   | 2  | some     |       | Length    | 10                                    |
   | 3  | fields   |       | Decimal   | 2                                     |
   | 4  | more     |       | Nullable  | .F.                                   |
   |... |          |       |           |                                       |
   -----------------       -----------------------------------------------------
   The use of hash array for field description was Copilots invention, therefore
   the need of DBStructToFields( aStruct ), FieldsToDBStruct( aFields ) functions
*/

PROCEDURE FieldDesigner_Create()
   STATIC nSeq := 0
   LOCAL aFields, nSelectedField, cDataTypes, cAlias := PadR( "NEW", 32 ), lMem := .T., nSeqField := 0

   aFields := OnShiftRetStruct() /* press Shift Key to copy structure of currently focused workarea */

   IF ! aFields == NIL
      aFields := DBStructToFields( aFields )
      nSeqField := Len( aFields )
   ELSE
      aFields := {} 
   ENDIF

   nSelectedField := 0
   cDataTypes := ""

   AEval( aDataTypes, { |x| cDataTypes += x + hb_BChar( 0 ) } )

   IG_WinCreate( @FieldDesigner(), "fdcreate:" + HB_NtoS( ++nSeq ), { aFields, nSelectedField, cDataTypes, .F., cAlias, lMem, nSeqField } )

   RETURN

FUNCTION FieldDesigner( aFields, nSelectedField, cDataTypes, lModStru, cAlias, lMem, nSeq )
   LOCAL nTableFlags    := ImGuiTableFlags_Borders + ImGuiTableFlags_RowBg
   LOCAL leftPanelWidth := 300
   LOCAL nNext, cTmp, aTmp, lOpen := .T.
   LOCAL hField, hNewField, nCurrentType, nIdx, nI
   STATIC aDragDelta := { 0, 0 }
   STATIC a, lHasDup := .F., lInMemory := .T.

   ImGui::SetNextWindowSize( { 600, 400 }, ImGuiCond_Once )
#ifndef __PLATFORM__WASM
   ImGui::SetNextWindowSizeConstraints( { 500, 300 }, { FLT_MAX, FLT_MAX } )
/* needs extensive debugging or rechecking in later releases on WebAssembly (crash):
   RuntimeError: table index is out of bounds
    at CalcWindowSizeAfterConstraint(ImGuiWindow*, ImVec2 const&) (wasm://wasm/0097fe0a)
    at CalcWindowAutoFitSize(ImGuiWindow*, ImVec2 const&) (wasm://wasm/0097fe0a)
    at ImGui::Begin(char const*, bool*, int) (wasm://wasm/0097fe0a)
    at igBegin (0097fe0a:0x39699)
    at HB_FUN_IGBEGIN (0097fe0a:0x3ae29)
    at hb_vmProc (0097fe0a:0xc4be7)
    at hb_xvmFunction (0097fe0a:0xd9d9b)
    at HB_FUN_FIELDDESIGNER (0097fe0a:0x1e849)

   may be related to GetMainViewPort() which fails sometimes too in WASM
   RuntimeError: memory access out of bounds
    at ImGui::GetMainViewport() (wasm://wasm/0097fe0a)
    at igGetMainViewport (0097fe0a:0x39a99)
    at HB_FUN_IGGETMAINVIEWPORT (0097fe0a:0x3b733)
*/
#endif
   IF ImGui::Begin( "DBF Field Designer##" + IG_WinKeyCurrent(), @lOpen )
      ImGui::GetContentRegionAvail( @a )
      // --- Left Panel: Field List with Drag & Drop Reordering ---
      IF ImGui::BeginChildStr( "FieldsPanel##" + IG_WinKeyCurrent(), { leftPanelWidth, a[ 2 ] - 40 }, .T. )
         ImGui::Text( "Fields" )
         ImGui::Separator()

         // Create a table with two columns: sequential number and editable Field Name.
         IF ImGui::BeginTable( "FieldsTable", 3, nTableFlags )
            ImGui::TableSetupColumn( "No.", ImGuiTableColumnFlags_WidthFixed, 40 )
            ImGui::TableSetupColumn( "Field Name" )
            ImGui::TableSetupColumn( "Spec", ImGuiTableColumnFlags_WidthFixed, 60 )
            ImGui::TableHeadersRow()
            
            FOR nIdx := 1 TO Len( aFields )
               ImGui::TableNextRow()
               
               // Column 1: Show the sequential number (with an arrow if selected).
               ImGui::TableSetColumnIndex( 0 )
               IF nSelectedField == nIdx
                  ImGui::Text( hb_NtoS( nIdx ) + "  " + ICON_FA_CARET_RIGHT )
               ELSE
                  ImGui::Text( hb_NtoS( nIdx ) )
               ENDIF
               IF ImGui::IsItemClicked()
                  nSelectedField := nIdx
               ENDIF
               
               // Column 2: Editable field name.
               ImGui::TableSetColumnIndex( 1 )
               // Push an ID so that each input field is uniquely identified.
//               ImGui::PushIDStr( nIdx )
               cTmp := aFields[ nIdx ]["name"]
               // The label "##name" is hidden (used only for a unique ID).
               ImGui::PushItemWidth( -FLT_MIN )
               IF ImGui::InputText( "##name" + aFields[ nIdx ]["seqkey"], @cTmp, 128 )
                  aFields[ nIdx ]["name"] := Upper( AllTrim( cTmp ) )
                  // Check for duplicate names:
                  lHasDup := DupCheck(, aFields )
               ENDIF
               ImGui::PopItemWidth()
               // Also mark the field as selected when clicked.
               IF ImGui::IsItemClicked()
                  nSelectedField := nIdx
               ENDIF
//               ImGui::PopID()

               // --- Drag & Drop Reordering Logic ---
               
               // Only allow dragging if there are no duplicates.
               // Check if the item is active (being acted upon) but not hovered (to detect a drag gesture).

               IF ! lHasDup .AND. ImGui::IsItemActive() .AND. ! ImGui::IsItemHovered()
                  ImGui::GetMouseDragDelta( @aDragDelta, 0 )
                  // If the vertical drag exceeds a threshold (here: 6 pixels)
                  /* to Mr. Copilot: threshold is here to overcome a moment where
                     no widget is hovered (table/cell padding) */
                  IF Abs( aDragDelta[ 2 ] ) >= 6
                     // Determine swap direction (up or down).
                     aTmp := AClone( aFields )
                     nNext := nIdx + IIF( aDragDelta[ 2 ] < 0, -1, 1 )
                     IF nNext >= 1 .AND. nNext <= Len( aFields )
                        // Swap the current field with the target field.
                        /* to Mr. Copilot: swap done in AClone()'ed array, to not make
                           duplicate control id's in current FOR LOOP */
                        aTmp[ nIdx ]   := aFields[ nNext ]
                        aTmp[ nNext ]  := aFields[ nIdx ]
                        // Adjust the selected field index if needed.
                        IF nSelectedField == nIdx
                           nSelectedField := nNext
                        ELSEIF nSelectedField == nNext
                           nSelectedField := nIdx
                        ENDIF
                        ImGui::ResetMouseDragDelta()
                     ENDIF
                  ENDIF

               ENDIF

               ImGui::TableSetColumnIndex( 2 )

               cTmp := Left( aFields[ nIdx ]["dataType"], 1 )

               IF Left( aFields[ nIdx ]["dataType"], 1 ) == "N"
                  cTmp += " [" + hb_NtoS( aFields[ nIdx ]["length"] ) + "," + hb_NtoS( aFields[ nIdx ]["decimalPoints"] ) + "]"
               ELSEIF ! Empty( aFields[ nIdx ]["length"] )
                  cTmp += " [" + hb_NtoS( aFields[ nIdx ]["length"] ) + "]"
               ENDIF

               ImGui::Text( cTmp )
               IF ImGui::IsItemClicked()
                  nSelectedField := nIdx
               ENDIF
               
            NEXT
            ImGui::EndTable()
            IF aTmp <> NIL
               aFields := aTmp
            ENDIF
         ENDIF
         
      ENDIF
      ImGui::EndChild() /* corrected, Copilot placed it in-block, which breaks when minimized/hidden */
      
      ImGui::SameLine() // Place the two panels side by side
      
      // --- Right Panel: Field Properties ---
      IF ImGui::BeginChildStr( "FieldStructPanel##" + IG_WinKeyCurrent(), { 0, a[ 2 ] - 40 }, .T. )
         ImGui::Text( "Field Struct" + IIF( nSelectedField > 0, " " + aFields[ nSelectedField ]["name"], "" ) )
         ImGui::Separator()
         
         IF nSelectedField > 0 .AND. nSelectedField <= Len( aFields )
            hField := aFields[ nSelectedField ]
            
            // Create a combo box for the Data Type options.
            nCurrentType := AScan( aDataTypes, { |x| hField["dataType"] == x } )
            IF nCurrentType > 0
               nCurrentType--
            ELSE
               nCurrentType := 0
            ENDIF
            
            /* nCurrentType Combo is zero-based index */
            IF ImGui::ComboStr( "Data type", @nCurrentType, cDataTypes, Len( cDataTypes ) )
               hField["dataType"] := aDataTypes[ nCurrentType + 1 ]
            ENDIF
            /* Verify */
            // ImGui::Text( hField["dataType"] )

            // Input for field Length
            IF ImGui::InputInt( "Length", @hField["length"] )
               IF hField["length"] < 0
                  hField["length"] := 0
               ENDIF
               IF hField["decimalPoints"] > hField["length"] - 2
                  hField["decimalPoints"] := Max( hField["length"] - 2, 0 )
               ENDIF
            ENDIF

            IF HB_LeftEq( hField["dataType"], "N")
               // Input for Decimal Points
               IF ImGui::InputInt( "Decimal", @hField["decimalPoints"] )
                  IF hField["decimalPoints"] < 0
                     hField["decimalPoints"] := 0
                  ENDIF
                  IF hField["decimalPoints"] > hField["length"] - 2
                     hField["decimalPoints"] := Max( hField["length"] - 2, 0 )
                  ENDIF
               ENDIF
            ELSEIF HB_LeftEq( hField["dataType"], "Y")
               ImGui::Text("4 decimal digits")
            ENDIF
            // Checkbox for Nullable flag
            ImGui::Checkbox( "Nullable", @hField["nullable"] )

            IF TypeIsChar( hField["dataType"] )
               // Checkbox for Unicode flag
               IF ImGui::Checkbox( "Unicode", @hField["unicode"] )
                  IF hField["unicode"]
                     hField["binary"] := .F.
                  ENDIF
               ENDIF
               // Checkbox for Binary flag
               IF ImGui::Checkbox( "Binary", @hField["binary"] )
                  IF hField["binary"]
                     hField["unicode"] := .F.
                  ENDIF
               ENDIF
            ENDIF

         ELSE
            ImGui::Text( "Select a field from the list to see its properties." )
         ENDIF
      ENDIF
      ImGui::EndChild() /* corrected, Copilot placed it in-block, which breaks when minimized/hidden */
      
      // --- Bottom Buttons: Add & Delete Field ---
      IF ImGui::Button( "Add Field" )
         hNewField := { ;
            "name"          => "FIELD" + hb_NtoS( Len( aFields ) + 1 ), ;
            "dataType"      => "Numeric", ;
            "length"        => 10, ;
            "decimalPoints" => 2, ;
            "nullable"      => .F., ;
            "unicode"       => .F., ;
            "binary"        => .F., ;
            "seqkey"        => HB_NtoS( ++nSeq ) }
         AAdd( aFields, hNewField )
         nSelectedField := Len( aFields )
         lHasDup := DupCheck(, aFields )
      ENDIF
      
      ImGui::SameLine()
      
      IF ImGui::Button( "Delete Field" ) .AND. nSelectedField > 0 .AND. nSelectedField <= Len( aFields )
         HB_ADel( aFields, nSelectedField, .T. )
         IF nSelectedField > Len( aFields )
            nSelectedField := Len( aFields )
         ENDIF
      ENDIF

      ImGui::SameLine()

      /* TOFIX: also prevent empty field names! and invalid characters */
      IF lHasDup
         ImGui::Text( ICON_FA_CIRCLE_EXCLAMATION + " duplicate field names detected" )
      ELSE
         ImGui::CheckBox( "MEM:##" + IG_WinKeyCurrent(), @lMem )
         ImGui::SameLine()
         ImGui::PushItemWidth( 100 )
         ImGui::InputText( "Table Name##" + IG_WinKeyCurrent(), @cAlias, 32 )
         ImGui::PopItemWidth()
      ENDIF

      ImGui::BeginDisabled( lHasDup .OR. Len( aFields ) < 1 .OR. Select( AllTrim( cAlias ) ) > 0 )

      // right-aligned button
      ImGui::SameLine( a[ 1 ] - 100, 0 )
      IF lModStru
         IF ImGui::Button( "Modify Table", { 100, 0 } )
         // TODO: implement your create the DBF table logic here
         ENDIF                                                        
      ELSE
         IF ImGui::Button( "Create Table", { 100, 0 } )
            IF UIDBCreate( IIF( lMem, "mem:", "" ) + AllTrim( cAlias ), FieldsToDBStruct( aFields ), AllTrim( cAlias ) )
               IG_WinDestroy()
               ReloadAliases()
            ENDIF
         ENDIF
      ENDIF

      ImGui::EndDisabled()

   ENDIF

   IF ! lOpen
      IG_WinDestroy()
   ENDIF

   ImGui::End()  // End the main window.
   RETURN

STATIC FUNCTION DupCheck( nCurrent, a )
   LOCAL nI, nTo := nCurrent
   IF Empty( nCurrent )
      nCurrent := 1
      nTo := Len( a )
   ENDIF
   FOR nCurrent := nCurrent TO nTO
      FOR nI := 1 TO Len( a )
         IF nI <> nCurrent .AND. a[ nI ]["name"] == a[ nCurrent ]["name"]
            RETURN .T.
         ENDIF
      NEXT
   NEXT
   RETURN .F.

STATIC FUNCTION TypeIsChar( c )
   IF HB_LeftEq( c, "C" ) .OR. HB_LeftEq( c, "M" ) .OR. HB_LeftEq( c, "Q" )
      RETURN .T.
   ENDIF
   RETURN .F.

STATIC FUNCTION FieldsToDBStruct( aFields ) 
   LOCAL aStruct := {}, hFld, cType, nI

   FOR nI := 1 TO Len( aFields )
      hFld := aFields[ nI ]

      // 1) Base type is first character of the dataType
      cType := Left( AllTrim( hFld["dataType"] ), 1 )

      // 2) For Character/Memo types, add :U or :B
      IF HB_LeftEq( cType, "C" ) .OR. HB_LeftEq( cType, "M" )
         IF hFld["unicode"]
            cType += ":U"
         ELSEIF hFld["binary"]
            cType += ":B"
         ENDIF
      ENDIF

      // 3) If this field allows NULLs, append :N
      IF hFld["nullable"]
         cType += ":N"
      ENDIF

      // 4) Build the struct entry
      AAdd( aStruct, ;
         { ;
            Upper( AllTrim( hFld["name"] ) ), ;     // name
            cType,                            ;      // type code (e.g. "C:U:N")
            IIF( HB_IsNumeric( hFld["length"]        ), hFld["length"]       , 0 ), ;
            IIF( HB_IsNumeric( hFld["decimalPoints"] ), hFld["decimalPoints"], 0 ) ;
         } )
   NEXT

   RETURN aStruct

STATIC FUNCTION DBStructToFields( aStruct )
   LOCAL aFields   := {}
   LOCAL aTokens   := {}
   LOCAL hDef, hFld
   LOCAL cFullType := ""
   LOCAL cBase, cName
   LOCAL nLen, nDec
   LOCAL lUnicode, lBinary, lNullable
   LOCAL nSeq := 0
   LOCAL nI, cDataTypeName, x

   FOR nI := 1 TO Len( aStruct )
      aDef      := aStruct[ nI ]
      cName     := aDef[ 1 ]
      cFullType := aDef[ 2 ]            // e.g. "C", "C:U", "M:U:N"

      // split cFullType on ":" into tokens
      aTokens   := HB_ATokens( cFullType, ":" )  

      // base type is first token
      cBase     := aTokens[ 1 ]

      // detect flags in remaining tokens
      lUnicode  := AScan( aTokens, { |x| At( "U", x ) > 0 }, 2 ) > 0
      lBinary   := AScan( aTokens, { |x| At( "B", x ) > 0 }, 2 ) > 0
      lNullable := AScan( aTokens, { |x| At( "N", x ) > 0 }, 2 ) > 0

      // lengths/decimals
      nLen      := IIF( HB_IsNumeric( aDef[ 3 ] ), aDef[ 3 ], 0 )
      nDec      := IIF( HB_IsNumeric( aDef[ 4 ] ), aDef[ 4 ], 0 )

      cDataTypeName := cBase
      FOR EACH x IN aDataTypes
         IF Left( x, 1 ) == cBase
            cDataTypeName := x
            EXIT
         ENDIF
      NEXT

      // assemble the field hash
      hFld := { ;
         "name"          => cName,            ;
         "dataType"      => cDataTypeName,    ;
         "length"        => nLen,             ;
         "decimalPoints" => nDec,             ;
         "nullable"      => lNullable,        ;
         "unicode"       => lUnicode,         ;
         "binary"        => lBinary,          ;
         "seqkey"        => HB_NtoS( ++nSeq ) }

      AAdd( aFields, hFld )
   NEXT

   RETURN aFields
