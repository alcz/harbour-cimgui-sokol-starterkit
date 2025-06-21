/*
    yadbu.prg    -- yet another database utility

    by Aleksander Czajczyński

    license is MIT, see ../../LICENSE
*/

#include "fonts/IconsFontAwesome6.ch"
#include "hbimenum.ch"
#include "hbimstru.ch"

/* example requires Dear ImGui version 1.86+ */

#define TB_SIZE  40
#define TB_FLAGS ImGuiWindowFlags_NoDocking + ImGuiWindowFlags_NoTitleBar + ImGuiWindowFlags_NoResize + ImGuiWindowFlags_NoMove + ImGuiWindowFlags_NoScrollbar // + ImGuiWindowFlags_NoNavInputs
#define BTN_SIZE 30
#define TAB_SIZE 25

#ifndef ImGuiHoveredFlags_DelayNormal
#define ImGuiHoveredFlags_DelayNormal 0
#xtranslate ImGui::Shortcut( <v>, <r> ) => .F.
#endif

#ifndef ImGuiDockNodeFlags_NoDockingOverCentralNode
#define ImGuiDockNodeFlags_NoDockingOverCentralNode ImGuiDockNodeFlags_NoDockingInCentralNode
#endif

REQUEST HB_CODEPAGE_PL852, HB_CODEPAGE_PLISO, HB_CODEPAGE_PLWIN
REQUEST HB_CODEPAGE_HU852, HB_CODEPAGE_HU852C, HB_CODEPAGE_HUISO, HB_CODEPAGE_HUWIN
REQUEST HB_CODEPAGE_SK852, HB_CODEPAGE_SK852C, HB_CODEPAGE_SKISO, HB_CODEPAGE_SKWIN
REQUEST HB_CODEPAGE_CS852, HB_CODEPAGE_CS852C, HB_CODEPAGE_CSISO, HB_CODEPAGE_CSWIN
REQUEST HB_CODEPAGE_EL737, HB_CODEPAGE_ELWIN
REQUEST HB_CODEPAGE_UA866
REQUEST HB_CODEPAGE_PT850, HB_CODEPAGE_PT860
REQUEST HB_CODEPAGE_ES850, HB_CODEPAGE_ES850M, HB_CODEPAGE_ES850C, HB_CODEPAGE_ESWIN
REQUEST HB_CODEPAGE_EE775
REQUEST HB_CODEPAGE_DE858, HB_CODEPAGE_DE850, HB_CODEPAGE_DEWIN, HB_CODEPAGE_DEISO
REQUEST HB_CODEPAGE_FR850, HB_CODEPAGE_FRISO, HB_CODEPAGE_FRWIN, HB_CODEPAGE_FR850M, HB_CODEPAGE_FR850C
REQUEST HB_CODEPAGE_FI850
REQUEST HB_CODEPAGE_IS861
REQUEST HB_CODEPAGE_TR857
REQUEST HB_CODEPAGE_UTF8EX
#define ATLAS_CDPLIST { "PL852", "EL737", "UA866", "PT850", "PT860", "ES850", "EE775", "DE858", "IS861", "TR857", "HE862" }
REQUEST DBFCDX, HB_MEMIO

/* redacted array of workareas */
#define _WA_ID        1
#define _WA_ALIAS     2
#define _WA_RDD       3
#define _WA_FULLPATH  4
#define _WA_ORDERS    5
#define _WA_HIDDEN    6
#define _WA_SCROLLTO  7

/* array of files opened by multi-selection or drag'n'drop */
#define _OO_SEQ       1
#define _OO_NAME      2
#define _OO_SIZE      3
#define _OO_PATH      4
#define _OO_LOAD      5
#define _OO_ALIAS     6

THREAD STATIC s_nTBSize := TB_SIZE
THREAD STATIC s_aAliases := { }, s_nActive := 0
// THREAD STATIC l_AutoOpenDropped := .F.
THREAD STATIC s_cRDD := "DBFNTX", s_cCodepage := ""
THREAD STATIC s_hFontNumOnly

PROCEDURE MAIN
   LOCAL i, hFiles := { => }

   hb_cdpSelect("UTF8EX")

   IG_MultiWin_Init()
   InitInfos()

#ifdef __PLATFORM__WINDOWS
   hb_hSetCaseMatch( hFiles, .F. )
#endif
   FOR i := 1 TO PCount()
      IF File( HB_PValue( i ) )
         hFiles[ HB_PValue( i ) ] := NIL
      ENDIF
   NEXT

   IF Len( hFiles ) > 0
      IG_WinCreate( @AskToLoad(), "asktoloadcmd", , PrepFiles( hb_hKeys( hFiles ), .F. /* implement to skip emscrpiten parts */ ), "from command-line" )
   ENDIF

#ifndef __PLATFORM__WASM
   IF ! File( "OpenSans-Regular.ttf" )
      Alert("can't find my font")
   ENDIF
#endif
   hb_sokol_imguiNoDefaultFont( .T. )
   sapp_run_default( "Yet Another DataBase Utility", 800, 600, .T., .T., 16, 8192 )

#ifdef __PLATFORM__WASM
   IF ImFrame() # NIL /* dummy calls for emscripten, to be removed when those functions are properly requested from .c code */
      ImInit()
      DBFCDX()
      HB_MEMIO()
   ENDIF
#endif
   RETURN

PROCEDURE ImInit
#ifdef __PLATFORM__WASM
   LOCAL cFontBuf, cFontABuf
#pragma __binarystreaminclude "../OpenSans-Regular.ttf"|cFontBuf := %s
   hb_igAddFontFromMemoryTTF( cFontBuf, 18.0, , ATLAS_CDPLIST, .T., .F. )
#pragma __binarystreaminclude "../fonts/fa-solid-900.ttf"|cFontABuf := %s
   hb_igAddFontFromMemoryTTF( cFontABuf, 18.0 * ( 3 / 4 ), , { ICON_MIN_FA, ICON_MAX_FA, 0 }, .F., .T. )
   s_hFontNumOnly := hb_igAddFontFromMemoryTTF( cFontABuf, 18.0 * ( 3 / 4 ), , { Asc("0"), Asc("9"), 0 }, .F., .F. )
   hb_igAddFontFromMemoryTTF( cFontBuf, 38.0, , { 32, 32, 0 }, .F., .T. )
   /* fixed with font for numbers (something better? icon font doesn't even have a space, therefore a hack) */
#else
   hb_igAddFontFromFileTTF( "OpenSans-Regular.ttf", 18.0, , ATLAS_CDPLIST, .T., .F. )
   hb_igAddFontFromFileTTF( "fonts/fa-solid-900.ttf", 18.0 * ( 3 / 4 ), , { ICON_MIN_FA, ICON_MAX_FA, 0 }, .F., .T. )
   s_hFontNumOnly := hb_igAddFontFromFileTTF( "fonts/fa-solid-900.ttf", 18.0 * ( 3 / 4 ), , { Asc("0"), Asc("9"), 0 }, .F., .F. )
   hb_igAddFontFromFileTTF( "OpenSans-Regular.ttf", 38.0, , { 32, 32, 0 }, .F., .T. )
#endif

   hb_sokol_imguiFont2Texture()

   hb_igConfigFlagsAdd( ImGuiConfigFlags_NavEnableKeyboard )
#ifdef ImGuiConfigFlags_DockingEnable
   hb_igConfigFlagsAdd( ImGuiConfigFlags_DockingEnable )
