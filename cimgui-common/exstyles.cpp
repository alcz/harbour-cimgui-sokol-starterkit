/* this is kept as .cpp for easier importing of styles from other contributors */

#include "imgui.h"
#ifdef CIMGUI_FREETYPE
#include "misc/freetype/imgui_freetype.h"
#endif
// following define clashes with cpp definitions
// #define CIMGUI_DEFINE_ENUMS_AND_STRUCTS
#include "imgui_internal.h"
#include "cimgui.h"
#include "hbapi.h"
#include "hbapiitm.h"

// countersy of @r-lyeh on GitHub
CIMGUI_API void hb_igThemeCherry()
{
   // cherry colors, 3 intensities
   #define HI(v)   ImVec4(0.502f, 0.075f, 0.256f, v)
   #define MED(v)  ImVec4(0.455f, 0.198f, 0.301f, v)
   #define LOW(v)  ImVec4(0.232f, 0.201f, 0.271f, v)
   // backgrounds (@todo: complete with BG_MED, BG_LOW)
   #define BG(v)   ImVec4(0.200f, 0.220f, 0.270f, v)
   // text
   #define TEXT(v) ImVec4(0.860f, 0.930f, 0.890f, v)

   /* auto &style = ImGui::GetStyle();*/
   ImGuiStyle* style = &ImGui::GetStyle();

   style->Colors[ImGuiCol_Text]                  = TEXT(0.78f);
   style->Colors[ImGuiCol_TextDisabled]          = TEXT(0.28f);
   style->Colors[ImGuiCol_WindowBg]              = ImVec4(0.13f, 0.14f, 0.17f, 1.00f);
   style->Colors[ImGuiCol_ChildBg]               = BG( 0.58f);
   style->Colors[ImGuiCol_PopupBg]               = BG( 0.9f);
   style->Colors[ImGuiCol_Border]                = ImVec4(0.31f, 0.31f, 1.00f, 0.00f);
   style->Colors[ImGuiCol_BorderShadow]          = ImVec4(0.00f, 0.00f, 0.00f, 0.00f);
   style->Colors[ImGuiCol_FrameBg]               = BG( 1.00f);
   style->Colors[ImGuiCol_FrameBgHovered]        = MED( 0.78f);
   style->Colors[ImGuiCol_FrameBgActive]         = MED( 1.00f);
   style->Colors[ImGuiCol_TitleBg]               = LOW( 1.00f);
   style->Colors[ImGuiCol_TitleBgActive]         = HI( 1.00f);
   style->Colors[ImGuiCol_TitleBgCollapsed]      = BG( 0.75f);
   style->Colors[ImGuiCol_MenuBarBg]             = BG( 0.47f);
   style->Colors[ImGuiCol_ScrollbarBg]           = BG( 1.00f);
   style->Colors[ImGuiCol_ScrollbarGrab]         = ImVec4(0.09f, 0.15f, 0.16f, 1.00f);
   style->Colors[ImGuiCol_ScrollbarGrabHovered]  = MED( 0.78f);
   style->Colors[ImGuiCol_ScrollbarGrabActive]   = MED( 1.00f);
   style->Colors[ImGuiCol_CheckMark]             = ImVec4(0.71f, 0.22f, 0.27f, 1.00f);
   style->Colors[ImGuiCol_SliderGrab]            = ImVec4(0.47f, 0.77f, 0.83f, 0.14f);
   style->Colors[ImGuiCol_SliderGrabActive]      = ImVec4(0.71f, 0.22f, 0.27f, 1.00f);
   style->Colors[ImGuiCol_Button]                = ImVec4(0.47f, 0.77f, 0.83f, 0.14f);
   style->Colors[ImGuiCol_ButtonHovered]         = MED( 0.86f);
   style->Colors[ImGuiCol_ButtonActive]          = MED( 1.00f);
   style->Colors[ImGuiCol_Header]                = MED( 0.76f);
   style->Colors[ImGuiCol_HeaderHovered]         = MED( 0.86f);
   style->Colors[ImGuiCol_HeaderActive]          = HI( 1.00f);
//   style->Colors[ImGuiCol_Column]                = ImVec4(0.14f, 0.16f, 0.19f, 1.00f);
//   style->Colors[ImGuiCol_ColumnHovered]         = MED( 0.78f);
//   style->Colors[ImGuiCol_ColumnActive]          = MED( 1.00f);
   style->Colors[ImGuiCol_ResizeGrip]            = ImVec4(0.47f, 0.77f, 0.83f, 0.04f);
   style->Colors[ImGuiCol_ResizeGripHovered]     = MED( 0.78f);
   style->Colors[ImGuiCol_ResizeGripActive]      = MED( 1.00f);
   style->Colors[ImGuiCol_PlotLines]             = TEXT(0.63f);
   style->Colors[ImGuiCol_PlotLinesHovered]      = MED( 1.00f);
   style->Colors[ImGuiCol_PlotHistogram]         = TEXT(0.63f);
   style->Colors[ImGuiCol_PlotHistogramHovered]  = MED( 1.00f);
   style->Colors[ImGuiCol_TextSelectedBg]        = MED( 0.43f);

//    style->Colors[ImGuiCol_ModalWindowDarkening]  = BG( 0.73f);

   style->WindowPadding            = ImVec2(6, 4);
   style->WindowRounding           = 0.0f;
   style->FramePadding             = ImVec2(5, 2);
   style->FrameRounding            = 3.0f;
   style->ItemSpacing              = ImVec2(7, 1);
   style->ItemInnerSpacing         = ImVec2(1, 1);
   style->TouchExtraPadding        = ImVec2(0, 0);
   style->IndentSpacing            = 6.0f;
   style->ScrollbarSize            = 12.0f;
   style->ScrollbarRounding        = 16.0f;
   style->GrabMinSize              = 20.0f;
   style->GrabRounding             = 2.0f;

   style->WindowTitleAlign.x = 0.50f;

   style->Colors[ImGuiCol_Border] = ImVec4(0.539f, 0.479f, 0.255f, 0.162f);
   style->FrameBorderSize = 0.0f;
   style->WindowBorderSize = 1.0f;
}

