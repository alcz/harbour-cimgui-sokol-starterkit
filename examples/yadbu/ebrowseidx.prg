/*
    ebrowseidx.prg    -- yet another database utility, indexed table editor

    license is MIT, see ../LICENSE
*/

#xtranslate EBrowser( => EBrowserIdx(
#xtranslate ToggleEBrowserEnter( => ToggleEBrowserIdxEnter(
#xtranslate DBGoTo( => OrdKeyGoTo(
#xtranslate RecNo( => OrdKeyNo(
#define RECCOUNT_TRANSLATION OrdKeyCount(
#define FIRST_COLUMN_TITLE "  Order"
#define FIRST_COLUMN_EXPR Str( OrdKeyNo() )
#define NEED_SCROLL_AFTER_EDIT NeedScrollAfterEdit( @nOldRec, @nGoTo )
#include "ebrowse.prg"

FUNCTION NeedScrollAfterEdit( nOldRec, nGoTo )
   IF IndexOrd() > 0
      IF nOldRec /* OrdKeyNo() based */ != OrdKeyNo()
         nGoTo := nOldRec := OrdKeyNo()
         RETURN .T.
      ENDIF
   ENDIF
   RETURN .F.
