/* by Copilot + manual patches - trivial generator in case entries in infos.prg needs updating */

FUNCTION GenerateCodeFromHeader()

   LOCAL cFileName := "include/dbinfo.ch"
   LOCAL cContents, cLine, cCode := "", aFields := {}
   LOCAL aTokens, cKey, cValue, cComment, aFilteredTokens := {}
   LOCAL nCommentStart, nCommentEnd, nMaxId := 10

   // Read the entire file contents
   cContents := hb_MemoRead( cFileName )

   IF Empty( cContents )
      ? "Error: Could not read " + cFileName
      RETURN NIL
   ENDIF

   // Process each line separately
   FOR EACH cLine IN hb_ATokens( cContents, Chr( 10 ) )  // Split by LF (Unix-friendly)
      cLine := AllTrim( StrTran( cLine, Chr( 13 ), "" ) )  // Trim potential CR for platform independence

      // Check if the line contains a macro definition
      IF Left( cLine, 7 ) == "#define"
         cLine := SubStr( cLine, 8 )  // Remove "#define"

         // Extract comment if present (look for /* ... */)
         nCommentStart := At( "/*", cLine )
         nCommentEnd := At( "*/", cLine )

         IF nCommentStart > 0 .AND. nCommentEnd > nCommentStart
            cComment := AllTrim( SubStr( cLine, nCommentStart + 2, nCommentEnd - nCommentStart - 2 ) )  // Extract text between /* ... */
            cLine := Left( cLine, nCommentStart - 1 )  // Remove comment part from main definition
         ELSE
            cComment := "No description available"  // Default if no comment exists
         ENDIF

         aTokens := hb_ATokens( cLine, " " )  // Split by spaces

         // Use AEval() to filter out empty tokens
         AEval( aTokens, {| x | iif( !Empty( x ), AAdd( aFilteredTokens, x ), NIL ) } )

         // Ensure we have at least two valid tokens (macro name + value)
         IF Len( aFilteredTokens ) >= 2
            cKey := aFilteredTokens[ 1 ]
            cValue := cComment  // Assign extracted comment as description

            // Validate extracted values before adding to the hash
            IF !Empty( cKey ) .AND. !Empty( cValue )
               AAdd( aFields, { cKey, cValue } )
            ENDIF
         ENDIF

         // Reset filtered tokens for next iteration
         aFilteredTokens := {}
      ENDIF
   NEXT

   // Check out the longest id
   FOR EACH cKey IN aFields
      nMaxId := Max( nMaxId, Len( cKey[ 1 ] ) + Len( "hFields" ) + 4 )
   NEXT

   // Generate dynamic code
   FOR EACH cKey IN aFields
      cCode += PadR("hFields[ " + cKey[ 1 ] + " ] ", nMaxId ) + " := { '" + cKey[ 2 ] + "', '" + cKey[ 1 ] + "' }" + hb_EoL()
   NEXT

   RETURN cCode
