/*
    cimgui/hbimca.ch   -- caching displayed expressions
                          in case they are too expensive
                          to run repeatedly at 60 fps

    license is MIT, see ../LICENSE

    Copyright (c) 2023 Aleksander Czajczynski
*/

#ifndef IG_LINECACHE_VAR
 #define IG_LINECACHE_VAR aImLineCache
#endif

#define LC_COUNTER() hb_igLineCounterSet( __LINE__ )
#xtranslate hb_igLineCounterSet( <x> ) => #undef __LLINE__ ; #define __LLINE__ <x>
#xtranslate LC_( <exp> ) =>  IIF( hb_igLineCacheGet( IG_LINECACHE_VAR, __LINE__ - __LLINE__ ) == NIL, hb_igLineCache( IG_LINECACHE_VAR, __LINE__ - __LLINE__, 0, <exp> ), IG_LINECACHE_VAR\[ __LINE__ - __LLINE__ \] )
#xtranslate LC_( <n>, <exp> ) =>  IIF( hb_igLineCacheGet( IG_LINECACHE_VAR, __LINE__ - __LLINE__ ) == NIL .OR. hb_igLineCacheGet( IG_LINECACHE_VAR\[ __LINE__ - __LLINE__ \], <n> ) == NIL, hb_igLineCache( IG_LINECACHE_VAR, __LINE__ - __LLINE__, <n>, <exp> ), IG_LINECACHE_VAR\[ __LINE__ - __LLINE__ \]\[ <n> \] )

#ifdef IG_LINECACHE_IMPL
 #include "hbimca.prg"
#endif

/* 
  declare THREAD STATIC aImLineCache or similar kind of persistent 
  parameter passed by reference
 
  variable can be renamed:
  #define IG_LINECACHE_VAR aCache

  basic usage:
  LC_COUNTER() - placed in function body, before first occurence of LC_() macro

  test using:
  igTextUnformatted( LC_( Time() ) )
*/
