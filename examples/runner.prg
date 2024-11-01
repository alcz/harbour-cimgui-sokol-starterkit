/*
    runner.prg    -- simplest possible Dear ImGui .hrb script runner

    by Aleksander Czajczyński

    license is MIT, see ../LICENSE
*/

#include "hbhrb.ch"

#include "hbimenum.ch"
#include "hbimstru.ch"

#define __HBEXTERN__CIMGUI__REQUEST
#include "cimgui.hbx" 

#define __HBEXTERN__HBCPAGE__REQUEST
#include "hbcpage.hbx" 

#define __HBEXTERN__HARBOUR__REQUEST
#include "harbour.hbx" 

REQUEST HB_CODEPAGE_UTF8EX

STATIC s_pHRB, s_symImFrame

PROCEDURE Main( cRun )
   LOCAL aScriptHost

   /* TODO if cRun = "@" or "-", read HRB from STDIN */

   hb_cdpSelect("UTF8EX")

   IG_MultiWin_Init()

   BEGIN SEQUENCE WITH { |e| Break(e) }
      s_pHRB := hb_hrbLoad( HB_HRB_BIND_FORCELOCAL, cRun )
   RECOVER USING e
      __ErrorWindow_Create( "unable to load script", ;
      e:Operation + Chr(10) + e:Description )
   END SEQUENCE

   hb_sokol_imguiNoDefaultFont( .T. )

   sapp_run_default( "Dear ImGui HRB runner", 800, 600 )

   RETURN

PROCEDURE ImInit
   LOCAL sym
#ifdef __PLATFORM__WEB
   LOCAL cFontBuf
#pragma __binarystreaminclude "OpenSans-Regular.ttf"|cFontBuf := %s
   hb_igAddFontFromMemoryTTF( cFontBuf, 18.0, , __cdpList(), .T., .F. )
#else
   hb_igAddFontFromFileTTF( "OpenSans-Regular.ttf", 18.0, , __cdpList(), .T., .F. )
#endif
   hb_sokol_imguiFont2Texture()

   hb_igConfigFlagsAdd( ImGuiConfigFlags_NavEnableKeyboard )
#ifdef ImGuiConfigFlags_DockingEnable
   hb_igConfigFlagsAdd( ImGuiConfigFlags_DockingEnable )
#endif

   hb_igThemeCherry()

   IF s_pHRB <> NIL
      sym := hb_hrbGetFunSym( s_pHRB, "IMINIT" )
      IF sym <> NIL
         BEGIN SEQUENCE WITH { |e| Break(e) }
            Eval( sym )
         RECOVER USING e
            __ErrorWindow_Create( "script ImInit function failure", ;
            e:Operation + Chr(10) + e:Description )
         END SEQUENCE
      ENDIF
      s_symImFrame := hb_hrbGetFunSym( s_pHRB, "IMFRAME" )
   ENDIF

   RETURN

PROCEDURE ImFrame
   IF s_pHRB <> NIL
      IF s_symImFrame <> NIL
         Eval( s_symImFrame )
      ELSE /* script does not contain PROC ImFrame, execute main function hoping it really has imgui widgets */
         hb_hrbDo( s_pHRB )
      ENDIF   
   ENDIF

   IG_MultiWin()

   RETURN

PROCEDURE __ErrorWindow_Create( cTitle, cText )
   STATIC nErrCount := 0
   IG_WinCreate( @__ErrorWindow(), "error:" + hb_NtoS( ++nErrCount ), { cTitle, cText } )
   RETURN

PROCEDURE __ErrorWindow( cTitle, cText )
   LOCAL lOpen := .T.
   IF ! HB_IsString( cTitle )
      cTitle := "Error"
   ENDIF
   igBegin( cTitle, @lOpen, ImGuiWindowFlags_Modal )
   igTextUnformatted( cText )
   IF ! lOpen .OR. igButton( "Dismiss" )
      IG_WinDestroy()
   ENDIF
   igEnd()
   RETURN

STATIC FUNCTION __cdpList()
   RETURN {"PL852", "EL737", "UA866", "PT850", "ES850", "EE775", "IS861", "TR857", "HE862" }   
 
/*
   // NEEDS DEBUG: full list upsets font atlas generation...
   LOCAL aList := hb_cdpList(), i

   FOR i := 1 TO Len( aList )
       
      IF aList[ i ] == "EN" .OR. Left( aList[ i ], 3 ) == "UTF"
         hb_ADel( aList, i--, .T. )
      ENDIF
   NEXT
   RETURN aList
*/
