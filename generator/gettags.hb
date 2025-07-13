/* get git tags for repositories listed with not empty FILTERTAG, 
   otherwise commit hashes AFTERHASH will be used to distinct.
   TODO: projects that actually have releases */

PROCEDURE GetTags()
   LOCAL cRun, cErr, nRet

   USE catalog ALIAS "CATALOG" VIA "DBFNTX" EXCLUSIVE
   ZAP /* git checkout catalog.dbf - to revert if sth goes wrong */

   USE projects VIA "DBFNTX" SHARED NEW
   DO WHILE ! EoF()
      IF ! Empty( PROJECTS->FILTERTAG )
         nRet := hb_processRun( "git ls-remote --tags " + RTrim( PROJECTS->DEFURL ), , @cRun, @cErr )
      ENDIF
      /* TODO: git log/commits */
      IF nRet # 0
         OutErr( cErr )
      ELSE
         ParseTags( cRun )
      ENDIF
      DBSkip()
   ENDDO

   DBSelectArea("CATALOG")
   COPY TO catalog DELIMITED WITH ""

   DBSelectArea("PROJECTS")
   COPY TO projects DELIMITED WITH ""

   DBCloseAll()

   RETURN

PROCEDURE ParseTags( cRun )
   LOCAL c, aIn, cOp, cFilter := "", bFilter, n, nRev := 0

   aIn := hb_ATokens( PROJECTS->FILTERTAG, "," )

   cFilter += "{ |c| "
   FOR EACH c IN aIn
      cOp := NIL
      IF c:__enumIndex > 1
         cFilter += " .AND. "
      ENDIF
      c := AllTrim( c )
      IF Left( c, 1 ) == "!"
         cFilter += "! "
         c := LTrim( SubStr( c, 2 ) )
      ELSEIF Left( c, 1 ) $ "<>"
         cOp := Left( c, 1 )
         c := LTrim( SubStr( c, 2 ) )
      ENDIF
      IF ! cOp == NIL
         cFilter += " c " + cOp + " [" + c + "]"
      ELSE
         cFilter += " At([" + c + "], c ) > 0"
      ENDIF
   NEXT
   cFilter += "}"
// ? cFilter
   bFilter := &( cFilter )

   aIn := hb_ATokens( cRun, hb_eol() )
   FOR EACH c IN aIn
      c := SubStr( c, 41 )
      n := At( "refs/tags/", c )
      IF n > 0 .AND. Eval( bFilter, c := SubStr( c, Len( "refs/tags/" ) + 2 ) )
         nRev++
         CATALOG->( DBAppend() )
         CATALOG->PROJECT := PROJECTS->PROJECT
         CATALOG->BRANCH  := PROJECTS->BRANCH
         CATALOG->REV     := nRev
         CATALOG->TAG     := c
         CATALOG->DEFURL  := PROJECTS->DEFURL
      ENDIF
   NEXT

   RETURN