// countersy of @usernameiwantedwasalreadytaken on GitHub
CIMGUI_API void hb_igThemeWin10()
{

/* 
   suggested font

   ImGuiIO& io = ImGui::GetIO();
   io.Fonts->Clear();
   ImFont* font = io.Fonts->AddFontFromFileTTF("C:\\Windows\\Fonts\\segoeui.ttf", 18.0f);
   if (font != NULL) {
   	io.FontDefault = font;
   } else {
   	io.Fonts->AddFontDefault();
   }
   io.Fonts->Build();
*/

   ImGuiStyle* style = &ImGui::GetStyle();
   int hspacing = 8;
   int vspacing = 6;
   style->DisplaySafeAreaPadding = ImVec2(0, 0);
   style->WindowPadding = ImVec2(hspacing/2, vspacing);
   style->FramePadding = ImVec2(hspacing, vspacing);
   style->ItemSpacing = ImVec2(hspacing, vspacing);
   style->ItemInnerSpacing = ImVec2(hspacing, vspacing);
   style->IndentSpacing = 20.0f;

   style->WindowRounding = 0.0f;
   style->FrameRounding = 0.0f;

   style->WindowBorderSize = 0.0f;
   style->FrameBorderSize = 1.0f;
   style->PopupBorderSize = 1.0f;

   style->ScrollbarSize = 20.0f;
   style->ScrollbarRounding = 0.0f;
   style->GrabMinSize = 5.0f;
   style->GrabRounding = 0.0f;

   ImVec4 white = ImVec4(1.00f, 1.00f, 1.00f, 1.00f);
   ImVec4 transparent = ImVec4(0.00f, 0.00f, 0.00f, 0.00f);
   ImVec4 dark = ImVec4(0.00f, 0.00f, 0.00f, 0.20f);
   ImVec4 darker = ImVec4(0.00f, 0.00f, 0.00f, 0.50f);

   ImVec4 background = ImVec4(0.95f, 0.95f, 0.95f, 1.00f);
   ImVec4 text = ImVec4(0.10f, 0.10f, 0.10f, 1.00f);
   ImVec4 border = ImVec4(0.60f, 0.60f, 0.60f, 1.00f);
   ImVec4 grab = ImVec4(0.69f, 0.69f, 0.69f, 1.00f);
   ImVec4 header = ImVec4(0.86f, 0.86f, 0.86f, 1.00f);
   ImVec4 active = ImVec4(0.00f, 0.47f, 0.84f, 1.00f);
   ImVec4 hover = ImVec4(0.00f, 0.47f, 0.84f, 0.20f);

   style->Colors[ImGuiCol_Text] = text;
   style->Colors[ImGuiCol_WindowBg] = background;
   style->Colors[ImGuiCol_ChildBg] = background;
   style->Colors[ImGuiCol_PopupBg] = white;

   style->Colors[ImGuiCol_Border] = border;
   style->Colors[ImGuiCol_BorderShadow] = transparent;

   style->Colors[ImGuiCol_Button] = header;
   style->Colors[ImGuiCol_ButtonHovered] = hover;
   style->Colors[ImGuiCol_ButtonActive] = active;

   style->Colors[ImGuiCol_FrameBg] = white;
   style->Colors[ImGuiCol_FrameBgHovered] = hover;
   style->Colors[ImGuiCol_FrameBgActive] = active;

   style->Colors[ImGuiCol_MenuBarBg] = header;
   style->Colors[ImGuiCol_Header] = header;
   style->Colors[ImGuiCol_HeaderHovered] = hover;
   style->Colors[ImGuiCol_HeaderActive] = active;

   style->Colors[ImGuiCol_CheckMark] = text;
   style->Colors[ImGuiCol_SliderGrab] = grab;
   style->Colors[ImGuiCol_SliderGrabActive] = darker;

   //style->Colors[ImGuiCol_CloseButton] = transparent;
   //style->Colors[ImGuiCol_CloseButtonHovered] = transparent;
   //style->Colors[ImGuiCol_CloseButtonActive] = transparent;

   style->Colors[ImGuiCol_ScrollbarBg] = header;
   style->Colors[ImGuiCol_ScrollbarGrab] = grab;
   style->Colors[ImGuiCol_ScrollbarGrabHovered] = dark;
   style->Colors[ImGuiCol_ScrollbarGrabActive] = darker;

}

