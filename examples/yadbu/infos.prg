/*
    info.prg    -- yet another database utility
                   DBInfo() dictionary

    license is MIT, see ../../LICENSE
*/

#include "dbinfo.ch"

STATIC hFields := { => }

FUNCTION InitInfos()
   hFields[ RDDI_ISDBF ]          := { "Supports DBF?", "RDDI_ISDBF" }
   hFields[ RDDI_CANPUTREC ]      := { "Can Put Records?", "RDDI_CANPUTREC" }
   hFields[ RDDI_DELIMITER ]      := { "Field Delimiter", "RDDI_DELIMITER" }
   hFields[ RDDI_SEPARATOR ]      := { "Record Separator", "RDDI_SEPARATOR" }
   hFields[ RDDI_TABLEEXT ]       := { "Data File Extension", "RDDI_TABLEEXT" }
   hFields[ RDDI_MEMOEXT ]        := { "Memo File Extension", "RDDI_MEMOEXT" }
   hFields[ RDDI_ORDBAGEXT ]      := { "Multi Tag Index File Extension", "RDDI_ORDBAGEXT" }
   hFields[ RDDI_ORDEREXT ]       := { "Single Tag Index File Extension", "RDDI_ORDEREXT" }
   hFields[ RDDI_ORDSTRUCTEXT ]   := { "Struct Index File Extension", "RDDI_ORDSTRUCTEXT" }
   hFields[ RDDI_LOCAL ]          := { "Local File Access?", "RDDI_LOCAL" }
   hFields[ RDDI_REMOTE ]         := { "Remote Table Access?", "RDDI_REMOTE" }
   hFields[ RDDI_CONNECTION ]     := { "Default Connection", "RDDI_CONNECTION" }
   hFields[ RDDI_TABLETYPE ]      := { "Table File Type", "RDDI_TABLETYPE" }
   hFields[ RDDI_MEMOTYPE ]       := { "Memo File Type", "RDDI_MEMOTYPE" }
   hFields[ RDDI_LARGEFILE ]      := { "Supports Large File?", "RDDI_LARGEFILE" }
   hFields[ RDDI_LOCKSCHEME ]     := { "Locking Scheme", "RDDI_LOCKSCHEME" }
   hFields[ RDDI_RECORDMAP ]      := { "Supports Record Map?", "RDDI_RECORDMAP" }
   hFields[ RDDI_ENCRYPTION ]     := { "Supports Encryption?", "RDDI_ENCRYPTION" }
   hFields[ RDDI_TRIGGER ]        := { "Default Trigger Function", "RDDI_TRIGGER" }
   hFields[ RDDI_AUTOLOCK ]       := { "Auto Locking on Update?", "RDDI_AUTOLOCK" }
   hFields[ RDDI_STRUCTORD ]      := { "Supports Structural Index?", "RDDI_STRUCTORD" }
   hFields[ RDDI_STRICTREAD ]     := { "Strict Read Mode?", "RDDI_STRICTREAD" }
   hFields[ RDDI_STRICTSTRUCT ]   := { "Strict Structural Order?", "RDDI_STRICTSTRUCT" }
   hFields[ RDDI_OPTIMIZE ]       := { "Query Optimization?", "RDDI_OPTIMIZE" }
   hFields[ RDDI_FORCEOPT ]       := { "Force Linear Optimization?", "RDDI_FORCEOPT" }
   hFields[ RDDI_AUTOOPEN ]       := { "Auto-Open Structural Indexes?", "RDDI_AUTOOPEN" }
   hFields[ RDDI_AUTOORDER ]      := { "Default Structural Index Order?", "RDDI_AUTOORDER" }
   hFields[ RDDI_AUTOSHARE ]      := { "Auto-Share Indexes on Network?", "RDDI_AUTOSHARE" }
   hFields[ RDDI_MULTITAG ]       := { "Supports Multi-Tag Indexes?", "RDDI_MULTITAG" }
   hFields[ RDDI_SORTRECNO ]      := { "Record Number in Sorting?", "RDDI_SORTRECNO" }
   hFields[ RDDI_MULTIKEY ]       := { "Custom Orders Allow Duplicate Keys?", "RDDI_MULTIKEY" }
   hFields[ RDDI_MEMOBLOCKSIZE ]  := { "Memo Block Size", "RDDI_MEMOBLOCKSIZE" }
   hFields[ RDDI_MEMOVERSION ]    := { "Memo Sub-Version", "RDDI_MEMOVERSION" }
   hFields[ RDDI_MEMOGCTYPE ]     := { "Memo Garbage Collector Type", "RDDI_MEMOGCTYPE" }
   hFields[ RDDI_MEMOREADLOCK ]   := { "Memo Read Lock?", "RDDI_MEMOREADLOCK" }
   hFields[ RDDI_MEMOREUSE ]      := { "Reuse Free Memo Space?", "RDDI_MEMOREUSE" }
   hFields[ RDDI_BLOB_SUPPORT ]   := { "Supports BLOB Files?", "RDDI_BLOB_SUPPORT" }
   hFields[ RDDI_PENDINGTRIGGER ] := { "Pending Trigger for Next Open?", "RDDI_PENDINGTRIGGER" }
   hFields[ RDDI_PENDINGPASSWORD ]:= { "Pending Password for Next Open?", "RDDI_PENDINGPASSWORD" }
   hFields[ RDDI_PASSWORD ]       := { "Default Password", "RDDI_PASSWORD" }
   hFields[ RDDI_LOCKRETRY ]      := { "Lock Timeout Value", "RDDI_LOCKRETRY" }
   hFields[ RDDI_DIRTYREAD ]      := { "Index Dirty Read Flag?", "RDDI_DIRTYREAD" }
   hFields[ RDDI_INDEXPAGESIZE ]  := { "Default Index Page Size", "RDDI_INDEXPAGESIZE" }
   hFields[ RDDI_DECIMALS ]       := { "Default Decimal Places", "RDDI_DECIMALS" }
   hFields[ RDDI_SETHEADER ]      := { "DBF Header Update Mode", "RDDI_SETHEADER" }
   RETURN

FUNCTION RDDInfoKeys()
   RETURN HB_HKeys( hFields )

FUNCTION RDDInfoName( nField )
   RETURN HB_HGetDef( hFields, nField, "Unknown property #" + hb_NtoS( nField ) )
