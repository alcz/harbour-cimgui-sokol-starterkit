/*
    runner.prg    -- simplest possible Dear ImGui .hrb script runner

    by Aleksander Czajczyński

    license is MIT, see ../LICENSE
*/

#include "hbhrb.ch"

#include "hbimenum.ch"
#include "hbimstru.ch"

#ifndef __PLATFORM__WASM

#define __HBEXTERN__CIMGUI__REQUEST
#include "cimgui.hbx"

#define __HBEXTERN__HBCPAGE__REQUEST
#include "hbcpage.hbx"

#define __HBEXTERN__HARBOUR__REQUEST
#include "harbour.hbx"

#endif

REQUEST HB_CODEPAGE_UTF8EX

STATIC s_pHRB, s_symImFrame

PROCEDURE Main( cRun, cHiDPI )
   LOCAL aScriptHost, cBuf, nRead, lLoad := .T., lDynAddFiles := .F.

   hb_cdpSelect("UTF8EX")

   IG_MultiWin_Init()

   IF Empty( cRun )
      __ErrorWindow_Create( "no arguments specified", "usage: runner <file.hrb> or - (stdin) or + (GUI open/drop) <-hidpi>" )
      lLoad := .F.
   ELSEIF cRun == "@" .OR. cRun == "-" /* in future @ may force .hrb mode with less header checks */
      cBuf := Space( 4 )
      IF ( nRead := hb_pread( hb_getStdIn(), @cBuf, 4, 5000 ) ) < 4
         __ErrorWindow_Create( "STDIN error", "runner " + cRun + " parameter passed, but didn't get valid .hrb on STDIN, read " + hb_ntos( nRead ) + " bytes" )
         lLoad := .F.
      ELSEIF ! cBuf == hb_BChar( 0xC0 ) + "HRB" .AND. ! Left( cBuf, 1 ) == "*"
         /* .html#![...] in address bar of a browser denotes urlized .prg code
            .html#*[...] in address bar of a browser denotes urlized .hrb body
            STDIN of this example runner is only capable of "*" -> .hrb, as
            we don't have a built-in .prg (Harbour Compiler), reason is this
            source is MIT licensed, not GPL */
         __ErrorWindow_Create( "STDIN error", "file passed on STDIN doesn't look like .hrb module" )
         lLoad := .F.
      ELSE
         cRun := cBuf
         cBuf := Space( 32768 )
         DO WHILE ( nRead := hb_pread( hb_getStdIn(), @cBuf, 32768 ) ) > 0
            cRun += hb_BLeft( cBuf, nRead )
         ENDDO
         IF Left( cRun, 1 ) == "*"
            cRun := __unhbz( SubStr( cRun, 2 ) )
         ENDIF
      ENDIF
   ELSEIF cRun == "+" /* instead enable runtime adding of .hrb files using OS open file dialog and/or drag-and-drop */
      lDynAddFiles := .T.
      lLoad := .F.
   ENDIF

   IF lLoad
      BEGIN SEQUENCE WITH { |e| Break(e) }
         s_pHRB := hb_hrbLoad( HB_HRB_BIND_FORCELOCAL, cRun )
      RECOVER USING e
         __ErrorWindow_Create( ".hrb error", "unable to load script:" + ;
         StrTran( hb_BLeft( cRun, 16 ), hb_BChar( 0 ), "_" ) + ;
         IIF( hb_BLen( cRun ) > 16, "...<total length: " + hb_ntos( hb_BLen( cRun ) ) + ">" , "" ) + ;
         hb_BChar( 10 ) + e:Operation + hb_BChar( 10 ) + e:Description )
      END SEQUENCE
   ENDIF

   hb_sokol_imguiNoDefaultFont( .T. )

   sapp_run_default( "Dear ImGui HRB runner", 800, 600, ;
                     .T. /* clipboard access */, ;
                     HB_IsString( cHiDPI ) .AND. Lower( cHiDPI ) == "-hidpi", ;
                     IIF( lDynAddFiles, 16, 0 ) /* opt. enable drag-and-drop of up to 16 files at once */, ;
                     8192 /* maximum length of filesystem path supported */ )

#ifdef __PLATFORM__WASM
   IF ImFrame() # NIL /* dummy calls for emscripten, to be removed when those functions are properly requested from .c code */
      ImInit()
      ImDrop()
      ImAsyncFile()
#command DYNAMIC <fncs,...> => <fncs>()
#include "cimgui.hbx"
#include "hbcpage.hbx"
#include "hbct.hbx"
#include "emcc_uncool.ch"
#include "harbour.hbx"
#uncommand DYNAMIC <fncs,...> => <fncs>()
   ENDIF
#endif

   RETURN

PROCEDURE ImInit
   LOCAL sym
#ifdef __PLATFORM__WASM
   LOCAL cFontBuf
#pragma __binarystreaminclude "OpenSans-Regular.ttf"|cFontBuf := %s
   hb_igAddFontFromMemoryTTF( cFontBuf, 18.0, , __cdpList(), .T., .F. )
#else
//   hb_igAddFontFromFileTTF( "OpenSans-Regular.ttf", 18.0, , __cdpList(), .T., .F. )
   hb_igAddFontFromFileTTF( "UbuntuMono.ttf", 18.0, , __cdpList(), .T., .F. )
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
            __ErrorWindow_Create( "ImInit error", "script ImInit function failure", ;
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

PROCEDURE ImDrop( aFiles )
   LOCAL cFile

   FOR EACH cFile IN aFiles
#ifdef __PLATFORM__WASM
      IG_WinCreate( @__ErrorWindow(), "loading:" + hb_NtoS( cFile:__enumIndex ), ;
                    { "loading async", cFile + " size: " + hb_NtoS( hb_sokol_wasm_droppedfilesize( cFile:__enumIndex ) ) } )
      hb_sokol_wasm_droppedfileload( cFile:__enumIndex,, cFile )
//      hb_sokol_wasm_droppedfileload( cFile:__enumIndex,, { |cBody,nIndex| IIF( hb_isString( cBody ), ImAsyncFile( cBody, nIndex, cFile + ":codeblock" ), NIL ) } )
#else
      IG_WinCreate( @__ErrorWindow(), "loading:" + hb_NtoS( cFile:__enumIndex ), ;
                    { "local file", cFile } )
#endif
   NEXT

   RETURN

#ifdef __PLATFORM__WASM
PROCEDURE ImAsyncFile( cBody, nIndex, cName )
   IG_WinDestroy( "loading:" + hb_NtoS( nIndex ) )
   IG_WinCreate( @__ErrorWindow(), "completed:" + hb_NtoS( nIndex ), ;
                 { "load completed", cName + " size: " + hb_NtoS( Len( cBody ) ) + hb_EoL() + Left( cBody, 16 ) + "..." } )

   RETURN
#endif

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

/* -urlize -deurlize concept by Viktor Szakats,
   originally implemented in Harbour 3.4 hbmk2,
   for use with Harbour Playground
   and interactive hbdoc */

/* deurlize (url to body) */
STATIC FUNCTION __unhbz( cIn )
   LOCAL cTmp

   IF ! hb_IsString( cIn )
      RETURN NIL
   ENDIF

   cIn := hb_base64Decode( hb_StrReplace( cIn, "-_", "+/" ) )
   IF ( cTmp := hb_ZUncompress( cIn ) ) == NIL
      cTmp := cIn
   ENDIF

   RETURN cTmp