// countersy of @mnurzia on GitHub
CIMGUI_API void hb_igThemeVSC()
{

   ImGuiStyle& style = ImGui::GetStyle();

   style.TabRounding = 0.0f;
   style.FrameBorderSize = 1.0f;
   style.ScrollbarRounding = 0.0f;
   style.ScrollbarSize = 10.0f;

   ImVec4* colors = ImGui::GetStyle().Colors;

   colors[ImGuiCol_Text] = ImVec4(0.95f, 0.95f, 0.95f, 1.00f);
   colors[ImGuiCol_TextDisabled] = ImVec4(0.50f, 0.50f, 0.50f, 1.00f);
   colors[ImGuiCol_WindowBg] = ImVec4(0.12f, 0.12f, 0.12f, 1.00f);
   colors[ImGuiCol_ChildBg] = ImVec4(0.04f, 0.04f, 0.04f, 0.50f);
   colors[ImGuiCol_PopupBg] = ImVec4(0.12f, 0.12f, 0.12f, 0.94f);
   colors[ImGuiCol_Border] = ImVec4(0.25f, 0.25f, 0.27f, 0.50f);
   colors[ImGuiCol_BorderShadow] = ImVec4(0.00f, 0.00f, 0.00f, 0.00f);
   colors[ImGuiCol_FrameBg] = ImVec4(0.20f, 0.20f, 0.22f, 0.50f);
   colors[ImGuiCol_FrameBgHovered] = ImVec4(0.25f, 0.25f, 0.27f, 0.75f);
   colors[ImGuiCol_FrameBgActive] = ImVec4(0.30f, 0.30f, 0.33f, 1.00f);
   colors[ImGuiCol_TitleBg] = ImVec4(0.04f, 0.04f, 0.04f, 1.00f);
   colors[ImGuiCol_TitleBgActive] = ImVec4(0.04f, 0.04f, 0.04f, 1.00f);
   colors[ImGuiCol_TitleBgCollapsed] = ImVec4(0.04f, 0.04f, 0.04f, 0.75f);
   colors[ImGuiCol_MenuBarBg] = ImVec4(0.18f, 0.18f, 0.19f, 1.00f);
   colors[ImGuiCol_ScrollbarBg] = ImVec4(0.24f, 0.24f, 0.26f, 0.75f);
   colors[ImGuiCol_ScrollbarGrab] = ImVec4(0.41f, 0.41f, 0.41f, 0.75f);
   colors[ImGuiCol_ScrollbarGrabHovered] = ImVec4(0.62f, 0.62f, 0.62f, 0.75f);
   colors[ImGuiCol_ScrollbarGrabActive] = ImVec4(0.94f, 0.92f, 0.94f, 0.75f);
   colors[ImGuiCol_CheckMark] = ImVec4(0.60f, 0.60f, 0.60f, 1.00f);
   colors[ImGuiCol_SliderGrab] = ImVec4(0.41f, 0.41f, 0.41f, 0.75f);
   colors[ImGuiCol_SliderGrabActive] = ImVec4(0.62f, 0.62f, 0.62f, 0.75f);
   colors[ImGuiCol_Button] = ImVec4(0.20f, 0.20f, 0.22f, 1.00f);
   colors[ImGuiCol_ButtonHovered] = ImVec4(0.25f, 0.25f, 0.27f, 1.00f);
   colors[ImGuiCol_ButtonActive] = ImVec4(0.41f, 0.41f, 0.41f, 1.00f);
   colors[ImGuiCol_Header] = ImVec4(0.18f, 0.18f, 0.19f, 1.00f);
   colors[ImGuiCol_HeaderHovered] = ImVec4(0.25f, 0.25f, 0.27f, 1.00f);
   colors[ImGuiCol_HeaderActive] = ImVec4(0.41f, 0.41f, 0.41f, 1.00f);
   colors[ImGuiCol_Separator] = ImVec4(0.25f, 0.25f, 0.27f, 1.00f);
   colors[ImGuiCol_SeparatorHovered] = ImVec4(0.41f, 0.41f, 0.41f, 1.00f);
   colors[ImGuiCol_SeparatorActive] = ImVec4(0.62f, 0.62f, 0.62f, 1.00f);
   colors[ImGuiCol_ResizeGrip] = ImVec4(0.30f, 0.30f, 0.33f, 0.75f);
   colors[ImGuiCol_ResizeGripHovered] = ImVec4(0.41f, 0.41f, 0.41f, 0.75f);
   colors[ImGuiCol_ResizeGripActive] = ImVec4(0.62f, 0.62f, 0.62f, 0.75f);
   colors[ImGuiCol_Tab] = ImVec4(0.21f, 0.21f, 0.22f, 1.00f);
   colors[ImGuiCol_TabHovered] = ImVec4(0.37f, 0.37f, 0.39f, 1.00f);
   colors[ImGuiCol_TabActive] = ImVec4(0.30f, 0.30f, 0.33f, 1.00f);
   colors[ImGuiCol_TabUnfocused] = ImVec4(0.12f, 0.12f, 0.12f, 0.97f);
   colors[ImGuiCol_TabUnfocusedActive] = ImVec4(0.18f, 0.18f, 0.19f, 1.00f);
#ifdef ImGuiCol_DockingPreview
   colors[ImGuiCol_DockingPreview] = ImVec4(0.26f, 0.59f, 0.98f, 0.50f);
#endif
#ifdef ImGuiCol_DockingEmptyBg
   colors[ImGuiCol_DockingEmptyBg] = ImVec4(0.20f, 0.20f, 0.20f, 1.00f);
#endif
   colors[ImGuiCol_PlotLines] = ImVec4(0.61f, 0.61f, 0.61f, 1.00f);
   colors[ImGuiCol_PlotLinesHovered] = ImVec4(1.00f, 0.43f, 0.35f, 1.00f);
   colors[ImGuiCol_PlotHistogram] = ImVec4(0.90f, 0.70f, 0.00f, 1.00f);
   colors[ImGuiCol_PlotHistogramHovered] = ImVec4(1.00f, 0.60f, 0.00f, 1.00f);
   colors[ImGuiCol_TextSelectedBg] = ImVec4(0.26f, 0.59f, 0.98f, 0.50f);
   colors[ImGuiCol_DragDropTarget] = ImVec4(1.00f, 1.00f, 0.00f, 0.90f);
   colors[ImGuiCol_NavHighlight] = ImVec4(0.26f, 0.59f, 0.98f, 1.00f);
   colors[ImGuiCol_NavWindowingHighlight] = ImVec4(1.00f, 1.00f, 1.00f, 0.70f);
   colors[ImGuiCol_NavWindowingDimBg] = ImVec4(0.80f, 0.80f, 0.80f, 0.20f);
   colors[ImGuiCol_ModalWindowDimBg] = ImVec4(0.80f, 0.80f, 0.80f, 0.35f);

   style.WindowMenuButtonPosition = ImGuiDir_Right;
}

HB_FUNC( HB_IGTHEMEWIN10 )
{
   hb_igThemeWin10();
   hb_ret();
}

HB_FUNC( HB_IGTHEMECHERRY )
{
   hb_igThemeCherry();
   hb_ret();
}

HB_FUNC( HB_IGTHEMEVSC )
{
   hb_igThemeVSC();
   hb_ret();
}

/* bool hb_igButtonRounded(const char* label,const ImVec2 size, float radius) */
HB_FUNC( HB_IGBUTTONROUNDED )
{
   const char* label = hb_parcx( 1 );
   PHB_ITEM psize = hb_param( 2, HB_IT_ARRAY );
   ImVec2 size;
   float rr = ( float ) hb_parnd( 3 );
   bool ret;
   if( psize )
      size = ImVec2{ ( float ) hb_arrayGetND( psize, 1 ), ( float ) hb_arrayGetND( psize, 2 ) };
   else
      size = ImVec2{ 0, 0 };
   if( rr < 0.01 )
      rr = 5;
   ImGui::PushStyleVar( ImGuiStyleVar_FrameRounding, rr );
   ret = ImGui::Button( label, size );
   ImGui::PopStyleVar( 1 );
   hb_retl( ret );
}
