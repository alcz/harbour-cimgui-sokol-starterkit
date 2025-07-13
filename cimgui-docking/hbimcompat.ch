/*
    hbimcompat.ch   -- some compatibility between ImGui 
                       versions for commoly used, but
                       evolving stuff

    license is MIT, see ../LICENSE

    Copyright (c) 2025 Aleksander Czajczynski
*/

/* this file should be included AFTER "hbimenum.ch", though this requrement may be waived in the future,
   and the contents will auto-generated */

/* off by one/array indexing confilct, in addition keymap functionality is evolving, in ImGui 1.87+ it will move on */
#xtranslate ImGuiCompat::IsKeyPressed( <n> ) => igIsKeyPressed( ImGuiIO( igGetIO() ):KeyMap\[ <n> + 1 /* offset BUG */ \] )
#xtranslate ImGuiCompat::IsKeyDown( <n> ) => igIsKeyDown( ImGuiIO( igGetIO() ):KeyMap\[ <n> + 1 /* offset BUG */ \] )

#ifndef ImGuiHoveredFlags_DelayNormal
#define ImGuiHoveredFlags_DelayNormal 0
#xtranslate ImGui::Shortcut( <v>, <r> ) => .F.
#endif

#ifndef ImGuiDockNodeFlags_NoDockingOverCentralNode
#define ImGuiDockNodeFlags_NoDockingOverCentralNode ImGuiDockNodeFlags_NoDockingInCentralNode
#endif