#include "src/Hexe/Terminal/TerminalEmulator.h"
#include "src/Hexe/Terminal/ImGuiTerminal.h"
#include "cmath"

extern "C" {

void tframe(void) 
{
   static std::shared_ptr<Hexe::Terminal::ImGuiTerminal> terminal = nullptr;
   bool showTerminalWindow = true;
   auto fontDefault = ImGui::GetFont();
   ImGuiIO& io = ImGui::GetIO();

   if( ! fontDefault )
      return;

   ImGui::SetNextWindowSize((ImVec2){400, 200}, ImGuiCond_Once);

   if (ImGui::Begin("Terminal", &showTerminalWindow,
                   io.KeyShift ? ImGuiWindowFlags_NoMove : 0 ))
   {
      auto scale = ImGui::GetFontSize() / fontDefault->FontSize;
      auto contentRegion = ImGui::GetContentRegionAvail();
      auto contentPos = ImGui::GetCursorScreenPos();

      if( ! terminal || terminal->HasTerminated() )
      {
         auto spacingChar = fontDefault->FindGlyph('A');
         auto charWidth = spacingChar->AdvanceX * scale;
         auto charHeight = fontDefault->FontSize * scale;

         auto columns =
            (int)std::floor(std::max(1.0f, contentRegion.x / charWidth));
         auto rows =
            (int)std::floor(std::max(1.0f, contentRegion.y / charHeight));

         terminal = Hexe::Terminal::ImGuiTerminal::Create( columns, rows );
      }
      if( ! terminal )
      { } // exitRequested = true;
      else
      {
         terminal->Draw(ImVec4(contentPos.x, contentPos.y,
                               contentPos.x + contentRegion.x,
                               contentPos.y + contentRegion.y),
                        scale);
      }

   }
   ImGui::End();

   if(terminal)
      terminal->Update();

  ImGui::SetNextWindowPos(ImVec2(10,550), ImGuiCond_Once, ImVec2(0,0));
  if (ImGui::Begin("Terminal tester"))
  {
     if (ImGui::Button("Feed terminal"))
     {
        terminal->Feed("qwertyuiop\r\n",12);
        terminal->Feed("abc\r\n",5);
     }
  }
  ImGui::End();

}

} // extern "C"