#endif
#ifdef ImGuiIO_ConfigDockingWithShift
   ImGuiIO( igGetIO() ):ConfigDockingWithShift := .T.
#endif
   RETURN

PROCEDURE ImFrame
   __DockSpace()
   __Toolbar()
   __TabBar()
   __OverviewUI()
   __Areas()
   IG_MultiWin()
   Toolbox()
   RETURN

PROCEDURE ImDrop( aFiles )
   LOCAL cFile
   FOR EACH cFile IN aFiles
#ifdef __PLATFORM__WASM
      IG_WinCreate( @__ErrorWindow(), "loading:" + hb_NtoS( cFile:__enumIndex ), ;
                    { "loading async", cFile + " size: " + hb_NtoS( hb_sokol_wasm_droppedfilesize( cFile:__enumIndex ) ) } )
      hb_sokol_wasm_droppedfileload( cFile:__enumIndex,, cFile )
//    hb_sokol_wasm_droppedfileload( cFile:__enumIndex,, { |cBody,nIndex| IIF( hb_isString( cBody ), ImAsyncFile( cBody, nIndex, cFile + ":codeblock" ), NIL ) } )
#elseif __PLATFORM__WINDOWS
      // use NETDISK() to detect and open a networked file in some buffered way
      IF Left( c, 2 ) == "\\" .OR. ( SubStr( c, 2, 1 ) == ":" .AND. NetDisk( Left( c, 1 ) )
      ENDIF
#endif
   NEXT

   IG_WinCreate( @AskToLoad(), "asktoload", , PrepFiles( aFiles ) )

//   __ErrorWindow_Create( "dropped files", hb_valToExp( aFiles ) )

   RETURN

PROCEDURE PrepFiles( aFiles )
   LOCAL aTable, aTmp, a

   IF HB_IsArray( aFiles )
      aTable := Array( Len( aFiles ) )
      FOR EACH a IN aFiles
         /* keeping original index is significant only on WebAssembly implementation of file upload within sokol and emscripten... */
         aTable[ a:__enumIndex ] := { a:__enumIndex /* original index */, a, /* file size */, /* path */, .T. /* load/ignore */, Space( 32 ) }
      NEXT
      aFiles := NIL
      aTmp := { }
      FOR EACH a IN aTable
#ifdef __PLATFORM__WASM
         a[ _OO_SIZE ] := hb_sokol_wasm_droppedfilesize( a:__enumIndex )
         a[ _OO_PATH ] := ""
#else
         a[ _OO_SIZE ] := hb_FSize( a[ _OO_NAME ] )
         a[ _OO_PATH ] := hb_FNameDir( a[ _OO_NAME ] )
         a[ _OO_NAME ] := hb_FNameNameExt( a[ _OO_NAME ] )
#endif
         IF a[ _OO_SIZE ] == 0 /* ignore empty or folder for now */
            AAdd( aTmp, a:__enumIndex )
         ENDIF
      NEXT
      FOR EACH a IN aTmp
         hb_ADel( aTable, a, .T. )
      NEXT
      IF Len( aTable ) == 0
         __ErrorWindow_Create( "dropped files", "all dropped files were 0 bytes in size or were folders" )
         IG_WinDestroy("asktoload")
         RETURN
      ENDIF
   ENDIF

   RETURN aTable

PROCEDURE AskToLoad( aTable, cMode )
   STATIC a, aDragDelta := {0, 0}
   STATIC nTableFlags := ImGuiTableFlags_Resizable + ImGuiTableFlags_RowBg + ImGuiTableFlags_SizingFixedFit + ImGuiTableFlags_NoBordersInBody
   STATIC lShared := .T., lReadOnly := .T.
   LOCAL aTmp, lWarnExt := .F.

   IF ! HB_IsString( cMode )
      cMode := "drag&drop"
   ENDIF

   ImGui::SetNextWindowSize( {400, 250}, ImGuiCond_Once )
   ImGui::Begin( "Confirm opening " + cMode,, ImGuiWindowFlags_AlwaysAutoResize )

   IF ImGui::BeginTable( "TLoad", 5, nTableFlags )

      ImGui::TableSetupColumn( "Load?" )
      ImGui::TableSetupColumn( "Name", ImGuiTableColumnFlags_NoHide )
      ImGui::TableSetupColumn( "Size" )
      ImGui::TableSetupColumn( "Alias" )
      ImGui::TableSetupColumn( "Path",, 128 )
      ImGui::TableHeadersRow()

      FOR EACH a IN aTable
         ImGui::TableNextRow()
         ImGui::TableNextColumn()
         ImGui::Checkbox( "##askf" + hb_NtoS( a[ _OO_SEQ ] ), @a[ _OO_LOAD ] )
         ImGui::TableNextColumn()
         ImGui::SelectableBool( IIF( ! KnownExt( a[ _OO_NAME ] ), ( lWarnExt := .T., ICON_FA_CIRCLE_EXCLAMATION + " " ), "" ) + a[ _OO_NAME ] )
         IF ImGui::IsItemActive() .AND. ! ImGui::IsItemHovered() // .AND. ! HB_IsArray( aTmp )
            /* you can reorder index files up and down to match (follow) the database */
            ImGui::GetMouseDragDelta( @aDragDelta, 0 )
            IF Abs( aDragDelta[ 2 ] ) >= 6 /* compensate padding, which this code does not expect (should read style padding px?) */
              nNext := a:__enumIndex + IIF( aDragDelta[ 2 ] < 0.0, -1, 1 )
              IF nNext >= 1 .AND. nNext <= Len( aTable )
                 aTmp := AClone( aTable )
                 aTmp[ a:__enumIndex ] := aTable[ nNext ]
                 aTmp[ nNext ] := aTable[ a:__enumIndex ]
                 ImGui::ResetMouseDragDelta()
              ENDIF
            ENDIF
         ENDIF

         ImGui::TableNextColumn()
         ImGui::PushFont( s_hFontNumOnly )
         ImGui::Text( Transform( a[ 3 ], "999 999 999 999" ) )
         ImGui::PopFont()
         ImGui::TableNextColumn()
         ImGui::PushItemWidth( 100 )
         ImGui::InputText( "##askalias" + hb_NtoS( a[ _OO_SEQ ] ), @a[ _OO_ALIAS ],, ImGuiInputTextFlags_CharsUppercase )
         ImGui::PopItemWidth()
         ImGui::TableNextColumn()
         ImGui::Text( a[ _OO_PATH ] )
         IF ImGui::IsItemHovered()
            ImGui::SetTooltip( a[ _OO_PATH ] )
         ENDIF

      NEXT
      ImGui::EndTable()
   ENDIF
   IF lWarnExt
      ImGui::Text( "some of the files have unrecognized extensions" )
   ENDIF
#ifndef __PLATFORM__WASM
   IF ImGui::Button("Open")
      IF OpenFromDisk( aTable, lShared, lReadOnly )
         ReloadAliases()
         IG_WinDestroy()
      ENDIF
   ENDIF
   ImGui::SameLine()
#endif

#ifndef __PLATFORM__WASM
   IF ImGui::Button("Copy to MEM: and Open")
      FOR EACH a IN aTable
         IF ! a[ _OO_LOAD ]
            LOOP
         ENDIF
         hb_vfCopyFile( a[ _OO_PATH ] + a[ _OO_NAME ], "mem:" + a[ _OO_NAME ] )
         IF Lower( hb_FNameExt( a[ _OO_NAME ] ) ) == ".dbf"
            hb_vfCopyFile( a[ _OO_PATH ] + hb_FNameName( a[ _OO_NAME ] ) + ".dbt", "mem:" + hb_FNameName( a[ _OO_NAME ] ) + ".dbt" )
            hb_vfCopyFile( a[ _OO_PATH ] + hb_FNameName( a[ _OO_NAME ] ) + ".fpt", "mem:" + hb_FNameName( a[ _OO_NAME ] ) + ".fpt" )
            hb_vfCopyFile( a[ _OO_PATH ] + hb_FNameName( a[ _OO_NAME ] ) + ".smt", "mem:" + hb_FNameName( a[ _OO_NAME ] ) + ".smt" )
         ENDIF
         a[ 4 ] := "mem:"
      NEXT
#else
   IF ImGui::Button("Open")
#endif
      IF OpenFromDisk( aTable, lShared, lReadOnly )
         ReloadAliases()
         IG_WinDestroy()
      ENDIF
   ENDIF

   ImGui::SameLine()
   IF ImGui::Button("Copy to MEM:")
      FOR EACH a IN aTable
         IF ! a[ _OO_LOAD ]
            LOOP
         ENDIF
         hb_vfCopyFile( a[ _OO_PATH ] + a[ _OO_NAME ], "mem:" + a[ _OO_NAME ] )
         IF Lower( hb_FNameExt( a[ _OO_NAME ] ) ) == ".dbf"
            hb_vfCopyFile( a[ _OO_PATH ] + hb_FNameName( a[ _OO_NAME ] ) + ".dbt", "mem:" + hb_FNameName( a[ _OO_NAME ] ) + ".dbt" )
            hb_vfCopyFile( a[ _OO_PATH ] + hb_FNameName( a[ _OO_NAME ] ) + ".fpt", "mem:" + hb_FNameName( a[ _OO_NAME ] ) + ".fpt" )
            hb_vfCopyFile( a[ _OO_PATH ] + hb_FNameName( a[ _OO_NAME ] ) + ".smt", "mem:" + hb_FNameName( a[ _OO_NAME ] ) + ".smt" )
         ENDIF
         IG_WinDestroy()
      NEXT
   ENDIF

   ImGui::SameLine()                                                                                     
   IF ImGui::Button("Discard")
      IG_WinDestroy()
   ENDIF

   ImGui::Checkbox( "Shared", @lShared )
   ImGui::SameLine()
   ImGui::Checkbox( "Read Only", @lReadOnly )

   ImGui::End()

   IF HB_IsArray( aTmp )
      aTable := aTmp
   ENDIF

   RETURN

FUNCTION OpenFromDisk( aTable, lShared, lReadOnly )
   LOCAL a, c, i

#ifdef __PLATFORM__WASM
   lShared := .F.
#endif

   IF ! HB_IsArray( aTable )
      aTable := { { 1, aTable, 0, "", .T., } }
   ENDIF

   FOR EACH a IN aTable
      IF ! a[ _OO_LOAD ]
         LOOP
      ENDIF
      IF ( c := Lower( hb_FNameExt( a[ _OO_NAME ] ) ) ) == ".dbf" .OR. ;
         ! KnownExt( a[ _OO_NAME ] )

         c := a[ _OO_ALIAS ]
         IF Empty( c )
            c := Upper( hb_FNameName( a[ _OO_NAME ] ) )
         ENDIF /* something to prevent duplicate aliases */
         c := AllTrim( c )
         IF Select( c ) > 0
            FOR i := 1 TO 999
               IF Select( c + hb_NtoS( i ) ) == 0
                  a[ _OO_ALIAS ] := c + hb_NtoS( i )
                  EXIT
               ENDIF
            NEXT
         ENDIF

         DBUseArea( .T., s_cRDD, a[ _OO_PATH ] + a[ _OO_NAME ], IIF( ! Empty( a[ _OO_ALIAS ] ), a[ _OO_ALIAS ], NIL ), lShared, lReadOnly, IIF( hb_cdpExists( s_cCodePage ), s_cCodePage, "EN" ) )

      ELSEIF Used()
         IF c == ".cdx" .OR. c == ".ntx" .OR. c == ".nsx"

            OrdListAdd( a[ _OO_PATH ] + a[ _OO_NAME ], IIF( ! Empty( a[ _OO_ALIAS ] ), a[ _OO_ALIAS ], NIL ) /* only specific order from file */ )

         ENDIF
      ENDIF
   NEXT

   RETURN .T.

STATIC FUNCTION KnownExt( cName )
   LOCAL cExt := Lower( hb_FNameExt( cName ) )

   SWITCH cExt
      CASE ".dbf" 
      CASE ".dbt"
      CASE ".ntx"
      CASE ".cdx"
      CASE ".fpt"
      CASE ".smt"
      CASE ".dbv"
      CASE ".nsx"
         RETURN .T.
   END SWITCH

   RETURN .F.

#ifdef __PLATFORM__WASM
PROCEDURE ImAsyncFile( cBody, nIndex, cName )
   IG_WinDestroy( "loading:" + hb_NtoS( nIndex ) )
   hb_memoWrit( "mem:" + cFile, cBody )
   IG_WinCreate( @__ErrorWindow(), "completed:" + hb_NtoS( nIndex ), ;
                 { "load completed", cName + " size: " + hb_NtoS( Len( cBody ) ) + hb_EoL() + Left( cBody, 16 ) + "..." } )

   RETURN
#endif

PROCEDURE __ErrorWindow_Create( cTitle, cText )
   STATIC nErrCount := 0
   IG_WinCreate( @__ErrorWindow(), "error:" + hb_NtoS( ++nErrCount ), { cTitle + "##err" + hb_NtoS( nErrCount ), cText } )
   RETURN

PROCEDURE __ErrorWindow( cTitle, cText )
   LOCAL lOpen := .T.
   IF ! HB_IsString( cTitle )
      cTitle := "Error"
   ENDIF
   ImGui::Begin( cTitle, @lOpen, ImGuiWindowFlags_Modal )
   ImGui::TextUnformatted( cText )
   IF ! lOpen .OR. igButton( "Dismiss" )
      IG_WinDestroy()
   ENDIF
   ImGui::End()
   RETURN

PROCEDURE NEWFILE( cRDD )
   FieldDesigner_Create( cRDD )
   RETURN

PROCEDURE OPENFILE()
#ifdef __PLATFORM__WINDOWS
   LOCAL xFile
   LOCAL nFlags := NIL
   xFile := win_GetOpenFileName( @nFlags, "Open database or index",, "*.dbf", ;
                                  { { "DBF database", "*.dbf" }, ;
                                    { "NTX index",    "*.ntx" }, ;
                                    { "CDX index",    "*.cdx" }, ;
                                    { "NSX index",    "*.nsx" }, ;
                                    { "All known",    "*.dbf;*.ntx;*.cdx;*.nsx" }, ;
                                    { "All files",    "*.*" } ;
                                  } )

   IF hb_BChar( 0 ) $ xFile /* At(), hb_BAt() are unable to locate Chr( 0 ) */
      xFile := hb_ATokens( xFile, hb_BChar( 0 ) )
      AEval( xFile, { |x,n| xFile[ n ] := xFile[ 1 ] + hb_ps() + x }, 2 )
      hb_ADel( xFile, 1, .T. )
   ENDIF

   IF hb_IsArray( xFile )
      IG_WinCreate( @AskToLoad(), "asktoloadofn", , PrepFiles( xFile, .F. ), "from multple selection" )
   ELSEIF File( xFile )
      IF OpenFromDisk( xFile, .T., .T. )
         ReloadAliases()
      ENDIF
   ENDIF
#endif
   RETURN

PROCEDURE SAVEFILE()
PROCEDURE SAVEFILEAS()
PROCEDURE SAVEALL()
PROCEDURE SHOWCODE()

STATIC PROCEDURE __Toolbar()
   LOCAL pMV := ImGui::GetMainViewPort(), nCX, i
   STATIC a := { 0, 0 }
   STATIC s_aStyles := { ; /* style does not reset all customizations of others FIXME */
                         { "VSCode-like",   @hb_igThemeVSC() }, ;
                         { "Win10-like",    { || s_nTBSize := 40, ImGui::StyleColorsLight( ImGui::GetStyle() ), hb_igThemeWin10() } }, ;
                         { "Cherry",        { || s_nTBSize := 30, ImGui::StyleColorsDark( ImGui::GetStyle() ), hb_igThemeCherry() } }, ;
                         { "ImGui dark",    { || s_nTBSize := 40, ImGui::StyleColorsDark( ImGui::GetStyle() ) } }, ;
                         { "ImGui light",   { || s_nTBSize := 40, ImGui::StyleColorsLight( ImGui::GetStyle() ) } }, ;
                         { "ImGui classic", { || s_nTBSize := 40, ImGui::StyleColorsClassic( ImGui::GetStyle() ) } } ;
                       }

   STATIC s_cStyle := "default", s_lCodePageOpen := .F., s_lCodePageDirty := .F., s_nQuickScale := 1.0, s_lShiftDock := .T.

   ImGui::SetNextWindowPos( ImGuiViewport( pMV ):Pos )
   ImGui::SetNextWindowSize( { ImGuiViewport( pMV ):Size[ 1 ], s_nTBSize * s_nQuickScale } )
   ImGui::SetNextWindowViewport( ImGuiViewport( pMV ):ID )

   ImGui::PushStyleVarFloat( ImGuiStyleVar_WindowBorderSize, 0 )
   ImGui::Begin( "Toolbar",, TB_FLAGS )
   ImGui::PopStyleVar( 1 )

    IF ImGui::Button( ICON_FA_FILE + " " + ICON_FA_CARET_DOWN ) ;
       .OR. ImGui::Shortcut( ImGuiMod_Ctrl + ImGuiKey_N, ImGuiInputFlags_RouteGlobal )
       ImGui::OpenPopup("NewMenu")
    ENDIF
    IF ImGui::IsItemHovered( ImGuiHoveredFlags_DelayNormal )
       ImGui::SetTooltip("New File (Ctrl+N)" + IIF( s_nActive > 0, HB_EoL() + "use Shift to copy current DB struct", "" ) )
    ENDIF

    ImGui::SetNextWindowPos( ImGui::GetCursorPos( @a ) )
    ImGui::PushStyleVarVec2( ImGuiStyleVar_ItemSpacing, { 0, 10 } )
    IF ImGui::BeginPopup("NewMenu")

        IF ImGui::MenuItemBool( "DBFNTX", "\t.dbf" )
           NewFile( "DBFNTX" )
        ENDIF
        IF ImGui::IsItemHovered( ImGuiHoveredFlags_DelayNormal )
            ImGui::SetTooltip("use DBFNTX RDD")
        ENDIF
        IF ImGui::MenuItemBool( "DBFCDX", "\t.dbf" )
           NewFile( "DBFCDX" )
        ENDIF
        IF ImGui::IsItemHovered( ImGuiHoveredFlags_DelayNormal )
           ImGui::SetTooltip("use DBFCDX RDD")
        ENDIF

        ImGui::EndPopup()
    ENDIF
    ImGui::PopStyleVar( 1 )

    ImGui::SameLine()
    IF ImGui::Button( ICON_FA_FOLDER_OPEN ) ;
       .OR. ImGui::Shortcut( ImGuiMod_Ctrl + ImGuiKey_O, ImGuiInputFlags_RouteGlobal )
       OpenFile()
    ENDIF
    IF ImGui::IsItemHovered( ImGuiHoveredFlags_DelayNormal )
       ImGui::SetTooltip("Open File (Ctrl+O)" + hb_EoL() + "multiselection" + hb_EoL() + "drag and drop to open file" + hb_EoL() + "are supported" )
    ENDIF

    ImGui::BeginDisabled( s_nActive < 1 )

    ImGui::SameLine()
    nCX := ImGui::GetCursorPosX()
    IF ImGui::Button( ICON_FA_FLOPPY_DISK ) ;
       .OR. ImGui::Shortcut( ImGuiMod_Ctrl + ImGuiKey_S, ImGuiInputFlags_RouteGlobal )
        SaveFile(.F.)
    ENDIF
    IF ImGui::IsItemHovered( ImGuiHoveredFlags_DelayNormal )
       ImGui::SetTooltip("Save File (Ctrl+S)")
    ENDIF

    ImGui::SameLine(0, 0)
    ImGui::SeparatorEx( ImGuiSeparatorFlags_Vertical )
    ImGui::SameLine(0, 0)
    ImGui::PushStyleVarVec2( ImGuiStyleVar_FramePadding, { 2, ImGuiStyle( ImGui::GetStyle() ):FramePadding[ 2 ] } )
    IF ImGui::Button( ICON_FA_CARET_DOWN ) 
       ImGui::OpenPopup("SaveMenu")
    ENDIF
    ImGui::PopStyleVar( 1 )
    ImGui::SetNextWindowPos( { nCX, ImGui::GetCursorPosY() } )
    IF ImGui::BeginPopup("SaveMenu")
        IF ImGui::MenuItemBool("Save As...")
           SaveFileAs(.F.)
        ENDIF
        IF ImGui::MenuItemBool("Save All", "\tCtrl+Shift+S")
           SaveAll()
        ENDIF
#ifndef __PLATFORM__WASM
        ImGui::TextWrapped( ICON_FA_CIRCLE_EXCLAMATION + " " + ;
                            "Please note that any changes to on-disk databases are saved immediately as edited in table" + hb_EoL() + ;
                            "Do not edit your production databases with this GUI tool of unproven quality!" )
#endif
        ImGui::EndPopup()
    ENDIF

/*
    IF ImGui::Shortcut( ImGuiMod_Ctrl + ImGuiMod_Shift + ImGuiKey_S, ImGuiInputFlags_RouteGlobal )
        SaveAll()
*/

    ImGui::EndDisabled()

    ImGui::SameLine()
    ImGui::SeparatorEx( ImGuiSeparatorFlags_Vertical )
    ImGui::SameLine()

    ImGui::Text("Style")
    ImGui::SameLine()
    ImGui::SetNextItemWidth(100)

    IF ImGui::BeginCombo( "##style", s_cStyle )
       FOR i := 1 TO Len( s_aStyles )
          IF ImGui::SelectableBool( s_aStyles[ i ][ 1 ], s_aStyles[ i ][ 1 ] == s_cStyle )
             s_cStyle := s_aStyles[ i ][ 1 ]
             Eval( s_aStyles[ i ][ 2 ] )
          ENDIF
          IF Len( s_aStyles ) > i
             ImGui::Separator()
          ENDIF
       NEXT 
       ImGui::EndCombo()
    ENDIF

    ImGui::SameLine()
    ImGui::SeparatorEx( ImGuiSeparatorFlags_Vertical )
    ImGui::SameLine()

    ImGui::Text("RDD")
    ImGui::SameLine()
    ImGui::SetNextItemWidth(100)

    IF ImGui::BeginCombo( "##rdd", s_cRDD )
       FOR i := 1 TO Len( RDDList() )
          IF ImGui::SelectableBool( RDDList()[ i ], RDDList()[ i ] == s_cRDD )
             s_cRDD := RDDList()[ i ]
             RDDSetDefault( s_cRDD )
          ENDIF
          IF Len( RDDList() ) > i
             ImGui::Separator()
          ENDIF
       NEXT 
       ImGui::EndCombo()
    ENDIF

    IF ImGui::IsItemHovered( ImGuiHoveredFlags_DelayNormal )
       ImGui::SetTooltip("preferred Replacable Data Driver setting" + hb_EoL() + "not used in case the DBF file already has accompanying *.ntx *.cdx *.fpt")
    ENDIF

    ImGui::SameLine()
    ImGui::SeparatorEx( ImGuiSeparatorFlags_Vertical )
    ImGui::SameLine()

    ImGui::Text("Codepage")
    ImGui::SameLine()
    ImGui::SetNextItemWidth(100)

    hb_igComboText( "##cdp", @s_cCodePage, 10, hb_cdpList(), Empty( s_cCodePage ), ImGuiInputTextFlags_CharsUppercase, "EN", @s_lCodePageOpen )
    IF ! s_lCodePageOpen .AND. ImGui::IsItemHovered( ImGuiHoveredFlags_DelayNormal )
       ImGui::SetTooltip( hb_cdpInfo( IIF( hb_cdpExists( s_cCodePage ), s_cCodePage, "EN" ) ) + hb_EoL() + ;
                          "preferred database codepage for opened files" + hb_EoL() + ;
                          "input is auto-completed, erase to see all possibilities")
    ENDIF
    IF ImGui::IsItemEdited()
       s_lCodePageDirty := .T.
    ELSEIF ! ImGui::IsItemFocused() .AND. s_lCodePageDirty 
       IF ( AScan( hb_cdpList(), RTrim( s_cCodePage ) ) == 0 )
          s_cCodePage := "EN"
       ENDIF
       s_lCodePageDirty := .F.
    ENDIF
    ImGui::SameLine()

    ImGui::BeginDisabled( /* */ )

    ImGui::SameLine()
    IF ImGui::Button( ICON_FA_CLONE )
       /* */
    ENDIF
    IF ImGui::IsItemHovered( ImGuiHoveredFlags_DelayNormal )
       ImGui::SetTooltip("Convert data")
    ENDIF
    ImGui::SameLine()
    ImGui::SeparatorEx( ImGuiSeparatorFlags_Vertical )
    ImGui::EndDisabled()
    ImGui::SameLine()
    ImGui::BeginDisabled( /* */ )
    IF ImGui::Button( ICON_FA_BOLT ) ; // ICON_FA_BOLT, ICON_FA_RIGHT_TO_BRACKET) ||
       .OR. ImGui::Shortcut( ImGuiMod_Ctrl + ImGuiKey_P, ImGuiInputFlags_RouteGlobal )
       ShowCode()
    ENDIF
    IF ImGui::IsItemHovered( ImGuiHoveredFlags_DelayNormal )
       ImGui::SetTooltip("Preview Code (Ctrl+P)")
    ENDIF
    ImGui::EndDisabled()

    ImGui::SameLine()
    IF ImGui::Button( ICON_FA_STAR )
       /* */
    ENDIF
    IF ImGui::IsItemHovered( ImGuiHoveredFlags_DelayNormal )
       ImGui::SetTooltip( "Favourites" )
    ENDIF

    ImGui::SameLine()
    ImGui::SeparatorEx( ImGuiSeparatorFlags_Vertical )

    ImGui::SameLine()
    IF ImGui::Button( ICON_FA_GEAR )
       ImGui::OpenPopup("Qconf")
    ENDIF
    IF ImGui::BeginPopup("Qconf")
       ImGui::Text( "Requested DPI font scaling: " + hb_ntos( sapp_dpi_scale() ) )
       ImGui::Text( "Active DPI font scaling: " + hb_ntos( __igfonthidpitest() ) )
       IF ImGui::SliderFloat( "rescale whole app by a factor", @s_nQuickScale, 0.5, 3.0, "%.1f" )
          /* ImGuiStyle( igGetStyle() ):ScaleAllSizes( s_nQuickScale ) */
          ImGuiIO( igGetIO() ):FontGlobalScale := s_nQuickScale
          s_nTBSize := TB_SIZE * s_nQuickScale 
       ENDIF
       IF ImGui::Button( IIF( sapp_is_fullscreen(), "Exit", "Enter" ) + " full screen" )
          sapp_toggle_fullscreen()
       ENDIF
#ifdef ImGuiIO_ConfigDockingWithShift
       IF ImGui::Checkbox( "docking a window requires shift key", @s_lShiftDock )
          ImGuiIO( igGetIO() ):ConfigDockingWithShift := s_lShiftDock
       ENDIF
#endif
       ImGui::EndPopup()
    ENDIF

    ImGui::End()

    RETURN

STATIC PROCEDURE __DockSpace()
   LOCAL pMV := ImGui::GetMainViewPort(), nCX, nDSID
   LOCAL nDRight, nDLeft, nDRight1, nDRight2, nDLeft1, nDLeft2, nDTop, nVH
   STATIC a := { 0.0, 0.0 }, s_lInit := .F.

   ImGui::SetNextWindowPos( { ImGuiViewport( pMV ):Pos[ 1 ], ImGuiViewport( pMV ):Pos[ 2 ] + s_nTBSize /* TB_SIZE */ } )
   ImGui::SetNextWindowSize( { ImGuiViewport( pMV ):Size[ 1 ], ImGuiViewport( pMV ):Size[ 2 ] - s_nTBSize /* TB_SIZE */ } )
   ImGui::SetNextWindowViewport( ImGuiViewport( pMV ):ID )

   ImGui::PushStyleVarFloat( ImGuiStyleVar_WindowRounding, 0.0 )
   ImGui::PushStyleVarFloat( ImGuiStyleVar_WindowBorderSize, 0.0 )

#define DS_FLAGS ImGuiWindowFlags_NoTitleBar + ImGuiWindowFlags_NoCollapse + ImGuiWindowFlags_NoResize + ;
                 ImGuiWindowFlags_NoMove + ImGuiWindowFlags_NoBringToFrontOnFocus + ImGuiWindowFlags_NoNavFocus + ;
                 ImGuiWindowFlags_NoBackground

   ImGui::PushStyleVarVec2( ImGuiStyleVar_WindowPadding, a /* { 0.0, 0.0 } */ )
   ImGui::Begin( "DockSpace", NIL, DS_FLAGS )
   ImGui::PopStyleVar( 3 )

   nDSID := ImGui::GetIDStr( "MyDockSpace" )
   ImGui::DockSpace( nDSID, a /* { 0.0, 0.0 } */, ;
                     ImGuiDockNodeFlags_PassthruCentralNode + ImGuiDockNodeFlags_NoDockingOverCentralNode )

   IF ! s_lInit

        ImGui::DockBuilderRemoveNode( nDSID )
        ImGui::DockBuilderAddNode( nDSID, ImGuiDockNodeFlags_PassthruCentralNode + ImGuiDockNodeFlags_DockSpace )
        ImGui::DockBuilderSetNodeSize( nDSID, ImGuiViewport( pMV ):Size )
        nDRight := ImGui::DockBuilderSplitNode( nDSID, ImGuiDir_Right, 350.0 / ImGuiViewport( pMV ):Size[ 1 ], NIL, @nDSID )
        nDLeft  := ImGui::DockBuilderSplitNode( nDSID, ImGuiDir_Left, 300.0 / ( ImGuiViewport( pMV ):Size[ 1 ] - 350 ), NIL, @nDSID )

        nVH := ImGuiViewport( pMV ):Size[ 2 ] - s_nTBSize /* TB_SIZE */
        ImGui::DockBuilderSplitNode( nDRight, ImGuiDir_Up, 230.0 / nVH, @nDRight1, @nDRight2 )
        ImGui::DockBuilderSplitNode( nDLeft, ImGuiDir_Down, 100.0 / nVH, @nDLeft1, @nDLeft2 )
        nDTop := ImGui::DockBuilderSplitNode( nDSID, ImGuiDir_Up, TAB_SIZE / nVH, NIL, @nDSID )

        ImGui::DockBuilderDockWindow( "FileTabs", nDTop )
        ImGui::DockBuilderDockWindow( "Overview", nDLeft2 )
        ImGui::DockBuilderDockWindow( "Toolbox", nDLeft1 )
        ImGui::DockBuilderDockWindow( "Widgets", nDRight1 )
//        ImGui::DockBuilderDockWindow( "Properties", nDRight2 )
//        ImGui::DockBuilderDockWindow( "Events", nDRight2 )
        ImGui::DockBuilderFinish( nDSid );

        s_lInit := .T.

   ENDIF

   // ImGui::DockBuilderGetCentralNode(dockspace_id)

    ImGui::End()

   RETURN

STATIC PROCEDURE __TabBar()
    LOCAL aWA, lOpen
    STATIC s_pWinClass, a := { 4.0, 0.0 }

#define TABW_FLAGS ImGuiWindowFlags_NoTitleBar + ImGuiWindowFlags_NoResize + ImGuiWindowFlags_NoCollapse + ImGuiWindowFlags_NoMove + ImGuiWindowFlags_NoScrollbar + ImGuiWindowFlags_NoNav

    IF s_pWinClass == NIL
       s_pWinClass := ImGuiWindowClass_ImGuiWindowClass()
       ImGuiWindowClass( s_pWinClass ):DockNodeFlagsOverrideSet := ImGuiDockNodeFlags_NoTabBar + ;
                                                                   ImGuiDockNodeFlags_NoResize + ;
                                                                   ImGuiDockNodeFlags_NoDockingOverMe
    ENDIF

    ImGui::PushStyleVarVec2( ImGuiStyleVar_WindowPadding, a /* { 4.0, 0.0 } */ )
    ImGui::SetNextWindowClass( s_pWinClass )
    ImGui::Begin( "FileTabs", 0, TABW_FLAGS )

    IF ImGui::BeginTabBar(".Tabs", ImGuiTabBarFlags_NoTabListScrollingButtons )
       ImGui::PopStyleVar()

       FOR EACH aWA in s_aAliases

          lOpen := .T.

          IF ImGui::BeginTabItem( ICON_FA_DATABASE + " " + aWA[ _WA_ALIAS ], ;
                                  @lOpen, ;
                                  IIF( s_nActive == aWA[ _WA_ID ], ImGuiTabItemFlags_SetSelected, ImGuiTabItemFlags_NoCloseButton ) )
             IF ! lOpen
                DBSelectArea( aWA[ _WA_ID ] )
                DBCloseArea()
                ReloadAliases()
             ELSEIF ImGui::IsItemFocused()
                s_nActive := aWA[ _WA_ID ]
                ImGui::SetWindowFocusStr( aWA[ _WA_ALIAS ] )
             ENDIF
             ImGui::EndTabItem()
          ENDIF

       NEXT

       // IF ImGui::IsItemHovered( ImGuiHoveredFlags_DelayNormal )
       //    SetTooltip( cFileName + " " + aWA[ _WA_ID ] )
       // ENDIF

       ImGui::EndTabBar()
    ELSE
       ImGui::PopStyleVar()
    ENDIF
    ImGui::End()

    RETURN

STATIC PROCEDURE __OverviewUI()
   LOCAL lOpen := .F., cTmp
   LOCAL cPropName, uValue, nKey, aStruct, a

   STATIC nTableFlags := ImGuiTableFlags_BordersV + ImGuiTableFlags_BordersOuterH + ;
                         ImGuiTableFlags_Resizable + ImGuiTableFlags_RowBg + ;
                         ImGuiTableFlags_NoBordersInBody

   STATIC nTextBWidth := NIL

   STATIC b := NIL

   IF nTextBWidth == NIL
      igCalcTextSize( @nTextBWidth,"A" ) // -> {x,y}
      nTextBWidth := nTextBWidth[ 1 ]
   ENDIF

   ImGui::Begin("Overview")
   IF ImGui::BeginTable( "TView", 1, nTableFlags )

      ImGui::TableNextRow()
      ImGui::TableNextColumn()

      SelectActiveInUI()
      IF Used()
         ImGui::TreeNodeExStr( "Current DB focus: " + Alias(), ImGuiTreeNodeFlags_Leaf + ;
                                                      ImGuiTreeNodeFlags_NoTreePushOnOpen + ;
                                                      ImGuiTreeNodeFlags_SpanFullWidth )
      ENDIF

      IF Len( s_aAliases ) > 0
         lOpen := ImGui::TreeNodeExStr( "Tables", ImGuiTreeNodeFlags_SpanFullWidth )
      ELSE
         ImGui::TreeNodeExStr( "Tables (not used)", ImGuiTreeNodeFlags_Leaf + ;
                                         ImGuiTreeNodeFlags_Bullet + ;
                                         ImGuiTreeNodeFlags_NoTreePushOnOpen + ;
                                         ImGuiTreeNodeFlags_SpanFullWidth )
      ENDIF

      IF lOpen
         FOR EACH uValue IN s_aAliases

            lOpen := ImGui::TreeNodeExStr( ICON_FA_DATABASE + " " + uValue[ 2 ], ImGuiTreeNodeFlags_SpanFullWidth )

            // ImGui::TreeNodeExStr( ICON_FA_DATABASE + " " + uValue[ 2 ], ImGuiTreeNodeFlags_Leaf + ;
            //                                         ImGuiTreeNodeFlags_Bullet + ;
            //                                         ImGuiTreeNodeFlags_NoTreePushOnOpen + ;
            //                                         ImGuiTreeNodeFlags_SpanFullWidth )
            IF ImGui::IsItemHovered() .AND. ImGui::IsMouseDoubleClicked( 0 )
               s_nActive := uValue[ 1 ]
               ImGui::SetWindowFocusStr( uValue[ 2 ] )
            ENDIF

            IF lOpen
               DBSelectArea( uValue[ 1 ] )
               aStruct := DBStruct()
               IF !Empty( aStruct )
                  IF ImGui::TreeNodeExStr("Struct", ImGuiTreeNodeFlags_SpanFullWidth )
                     FOR EACH a IN aStruct
                         cTmp := a[ 1 ] + " (" + a[ 2 ] + ")"

                         IF a[ 2 ] == "N" .AND. Len( a ) >= 4
                            cTmp += " [" + hb_NtoS( a[ 3 ] ) + "," + hb_NtoS( a[ 4 ] ) + "]"
                         ELSEIF ! Empty( a[ 3 ] )
                            cTmp += " [" + hb_NtoS( a[ 3 ] ) + "]"
                         ENDIF

                         ImGui::TreeNodeExStr( ICON_FA_TABLE_COLUMNS + " " + cTmp, ImGuiTreeNodeFlags_Leaf + ;
                                                                                   /* ImGuiTreeNodeFlags_Bullet + */ ;
                                                                                   ImGuiTreeNodeFlags_NoTreePushOnOpen + ;
                                                                                   ImGuiTreeNodeFlags_SpanFullWidth )
                        // ImGui::TreePop() // Close the field node - not needed when tree node is not opened
                     NEXT
                     ImGui::TreePop() /* Close the Struct node */
                  ENDIF
               ENDIF  
               ImGui::TreePop() /* Close the Workarea node */
            ENDIF

         NEXT
         ImGui::TreePop()
      ENDIF

      ImGui::TableNextRow()
      ImGui::TableNextColumn()

      lOpen := .F.

      IF Len( uValue := hb_vfDirectory("mem:") ) > 0
         lOpen := ImGui::TreeNodeExStr( "Memory FS", ImGuiTreeNodeFlags_SpanFullWidth )
      ELSE
         ImGui::TreeNodeExStr( "Memory FS (empty)", ImGuiTreeNodeFlags_Leaf + ;
                                            ImGuiTreeNodeFlags_Bullet + ;
                                            ImGuiTreeNodeFlags_NoTreePushOnOpen + ;
                                            ImGuiTreeNodeFlags_SpanFullWidth )
      ENDIF

      IF lOpen
         FOR EACH a IN uValue
            cTmp := a[ 1 ]
            ImGui::TreeNodeExStr( ICON_FA_FILE + " " + cTmp, ImGuiTreeNodeFlags_Leaf + ;
                                                                    /* ImGuiTreeNodeFlags_Bullet + */ ;
                                                                    ImGuiTreeNodeFlags_NoTreePushOnOpen + ;
                                                                    ImGuiTreeNodeFlags_SpanFullWidth )
            IF ImGui::IsItemHovered() .AND. ImGui::IsMouseDoubleClicked( 0 )
               IF OpenFromDisk( "mem:" + cTmp, .T., .T. )
                  ReloadAliases()
               ENDIF
            ENDIF  
         NEXT
         ImGui::TreePop()
      ENDIF

      ImGui::TableNextRow()
      ImGui::TableNextColumn()

      IF Len( RDDList() ) > 0
         lOpen := ImGui::TreeNodeExStr( "Drivers", ImGuiTreeNodeFlags_SpanFullWidth )
      ELSE
         ImGui::TreeNodeExStr( "Drivers", ImGuiTreeNodeFlags_Leaf + ;
                                          ImGuiTreeNodeFlags_Bullet + ;
                                          ImGuiTreeNodeFlags_NoTreePushOnOpen + ;
                                          ImGuiTreeNodeFlags_SpanFullWidth )
      ENDIF

      IF lOpen
         FOR EACH cTmp IN RddList()
            IF ImGui::TreeNodeExStr( ICON_FA_CUBE + " " + cTmp, ImGuiTreeNodeFlags_SpanFullWidth )
               IF ImGui::BeginTable( "TDrivers" + cTmp, 1 )

                  ImGui::TableSetupColumn( "Properties" )
                  // ImGui::TableSetupColumn( "Value" )

                  FOR EACH nKey IN RDDInfoKeys()
                     cPropName := RDDInfoName( nKey )[ 1 ]
                     uValue := RDDInfo( nKey,, cTmp )

                     ImGui::TableNextRow( ImGuiTableRowFlags_None )
                     ImGui::TableNextColumn()
                     ImGui::Text( cPropName )

                     ImGui::TableNextRow( ImGuiTableRowFlags_None )                       
                     ImGui::TableNextColumn()
                     IF ValType( uValue ) == "C"
                        ImGui::InputText( "##" + cTmp + hb_NtoS( nKey ), @uValue, 255 )
                     ELSEIF ValType( uValue ) == "N"
                        ImGui::InputInt( "##" + cTmp + hb_NtoS( nKey ), @uValue )
                     ELSEIF ValType( uValue ) == "L"
                        ImGui::Checkbox( "##" + cTmp + hb_NtoS( nKey ), @uValue )
                     ENDIF
                     IF ImGui::IsItemHovered()
                        ImGui::SetTooltip( "RDDInfo( " + RDDInfoName( nKey )[ 2 ] + " /* " + hb_NtoS( nKey ) + " */ )" )
                     ENDIF
                  NEXT

                  ImGui::EndTable()
               ENDIF
               ImGui::TreePop()
            ENDIF
         NEXT
         ImGui::TreePop()
      ENDIF

      // The first column will use the default _WidthStretch when ScrollX is Off and _WidthFixed when ScrollX is On
      //igTableSetupColumn( "Name", ImGuiTableColumnFlags_NoHide )
      //igTableSetupColumn( "Size", ImGuiTableColumnFlags_WidthFixed, nTextBWidth * 12.0 )
      //igTableSetupColumn( "Type", ImGuiTableColumnFlags_WidthFixed, nTextBWidth * 18.0 )
      //igTableHeadersRow()

      ImGui::EndTable()

   ENDIF
   ImGui::End()

   RETURN

STATIC PROCEDURE __Areas() 
   LOCAL aWA, lOpen := .T.
   FOR EACH aWA in s_aAliases
      ImGui::SetNextWindowSize( {600, 350}, ImGuiCond_Once )
      IF ImGui::Begin( aWA[ _WA_ALIAS ], @lOpen )
         DBSelectArea( aWA[ _WA_ID ] )
         IF ImGui::IsWindowFocused( ImGuiFocusedFlags_ChildWindows )
            s_nActive := aWA[ _WA_ID ]
         ENDIF
         IF ! lOpen
            DBCloseArea()
            ReloadAliases()
         ELSE
            Browser( .T., @aWA[ _WA_SCROLLTO ] )
         ENDIF
      ENDIF
      ImGui::End()
   NEXT

STATIC PROCEDURE Browser( lFit, nGoTo )
   STATIC nTableFlags := ImGuiTableFlags_BordersV + ImGuiTableFlags_BordersOuterH + ;
                         ImGuiTableFlags_Resizable + ImGuiTableFlags_RowBg + ;
                         ImGuiTableFlags_NoBordersInBody + ImGuiTableFlags_ScrollX + ;
                         ImGuiTableFlags_ScrollY + ImGuiTableFlags_SizingFixedFit + ;
                         ImGuiTableFlags_Reorderable

   STATIC nTextBHeight := NIL

   STATIC a, aColor

   LOCAL pClip, i, nF, x, nOldRec := RecNo()

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

   IF ImGui::BeginTable( "wa##" + Alias(), FCount() + 1 /* recno() pseudocolumn */, ;
                         nTableFlags, a /* widget size */ )

      pClip := ImGuiListClipper_ImGuiListClipper()

      ImGui::TableSetupColumn( "RECNO()" )

      FOR i := 1 TO FCount()
         ImGui::TableSetupColumn( FieldName( i ) )
      NEXT

      ImGui::TableSetupScrollFreeze( 3, 1 /* "regular" header row needs a freeze! */ )
      ImGui::TableHeadersRow()

      ImGuiListClipper( pClip ):Begin( RecCount() )

      IF nGoTo > 0
         ImGuiListClipper( pClip ):IncludeItemsByIndex( nGoTo - 1, nGoTo )
      ENDIF

      DO WHILE ImGuiListClipper( pClip ):Step()

         FOR i := ImGuiListClipper( pClip ):DisplayStart + 1 ;
               TO ImGuiListClipper( pClip ):DisplayEnd

            DBGoTo( i )

            IF EoF()
               EXIT
            ENDIF

            IF i == nOldRec
               aColor := hb_igGetStyleColorVec4( @aColor, ImGuiCol_PlotHistogram )
               ImGui::PushStyleColorVec4( ImGuiCol_Text, aColor )
               lPop := .T.
            ELSE
               lPop := .F.
            ENDIF

            ImGui::TableNextRow( ImGuiTableRowFlags_None /*, row_min_height */ )

            ImGui::TableNextColumn()

//            ImGui::Text( Str( RecNo() ) )
            IF ImGui::SelectableBool( Str( RecNo() ) + "##sel" + Alias(), .F., ImGuiSelectableFlags_SpanAllColumns )
               nOldRec := RecNo()
            ENDIF

            IF nGoTo == i
               nGoTo := 0
               ImGui::SetScrollHereY( 0.5 )
            ENDIF

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
//                     ImGui::CheckBox( "##" + FieldName( nF ), x )
                     IF x
                        ImGui::Text( ICON_FA_CHECK )
                     ENDIF
                     EXIT
                  CASE "C"
                     ImGui::Text( RTrim( x ) )
                     EXIT
               ENDSWITCH
            NEXT

            IF lPop
               ImGui::PopStyleColor()
            ENDIF

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

      ImGui::EndTable()

   ENDIF

   DBGoTo( nOldRec )

   RETURN

#include "dbinfo.ch"

FUNCTION ReloadAliases()
   LOCAL i := 0
   hb_WAEval( { |a| a := { Select(), Alias(), RDDName(), DBInfo( DBI_FULLPATH ), ReloadIndexes(), .F. /* show/hide */, 0 /* goto */ }, ;
                           IIF( Len( s_aAliases ) >= ++i, s_aAliases[ i ] := a, AAdd( s_aAliases, a ) ) } )
   ASize( s_aAliases, i )
   s_nActive := 0
   RETURN s_aAliases

FUNCTION SelectActiveInUI()
   IF s_nActive > 0
      IF s_nActive > Len( s_aAliases )
         s_nActive := Len( s_aAliases )
      ENDIF
      DBSelectArea( s_aAliases[ s_nActive ][ _WA_ID ] )
      RETURN .T.
   ENDIF
   RETURN .F.

FUNCTION ReloadIndexes()
   RETURN {}

PROCEDURE ToolBox()
   STATIC s_cGoTo := "        "
   STATIC s_aToolOpCodes := { ICON_FA_BACKWARD_STEP, ICON_FA_BACKWARD, ICON_FA_CARET_LEFT, ;
                              ICON_FA_CARET_RIGHT, ICON_FA_FORWARD, ICON_FA_FORWARD_STEP, ;
                              ICON_FA_PLUS, ICON_FA_MINUS, ICON_FA_CHECK, ;
                              ICON_FA_RECYCLE } /* use UCodes of the icons as opcode, because why not */
   LOCAL nOpRepeat

   IF ImGui::Begin("Toolbox")
      AEval( s_aToolOpCodes, { |x, n| IIF( n > 1, ImGui::SameLine(), NIL ), ;
                                      IIF( ImGui::SmallButton( x ) .AND. s_nActive > 0, ;
                                           ToolOp( x, @s_aAliases[ s_nActive ][ _WA_SCROLLTO ] ), ;
                                           IIF( ImGui::IsItemActive(), nOpRepeat := x , NIL ) ) } )
      IF ImGui::InputText( "##goto", @s_cGoTo,, ImGuiInputTextFlags_CharsDecimal + ;
                                                ImGuiInputTextFlags_CharsNoBlank + ;
                                                ImGuiInputTextFlags_EnterReturnsTrue )
         UIGoto( Val( s_cGoTo ) )
      ENDIF
      ImGui::SameLine()
      IF ImGui::Button("Goto")
         UIGoto( Val( s_cGoTo ) )
      ENDIF
      IF nOpRepeat <> NIL .AND. s_nActive > 0
         IF nOpRepeat == ICON_FA_CARET_LEFT .OR. ;
            nOpRepeat == ICON_FA_CARET_RIGHT /* make skipping repeatable while Shift is being held */
            IF ImGuiIO( igGetIO() ):KeyShift
               ToolOp( nOpRepeat, @s_aAliases[ s_nActive ][ _WA_SCROLLTO ] )
            ENDIF
         ENDIF
      ENDIF
//      ImGui::Text( HB_NtoS( s_nGoTo ) )
   ENDIF
   ImGui::End()
   RETURN

PROCEDURE ToolOp( nCode, nGoTo )
   IF ! SelectActiveInUI()
      RETURN
   ENDIF
   SWITCH nCode
      CASE ICON_FA_BACKWARD_STEP
         IF RecCount() >= 1
            nGoTo := 1
            DBGoto( nGoTo )
         ENDIF
         EXIT
      CASE ICON_FA_CARET_LEFT
         nGoTo := RecNo() - 1
         DBGoto( nGoTo )
         EXIT
      CASE ICON_FA_CARET_RIGHT
         nGoTo := RecNo() + 1
         DBGoto( nGoTo )
         EXIT
      CASE ICON_FA_PLUS
         DBAppend()
      CASE ICON_FA_FORWARD_STEP
         nGoTo := RecCount()
         DBGoto( nGoTo )
         EXIT
      CASE ICON_FA_MINUS
         DBDelete()
         EXIT
      CASE ICON_FA_BACKWARD
         nGoTo := -1
         EXIT
      CASE ICON_FA_FORWARD
         nGoTo := -2
         EXIT
      CASE ICON_FA_CHECK
         /* commit */
      CASE ICON_FA_RECYCLE
         /* rollback */
   END SWITCH
   RETURN

STATIC PROCEDURE UIGoto( nGoto )
   IF SelectActiveInUI()
      DBGoto( s_aAliases[ s_nActive ][ _WA_SCROLLTO ] := nGoto )
   ENDIF
   RETURN

FUNCTION OnShiftRetStruct()
   IF ImGuiIO( igGetIO() ):KeyShift .AND. SelectActiveInUI()
      RETURN DBStruct()
   ENDIF
   RETURN NIL

FUNCTION UIDBCreate( cFile, aStruct, cAlias )
   RETURN DBCreate( cFile, aStruct, s_cRDD, .T., cAlias,, IIF( hb_cdpExists( s_cCodePage ), s_cCodePage, "EN" ) )
