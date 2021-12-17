/*
    browse1.prg    -- first experiment with databrowsing

    license is MIT, see ../LICENSE
*/

/* example uses ImGui:: pseudo namespace */

#include "hbimenum.ch"
#include "hbimstru.ch"

REQUEST HB_CODEPAGE_UTF8EX
REQUEST HB_MEMIO

PROCEDURE MAIN

#ifdef __PLATFORM__WEB
   LOCAL cDBF
#pragma __binarystreaminclude "test.dbf"|cDBF := %s
   hb_memoWrit( "mem:test.dbf", cDBF )
#else
   hb_vfCopyFile( "test.dbf", "mem:test.dbf" )
   USE test ALIAS test SHARED
#endif

   USE mem:test ALIAS testmem EXCLUSIVE NEW

   hb_cdpSelect("UTF8EX")

   sapp_run_default( "Simple databrowser", 800, 600 )

#ifdef __PLATFORM__WEB
   ImFrame()  /* dummy calls for emscripten, to be removed when those */
   HB_MEMIO() /* functions are properly requested from .c code        */
   DBFNTX()
#endif
   RETURN

PROCEDURE ImFrame
   STATIC lMem := .F., lFit := .F.

   ImGui::SetNextWindowPos( {10,10}, ImGuiCond_Once, {0,0} )
   ImGui::SetNextWindowSize( {650, 350}, ImGuiCond_Once )
   ImGui::Begin( ".dbf browse", 0, ImGuiWindowFlags_None )

#ifndef __PLATFORM__WEB
   IF ImGui::CheckBox("use in-memory .dbf", @lMem )
      IF lMem
         DBSelectArea("TESTMEM")
      ELSE
         DBSelectArea("TEST")
      ENDIF
   ENDIF
#endif

   ImGui::CheckBox("fit rows to window", @lFit )

   Browser( lFit )

   ImGui::End()

   RETURN

STATIC PROCEDURE Browser( lFit )
   STATIC nTableFlags := ImGuiTableFlags_BordersV + ImGuiTableFlags_BordersOuterH + ;
                         ImGuiTableFlags_Resizable + ImGuiTableFlags_RowBg + ;
                         ImGuiTableFlags_NoBordersInBody + ImGuiTableFlags_ScrollX + ;
                         ImGuiTableFlags_ScrollY + ImGuiTableFlags_SizingFixedFit + ;
                         ImGuiTableFlags_Reorderable

   STATIC nTextBHeight := NIL

   STATIC a

   LOCAL pClip, i, nF, x

   IF nTextBHeight == NIL
      ImGui::CalcTextSize( @nTextBHeight, "A" ) // -> {x,y}
      nTextBHeight := nTextBHeight[ 2 ]
      a := { 0, 0 }
   ENDIF

   IF lFit
      ImGui::GetContentRegionAvail( @a )
   ELSE
      a[1] := 0
      a[2] := nTextBHeight * 12 /* 12 rows should be shown */
   ENDIF

   IF ImGui::BeginTable( "table_easy", FCount() + 1 /* recno() pseudocolumn */, ;
                         nTableFlags, a /* widget size */ )

      pClip := ImGuiListClipper_ImGuiListClipper()

      ImGui::TableSetupColumn( "RECNO()" )

      FOR i := 1 TO FCount()
         ImGui::TableSetupColumn( FieldName( i ) )
      NEXT

      ImGui::TableSetupScrollFreeze( 3, 1 /* "regular" header row needs a freeze! */ )
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
               //ImGui::TableSetColumnIndex( nF - 1 /* zero based, be careful */ )
               ImGui::TableNextColumn()
               x := FieldGet( nF )
               SWITCH ValType( x )
                  CASE "N"
                     ImGui::Text( hb_NtoS( x ) )
                     EXIT
                  CASE "D"
                     ImGui::Text( hb_DtoC( x ) )
                     EXIT
                  CASE "L"
                     /* TOFIX: in-table CheckBox could be smaller */
                     ImGui::CheckBox( "##" + FieldName( nF ), x )
                     EXIT
                  CASE "C"
                     ImGui::Text( RTrim( x ) )
                     EXIT
               ENDSWITCH
            NEXT
         NEXT
      ENDDO

      ImGuiListClipper( pClip ):destroy() /* TODO: GC collectible pointer */

      ImGui::EndTable()

   ENDIF

   RETURN
